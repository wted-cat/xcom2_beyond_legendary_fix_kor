class X2Effect_CoarseShigaite extends ARFM_Capstone_Shigaite;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability Context, XComGameState_Ability Ability, XComGameState_Unit SourceUnit, XComGameState_Item Weapon, XComGameState NewGameState, const array<name> Before, const array<name> ReserveBefore)
{
	local UnitValue Used;

	SourceUnit.GetUnitValue('ARFMShigaite', Used);
	if (Before.Length > SourceUnit.ActionPoints.Length && Used.fValue < 2)
	{
		SourceUnit.ActionPoints = Before;
		SourceUnit.SetUnitFloatValue('ARFMShigaite', Used.fValue + 1, eCleanup_BeginTurn);
	}
	return false;
}
