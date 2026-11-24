class X2Condition_CoarseMercyTarget extends X2Condition;

var bool bRequiresBleedingOut;

static function Install(X2AbilityTemplateManager Manager)
{
	RepairMercyCondition(Manager, 'AHWShinanimMercy1', class'X2StatusEffects'.default.BleedingOutName, true);
	RepairMercyCondition(Manager, 'AHWShinanimMercy2', class'X2AbilityTemplateManager'.default.DazedName, false);
}

static private function RepairMercyCondition(X2AbilityTemplateManager Manager, name AbilityName, name RequiredEffect, bool bBleedingOut)
{
	local array<X2AbilityTemplate> Variants;
	local X2AbilityTemplate Ability;
	local X2Condition_UnitEffects Original;
	local X2Condition_CoarseMercyTarget Replacement;
	local int Index;

	Manager.FindAbilityTemplateAllDifficulties(AbilityName, Variants);
	foreach Variants(Ability)
	{
		for (Index = 0; Index < Ability.AbilityTargetConditions.Length; ++Index)
		{
			Original = X2Condition_UnitEffects(Ability.AbilityTargetConditions[Index]);
			// Replace only the original single-effect check. Other mods may supply a stricter combination.
			if (Original != none && Original.Class == class'X2Condition_UnitEffects'
				&& Original.ExcludeEffects.Length == 0 && Original.RequireEffects.Length == 1
				&& Original.RequireEffects[0].EffectName == RequiredEffect)
			{
				Replacement = new(Ability) class'X2Condition_CoarseMercyTarget';
				Replacement.bRequiresBleedingOut = bBleedingOut;
				Ability.AbilityTargetConditions[Index] = Replacement;
				PermitIncapacitatedTarget(Ability, bBleedingOut);
				break;
			}
		}
	}
}

static private function PermitIncapacitatedTarget(X2AbilityTemplate Ability, bool bBleedingOut)
{
	local X2Condition_UnitProperty Original, TargetProperty;
	local int Index;

	for (Index = 0; Index < Ability.AbilityTargetConditions.Length; ++Index)
	{
		Original = X2Condition_UnitProperty(Ability.AbilityTargetConditions[Index]);
		if (Original != none && Original.Class == class'X2Condition_UnitProperty'
			&& Original.ExcludeDead && Original.ExcludeFriendlyToSource && !Original.ExcludeHostileToSource
			&& Original.TreatMindControlledSquadmateAsHostile)
		{
			// Ordinary attacks reject bleeding or unconscious units here before the status check runs.
			// This property is shared by other attacks. Copy it before applying the stabilize/kidnap rule.
			TargetProperty = new(Ability) class'X2Condition_UnitProperty'(Original);
			TargetProperty.ExcludeDead = false;
			TargetProperty.IsBleedingOut = bBleedingOut;
			TargetProperty.FailOnNonUnits = true;
			Ability.AbilityTargetConditions[Index] = TargetProperty;
			return;
		}
	}
}

event name CallMeetsCondition(XComGameState_BaseObject Target)
{
	local XComGameState_Unit Unit;

	Unit = XComGameState_Unit(Target);
	if (Unit == none || Unit.IsDead())
	{
		return 'AA_MissingRequiredEffect';
	}
	if (bRequiresBleedingOut)
	{
		if (Unit.IsUnitAffectedByEffectName(class'X2StatusEffects'.default.BleedingOutName))
		{
			return 'AA_Success';
		}
	}
	else if (Unit.IsUnitAffectedByEffectName(class'X2AbilityTemplateManager'.default.DazedName)
		|| Unit.IsUnitAffectedByEffectName(class'X2StatusEffects'.default.UnconsciousName))
	{
		return 'AA_Success';
	}
	return 'AA_MissingRequiredEffect';
}
