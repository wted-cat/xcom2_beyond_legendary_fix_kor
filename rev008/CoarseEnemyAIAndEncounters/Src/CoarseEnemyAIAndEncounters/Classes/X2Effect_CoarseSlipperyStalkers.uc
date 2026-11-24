class X2Effect_CoarseSlipperyStalkers extends ARFM_Effect_SlipperyStalker;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability Context, XComGameState_Ability Ability, XComGameState_Unit SourceUnit, XComGameState_Item Weapon, XComGameState NewGameState, const array<name> Before, const array<name> ReserveBefore)
{
	local XComGameState_Unit Target;

	if (Ability == none || Before.Length == 0 || Ability.GetMyTemplate().Hostility != eHostility_Offensive
		|| Context.ResultContext.HitResult != eHit_Crit)
	{
		return false;
	}
	Target = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID));
	if (Target != none)
	{
		Target = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', Target.ObjectID));
		++SourceUnit.Untouchable;
		++Target.Ruptured;
	}
	return false;
}
