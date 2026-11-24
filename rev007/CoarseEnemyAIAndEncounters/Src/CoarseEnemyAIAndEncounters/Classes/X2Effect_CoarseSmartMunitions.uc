class X2Effect_CoarseSmartMunitions extends ARFM_Effect_Woodpecker;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability Context, XComGameState_Ability Ability, XComGameState_Unit SourceUnit, XComGameState_Item Weapon, XComGameState NewGameState, const array<name> Before, const array<name> ReserveBefore)
{
	local UnitValue Used;

	if (Ability != none && Ability.GetMyTemplateName() == 'StandardShot' && Before.Length > 0
		&& !SourceUnit.GetUnitValue('CoarseSmartMunitionsUsed', Used))
	{
		SourceUnit.SetUnitFloatValue('CoarseSmartMunitionsUsed', 1, eCleanup_BeginTurn);
		if (SourceUnit.ActionPoints.Length < Before.Length)
		{
			SourceUnit.ActionPoints = Before;
		}
	}
	return false;
}
