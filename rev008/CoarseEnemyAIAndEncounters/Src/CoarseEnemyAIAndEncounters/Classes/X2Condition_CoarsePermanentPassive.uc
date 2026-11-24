class X2Condition_CoarsePermanentPassive extends X2Condition;

var name AbilityName;
var int PermanentIndex;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit Unit;
	local XComGameState_Effect Effect;
	local StateObjectReference Ref;

	Unit = XComGameState_Unit(kTarget);
	if (Unit == none || kAbility == none || kAbility.GetMyTemplateName() != AbilityName || kAbility.OwnerStateObject.ObjectID != Unit.ObjectID)
	{
		return 'AA_Success';
	}
	foreach Unit.AffectedByEffects(Ref)
	{
		// Only a previously submitted activation counts. All effects of the first activation may run together.
		Effect = XComGameState_Effect(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));
		if (Effect != none && !Effect.bRemoved && Effect.ApplyEffectParameters.SourceStateObjectRef.ObjectID == Unit.ObjectID
			&& Effect.ApplyEffectParameters.TargetStateObjectRef.ObjectID == Unit.ObjectID
			&& Effect.ApplyEffectParameters.EffectRef.SourceTemplateName == AbilityName
			&& Effect.ApplyEffectParameters.EffectRef.LookupType == TELT_AbilityTargetEffects
			&& Effect.ApplyEffectParameters.EffectRef.TemplateEffectLookupArrayIndex == PermanentIndex)
		{
			return 'AA_DuplicateEffectIgnored';
		}
	}
	return 'AA_Success';
}
