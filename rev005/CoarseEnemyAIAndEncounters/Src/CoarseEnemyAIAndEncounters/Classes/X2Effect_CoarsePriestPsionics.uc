class X2Effect_CoarsePriestPsionics extends ARFM_Effect_PriestProtein;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability Context, XComGameState_Ability Ability, XComGameState_Unit SourceUnit, XComGameState_Item Weapon, XComGameState NewGameState, const array<name> Before, const array<name> ReserveBefore)
{
	if (Ability != none && Before.Length > SourceUnit.ActionPoints.Length
		&& (AllowedAbilities.Find(Ability.GetMyTemplateName()) != INDEX_NONE || Ability.GetMyTemplate().AbilitySourceName == 'eAbilitySource_Psionic'))
	{
		SourceUnit.ActionPoints = Before;
	}
	return false;
}
