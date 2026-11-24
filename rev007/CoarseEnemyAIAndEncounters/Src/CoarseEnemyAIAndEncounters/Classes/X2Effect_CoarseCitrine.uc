class X2Effect_CoarseCitrine extends ARFM_Lodestone_Citrine;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability Context, XComGameState_Ability Ability, XComGameState_Unit SourceUnit, XComGameState_Item Weapon, XComGameState NewGameState, const array<name> Before, const array<name> ReserveBefore)
{
	local XComGameState_Unit Target;

	Target = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID));
	if (Ability != none && Target != none && Before.Length > 0 && Ability.GetMyTemplate().Hostility == eHostility_Offensive
		&& (Context.ResultContext.HitResult == eHit_Success || Context.ResultContext.HitResult == eHit_Crit)
		&& Target.IsFlanked(SourceUnit.GetReference()))
	{
		SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
	}
	return false;
}
