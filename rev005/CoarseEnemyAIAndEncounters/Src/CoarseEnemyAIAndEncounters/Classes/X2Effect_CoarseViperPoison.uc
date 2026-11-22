class X2Effect_CoarseViperPoison extends ARFMDarkEvents.ARFM_Effect_MurderDrool;

function int GetAttackingDamageModifier_CH(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable,
	XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage,
	X2Effect_ApplyWeaponDamage WeaponDamageEffect, optional XComGameState NewGameState)
{
	local XComGameState_Unit TargetUnit;
	local array<name> Types;
	local int Bonus, Divisor, Cap;

	TargetUnit = XComGameState_Unit(TargetDamageable);
	if (TargetUnit == none || WeaponDamageEffect == none)
	{
		return 0;
	}
	WeaponDamageEffect.GetEffectDamageTypes(NewGameState, AppliedData, Types);
	if (Types.Find('Poison') == INDEX_NONE)
	{
		return 0;
	}
	if (TargetUnit.GetTeam() == eTeam_TheLost)
	{
		return TargetUnit.GetMaxStat(eStat_HP);
	}
	if (TargetUnit.GetTeam() != eTeam_XCom || !TargetUnit.IsSoldier() || TargetUnit.IsRobotic())
	{
		return 0;
	}
	Divisor = class'ARFM_Effect_MurderDrool'.default.MurderDroolDivisor;
	if (Divisor <= 0)
	{
		return 0;
	}
	Bonus = int(TargetUnit.GetMaxStat(eStat_HP)) / Divisor;
	Cap = class'ARFM_Effect_MurderDrool'.default.MurderDroolCap;
	return Cap > 0 ? Min(Cap, Bonus) : Bonus;
}
