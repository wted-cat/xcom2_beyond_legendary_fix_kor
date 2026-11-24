class X2Effect_CoarseDemocracyProtects extends ARFM_Effect_DemocracyProtects;

function bool PreDeathCheck(XComGameState NewGameState, XComGameState_Unit UnitState, XComGameState_Effect EffectState)
{
	local int VisibleXCom;

	if (class'CoarseYearningCardEffects'.static.HasNumericalAdvantage(UnitState, VisibleXCom, NewGameState)
		&& `SYNC_RAND_STATIC(100) <= class'ARFM_Effect_DemocracyProtects'.default.DemocracyBaseChance + VisibleXCom)
	{
		UnitState.SetCurrentStat(eStat_HP, 1);
		return true;
	}
	return false;
}
