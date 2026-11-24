class CoarseYearningAttackCards extends Object;

static function Install(X2AbilityTemplateManager Manager)
{
	local array<name> Names;
	local array<X2AbilityTemplate> Variants;
	local X2AbilityTemplate Ability;
	local name Id;

	Names.AddItem('PsiBombStage1');
	Names.AddItem('Vanish');
	Names.AddItem('DevastatingPunch');
	Names.AddItem('AHWMagnaDevastatingPunch');
	Names.AddItem('ARFMPYP_BrutalistMuton');
	Names.AddItem('ARFMPYP_TrooperAim');
	Names.AddItem('RocketLauncher');
	Names.AddItem('ThrowGrenade');
	Names.AddItem('LaunchGrenade');
	Names.AddItem('AHWKosmaLauncher');
	foreach Names(Id)
	{
		Variants.Length = 0;
		Manager.FindAbilityTemplateAllDifficulties(Id, Variants);
		foreach Variants(Ability)
		{
			switch (Id)
			{
			case 'PsiBombStage1':
				AddBombCards(Ability);
				break;
			case 'Vanish':
				AddVanishHeal(Ability);
				break;
			case 'DevastatingPunch':
			case 'AHWMagnaDevastatingPunch':
				AddPunchCard(Ability);
				break;
			case 'ARFMPYP_BrutalistMuton':
				CorrectShooterTag(Ability, 'BrutalistMuton');
				break;
			case 'ARFMPYP_TrooperAim':
				CorrectShooterTag(Ability, 'ARFMPYP_TrooperRoll');
				break;
			case 'RocketLauncher':
				AddRadiusIfMissing(Ability, 'ARFMPYP_WeGotTheRockets', `TILESTOMETERS(1) + 0.01);
				break;
			default:
				// These abilities launch grenades, including the Coarse Kosma grenade.
				AddRadiusIfMissing(Ability, 'ARFMPYP_BedlamBlasting', `TILESTOMETERS(1) + 0.01);
				if (Id == 'ThrowGrenade')
				{
					AddRadiusIfMissing(Ability, 'ARFMTPY_JANMegaNades', `TILESTOMETERS(3) + 0.01);
				}
			}
		}
	}
}

static private function CorrectShooterTag(X2AbilityTemplate Ability, name OldTag)
{
	local X2Condition Condition;
	local X2Condition_GameplayTag Tag;

	foreach Ability.AbilityShooterConditions(Condition)
	{
		Tag = X2Condition_GameplayTag(Condition);
		if (Tag != none && Tag.RequiredGameplayTag == OldTag)
		{
			Tag.RequiredGameplayTag = Ability.DataName;
		}
	}
}

static private function AddRadiusIfMissing(X2AbilityTemplate Ability, name Id, float Distance)
{
	local X2AbilityMultiTarget_Radius Radius;

	Radius = X2AbilityMultiTarget_Radius(Ability.AbilityMultiTargetStyle);
	if (Radius != none && Radius.AbilityBonusRadii.Find('RequiredAbility', Id) == INDEX_NONE)
	{
		Radius.AddAbilityBonusRadius(Id, Distance);
	}
}

static private function ARFM_Condition_GameplayTag CardGate(name Id)
{
	local ARFM_Condition_GameplayTag Tag;

	Tag = new class'ARFM_Condition_GameplayTag';
	Tag.RequiredGameplayTag = Id;
	return Tag;
}

static private function bool HasEffectForCard(const out array<X2Effect> Effects, class<X2Effect> EffectClass, name Id)
{
	local X2Effect Effect;
	local X2Condition Condition;
	local ARFM_Condition_GameplayTag Tag;

	foreach Effects(Effect)
	{
		if (Effect == none || !ClassIsChildOf(Effect.Class, EffectClass))
		{
			continue;
		}
		foreach Effect.TargetConditions(Condition)
		{
			Tag = ARFM_Condition_GameplayTag(Condition);
			if (Tag != none && Tag.RequiredGameplayTag == Id)
			{
				return true;
			}
		}
	}
	return false;
}

static private function AddBombCards(X2AbilityTemplate Ability)
{
	local ARFM_Condition_UnitTeam Team;
	local X2Effect Effect;

	Team = new class'ARFM_Condition_UnitTeam';
	Team.DoNotAffectAlien = true;
	Team.DoNotAffectXCom = false;
	if (!HasEffectForCard(Ability.AbilityMultiTargetEffects, class'ARFM_Effect_Malfunction', 'ARFMPYP_CodexSadness'))
	{
		Effect = new class'ARFM_Effect_Malfunction';
		Effect.TargetConditions.AddItem(CardGate('ARFMPYP_CodexSadness'));
		Effect.TargetConditions.AddItem(Team);
		Ability.AddMultiTargetEffect(Effect);
	}
	if (!HasEffectForCard(Ability.AbilityMultiTargetEffects, class'ARFM_Aspect_Grail', 'ARFMPYP_GrailCurse'))
	{
		Effect = new class'ARFM_Aspect_Grail';
		Effect.TargetConditions.AddItem(CardGate('ARFMPYP_GrailCurse'));
		Effect.TargetConditions.AddItem(Team);
		Ability.AddMultiTargetEffect(Effect);
	}
	if (Ability.PostActivationEvents.Find('ARFMPsiBombActivated') == INDEX_NONE)
	{
		Ability.PostActivationEvents.AddItem('ARFMPsiBombActivated');
	}
}

static private function AddVanishHeal(X2AbilityTemplate Ability)
{
	local X2Effect_ApplyMedikitHeal Heal;

	if (!HasEffectForCard(Ability.AbilityTargetEffects, class'X2Effect_ApplyMedikitHeal', 'ARFMPYP_SpectreRegen'))
	{
		Heal = new class'X2Effect_ApplyMedikitHeal';
		Heal.PerUseHP = 400;
		Heal.IncreasedHealProject = 'BattlefieldMedicine';
		Heal.IncreasedPerUseHP = 420;
		Heal.TargetConditions.AddItem(CardGate('ARFMPYP_SpectreRegen'));
		Ability.AddTargetEffect(Heal);
	}
}

static private function AddPunchCard(X2AbilityTemplate Ability)
{
	local X2AbilityMultiTarget_Radius Radius;
	local X2Effect_ApplyWeaponDamage Damage;
	local X2Effect_ImmediateAbilityActivation Impair;
	local ARFM_Condition_GameplayTag Gate;

	Gate = CardGate('ARFMPYP_Spinebreakers');
	Radius = X2AbilityMultiTarget_Radius(Ability.AbilityMultiTargetStyle);
	if (Ability.AbilityMultiTargetStyle == none)
	{
		Radius = new class'X2AbilityMultiTarget_Radius';
		Radius.fTargetRadius = 3;
		Radius.bUseWeaponRadius = false;
		Radius.bExcludeSelfAsTargetIfWithinRadius = true;
		Ability.AbilityMultiTargetStyle = Radius;
		// An ordinary punch keeps no secondary targets when this card is absent.
		Ability.AbilityMultiTargetConditions.AddItem(Gate);
	}
	if (Radius == none)
	{
		return;
	}

	// A standard radius excludes the primary target. Give it the advertised bonus exactly once.
	if (!Radius.bAllowSameTarget && !Radius.bAddPrimaryTargetAsMultiTarget
		&& !HasEffectForCard(Ability.AbilityTargetEffects, class'X2Effect_ApplyWeaponDamage', 'ARFMPYP_Spinebreakers'))
	{
		Damage = new class'X2Effect_ApplyWeaponDamage';
		Damage.EffectDamageValue = class'X2Item_DefaultWeapons'.default.BERSERKER_MELEEATTACK_BASEDAMAGE;
		Damage.EffectDamageValue.DamageType = 'Melee';
		Damage.bIgnoreBaseDamage = true;
		Damage.TargetConditions.AddItem(Gate);
		Ability.AddTargetEffect(Damage);
	}
	if (!HasEffectForCard(Ability.AbilityMultiTargetEffects, class'X2Effect_ApplyWeaponDamage', 'ARFMPYP_Spinebreakers'))
	{
		Damage = new class'X2Effect_ApplyWeaponDamage';
		Damage.EffectDamageValue = class'X2Item_DefaultWeapons'.default.BERSERKER_MELEEATTACK_BASEDAMAGE;
		Damage.EffectDamageValue.DamageType = 'Melee';
		Damage.TargetConditions.AddItem(Gate);
		Ability.AddMultiTargetEffect(Damage);
	}
	if (!HasEffectForCard(Ability.AbilityMultiTargetEffects, class'X2Effect_ImmediateAbilityActivation', 'ARFMPYP_Spinebreakers'))
	{
		Impair = new class'X2Effect_ImmediateAbilityActivation';
		Impair.BuildPersistentEffect(1, false, true, , eGameRule_PlayerTurnBegin);
		Impair.EffectName = 'ImmediateBrainDamage';
		Impair.AbilityName = class'X2Ability_Impairing'.default.ImpairingAbilityName;
		Impair.SetDisplayInfo(ePerkBuff_Passive, Ability.LocFriendlyName, Ability.GetMyLongDescription(), Ability.IconImage, true, , Ability.AbilitySourceName);
		Impair.bRemoveWhenTargetDies = true;
		Impair.VisualizationFn = class'X2Ability_Impairing'.static.ImpairingAbilityEffectTriggeredVisualization;
		Impair.TargetConditions.AddItem(Gate);
		Ability.AddMultiTargetEffect(Impair);
	}
}
