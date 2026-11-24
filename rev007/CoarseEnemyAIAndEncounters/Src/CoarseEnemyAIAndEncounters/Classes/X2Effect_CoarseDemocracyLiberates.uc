class X2Effect_CoarseDemocracyLiberates extends ARFM_Effect_DemocracyLiberates;

function ModifyTurnStartActionPoints(XComGameState_Unit UnitState, out array<name> ActionPoints, XComGameState_Effect EffectState)
{
	local int VisibleXCom;

	if (class'CoarseYearningCardEffects'.static.HasNumericalAdvantage(UnitState, VisibleXCom))
	{
		ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
	}
}

function EffectAddedCallback(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
{
	local XComGameState_Unit Unit;
	local int VisibleXCom;

	Unit = XComGameState_Unit(kNewTargetState);
	if (class'CoarseYearningCardEffects'.static.HasNumericalAdvantage(Unit, VisibleXCom, NewGameState))
	{
		Unit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
	}
}
