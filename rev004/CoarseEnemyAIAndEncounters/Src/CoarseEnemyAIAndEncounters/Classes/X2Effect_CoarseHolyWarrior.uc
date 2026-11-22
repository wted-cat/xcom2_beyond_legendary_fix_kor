class X2Effect_CoarseHolyWarrior extends X2Effect_Persistent;

function int GetDefendingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect, optional XComGameState NewGameState)
{
	local XComGameState_Unit Unit;
	local XComGameState_Effect Link, Earlier;
	local StateObjectReference Ref;

	Unit = XComGameState_Unit(TargetDamageable);
	if (Unit == none || EffectState == none)
	{
		return 0;
	}
	if (EffectName == class'ARFM_Effect_BattlePriest'.default.EffectName)
	{
		if (Unit.IsUnitApplyingEffectName('HolyWarriorEffect') && Unit.GetUnitAffectedByEffectState(EffectName) == EffectState)
		{
			return CurrentDamage * class'ARFM_Effect_BattlePriest'.default.BattlepriestReduction;
		}
	}
	else
	{
		if (Unit.IsUnitApplyingEffectName('HolyWarriorEffect') && Unit.IsUnitAffectedByEffectName(class'ARFM_Effect_BattlePriest'.default.EffectName))
		{
			return 0;
		}
		Link = Unit.GetUnitAffectedByEffectState('HolyWarriorEffect');
		if (Link != none && Link.ApplyEffectParameters.SourceStateObjectRef.ObjectID == EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID)
		{
			// Older tactical saves can contain several infinite markers from the same priest.
			foreach Unit.AffectedByEffects(Ref)
			{
				Earlier = XComGameState_Effect(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));
				if (Earlier != none && !Earlier.bRemoved && Earlier.GetX2Effect().EffectName == EffectName
					&& Earlier.ApplyEffectParameters.SourceStateObjectRef.ObjectID == Link.ApplyEffectParameters.SourceStateObjectRef.ObjectID)
				{
					if (Earlier == EffectState)
					{
						return CurrentDamage * class'ARFM_Effect_Battlehaunt'.default.BattlehauntReduction;
					}
					break;
				}
			}
		}
	}
	return 0;
}
