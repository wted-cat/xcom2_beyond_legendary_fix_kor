class CoarseYearningCardEffects extends Object dependson(CHHelpers);

static function Install(X2AbilityTemplateManager Manager)
{
	ReplaceCardEffect(Manager, 'ARFMDESW_ChryssalidSteroids', class'ARFM_Effect_ChryssalidSteroids', class'X2Effect_CoarseChryssalidHits');
	ReplaceCardEffect(Manager, 'ARFMDESW_FacelessJelly', class'ARFM_Effect_FacelessJelly', class'X2Effect_CoarseFacelessCritical');
	ReplaceCardEffect(Manager, 'ARFMDESW_SlipperyStalkers', class'ARFM_Effect_SlipperyStalker', class'X2Effect_CoarseSlipperyStalkers');
	ReplaceCardEffect(Manager, 'ARFMDESW_PriestProtein', class'ARFM_Effect_PriestProtein', class'X2Effect_CoarsePriestPsionics');
	ReplaceCardEffect(Manager, 'ARFMDESW_AvatarPower', class'ARFM_Effect_PriestProtein', class'X2Effect_CoarsePriestPsionics');
	ReplaceCardEffect(Manager, 'ARFMDESW_Woodpecker', class'ARFM_Effect_Woodpecker', class'X2Effect_CoarseSmartMunitions');
	ReplaceCardEffect(Manager, 'ARFMDESW_RoboMadness', class'ARFM_Effect_RoboMadness', class'X2Effect_Persistent');
	if (Manager.FindAbilityTemplate('ARFMDESW_RoboMadness') != none)
	{
		AllowProcessorActionsToContinue(Manager);
	}
	ReplaceCardEffect(Manager, 'ARFMPYP_PoliceBrutality', class'ARFM_Effect_StunlanceRefund', class'X2Effect_CoarseStunLanceRefund');
	ReplaceCardEffect(Manager, 'ARFMDESW_WarlockPsyBooster', class'ARFM_Effect_WarlockPsyBooster', class'X2Effect_CoarseWarlockPsionics');
	ReplaceCardEffect(Manager, 'ARFMCapstoneTanzanite', class'ARFM_Capstone_Tanzanite', class'X2Effect_CoarseTanzanite');
	ReplaceCardEffect(Manager, 'ARFMCapstoneShigaite', class'ARFM_Capstone_Shigaite', class'X2Effect_CoarseShigaite');
	ReplaceCardEffect(Manager, 'ARFMLodestoneCitrine', class'ARFM_Lodestone_Citrine', class'X2Effect_CoarseCitrine');
	ReplaceCardEffect(Manager, 'ARFMLodestoneAmethyst', class'ARFM_Lodestone_Amethyst', class'X2Effect_CoarseAmethyst');
	ReplaceCardEffect(Manager, 'ARFMCapstoneZoisite', class'ARFM_Capstone_Zoisite', class'X2Effect_CoarseZoisite');
	ReplaceCardEffect(Manager, 'ARFMDedicationPower', class'ARFM_Dedication_Power', class'X2Effect_CoarseDedicationPower');
	ReplaceCardEffect(Manager, 'ARFMDedicationChange', class'ARFM_Dedication_Change', class'X2Effect_CoarseDedicationChange');
	ReplaceCardEffect(Manager, 'ARFMDedicationRememberance', class'ARFM_Dedication_Rememberance', class'X2Effect_CoarseRemembrance');
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
	ReplaceCardEffect(Manager, 'ARFMPYP_SectoidPsi', class'ARFM_Effect_AimAugment', class'ARFM_Effect_RollAugment');
	ReplaceCardEffect(Manager, 'ARFMPYP_LancerStun', class'ARFM_Effect_AimAugment', class'ARFM_Effect_RollAugment');
	ReplaceCardEffect(Manager, 'ARFMPYP_BerserkerRoll', class'ARFM_Effect_AimAugment', class'ARFM_Effect_RollAugment');
	ReplaceCardEffect(Manager, 'ARFMPYP_MutonRoll', class'ARFM_Effect_AimAugment', class'ARFM_Effect_RollAugment');
	class'CoarseYearningAttackCards'.static.Install(Manager);
	class'CoarseYearningStatRolls'.static.Install(Manager);
	ProtectPermanentPassives(Manager);
}

static private function AllowProcessorActionsToContinue(X2AbilityTemplateManager Manager)
{
	local array<name> AbilityNames;
	local array<X2AbilityTemplate> Variants;
	local name AbilityName, ProcessorEffectName;
	local X2AbilityTemplate Variant;
	local X2AbilityCost RawCost;
	local X2AbilityCost_ActionPoints Cost;

	ProcessorEffectName = class'ARFM_Effect_RoboMadness'.default.EffectName;
	Manager.GetTemplateNames(AbilityNames);
	foreach AbilityNames(AbilityName)
	{
		Manager.FindAbilityTemplateAllDifficulties(AbilityName, Variants);
		foreach Variants(Variant)
		{
			foreach Variant.AbilityCosts(RawCost)
			{
				Cost = X2AbilityCost_ActionPoints(RawCost);
				// Keep the ordinary price and allowed point types. A cost defined only as "all remaining" has no separate price to preserve.
				if (Cost != none && Cost.bConsumeAllPoints && !Cost.bFreeCost
					&& (Cost.iNumPoints > 0 || Cost.bAddWeaponTypicalCost || Cost.bMoveCost)
					&& Cost.DoNotConsumeAllEffects.Find(ProcessorEffectName) == INDEX_NONE)
				{
					Cost.DoNotConsumeAllEffects.AddItem(ProcessorEffectName);
				}
			}
		}
	}
}

