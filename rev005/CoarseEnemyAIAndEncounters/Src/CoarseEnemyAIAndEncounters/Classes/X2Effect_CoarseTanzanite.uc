class X2Effect_CoarseTanzanite extends ARFM_Capstone_Tanzanite;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability Context, XComGameState_Ability Ability, XComGameState_Unit SourceUnit, XComGameState_Item Weapon, XComGameState NewGameState, const array<name> Before, const array<name> ReserveBefore)
{
	if (Ability != none && Before.Length > 0 && Ability.GetMyTemplate().Hostility == eHostility_Offensive)
	{
		SourceUnit.ReserveActionPoints.AddItem(class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint);
	}
	return false;
}
