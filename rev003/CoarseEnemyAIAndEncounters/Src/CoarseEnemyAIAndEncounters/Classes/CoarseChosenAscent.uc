class CoarseChosenAscent extends Object;

var private array<name> Capstones, Keystones, Lodestones, Dedications, Aspects;

static function Install()
{
	local array<name> Ids;
	local name Id;
	local array<X2DataTemplate> Variants;
	local X2DataTemplate Variant;
	local X2ChosenActionTemplate Action;
	local X2StrategyElementTemplateManager Manager;

	Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	Ids.AddItem('CHAAscension');
	Ids.AddItem('CHAAssassinAscentIII');
	Ids.AddItem('CHAAssassinAscentII');
	Ids.AddItem('CHAAssassinAscentI');
	Ids.AddItem('CHAHunterAscentIII');
	Ids.AddItem('CHAHunterAscentII');
	Ids.AddItem('CHAHunterAscentI');
	Ids.AddItem('CHAWarlockAscentIII');
	Ids.AddItem('CHAWarlockAscentII');
	Ids.AddItem('CHAWarlockAscentI');
	foreach Ids(Id)
	{
		Manager.FindDataTemplateAllDifficulties(Id, Variants);
		foreach Variants(Variant)
		{
			Action = X2ChosenActionTemplate(Variant);
			if (Action != none)
			{
				Action.OnActivatedFn = ApplyAscent;
			}
		}
		Variants.Length = 0;
	}
}

static function ApplyAscent(XComGameState Pending, StateObjectReference Ref, optional bool bReactivate = false)
{
	local XComGameState_ChosenAction Action;
	local XComGameState_AdventChosen Chosen;
	local XComGameState_HeadquartersXCom HQ;
	local name Tag;
	local array<name> Pool;

	if (Pending == none)
	{
		return;
	}
	Action = XComGameState_ChosenAction(Pending.GetGameStateForObjectID(Ref.ObjectID));
	if (Action == none)
	{
		Action = XComGameState_ChosenAction(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));
	}
	if (Action == none || Action.ChosenRef.ObjectID == 0)
	{
		return;
	}
	switch (Action.GetMyTemplateName())
	{
	case 'CHAAscension':
		if (!`SecondWaveEnabled('ARFMPerilousYearning'))
		{
			return;
		}
		if (!class'X2DownloadableContentInfo_ARFMDarkEvents'.default.ARFMSW_LONGWAR_ACTIVE)
		{
			class'ARFM_DESW_StrategyActions'.static.ActivateChosenAscension(Pending, Ref, bReactivate);
			return;
		}
		break;
	case 'CHAAssassinAscentIII':
	case 'CHAHunterAscentIII':
	case 'CHAWarlockAscentIII':
		if (!class'X2DownloadableContentInfo_ARFMDarkEvents'.default.ARFMSW_LONGWAR_ACTIVE)
		{
			class'ARFM_DESW_StrategyActions'.static.ActivateCapstone(Pending, Ref, bReactivate);
			return;
		}
		Tag = 'ARFMDESW_CapstonesActive';
		Pool = default.Capstones;
		break;
	case 'CHAAssassinAscentII':
	case 'CHAHunterAscentII':
	case 'CHAWarlockAscentII':
		if (!class'X2DownloadableContentInfo_ARFMDarkEvents'.default.ARFMSW_LONGWAR_ACTIVE)
		{
			class'ARFM_DESW_StrategyActions'.static.ActivateKeystone(Pending, Ref, bReactivate);
			return;
		}
		Tag = 'ARFMDESW_KeystonesActive';
		Pool = default.Keystones;
		break;
	case 'CHAAssassinAscentI':
	case 'CHAHunterAscentI':
	case 'CHAWarlockAscentI':
		if (!class'X2DownloadableContentInfo_ARFMDarkEvents'.default.ARFMSW_LONGWAR_ACTIVE)
		{
			class'ARFM_DESW_StrategyActions'.static.ActivateLodestone(Pending, Ref, bReactivate);
			return;
		}
		Tag = 'ARFMDESW_LodestonesActive';
		Pool = default.Lodestones;
		break;
	default:
		return;
	}

	Chosen = XComGameState_AdventChosen(Pending.ModifyStateObject(class'XComGameState_AdventChosen', Action.ChosenRef.ObjectID));
	if (Chosen == none)
	{
		return;
	}
	if (Action.GetMyTemplateName() == 'CHAAscension')
	{
		GrantTrait(Chosen, default.Dedications[`SYNC_RAND_STATIC(default.Dedications.Length)]);
		GrantTrait(Chosen, default.Aspects[`SYNC_RAND_STATIC(default.Aspects.Length)]);
	}
	else
	{
		HQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom', true));
		if (HQ != none)
		{
			HQ = XComGameState_HeadquartersXCom(Pending.ModifyStateObject(class'XComGameState_HeadquartersXCom', HQ.ObjectID));
			if (HQ.TacticalGameplayTags.Find(Tag) == INDEX_NONE)
			{
				HQ.TacticalGameplayTags.AddItem(Tag);
			}
		}
		GrantTrait(Chosen, Pool[`SYNC_RAND_STATIC(Pool.Length)]);
	}
	if (Chosen.bMetXCom && !Chosen.bDefeated)
	{
		Chosen.bJustLeveledUp = true;
	}
}

