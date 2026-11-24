class X2Effect_CoarseStunLanceRefund extends ARFM_Effect_StunlanceRefund;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability Context, XComGameState_Ability Ability, XComGameState_Unit SourceUnit, XComGameState_Item Weapon, XComGameState NewGameState, const array<name> Before, const array<name> ReserveBefore)
{
	local UnitValue Used;

	SourceUnit.GetUnitValue('ARFMStunlanceRefund', Used);
	if (Ability != none && Ability.GetMyTemplateName() == 'StunLance' && Used.fValue < 2
		&& Before.Length > 0 && SourceUnit.ActionPoints.Length < Before.Length)
	{
		SourceUnit.SetUnitFloatValue('ARFMStunlanceRefund', Used.fValue + 3, eCleanup_BeginTurn);
		SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
	}
	return false;
}
