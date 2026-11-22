class X2Effect_CoarseZoisite extends ARFM_Capstone_Zoisite;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability Context, XComGameState_Ability Ability, XComGameState_Unit SourceUnit, XComGameState_Item Weapon, XComGameState NewGameState, const array<name> Before, const array<name> ReserveBefore)
{
	local XComGameState_Unit Target;
	local UnitValue Grudge;

	if (Ability == none || Ability.GetMyTemplate().Hostility != eHostility_Offensive)
	{
		return false;
	}
	Target = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID));
	if (Target == none || !SourceUnit.IsEnemyUnit(Target))
	{
		return false;
	}
	Target = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', Target.ObjectID));
	if (Context.IsResultContextHit())
	{
		Target.ClearUnitValue('ARFMCapstoneZoisite');
	}
	else
	{
		Target.GetUnitValue('ARFMCapstoneZoisite', Grudge);
		Target.SetUnitFloatValue('ARFMCapstoneZoisite', Grudge.fValue + `SYNC_RAND(9), eCleanup_Never);
	}
	return false;
}

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local XComGameState_Unit TargetUnit;
	local UnitValue DamageUnitValue;
	local int BonusDamage;

	if (class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult) && AbilityState.IsAbilityInputTriggered())
	{
		if (CurrentDamage > 0)
		{
			TargetUnit = XComGameState_Unit(TargetDamageable);
			if (TargetUnit != none)
			{
				TargetUnit.GetUnitValue('ARFMCapstoneZoisite', DamageUnitValue);
				if (DamageUnitValue.fValue > 0)
				{
					BonusDamage = DamageUnitValue.fValue;
					if (class'ARFM_Capstone_Zoisite'.default.ZoisiteCap > 0 && BonusDamage > class'ARFM_Capstone_Zoisite'.default.ZoisiteCap)
					{
						return class'ARFM_Capstone_Zoisite'.default.ZoisiteCap;
					}

					return BonusDamage;
				}
			}			
		}
	}
	
	return 0;
}