static private function ProtectPermanentPassives(X2AbilityTemplateManager Manager)
{
	local array<name> Names;
	local array<X2AbilityTemplate> Variants;
	local X2AbilityTemplate Ability;
	local name AbilityName;
	local string Id;

	Manager.GetTemplateNames(Names);
	foreach Names(AbilityName)
	{
		Id = string(AbilityName);
		if (InStr(Id, "ARFMPYP_") != 0 && InStr(Id, "ARFMDESW_") != 0 && InStr(Id, "ARFMCapstone") != 0
			&& InStr(Id, "ARFMKeystone") != 0 && InStr(Id, "ARFMLodestone") != 0 && InStr(Id, "ARFMDedication") != 0)
		{
			continue;
		}
		Variants.Length = 0;
		Manager.FindAbilityTemplateAllDifficulties(AbilityName, Variants);
		foreach Variants(Ability)
		{
			ProtectPassiveActivation(Ability);
		}
	}
}

static private function ProtectPassiveActivation(X2AbilityTemplate Ability)
{
	local X2Effect Effect;
	local X2Effect_Persistent Persistent;
	local X2Condition Condition;
	local X2Condition_CoarsePermanentPassive Guard;
	local int Index, PermanentIndex;

	if (!Ability.bUniqueSource || X2AbilityTarget_Self(Ability.AbilityTargetStyle) == none
		|| Ability.AbilityMultiTargetStyle != none || Ability.AbilityTriggers.Length != 1
		|| X2AbilityTrigger_UnitPostBeginPlay(Ability.AbilityTriggers[0]) == none)
	{
		return;
	}
	PermanentIndex = INDEX_NONE;
	for (Index = 0; Index < Ability.AbilityTargetEffects.Length; ++Index)
	{
		Effect = Ability.AbilityTargetEffects[Index];
		if (Effect == none)
		{
			continue;
		}
		foreach Effect.TargetConditions(Condition)
		{
			Guard = X2Condition_CoarsePermanentPassive(Condition);
			if (Guard != none && Guard.AbilityName == Ability.DataName)
			{
				return;
			}
		}
		Persistent = X2Effect_Persistent(Effect);
		if (PermanentIndex == INDEX_NONE && Persistent != none && Persistent.bInfiniteDuration && Effect.TargetConditions.Length == 0)
		{
			PermanentIndex = Index;
		}
	}
	if (PermanentIndex == INDEX_NONE)
	{
		return;
	}
	// Keep the original activation so WotC unregisters its temporary begin-play listener.
	Guard = new(Ability) class'X2Condition_CoarsePermanentPassive';
	Guard.AbilityName = Ability.DataName;
	Guard.PermanentIndex = PermanentIndex;
	foreach Ability.AbilityTargetEffects(Effect)
	{
		if (Effect != none)
		{
			Effect.TargetConditions.AddItem(Guard);
		}
	}
}

static function AddDedicationCoverModifiers(XComGameState_Unit Attacker, XComGameState_Unit Target, int HighCoverBonus, int LowCoverBonus, string Reason, out array<ShotModifierInfo> ShotModifiers)
{
	local GameRulesCache_VisibilityInfo Visibility;
	local ShotModifierInfo Modifier;

	if (Target == none || !Attacker.CanFlank() || !Target.CanTakeCover()
		|| !`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, Target.ObjectID, Visibility))
	{
		return;
	}
	switch (Visibility.TargetCover)
	{
	case CT_Standing:
		Modifier.Value = HighCoverBonus;
		break;
	case CT_Midlevel:
		Modifier.Value = LowCoverBonus;
		break;
	default:
		return;
	}
	if (Modifier.Value > 0)
	{
		Modifier.Reason = Reason;
		Modifier.ModType = eHit_Success;
		ShotModifiers.AddItem(Modifier);
		Modifier.ModType = eHit_Crit;
		ShotModifiers.AddItem(Modifier);
	}
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
			if (ReplacementClass == class'ARFM_Effect_RollAugment')
			{
				// Aim and offensive stat checks can apply to one unit and use different effect names.
				NewEffect.EffectName = class'ARFM_Effect_RollAugment'.default.EffectName;
			}
			if (OriginalClass == class'ARFM_Effect_Battlehaunt')
			{
				NewEffect.DuplicateResponse = eDupe_Ignore;
				NewEffect.bDupeForSameSourceOnly = true;
			}
			if (OriginalClass == class'ARFM_Effect_PriestProtein')
			{
				ARFM_Effect_PriestProtein(NewEffect).AllowedAbilities = ARFM_Effect_PriestProtein(OldEffect).AllowedAbilities;
			}
			if (OriginalClass == class'ARFM_Effect_WarlockPsyBooster')
			{
				ARFM_Effect_WarlockPsyBooster(NewEffect).AllowedAbilities = ARFM_Effect_WarlockPsyBooster(OldEffect).AllowedAbilities;
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
	if ((Unit.CharacterGroupName == 'Sectoid' || Unit.CharacterGroupName == 'Viper')
		&& Unit.Abilities.Find('ARFMDESW_SlipperyStalkers') == INDEX_NONE)
	{
		Unit.Abilities.AddItem('ARFMDESW_SlipperyStalkers');
	}
	if ((Unit.CharacterGroupName == 'Faceless' || Unit.CharacterGroupName == 'Berserker')
		&& Unit.Abilities.Find('ARFMDESW_SpeedyGonzales') == INDEX_NONE)
	{
		Unit.Abilities.AddItem('ARFMDESW_SpeedyGonzales');
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
