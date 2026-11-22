class X2Effect_CoarseDemocracyUnifies extends ARFM_Effect_DemocracyUnifies;

function bool ChangeHitResultForAttacker(XComGameState_Unit Attacker, XComGameState_Unit TargetUnit, XComGameState_Ability AbilityState, const EAbilityHitResult CurrentResult, out EAbilityHitResult NewHitResult)
{
	local X2AbilityTemplate Ability;
	local X2Effect Effect;
	local int VisibleXCom;

	if (TargetUnit == none || TargetUnit.GetTeam() != eTeam_XCom || AbilityState == none)
	{
		return false;
	}
	Ability = AbilityState.GetMyTemplate();
	if (Ability.AbilitySourceName != 'eAbilitySource_Psionic')
	{
		return false;
	}
	foreach Ability.AbilityTargetEffects(Effect)
	{
		if (X2Effect_MindControl(Effect) != none && class'CoarseYearningCardEffects'.static.HasNumericalAdvantage(Attacker, VisibleXCom))
		{
			NewHitResult = eHit_Success;
			return true;
		}
	}
	return false;
}