static private function GrantTrait(XComGameState_AdventChosen Chosen, name Trait)
{
	if (Chosen.Strengths.Find(Trait) == INDEX_NONE)
	{
		Chosen.Strengths.AddItem(Trait);
	}
	if (Chosen.RevealedChosenTraits.Find(Trait) == INDEX_NONE)
	{
		Chosen.RevealedChosenTraits.AddItem(Trait);
	}
}

defaultproperties
{
	Dedications(0)=ARFMDedicationChange
	Dedications(1)=ARFMDedicationChange
	Dedications(2)=ARFMDedicationChange
	Dedications(3)=ARFMDedicationEnlightenment
	Dedications(4)=ARFMDedicationEnlightenment
	Dedications(5)=ARFMDedicationSensation
	Dedications(6)=ARFMDedicationSensation
	Dedications(7)=ARFMDedicationRememberance
	Dedications(8)=ARFMDedicationRememberance
	Dedications(9)=ARFMDedicationPower
	Dedications(10)=ARFMDedicationPower
	Aspects(0)=ARFMAspectKnock
	Aspects(1)=ARFMAspectKnock
	Aspects(2)=ARFMAspectGrail
	Aspects(3)=ARFMAspectMoth
	Aspects(4)=ARFMAspectSoul
	Aspects(5)=ARFMAspectWinter
	Aspects(6)=ARFMAspectBlood
	Aspects(7)=ARFMAspectDawn
	Aspects(8)=ARFMAspectSky
	Aspects(9)=ARFMAspectEdge
	Aspects(10)=ARFMAspectEdge
	Capstones(0)=ARFMCapstoneRoselite
	Capstones(1)=ARFMCapstoneRoselite
	Capstones(2)=ARFMCapstoneRoselite
	Capstones(3)=ARFMCapstoneFlint
	Capstones(4)=ARFMCapstoneTanzanite
	Capstones(5)=ARFMCapstoneAugelite
	Capstones(6)=ARFMCapstoneBrookite
	Capstones(7)=ARFMCapstoneZoisite
	Capstones(8)=ARFMCapstoneAlmandine
	Capstones(9)=ARFMCapstoneAzurite
	Keystones(0)=ARFMKeystoneCavansite
	Keystones(1)=ARFMKeystoneCavansite
	Keystones(2)=ARFMKeystoneCavansite
	Keystones(3)=ARFMKeystoneGahnite
	Keystones(4)=ARFMKeystoneIolite
	Keystones(5)=ARFMKeystoneRhodolite
	Keystones(6)=ARFMKeystoneTinzenite
	Keystones(7)=ARFMKeystoneCreedite
	Keystones(8)=ARFMKeystoneBaryte
	Keystones(9)=ARFMKeystoneEuclase
	Lodestones(0)=ARFMLodestoneAdamite
	Lodestones(1)=ARFMLodestoneAdamite
	Lodestones(2)=ARFMLodestoneAdamite
	Lodestones(3)=ARFMLodestoneAegirine
	Lodestones(4)=ARFMLodestoneAmethyst
	Lodestones(5)=ARFMLodestoneCitrine
	Lodestones(6)=ARFMLodestoneCovellite
	Lodestones(7)=ARFMLodestoneElbaite
	Lodestones(8)=ARFMLodestoneLazurite
	Lodestones(9)=ARFMLodestoneDemantoid
	Lodestones(10)=ARFMLodestoneErythrite
}
