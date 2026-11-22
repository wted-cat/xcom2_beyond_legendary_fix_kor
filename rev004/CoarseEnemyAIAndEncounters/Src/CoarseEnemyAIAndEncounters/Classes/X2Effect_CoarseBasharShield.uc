class X2Effect_CoarseBasharShield extends X2Effect_Persistent;

var int DamageReduction;

function float GetPostDefaultDefendingDamageModifier_CH(XComGameState_Effect EffectState, XComGameState_Unit SourceUnit, XComGameState_Unit TargetUnit, XComGameState_Ability AbilityState, const out EffectAppliedData ApplyEffectParameters, float CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect, XComGameState NewGameState)
{
    if (TargetUnit != none && TargetUnit.GetCurrentStat(eStat_ShieldHP) > 0 && CurrentDamage > 0 && DamageReduction > 0)
    {
        return -FMin(CurrentDamage, float(DamageReduction));
    }
    return 0;
}

defaultproperties
{
    EffectName="CoarseBasharShieldDR"
    DuplicateResponse=eDupe_Ignore
}
