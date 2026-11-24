class X2Effect_CoarseFacelessCritical extends ARFM_Effect_FacelessJelly;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability Context, XComGameState_Ability Ability, XComGameState_Unit SourceUnit, XComGameState_Item Weapon, XComGameState NewGameState, const array<name> Before, const array<name> ReserveBefore)
{
	if (Ability != none && Before.Length > SourceUnit.ActionPoints.Length && Ability.GetMyTemplate().Hostility == eHostility_Offensive
		&& Context.ResultContext.HitResult == eHit_Crit
		&& XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID)) != none)
	{
		SourceUnit.ActionPoints = Before;
	}
	return false;
}
