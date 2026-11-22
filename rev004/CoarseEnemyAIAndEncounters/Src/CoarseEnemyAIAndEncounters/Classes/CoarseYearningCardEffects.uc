class CoarseYearningCardEffects extends Object dependson(CHHelpers);

static function Install(X2AbilityTemplateManager Manager)
{
	ReplaceCardEffect(Manager, 'ARFMPYP_LiddyBoxing', class'ARFM_Effect_UpgradeMeleeTier', class'X2Effect_CoarseBoxingBugs');
	ReplaceCardEffect(Manager, 'ARFMPYP_Pinpoint', class'ARFM_Effect_PYPPinpoint', class'X2Effect_CoarsePinpoint');
	ReplaceCardEffect(Manager, 'ARFMPYP_HighCaliber', class'ARFM_Effect_HighCaliber', class'X2Effect_CoarseHighCaliber');
	ReplaceCardEffect(Manager, 'ARFMPYP_Battleborn', class'ARFM_Effect_Battleborn', class'X2Effect_Persistent');
	ReplaceCardEffect(Manager, 'ARFMPYP_Dreadnaughts', class'ARFM_Effect_Battleborn', class'X2Effect_Persistent');
	ReplaceCardEffect(Manager, 'ARFMPYP_Battlehaunt', class'ARFM_Effect_BattlePriest', class'X2Effect_CoarseHolyWarrior');
	ReplaceCardEffect(Manager, 'HolyWarriorM1', class'ARFM_Effect_Battlehaunt', class'X2Effect_CoarseHolyWarrior');
	ReplaceCardEffect(Manager, 'HolyWarriorM2', class'ARFM_Effect_Battlehaunt', class'X2Effect_CoarseHolyWarrior');
	ReplaceCardEffect(Manager, 'HolyWarriorM3', class'ARFM_Effect_Battlehaunt', class'X2Effect_CoarseHolyWarrior');
	ReplaceCardEffect(Manager, 'ARFMPYP_DemocracyProtects', class'ARFM_Effect_DemocracyProtects', class'X2Effect_CoarseDemocracyProtects');
	ReplaceCardEffect(Manager, 'ARFMPYP_DemocracyLiberates', class'ARFM_Effect_DemocracyLiberates', class'X2Effect_CoarseDemocracyLiberates');
	ReplaceCardEffect(Manager, 'ARFMPYP_DemocracyUnifies', class'ARFM_Effect_DemocracyUnifies', class'X2Effect_CoarseDemocracyUnifies');
	ReplaceCardEffect(Manager, 'EnergyShield', class'ARFM_Effect_Beaglebusting', class'X2Effect_CoarseEnergyShield', true);
	ReplaceCardEffect(Manager, 'EnergyShieldMk3', class'ARFM_Effect_Beaglebusting', class'X2Effect_CoarseEnergyShield', true);
	class'CHHelpers'.static.GetCDO().AddAdjustArmorMitigationCallback(AdjustYearningArmor, 0);
}

static private function ReplaceCardEffect(X2AbilityTemplateManager Manager, name AbilityName, class<X2Effect_Persistent> OriginalClass, class<X2Effect_Persistent> ReplacementClass, optional bool MultiTarget)
{
	local array<X2AbilityTemplate> Variants;
	local X2AbilityTemplate Ability;
	local X2Effect_Persistent OldEffect, NewEffect;
	local array<X2Effect> Effects;
	local int Index;

	Manager.FindAbilityTemplateAllDifficulties(AbilityName, Variants);
	foreach Variants(Ability)
	{
		if (MultiTarget)
		{
			Effects = Ability.AbilityMultiTargetEffects;
		}
		else
		{
			Effects = Ability.AbilityTargetEffects;
		}
		for (Index = 0; Index < Effects.Length; ++Index)
		{
			OldEffect = X2Effect_Persistent(Effects[Index]);
			if (OldEffect == none || OldEffect.Class != OriginalClass)
			{
				continue;
			}
			NewEffect = new ReplacementClass;
			NewEffect.BuildPersistentEffect(OldEffect.iNumTurns, OldEffect.bInfiniteDuration, OldEffect.bRemoveWhenSourceDies, OldEffect.bIgnorePlayerCheckOnTick, OldEffect.WatchRule);
			NewEffect.SetDisplayInfo(OldEffect.BuffCategory, OldEffect.FriendlyName, OldEffect.FriendlyDescription, OldEffect.IconImage, OldEffect.bDisplayInUI, OldEffect.StatusIcon, OldEffect.AbilitySourceName);
			NewEffect.EffectName = OldEffect.EffectName;
			NewEffect.DuplicateResponse = OldEffect.DuplicateResponse;
			NewEffect.bDupeForSameSourceOnly = OldEffect.bDupeForSameSourceOnly;
			if (OriginalClass == class'ARFM_Effect_Battlehaunt')
			{
				NewEffect.DuplicateResponse = eDupe_Ignore;
				NewEffect.bDupeForSameSourceOnly = true;
			}
			NewEffect.TargetConditions = OldEffect.TargetConditions;
			NewEffect.bRemoveWhenTargetDies = OldEffect.bRemoveWhenTargetDies;
			// Tactical saves identify the applied effect by ability, array and index.
			if (MultiTarget)
			{
				Ability.AbilityMultiTargetEffects[Index] = NewEffect;
			}
			else
			{
				Ability.AbilityTargetEffects[Index] = NewEffect;
			}
		}
	}
}

