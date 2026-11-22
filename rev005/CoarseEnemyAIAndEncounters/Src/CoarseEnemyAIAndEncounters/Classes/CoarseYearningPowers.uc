class CoarseYearningPowers extends Object;

static function Install()
{
	local X2AbilityTemplateManager Manager;
	local array<X2AbilityTemplate> Variants;
	local X2AbilityTemplate Ability;

	Manager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	RegisterMissingAbilities(Manager);
	class'CoarseYearningCardEffects'.static.Install(Manager);
	RegisterUnitPassives();
	Manager.FindAbilityTemplateAllDifficulties('ARFMTA_ScarDecrepitude', Variants);
	foreach Variants(Ability)
	{
		if (Ability.AdditionalAbilities.Find('ARFMTA_ScarDecrepitudePassive') != INDEX_NONE && Manager.FindAbilityTemplate('ARFMTA_ScarDecrepitudePassive') == none)
		{
			Ability.AdditionalAbilities.RemoveItem('ARFMTA_ScarDecrepitudePassive');
			if (Ability.AdditionalAbilities.Find('ARFMTA_DecrepitudePassive') == INDEX_NONE)
			{
				Ability.AdditionalAbilities.AddItem('ARFMTA_DecrepitudePassive');
			}
		}
	}
	Variants.Length = 0;
	Manager.FindAbilityTemplateAllDifficulties('ARFMDESW_NetworkRepairShot', Variants);
	foreach Variants(Ability)
	{
		ConfigureNetworkRepairShot(Ability, class'ARFM_DESW_Abilities'.default.NetworkRepairsAllowedPanicked);
	}
	RestoreInputTrigger(Manager, 'ARFMTA_SoulHack');
	RestoreInputTrigger(Manager, 'ARFMTA_ScarWinter');
	Variants.Length = 0;

	Manager.FindAbilityTemplateAllDifficulties('ARFMDedicationChange', Variants);
	foreach Variants(Ability)
	{
		if (Ability.AdditionalAbilities.Find('TPYChosenTeleportEnemy') != INDEX_NONE
			&& Manager.FindAbilityTemplate('TPYChosenTeleportEnemy') == none)
		{
			Ability.AdditionalAbilities.RemoveItem('TPYChosenTeleportEnemy');
			if (Ability.AdditionalAbilities.Find('TPYChosenTeleport') == INDEX_NONE)
			{
				Ability.AdditionalAbilities.AddItem('TPYChosenTeleport');
			}
		}
	}
	Variants.Length = 0;
	Manager.FindAbilityTemplateAllDifficulties('TPYDuplicateUnit', Variants);
	foreach Variants(Ability)
	{
		Ability.BuildVisualizationFn = VisualizeDuplicate;
	}
	Variants.Length = 0;
	Manager.FindAbilityTemplateAllDifficulties('TPYChosenCommand', Variants);
	foreach Variants(Ability)
	{
		if (Ability.AbilityToHitCalc == none)
		{
			Ability.AbilityToHitCalc = new class'X2AbilityToHitCalc_DeadEye';
		}
	}
}

static function ConfigureNetworkRepairShot(X2AbilityTemplate Ability, bool AllowPanicked)
{
	local X2Condition Condition;
	local X2Condition_UnitEffects Suppression;
	local name Panic;

	Panic = class'X2AbilityTemplateManager'.default.PanickedName;
	foreach Ability.AbilityShooterConditions(Condition)
	{
		Suppression = X2Condition_UnitEffects(Condition);
		if (Suppression == none || Suppression.ExcludeEffects.Find('EffectName', 'AreaSuppression') == INDEX_NONE
			|| Suppression.ExcludeEffects.Find('EffectName', class'X2Effect_Suppression'.default.EffectName) == INDEX_NONE)
		{
			continue;
		}
		// The upstream factory adds panic to its suppression check when the allow setting is true.
		if (AllowPanicked)
		{
			Suppression.RemoveExcludeEffect(Panic);
		}
		else if (Suppression.ExcludeEffects.Find('EffectName', Panic) == INDEX_NONE)
		{
			Suppression.AddExcludeEffect(Panic, 'AA_UnitIsPanicked');
		}
		return;
	}
}

static private function RestoreInputTrigger(X2AbilityTemplateManager Manager, name Id)
{
	local array<X2AbilityTemplate> Variants;
	local X2AbilityTemplate Ability;

	Manager.FindAbilityTemplateAllDifficulties(Id, Variants);
	foreach Variants(Ability)
	{
		if (Ability.AbilityTriggers.Length == 0)
		{
			Ability.AbilityTriggers.AddItem(new class'X2AbilityTrigger_PlayerInput');
		}
	}
}

