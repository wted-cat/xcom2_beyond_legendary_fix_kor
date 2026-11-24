class X2Effect_CoarseDedicationChange extends ARFM_Dedication_Change;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local XComGameState_AdventChosen Chosen;

	if (Attacker != none && Attacker.IsChosen())
	{
		Chosen = Attacker.GetChosenGameState();
		if (Chosen != none)
		{
			class'CoarseYearningCardEffects'.static.AddDedicationCoverModifiers(Attacker, Target, 0, 2 * Chosen.NumEncounters, FriendlyName, ShotModifiers);
		}
	}
}
