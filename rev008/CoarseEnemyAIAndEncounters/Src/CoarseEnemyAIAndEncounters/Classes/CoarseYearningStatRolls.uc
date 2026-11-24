class CoarseYearningStatRolls extends Object;

static function Install(X2AbilityTemplateManager Manager)
{
	local array<name> Names;
	local array<X2AbilityTemplate> Variants;
	local X2AbilityTemplate Ability;
	local name Id;

	Manager.GetTemplateNames(Names);
	foreach Names(Id)
	{
		Variants.Length = 0;
		Manager.FindAbilityTemplateAllDifficulties(Id, Variants);
		foreach Variants(Ability)
		{
			Ability.AbilityToHitCalc = WithCardRoll(Ability.AbilityToHitCalc);
			Ability.AbilityToHitOwnerOnMissCalc = WithCardRoll(Ability.AbilityToHitOwnerOnMissCalc);
		}
	}
}

static private function X2AbilityToHitCalc WithCardRoll(X2AbilityToHitCalc Calc)
{
	if (Calc == none)
	{
		return none;
	}
	if (Calc.Class == class'X2AbilityToHitCalc_StatCheck_UnitVsUnit')
	{
		return new(Calc.Outer) class'X2AbilityToHitCalc_CoarseYearningUnitRoll'(Calc);
	}
	if (Calc.Class == class'X2AbilityToHitCalc_PanicCheck')
	{
		return new(Calc.Outer) class'X2AbilityToHitCalc_CoarseYearningPanicRoll'(Calc);
	}
	if (Calc.Class == class'ARFM_AbilityToHit_BrutalityDoctrine')
	{
		return new(Calc.Outer) class'X2AbilityToHitCalc_CoarseYearningDoctrineRoll'(Calc);
	}
	return Calc;
}

static function bool RollWithCardBonus(X2AbilityToHitCalc_StatCheck Calc, class<X2AbilityToHitCalc_StatCheck> OriginalClass, XComGameState_Ability Ability, AvailableTarget Target, out AbilityResultContext Result)
{
	local XComGameState_Unit Source;
	local XComGameState_Effect Effect;
	local X2AbilityToHitCalc_StatCheck Roll;
	local ARFM_Effect_RollAugment Bonus;

	Source = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Ability.OwnerStateObject.ObjectID));
	if (Source == none)
	{
		return false;
	}
	Effect = Source.GetUnitAffectedByEffectState(class'ARFM_Effect_RollAugment'.default.EffectName);
	if (Effect == none || Effect.bRemoved)
	{
		return false;
	}
	switch (Effect.ApplyEffectParameters.EffectRef.SourceTemplateName)
	{
	case 'ARFMPYP_SectoidPsi':
	case 'ARFMPYP_LancerStun':
	case 'ARFMPYP_BerserkerRoll':
	case 'ARFMPYP_MutonRoll':
		break;
	default:
		return false;
	}
	Bonus = ARFM_Effect_RollAugment(Effect.GetX2Effect());
	if (Bonus == none || Bonus.StatRollBonus == 0)
	{
		return false;
	}

	// Highlander includes the effect in its preview. The native roll reads BaseValue separately.
	// A private copy keeps the bonus out of other units' rolls and retains the native immunity and tier checks.
	Roll = new OriginalClass(Calc);
	Roll.BaseValue = Calc.BaseValue + Bonus.StatRollBonus;
	Roll.RollForAbilityHit(Ability, Target, Result);
	return true;
}
