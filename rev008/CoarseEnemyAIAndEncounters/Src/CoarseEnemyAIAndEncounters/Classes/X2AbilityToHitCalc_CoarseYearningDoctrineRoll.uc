class X2AbilityToHitCalc_CoarseYearningDoctrineRoll extends ARFM_AbilityToHit_BrutalityDoctrine;

function RollForAbilityHit(XComGameState_Ability Ability, AvailableTarget Target, out AbilityResultContext Result)
{
	if (!class'CoarseYearningStatRolls'.static.RollWithCardBonus(self, class'ARFM_AbilityToHit_BrutalityDoctrine', Ability, Target, Result))
	{
		super.RollForAbilityHit(Ability, Target, Result);
	}
}
