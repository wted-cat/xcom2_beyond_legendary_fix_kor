class CoarseYearningStrategy extends Object;

static function Install()
{
	local X2StrategyElementTemplateManager Strategies;
	local X2DataTemplate Variant;
	local array<X2DataTemplate> Variants;
	local ARFMYearningTemplate Choice;
	local X2AlienStrategyActionTemplate Action;
	local CHEventListenerTemplate Listener;

	Strategies = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Strategies.FindDataTemplateAllDifficulties('YMTriParteEighteen', Variants);
	foreach Variants(Variant)
	{
		Choice = ARFMYearningTemplate(Variant);
		if (Choice != none)
		{
			Choice.OnActivatedFn = class'ARFM_SE_YearningMutators'.static.PYPDroneOverlordsUnlock;
			Choice.OnSecondaryActivatedFn = class'ARFM_SE_YearningMutators'.static.ChemicalPinions;
			Choice.OnTrinaryActivatedFn = class'ARFM_SE_YearningMutators'.static.SoulPyres;
		}
	}
	Variants.Length = 0;
	Strategies.FindDataTemplateAllDifficulties('YMTriParteTwentyOne', Variants);
	foreach Variants(Variant)
	{
		Choice = ARFMYearningTemplate(Variant);
		if (Choice != none)
		{
			Choice.OnSecondaryActivatedFn = class'ARFM_SE_YearningMutators'.static.PyresOfDawn;
		}
	}
	Variants.Length = 0;
	Strategies.FindDataTemplateAllDifficulties('ARFMAI_AccelerateEvolution', Variants);
	foreach Variants(Variant)
	{
		Action = X2AlienStrategyActionTemplate(Variant);
		if (Action != none)
		{
			Action.PerformActionFn = OpenChoice;
		}
	}

	Listener = CHEventListenerTemplate(class'X2EventListenerTemplateManager'.static.GetEventListenerTemplateManager().FindEventListenerTemplate('ARFMDESWPYRevengenceHandler'));
	if (Listener != none)
	{
		Listener.RemoveEvent('OnUnitBeginPlay');
		Listener.AddCHEvent('OnUnitBeginPlay', class'CoarseYearningEquipment'.static.OnUnitBeginPlay, ELD_OnStateSubmitted, 1);
		Listener.RemoveEvent('ChosenKidnap');
		Listener.RemoveEvent('ChosenInterrogation');
		Listener.AddCHEvent('ChosenKidnap', RecordChosenVictory, ELD_OnStateSubmitted, 5);
		Listener.AddCHEvent('ChosenInterrogation', RecordChosenVictory, ELD_OnStateSubmitted, 5);
	}
	Listener = CHEventListenerTemplate(class'X2EventListenerTemplateManager'.static.GetEventListenerTemplateManager().FindEventListenerTemplate('ARFMDESWPYDoctrineHandler'));
	if (Listener != none)
	{
		// PostEndOfMonth supplies a pending state that the resistance report submits after immediate listeners return.
		Listener.RemoveEvent('PostEndOfMonth');
		Listener.AddCHEvent('PostEndOfMonth', ApplyDoctrines, ELD_Immediate);
	}
}

static function OpenChoice()
{
	local XComHQPresentationLayer HQPres;
	local array<ARFM_GS_YearningMutator> Deck;
	local ARFM_GS_YearningMutator Draw;
	local ARFMYearningTemplate Choice;
	local UICoarseYearningChoice Screen;

	HQPres = `HQPRES;
	if (HQPres == none || HQPres.ScreenStack.GetScreen_CH(class'UIYearningMutatorBox', true) != none)
	{
		return;
	}
	Deck = class'ARFM_DE_StrategyModifiers'.static.BuildYearningMutatorDeck();
	if (Deck.Length == 0)
	{
		return;
	}
	Draw = class'ARFM_DE_StrategyModifiers'.static.DrawFromYearningMutatorDeck(Deck);
	Choice = Draw.GetMyTemplate();
	Screen = HQPres.Spawn(class'UICoarseYearningChoice', HQPres);
	if (Screen == none)
	{
		return;
	}

	Screen.EventName = Choice.DataName;
	Screen.Title = Choice.MutatorName;
	Screen.Desc = Choice.MutatorDesc;
	Screen.ImagePath = Choice.ImagePath;
	Screen.ChoiceOne = Choice.ChoiceOne;
	Screen.ChoiceOneDesc = Choice.ChoiceOneDesc;
	Screen.ChoiceTwo = Choice.ChoiceTwo;
	Screen.ChoiceTwoDesc = Choice.ChoiceTwoDesc;
	Screen.ChoiceThree = Choice.ChoiceThree;
	Screen.ChoiceThreeDesc = Choice.ChoiceThreeDesc;
	`GAME.GetGeoscape().Pause();
	HQPres.ScreenStack.Push(Screen);
}

static function bool ApplyChoice(XComGameState Pending, ARFM_GS_YearningMutator Mutator, int Option)
{
	local ARFMYearningTemplate Choice;

	if (Pending == none || Mutator == none || !Mutator.CanActivate())
	{
		return false;
	}
	Choice = Mutator.GetMyTemplate();
	if (Option < 1 || Option > 3 || (Option == 1 && Choice.OnActivatedFn == none)
		|| (Option == 2 && Choice.OnSecondaryActivatedFn == none) || (Option == 3 && Choice.OnTrinaryActivatedFn == none))
	{
		return false;
	}
	Mutator = ARFM_GS_YearningMutator(Pending.ModifyStateObject(class'ARFM_GS_YearningMutator', Mutator.ObjectID));
	Mutator.TimesPlayed++;
	Mutator.ChoiceOne = Option == 1;
	Mutator.ChoiceTwo = Option == 2;
	Mutator.ChoiceThree = Option == 3;
	switch (Option)
	{
	case 1:
		Mutator.OnActivated(Pending);
		break;
	case 2:
		Mutator.OnSecondaryActivated(Pending);
		break;
	case 3:
		Mutator.OnTrinaryActivated(Pending);
		break;
	}
	return true;
}

