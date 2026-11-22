class X2Effect_CoarsePinpoint extends ARFM_Effect_PYPPinpoint;

function bool ChangeHitResultForAttacker(XComGameState_Unit Attacker, XComGameState_Unit TargetUnit, XComGameState_Ability AbilityState, const EAbilityHitResult CurrentResult, out EAbilityHitResult NewHitResult)
{
	if (Attacker == none || TargetUnit == none || AbilityState == none)
	{
		return false;
	}
	return super.ChangeHitResultForTarget(none, Attacker, TargetUnit, AbilityState, true, CurrentResult, NewHitResult);
}

function bool ChangeHitResultForTarget(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit TargetUnit, XComGameState_Ability AbilityState, bool bIsPrimaryTarget, const EAbilityHitResult CurrentResult, out EAbilityHitResult NewHitResult)
{
	return false;
}
