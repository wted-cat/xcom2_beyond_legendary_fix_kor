class X2Effect_CoarseHighCaliber extends ARFM_Effect_HighCaliber;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo Info;

	Info.ModType = eHit_Crit;
	Info.Value = bFlanking ? class'ARFM_Effect_HighCaliber'.default.HighCaliberFlankingCrit : class'ARFM_Effect_HighCaliber'.default.HighCaliberCrit;
	Info.Reason = FriendlyName;
	ShotModifiers.AddItem(Info);
}