static private function RegisterMissingAbilities(X2AbilityTemplateManager Manager)
{
	local X2AbilityTemplate Ability;
	local X2ItemTemplateManager Items;
	local array<X2DataTemplate> Found;
	local X2Effect_CoarseViperPoison Poison;
	local X2Effect_Persistent StatPenalty;

	Found.Length = 0;
	Manager.FindDataTemplateAllDifficulties('ARFMTPY_JANSniper', Found);
	if (Found.Length == 0)
	{
		Ability = class'ARFM_Abilities_Calendarium'.static.CreateARFMTPY_JANSniper();
		Manager.AddAbilityTemplate(Ability);
	}

	Found.Length = 0;
	Manager.FindDataTemplateAllDifficulties('ARFMDESW_TacticalAnalysisPassive', Found);
	if (Found.Length == 0)
	{
		Ability = class'ARFM_DESW_Abilities'.static.CreateARFMDESW_TacticalAnalysisPassive();
		Manager.AddAbilityTemplate(Ability);
	}

	Found.Length = 0;
	Manager.FindDataTemplateAllDifficulties('ARFMDEAbility_ArmoredInGold', Found);
	if (Found.Length == 0)
	{
		Ability = class'ARFM_DE_Abilities'.static.CreateARFMDEAbility_ArmoredInGold();
		// The original event tracks its duration on Alien HQ and never grants the gameplay tag.
		Ability.AbilityShooterConditions[0] = new class'X2Condition_CoarseArmoredInGold';
		StatPenalty = X2Effect_Persistent(Ability.AbilityTargetEffects[0]);
		StatPenalty.EffectName = 'ARFMDE_ArmoredInGoldPsi';
		StatPenalty.DuplicateResponse = eDupe_Ignore;
		Manager.AddAbilityTemplate(Ability);
	}

	Found.Length = 0;
	Manager.FindDataTemplateAllDifficulties('ARFMDEAbility_MedicalSurplus', Found);
	if (Found.Length == 0)
	{
		Ability = class'ARFM_DE_Abilities'.static.CreateARFMDEAbility_MedicalSurplus();
		Manager.AddAbilityTemplate(Ability);
	}

	Found.Length = 0;
	Manager.FindDataTemplateAllDifficulties('TPYAssassinStalk', Found);
	if (Found.Length == 0)
	{
		Ability = X2AbilityTemplate(class'ARFM_DESW_Abilities'.static.CreateTPYAssassinStalk());
		Ability.AbilityTargetConditions.AddItem(new class'X2Condition_CoarseShadowStalkTile');
		Ability.ModifyNewContextFn = PrepareShadowStalk;
		Ability.BuildNewGameStateFn = class'X2Ability_Cyberus'.static.Teleport_BuildGameState;
		Manager.AddAbilityTemplate(Ability);
	}

	Found.Length = 0;
	Manager.FindDataTemplateAllDifficulties('ARFMPYP_MurderDrool', Found);
	if (Found.Length == 0)
	{
		Ability = class'ARFM_PYP_Abilities'.static.CreateARFMPYP_MurderDrool();
		Poison = new class'X2Effect_CoarseViperPoison';
		Poison.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
		Poison.SetDisplayInfo(ePerkBuff_Passive, Ability.LocFriendlyName, Ability.GetMyLongDescription(), Ability.IconImage, true,, Ability.AbilitySourceName);
		Ability.AbilityTargetEffects[0] = Poison;
		Manager.AddAbilityTemplate(Ability);
	}

	Items = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	Found.Length = 0;
	Items.FindDataTemplateAllDifficulties('YearningAllSeeingBashar', Found);
	if (Found.Length == 0)
	{
		Items.AddItemTemplate(X2ItemTemplate(class'ARFM_Items_Yearning'.static.CreateYearningAllSeeingBashar()));
	}
}

static private function RegisterUnitPassives()
{
	local X2CharacterTemplateManager Manager;
	local array<name> Names;
	local array<X2DataTemplate> Variants;
	local X2DataTemplate Variant;
	local X2CharacterTemplate Unit;
	local name Id;

	Manager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	Manager.GetTemplateNames(Names);
	foreach Names(Id)
	{
		Manager.FindDataTemplateAllDifficulties(Id, Variants);
		foreach Variants(Variant)
		{
			Unit = X2CharacterTemplate(Variant);
			class'CoarseYearningCardEffects'.static.GrantCardPassives(Unit);
			if (Unit != none && Unit.bIsChosen && Unit.CharacterGroupName == 'ChosenAssassin' && Unit.Abilities.Find('TPYAssassinStalk') == INDEX_NONE)
			{
				// ARFM_Condition_Change filters this character ability before its tactical instance is created.
				Unit.Abilities.AddItem('TPYAssassinStalk');
			}
			if (Unit != none && Unit.bIsSoldier && Unit.Abilities.Find('ARFMDEAbility_ArmoredInGold') == INDEX_NONE)
			{
				Unit.Abilities.AddItem('ARFMDEAbility_ArmoredInGold');
			}
			if (Unit != none && !Unit.bIsSoldier && (Unit.CharacterGroupName == 'Viper' || Unit.CharacterGroupName == 'ViperKing' || Unit.CharacterGroupName == 'Taipan')
				&& Unit.Abilities.Find('ARFMPYP_MurderDrool') == INDEX_NONE)
			{
				Unit.Abilities.AddItem('ARFMPYP_MurderDrool');
			}
		}
		Variants.Length = 0;
	}
}

