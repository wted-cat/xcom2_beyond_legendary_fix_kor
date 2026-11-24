class X2AbilityToHitCalc_CoarseYearningUnitRoll extends X2AbilityToHitCalc_StatCheck_UnitVsUnit;

function RollForAbilityHit(XComGameState_Ability Ability, AvailableTarget Target, out AbilityResultContext Result)
{
	if (!class'CoarseYearningStatRolls'.static.RollWithCardBonus(self, class'X2AbilityToHitCalc_StatCheck_UnitVsUnit', Ability, Target, Result))
	{
		super.RollForAbilityHit(Ability, Target, Result);
	}
}
