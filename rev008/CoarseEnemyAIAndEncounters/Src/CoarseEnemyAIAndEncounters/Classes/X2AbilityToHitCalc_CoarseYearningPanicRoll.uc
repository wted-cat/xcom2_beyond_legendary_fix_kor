class X2AbilityToHitCalc_CoarseYearningPanicRoll extends X2AbilityToHitCalc_PanicCheck;

function RollForAbilityHit(XComGameState_Ability Ability, AvailableTarget Target, out AbilityResultContext Result)
{
	if (!class'CoarseYearningStatRolls'.static.RollWithCardBonus(self, class'X2AbilityToHitCalc_PanicCheck', Ability, Target, Result))
	{
		super.RollForAbilityHit(Ability, Target, Result);
	}
}