static simulated function PrepareShadowStalk(XComGameStateContext Context)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit Source, Target;
	local TTile Destination;

	AbilityContext = XComGameStateContext_Ability(Context);
	Source = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
	Target = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	// Target validation uses the same neighbor query. An interrupted move still needs a valid path for visualization.
	if (!class'X2Condition_CoarseShadowStalkTile'.static.FindLandingTile(Target, Destination))
	{
		Destination = Source.TileLocation;
	}
	AbilityContext.InputContext.TargetLocations.Length = 1;
	AbilityContext.InputContext.TargetLocations[0] = `XWORLD.GetPositionFromTileCoordinates(Destination);
	class'X2Ability_Cyberus'.static.Teleport_ModifyActivatedAbilityContext(Context);
}

static function VisualizeDuplicate(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability  AbilityContext;
	local StateObjectReference InteractingUnitRef;
	local X2AbilityTemplate AbilityTemplate;
	local VisualizationActionMetadata EmptyTrack, ActionMetadata, OriginalCodexMetadata;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyover;
	local XComGameState_Unit UnitState, SpawnedUnit;
	local UnitValue SpawnedUnitValue;
	local ARFM_Action_SpawnDuplicate MoveOriginalCodexAction;
	local ARFM_Action_SpawnDuplicateStay ShowUnitAction;
	local XGUnit OriginalCodex;
	local X2Action_CameraLookAt LookAtAction;
	local X2Action_UpdateFOW FOWAction;
	
	History = `XCOMHISTORY;

	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = AbilityContext.InputContext.PrimaryTarget;

	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.InputContext.AbilityTemplateName);
	OriginalCodexMetadata = EmptyTrack;
	OriginalCodexMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	OriginalCodexMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	OriginalCodexMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);
	UnitState = XComGameState_Unit(OriginalCodexMetadata.StateObject_NewState);
	UnitState.GetUnitValue(class'X2Effect_SpawnUnit'.default.SpawnedUnitValueName, SpawnedUnitValue);
	SpawnedUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(SpawnedUnitValue.fValue));

	UnitState = XComGameState_Unit(OriginalCodexMetadata.StateObject_NewState);
	LookAtAction = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(OriginalCodexMetadata, VisualizeGameState.GetContext(), false, OriginalCodexMetadata.LastActionAdded));
	LookAtAction.UseTether = false;
	LookAtAction.LookAtObject = UnitState;
	LookAtAction.BlockUntilActorOnScreen = true;

	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyover'.static.AddToVisualizationTree(OriginalCodexMetadata, AbilityContext));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', eColor_Bad);

	OriginalCodex = XGUnit(OriginalCodexMetadata.VisualizeActor);
	if (SpawnedUnit != none)
	{
		ActionMetadata = EmptyTrack;
		ActionMetadata.StateObject_OldState = SpawnedUnit;
		ActionMetadata.StateObject_NewState = ActionMetadata.StateObject_OldState;
		ActionMetadata.VisualizeActor = History.GetVisualizer(SpawnedUnit.ObjectID);

		ShowUnitAction = ARFM_Action_SpawnDuplicateStay(class'ARFM_Action_SpawnDuplicateStay'.static.AddToVisualizationTree(ActionMetadata, AbilityContext, false, SoundAndFlyOver));
		ShowUnitAction.OriginalCodex = OriginalCodex;
	}
	`assert((AbilityContext.InputContext.MovementPaths.Length == 1) && (AbilityContext.InputContext.MovementPaths[0].MovementData.Length == 2));
	MoveOriginalCodexAction = ARFM_Action_SpawnDuplicate(class'ARFM_Action_SpawnDuplicate'.static.AddToVisualizationTree(OriginalCodexMetadata, AbilityContext, false, SoundAndFlyOver));
	MoveOriginalCodexAction.bWaitForSpawnedUnitStay = SpawnedUnit != none;
	MoveOriginalCodexAction.Destination = AbilityContext.InputContext.MovementPaths[0].MovementData[1].Position;

	FOWAction = X2Action_UpdateFOW( class'X2Action_UpdateFOW'.static.AddToVisualizationTree( OriginalCodexMetadata, AbilityContext ) );
	FOWAction.ForceUpdate = true;
}
