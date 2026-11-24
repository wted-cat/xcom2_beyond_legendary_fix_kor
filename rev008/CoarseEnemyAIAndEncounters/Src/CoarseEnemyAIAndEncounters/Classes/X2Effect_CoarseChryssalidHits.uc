class X2Effect_CoarseChryssalidHits extends ARFM_Effect_ChryssalidSteroids;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability Context, XComGameState_Ability Ability, XComGameState_Unit SourceUnit, XComGameState_Item Weapon, XComGameState NewGameState, const array<name> Before, const array<name> ReserveBefore)
{
	if (Ability != none && Before.Length > 0 && Ability.GetMyTemplate().Hostility == eHostility_Offensive
		&& (Context.ResultContext.HitResult == eHit_Success || Context.ResultContext.HitResult == eHit_Crit)
		&& XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID)) != none)
	{
		SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
	}
	return false;
}
