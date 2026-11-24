class X2Effect_CoarseTimeShiftDamage extends ARFM_Effect_TimeShiftTarget;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit Source, Target;
	local int LastDamage;

	// An instant effect has no persistent NewEffectState. The application carries the caster reference.
	Source = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	Target = XComGameState_Unit(kNewTargetState);
	if (Source != none && Target != none && Source.DamageResults.Length > 0)
	{
		LastDamage = Source.DamageResults[Source.DamageResults.Length - 1].DamageAmount;
		if (LastDamage > 0)
		{
			Target.TakeEffectDamage(self, LastDamage, 0, 0, ApplyEffectParameters, NewGameState, false);
		}
	}
}