static function EventListenerReturn RecordChosenVictory(Object Data, Object Source, XComGameState Submitted, name EventID, Object CallbackData)
{
	local XComGameState_Unit Unit;
	local XComGameState_AdventChosen Chosen;
	local XComGameState Pending;

	Unit = XComGameState_Unit(Source);
	if (`SecondWaveEnabled('ARFMPerilousYearning') && Unit != none && Unit.IsChosen())
	{
		Chosen = Unit.GetChosenGameState();
		if (Chosen != none)
		{
			Pending = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Record Yearning Chosen victory");
			Chosen = XComGameState_AdventChosen(Pending.ModifyStateObject(class'XComGameState_AdventChosen', Chosen.ObjectID));
			Chosen.NumVictories++;
			`TACTICALRULES.SubmitGameState(Pending);
		}
	}
	return ELR_NoInterrupt;
}

static function EventListenerReturn ApplyDoctrines(Object EventData, Object EventSource, XComGameState GameState, Name EventName, Object CallbackData)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersAlien AlienHQ;
	local XComGameState_DarkEvent DarkEventState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersResistance ResHQ;
	local array<XComGameState_DarkEvent> DarkEventDeck;
	local XComGameState_UFO NewUFOState;
	local XComLWTuple Tuple;
	local int idx;

	if (GameState == none || !`SecondWaveEnabled('ARFMPerilousYearning'))
	{
		return ELR_NoInterrupt;
	}

	History = `XCOMHISTORY;
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	ResHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

	if (XComHQ == none || AlienHQ == none || ResHQ == none)
	{
		return ELR_NoInterrupt;
	}

	if(XComHQ.TacticalGameplayTags.Find('ARFMDESW_CHAAttritionDoctrine') != INDEX_NONE)
	{
		ResHQ = XComGameState_HeadquartersResistance(GameState.ModifyStateObject(class'XComGameState_HeadquartersResistance', ResHQ.ObjectID));
		if(XComHQ.TacticalGameplayTags.Find('NobleCauseActive') != INDEX_NONE)
		{
			ResHQ.WillRecoveryRateScalar = (1.0f - (float(20) / 100.0f));
		}

		if(XComHQ.TacticalGameplayTags.Find('NobleCauseActive') == INDEX_NONE)
		{
			ResHQ.WillRecoveryRateScalar = (1.0f - (float(50) / 100.0f));
		}
		ResHQ.AbilityPointScalar = (1.0f - (float(20) / 100.0f));
	}
	
	if(XComHQ.TacticalGameplayTags.Find('ARFMDESW_CHAExterminationDoctrine') != INDEX_NONE)
	{
		NewUFOState = XComGameState_UFO(GameState.CreateNewStateObject(class'XComGameState_UFO'));
		NewUFOState.PostCreateInit(GameState, true);
	}

	if(XComHQ.TacticalGameplayTags.Find('ARFMDESW_CHAOverrunDoctrine') != INDEX_NONE)
	{
		Tuple = new class'XComLWTuple';
		Tuple.Id = 'SetLWRegionalForceLevel';
		Tuple.Data.Add(5);
	
		Tuple.Data[0].kind = XComLWTVBool;
		Tuple.Data[0].b = true;

		Tuple.Data[1].kind = XComLWTVInt;
		Tuple.Data[1].i = 1;

		Tuple.Data[2].kind = XComLWTVBool;
		Tuple.Data[2].b = false;

		Tuple.Data[3].kind = XComLWTVInt;
		Tuple.Data[3].i = 1;

		Tuple.Data[4].kind = XComLWTVInt;
		Tuple.Data[4].i = 1;

		`XEVENTMGR.TriggerEvent('SetLWRegionalForceLevel', Tuple,, GameState);
	}

	if(XComHQ.TacticalGameplayTags.Find('ARFMDESW_CHAOppressorDoctrine') != INDEX_NONE)
	{
		AlienHQ = XComGameState_HeadquartersAlien(GameState.ModifyStateObject(class'XComGameState_HeadquartersAlien', AlienHQ.ObjectID));
		DarkEventDeck = AlienHQ.BuildDarkEventDeck();
		for (idx = DarkEventDeck.Length - 1; idx >= 0; --idx)
		{
			if (DarkEventDeck[idx] == none || !DarkEventDeck[idx].GetMyTemplate().bRepeatable
				|| AlienHQ.ActiveDarkEvents.Find('ObjectID', DarkEventDeck[idx].ObjectID) != INDEX_NONE)
			{
				DarkEventDeck.Remove(idx, 1);
			}
		}
		if (DarkEventDeck.Length > 0)
		{
			DarkEventState = AlienHQ.DrawFromDarkEventDeck(DarkEventDeck);
		}
		if(DarkEventState != none)
		{
			DarkEventState = XComGameState_DarkEvent(GameState.ModifyStateObject(class'XComGameState_DarkEvent', DarkEventState.ObjectID));
			AlienHQ.ActiveDarkEvents.AddItem(DarkEventState.GetReference());
			DarkEventState.TimesPlayed++;
			DarkEventState.OnActivated(GameState);
			DarkEventState.StartDurationTimer();
			DarkEventState.PauseTimer();
		}
	}
	return ELR_NoInterrupt;
}