static function EHLDelegateReturn AdjustYearningArmor(int WeaponDamage, out int ArmorMitigation, out int ArmorPiercing, out int MinMitigation, out int ArmorShred, EffectAppliedData ApplyEffectParams, X2Effect_ApplyWeaponDamage Source, optional bool ForMinDamagePreview, optional XComGameState NewGameState)
{
	local XComGameState_Unit Target;
	local int Reduction;

	if (WeaponDamage <= 0 || ArmorMitigation <= 0 || ArmorPiercing >= ArmorMitigation)
	{
		return EHLDR_NoInterrupt;
	}
	if (NewGameState != none)
	{
		Target = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParams.TargetStateObjectRef.ObjectID));
	}
	if (Target == none)
	{
		Target = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParams.TargetStateObjectRef.ObjectID));
	}
	if (Target != none && Target.IsUnitAffectedByEffectName(class'ARFM_Effect_Battleborn'.default.EffectName))
	{
		// The engine has already resolved weapon, ammo, upgrades, effects and armor-bypass here.
		// The mitigation floor does not alter the original armor used to cap shred.
		Reduction = -int(WeaponDamage * class'ARFM_Effect_Battleborn'.default.BattlebornArmorPower);
		MinMitigation = Max(MinMitigation, ArmorMitigation - ArmorPiercing + Reduction);
	}
	return EHLDR_NoInterrupt;
}

static function bool HasNumericalAdvantage(XComGameState_Unit Source, out int VisibleXCom, optional XComGameState Pending)
{
	local array<StateObjectReference> Visible;
	local StateObjectReference Ref;
	local XComGameState_Unit Unit, Current;
	local XComGameStateHistory History;
	local int Allies;

	VisibleXCom = 0;
	if (Source == none)
	{
		return false;
	}
	History = `XCOMHISTORY;
	foreach History.IterateByClassType(class'XComGameState_Unit', Unit)
	{
		Current = Unit;
		if (Pending != none && Pending.GetGameStateForObjectID(Unit.ObjectID) != none)
		{
			Current = XComGameState_Unit(Pending.GetGameStateForObjectID(Unit.ObjectID));
		}
		if (Current != none && Current.ObjectID != Source.ObjectID && Current.ControllingPlayer.ObjectID > 0 && Current.GetTeam() == Source.GetTeam() && Current.IsAlive() && !Current.bRemovedFromPlay)
		{
			++Allies;
		}
	}
	if (Pending != none)
	{
		foreach Pending.IterateByClassType(class'XComGameState_Unit', Unit)
		{
			if (History.GetGameStateForObjectID(Unit.ObjectID) == none && Unit.ObjectID != Source.ObjectID && Unit.ControllingPlayer.ObjectID > 0 && Unit.GetTeam() == Source.GetTeam() && Unit.IsAlive() && !Unit.bRemovedFromPlay)
			{
				++Allies;
			}
		}
	}

	class'X2TacticalVisibilityHelpers'.static.GetAllVisibleUnitsOnTeamForSource(Source.ObjectID, eTeam_XCom, Visible);
	foreach Visible(Ref)
	{
		Unit = none;
		if (Pending != none)
		{
			Unit = XComGameState_Unit(Pending.GetGameStateForObjectID(Ref.ObjectID));
		}
		if (Unit == none)
		{
			Unit = XComGameState_Unit(History.GetGameStateForObjectID(Ref.ObjectID));
		}
		if (Unit != none && Unit.IsAlive() && !Unit.bRemovedFromPlay)
		{
			++VisibleXCom;
		}
	}
	return Allies > VisibleXCom;
}

static function GrantCardPassives(X2CharacterTemplate Unit)
{
	if (Unit == none || Unit.bIsSoldier)
	{
		return;
	}
	if (Unit.CharacterGroupName == 'AdventStunLancer')
	{
		GrantLancerLink(Unit, 'ARFMPYP_StunlancerTacticLink', 'ARFMPYP_LancerTacticLink');
		GrantLancerLink(Unit, 'ARFMPYP_StunlancerPrecisionLink', 'ARFMPYP_LancerPrecisionLink');
		GrantLancerLink(Unit, 'ARFMPYP_StunlancerPerceptionLink', 'ARFMPYP_LancerPerceptionLink');
	}
	if (Unit.CharacterGroupName == 'AdventMec' && Unit.Abilities.Find('ARFMPYP_HighCaliber') == INDEX_NONE)
	{
		Unit.Abilities.AddItem('ARFMPYP_HighCaliber');
	}
	if (Unit.CharacterGroupName == 'AdventTrooper' && Unit.Abilities.Find('ARFMPYP_TrooperDamage') == INDEX_NONE)
	{
		Unit.Abilities.AddItem('ARFMPYP_TrooperDamage');
	}
	if (Unit.Abilities.Find('ARFMPYP_OfficerAim') != INDEX_NONE && Unit.Abilities.Find('ARFMPYP_OfficerDamage') == INDEX_NONE)
	{
		Unit.Abilities.AddItem('ARFMPYP_OfficerDamage');
	}
}

static private function GrantLancerLink(X2CharacterTemplate Unit, name OldName, name AbilityName)
{
	if (class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(OldName) == none)
	{
		Unit.Abilities.RemoveItem(OldName);
	}
	if (Unit.Abilities.Find(AbilityName) == INDEX_NONE)
	{
		Unit.Abilities.AddItem(AbilityName);
	}
}
