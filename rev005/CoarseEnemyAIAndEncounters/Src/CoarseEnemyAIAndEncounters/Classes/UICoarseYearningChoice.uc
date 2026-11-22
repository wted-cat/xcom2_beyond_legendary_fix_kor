class UICoarseYearningChoice extends ARFMDarkEvents.UIYearningMutatorBox;

var bool bChoiceSubmitted;

simulated function OnOptionOneButtonClicked(UIButton Button)
{
	Choose(1);
}

simulated function OnOptionTwoButtonClicked(UIButton Button)
{
	Choose(2);
}

simulated function OnOptionThreeButtonClicked(UIButton Button)
{
	Choose(3);
}

simulated function Choose(int Option)
{
	local ARFM_GS_YearningMutator Mutator;
	local XComGameState Pending;

	if (bChoiceSubmitted)
	{
		return;
	}

	foreach `XCOMHISTORY.IterateByClassType(class'ARFM_GS_YearningMutator', Mutator)
	{
		if (Mutator.GetMyTemplateName() == EventName)
		{
			break;
		}
	}
	if (Mutator == none || Mutator.GetMyTemplateName() != EventName || !Mutator.CanActivate())
	{
		CloseScreen();
		return;
	}

	bChoiceSubmitted = true;
	Pending = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Choose Yearning mutator");
	if (class'CoarseYearningStrategy'.static.ApplyChoice(Pending, Mutator, Option))
	{
		`XCOMGAME.GameRuleset.SubmitGameState(Pending);
		`XSTRATEGYSOUNDMGR.PlaySoundEvent("ChosenEndOfMonth_KnowledgeLevel4Achieved");
	}
	else
	{
		`XCOMHISTORY.CleanupPendingGameState(Pending);
	}

	`XSTRATEGYSOUNDMGR.PlayPersistentSoundEvent("ChosenEndOfMonth_Stop");
	CloseScreen();
}
