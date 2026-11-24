class X2Effect_CoarseEnergyShield extends ARFM_Effect_Beaglebusting;

function int GetDefendingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect, optional XComGameState NewGameState)
{
	local XComGameState_Unit Target;

	Target = XComGameState_Unit(TargetDamageable);
	if (Target != none && Target.GetCurrentStat(eStat_ShieldHP) >= 1)
	{
		return CurrentDamage * class'ARFM_Effect_Beaglebusting'.default.BeaglebustingReduction;
	}
	return 0;
}
