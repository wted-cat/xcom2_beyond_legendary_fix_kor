class CoarseEnemyEquipment extends X2Ability abstract;

static function RepairTemplates(X2AbilityTemplateManager Abilities, X2ItemTemplateManager Items)
{
    local X2AbilityTemplate Ability;
    local array<X2AbilityTemplate> Variants;
    local int Index;

    if (Abilities.FindAbilityTemplate('ARFMTPY_JANHighlander') == none)
    {
        Abilities.AddAbilityTemplate(class'ARFMDarkEvents.ARFM_Abilities_Calendarium'.static.CreateARFMTPY_JANHighlander());
    }
    if (Abilities.FindAbilityTemplate('ARFMPYP_SectoidLauncherFuse') == none)
    {
        Abilities.AddAbilityTemplate(class'ARFMDarkEvents.ARFM_PYP_Abilities'.static.CreateARFMPYP_SectoidLauncherFuse());
    }
    if (Abilities.FindAbilityTemplate('ARFMDESW_AvatarPower') == none)
    {
        Abilities.AddAbilityTemplate(class'ARFMDarkEvents.ARFM_DESW_Abilities'.static.CreateARFMDESW_AvatarPower());
    }
    if (Abilities.FindAbilityTemplate('ARFMTPY_JANWallPassive') == none)
    {
        // Calling the upstream Wall factory would recreate the live WholeHearted object by name.
        Ability = PurePassive('ARFMTPY_JANWallPassive', "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_battlelord", false, 'eAbilitySource_Perk', true);
        Ability.AdditionalAbilities.AddItem('ARFMTPY_JANMegaTank');
        Abilities.AddAbilityTemplate(Ability);
    }

    // The shipped Wall factory also registered its grant under WholeHearted.
    // Change only that erroneous grant, retaining any additions from another mod.
    Abilities.FindAbilityTemplateAllDifficulties('ARFMTPY_JANWholeHeartedPassive', Variants);
    foreach Variants(Ability)
    {
        if (Ability.AdditionalAbilities.Find('ARFMTPY_JANMegaTank') != INDEX_NONE)
        {
            Ability.AdditionalAbilities.RemoveItem('ARFMTPY_JANMegaTank');
            if (Ability.AdditionalAbilities.Find('ARFMTPY_JANMassFire') == INDEX_NONE)
            {
                Ability.AdditionalAbilities.AddItem('ARFMTPY_JANMassFire');
            }
        }

        // Another mod may already have corrected the grant while its factory is still missing.
        if (Ability.AdditionalAbilities.Find('ARFMTPY_JANMassFire') != INDEX_NONE
            && Abilities.FindAbilityTemplate('ARFMTPY_JANMassFire') == none)
        {
            RegisterMassFire(Abilities);
        }
    }

    Abilities.FindAbilityTemplateAllDifficulties('ARFMTPY_JANMegaTank', Variants);
    foreach Variants(Ability)
    {
        RepairShieldEffect(Ability);
    }

    // Some installs supply a real feedback template. Only remove the dangling grant.
    if (Abilities.FindAbilityTemplate('ARFMBugFeedback') == none)
    {
        for (Index = 1; Index <= 8; ++Index)
        {
            if (Index <= 4)
            {
                RemoveMissingFeedback(Items, name("SpectralBugM" $ Index $ "_MeleeAttack"));
            }
            RemoveMissingFeedback(Items, name("SpectralBugM" $ Index $ "T2_MeleeAttack"));
        }
    }
}

