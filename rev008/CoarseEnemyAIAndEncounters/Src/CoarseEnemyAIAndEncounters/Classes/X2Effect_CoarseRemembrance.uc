class X2Effect_CoarseRemembrance extends ARFM_Dedication_Rememberance;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability Context, XComGameState_Ability Ability, XComGameState_Unit SourceUnit, XComGameState_Item Weapon, XComGameState NewGameState, const array<name> Before, const array<name> ReserveBefore)
{
	local XComGameState_AdventChosen Chosen;

	if (Ability == none || !SourceUnit.IsChosen() || Ability.GetMyTemplate().Hostility != eHostility_Offensive
		|| (Context.ResultContext.HitResult != eHit_Success && Context.ResultContext.HitResult != eHit_Crit)
		|| XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID)) == none)
	{
		return false;
	}
	Chosen = SourceUnit.GetChosenGameState();
	if (Chosen == none)
	{
		return false;
	}
	if (Chosen.NumDefeats > 6 && (Ability.GetMyTemplateName() == 'OverwatchShot' || Ability.GetMyTemplateName() == 'PistolOverwatchShot'))
	{
		SourceUnit.ReserveActionPoints = ReserveBefore;
	}
	if (Chosen.NumDefeats > 9 && `SYNC_RAND(100) > 60)
	{
		if (Chosen.NumDefeats > 12)
		{
			SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
		}
		if (Context.ResultContext.HitResult == eHit_Crit)
		{
			SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
		}
	}
	return false;
}
