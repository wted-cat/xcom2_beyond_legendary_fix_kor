class X2Effect_CoarseWarlockPsionics extends ARFM_Effect_WarlockPsyBooster;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability Context, XComGameState_Ability Ability, XComGameState_Unit SourceUnit, XComGameState_Item Weapon, XComGameState NewGameState, const array<name> Before, const array<name> ReserveBefore)
{
	if (Ability != none && Before.Length > SourceUnit.ActionPoints.Length && Context.IsResultContextHit()
		&& Ability.GetMyTemplate().AbilitySourceName == 'eAbilitySource_Psionic')
	{
		SourceUnit.ActionPoints = Before;
	}
	return false;
}