static private function RegisterMassFire(X2AbilityTemplateManager Abilities)
{
    local X2AbilityTemplate Template;
    local X2AbilityCost_Ammo AmmoCost;
    local X2AbilityTarget_Cursor CursorTarget;
    local X2AbilityMultiTarget_Cone ConeMultiTarget;
    local X2Condition_UnitProperty UnitPropertyCondition;
    local X2AbilityToHitCalc_StandardAim StandardAim;
    local X2AbilityCooldown Cooldown;
    local X2Effect_ApplyWeaponDamage DamageEffect;
    local X2Effect_ApplyDirectionalWorldDamage WorldDamage;

    // The original factory creates an object named MassBombard. A separate object keeps any live MassBombard intact.
    `CREATE_X2ABILITY_TEMPLATE(Template, 'ARFMTPY_JANMassFire');

    AmmoCost = new class'X2AbilityCost_Ammo';
    AmmoCost.iAmmo = 1;
    AmmoCost.bConsumeAllAmmo = true;
    Template.AbilityCosts.AddItem(AmmoCost);

    Template.AbilityCosts.AddItem(default.WeaponActionTurnEnding);

    Cooldown = new class'X2AbilityCooldown';
    Cooldown.iNumTurns = class'ARFMDarkEvents.ARFM_Abilities_Calendarium'.default.JANMassFireCooldown;
    Template.AbilityCooldown = Cooldown;

    StandardAim = new class'X2AbilityToHitCalc_StandardAim';
    Template.AbilityToHitCalc = StandardAim;

    DamageEffect = new class'X2Effect_ApplyWeaponDamage';
    Template.AddMultiTargetEffect(DamageEffect);

    WorldDamage = new class'X2Effect_ApplyDirectionalWorldDamage';
    WorldDamage.bUseWeaponDamageType = true;
    WorldDamage.bUseWeaponEnvironmentalDamage = true;
    WorldDamage.bApplyOnHit = true;
    WorldDamage.bApplyOnMiss = true;
    WorldDamage.bApplyToWorldOnHit = true;
    WorldDamage.bApplyToWorldOnMiss = true;
    WorldDamage.bHitAdjacentDestructibles = true;
    WorldDamage.PlusNumZTiles = 1;
    WorldDamage.bHitTargetTile = true;
    WorldDamage.ApplyChance = class'ARFMDarkEvents.ARFM_Abilities_Calendarium'.default.JANMassFireEnvDamageChance;
    Template.AddMultiTargetEffect(WorldDamage);

    CursorTarget = new class'X2AbilityTarget_Cursor';
    Template.AbilityTargetStyle = CursorTarget;

    ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
    ConeMultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
    ConeMultiTarget.ConeEndDiameter = class'ARFMDarkEvents.ARFM_Abilities_Calendarium'.default.JANMassBombardWidth * class'XComWorldData'.const.WORLD_StepSize;
    ConeMultiTarget.bUseWeaponRangeForLength = true;
    ConeMultiTarget.fTargetRadius = 99;
    ConeMultiTarget.bIgnoreBlockingCover = true;
    Template.AbilityMultiTargetStyle = ConeMultiTarget;

    UnitPropertyCondition = new class'X2Condition_UnitProperty';
    UnitPropertyCondition.ExcludeDead = true;
    UnitPropertyCondition.ExcludeFriendlyToSource = false;
    Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);
    Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

    Template.AddShooterEffectExclusions();

    Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

    Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
    Template.AbilitySourceName = 'eAbilitySource_Perk';
    Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
    Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_saturationfire";
    Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

    Template.ActionFireClass = class'X2Action_Fire_SaturationFire';

    Template.TargetingMethod = class'X2TargetingMethod_Cone';

    Template.ActivationSpeech = 'SaturationFire';
    Template.CinescriptCameraType = "Grenadier_SaturationFire";
    Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

    Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
    Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
    Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

    Template.DefaultSourceItemSlot = eInvSlot_PrimaryWeapon;
    Template.bFrameEvenWhenUnitIsHidden = true;
    Template.bAllowAmmoEffects = true;
    Template.bAllowBonusWeaponEffects = true;
    Template.AddMultiTargetEffect(default.WeaponUpgradeMissDamage);

    Abilities.AddAbilityTemplate(Template);
}

static private function RepairShieldEffect(X2AbilityTemplate Ability)
{
    local X2Effect_CoarseBasharShield Shield;
    local X2Effect Effect;
    local int Index;

    foreach Ability.AbilityTargetEffects(Effect, Index)
    {
        // The upstream template appended the same plating object twice. Preserve the
        // first instance and third-party effects. A corrected template never enters here.
        if (X2Effect_KineticPlating(Effect) != none && Ability.AbilityTargetEffects.Find(Effect) < Index)
        {
            Shield = new class'X2Effect_CoarseBasharShield';
            Shield.DamageReduction = class'ARFMDarkEvents.ARFM_Abilities_Calendarium'.default.JANMegaTankShieldedDR;
            Shield.BuildPersistentEffect(1, true, false, false);
            Ability.AbilityTargetEffects.Remove(Index, 1);
            Ability.AddTargetEffect(Shield);
            return;
        }
    }
}

static private function RemoveMissingFeedback(X2ItemTemplateManager Items, name WeaponName)
{
    local array<X2DataTemplate> Variants;
    local X2DataTemplate Variant;
    local X2WeaponTemplate Weapon;

    Items.FindDataTemplateAllDifficulties(WeaponName, Variants);
    foreach Variants(Variant)
    {
        Weapon = X2WeaponTemplate(Variant);
        if (Weapon != none && Weapon.Abilities.Find('ARFMSpectralSlash') != INDEX_NONE)
        {
            Weapon.Abilities.RemoveItem('ARFMBugFeedback');
        }
    }
}
