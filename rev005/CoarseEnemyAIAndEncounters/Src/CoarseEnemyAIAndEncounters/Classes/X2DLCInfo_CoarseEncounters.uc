// Golden Path encounter overrides and Fortress portal variants for the Ted Jam Coarse profile.
class X2DLCInfo_CoarseEncounters extends X2DownloadableContentInfo config(CoarseEncounters);

struct PortalUnitPool
{
	var array<name> Units;
};

var config PortalUnitPool LateRequiemPool;

static event OnLoadedSavedGameToTactical()
{
	class'CoarseYearningEquipment'.static.RestoreBasharAbilityWeapons();
}

static event OnPostTemplatesCreated()
{
	local XComTacticalMissionManager MissionManager;
	local X2CharacterTemplateManager CharacterManager;
	local array<string> InstalledMods;
	local int UnitIndex;
	local name UnitName;

	class'CoarseYearningStrategy'.static.Install();
	class'CoarseChosenAscent'.static.Install();
	class'CoarseYearningPowers'.static.Install();

	CharacterManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	class'XGAIBehavior_CoarseFrost'.static.InstallForTemplate(CharacterManager, 'FrostMamba', "Viper_Mamba::CharacterRoot");
	class'XGAIBehavior_CoarseFrost'.static.InstallForTemplate(CharacterManager, 'FrostArchon', "Archon_Sentinel::CharacterRoot");
	class'XGAIBehavior_CoarseFrost'.static.InstallForTemplate(CharacterManager, 'FrostLancer_M1', "AdventStunLancer_ABA::CharacterRoot");
	class'XGAIBehavior_CoarseFrost'.static.InstallForTemplate(CharacterManager, 'FrostLancer_M2', "AdventStunLancer_ABA::CharacterRoot");
	class'XGAIBehavior_CoarseFrost'.static.InstallForTemplate(CharacterManager, 'FrostLancer_M3', "AdventStunLancer_ABA::CharacterRoot");

	class'CoarseEnemyEquipment'.static.RepairTemplates(
		class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager(),
		class'X2ItemTemplateManager'.static.GetItemTemplateManager());
	MissionManager = `TACTICALMISSIONMGR;
	RepairMissionScheduleReferences(MissionManager);
	if (CharacterManager.FindCharacterTemplate('BerserkerOmega') != none)
	{
		InstalledMods = class'Helpers'.static.GetInstalledModNames();
		if (InstalledMods.Find("LWOTCBerserkerOmegaBridge") != INDEX_NONE)
		{
			RestoreOmegaBossEntry(MissionManager);
		}
		IncludeOmegaInProtectedList(MissionManager, 'TerrorLeaders_LW', 'ETP_Original_TerrorLeaders');
		IncludeOmegaInProtectedList(MissionManager, 'DefaultLeaders_LW', 'ETP_Original_DefaultLeaders_LW');
		IncludeOmegaInProtectedList(MissionManager, 'AdventLeaders_LW', 'ETP_Original_AdventLeaders_LW');
	}

	if (default.LateRequiemPool.Units.Length != 6)
	{
		`log("FortressLateRequiem needs six reinforcement templates.",, 'FortressLateRequiem');
		return;
	}

	foreach default.LateRequiemPool.Units(UnitName, UnitIndex)
	{
		if (CharacterManager.FindCharacterTemplate(UnitName) == none
			|| default.LateRequiemPool.Units.Find(UnitName) != UnitIndex)
		{
			`log("FortressLateRequiem found an unavailable or duplicate template:" @ UnitName,, 'FortressLateRequiem');
			return;
		}
	}

	// LWOTC has already applied Ted Jam and the local reinforcement overrides.
	AddLateRequiemSlot(MissionManager, 'LIST_FinalShowdown_PurgeTeam');
	AddLateRequiemSlot(MissionManager, 'LIST_FinalShowdown_AvatarTeam');
	AddLateRequiemSlot(MissionManager, 'LIST_FinalShowdown_DualAvatarTeam');
}

static private function RepairMissionScheduleReferences(XComTacticalMissionManager Manager)
{
	local int Index, Slot;
	local name Missing, Replacement;

	for (Index = 0; Index < Manager.arrMissions.Length; ++Index)
	{
		switch (Manager.arrMissions[Index].MissionName)
		{
		case 'SupplyExtraction_LW':
		case 'BigSupplyExtraction_LW':
			Missing = 'Guerilla_D23_2_LW';
			Replacement = 'Guerilla_D22_2_LW';
			break;
		case 'SmashNGrab_LW':
			Missing = 'Guerilla_Revealed_D23_2_LW';
			Replacement = 'Guerilla_Revealed_D22_2_LW';
			break;
		case 'GatherSurvivors':
			Missing = 'ResistanceOps_D1_GatherSurvivorsPA';
			Replacement = 'ResistanceOps_D1_GatherSurvivors';
			break;
		default:
			Missing = '';
			break;
		}
		if (Missing == '')
		{
			continue;
		}
		Slot = Manager.arrMissions[Index].MissionSchedules.Find(Missing);
		if (Slot == INDEX_NONE || Manager.MissionSchedules.Find('ScheduleID', Missing) != INDEX_NONE
			|| Manager.MissionSchedules.Find('ScheduleID', Replacement) == INDEX_NONE)
		{
			continue;
		}
		// Preserve a provider's real alternative and never add weight to an existing card.
		if (Manager.arrMissions[Index].MissionSchedules.Find(Replacement) == INDEX_NONE)
		{
			Manager.arrMissions[Index].MissionSchedules[Slot] = Replacement;
		}
		else
		{
			Manager.arrMissions[Index].MissionSchedules.Remove(Slot, 1);
		}
	}
}

static function AddLateRequiemSlot(XComTacticalMissionManager MissionManager, name BucketID)
{
	local int BucketIndex, EncounterIndex;
	local name UnitName;
	local EncounterBucket Bucket;
	local ConditionalEncounter Candidate, VariantCandidate;
	local ConfigurableEncounter BaseEncounter, Variant;
	local array<ConfigurableEncounter> Variants;

	BucketIndex = MissionManager.EncounterBuckets.Find('EncounterBucketID', BucketID);
	if (BucketIndex == INDEX_NONE)
	{
		`log("FortressLateRequiem could not find the portal bucket:" @ BucketID,, 'FortressLateRequiem');
		return;
	}

	// A caller may reach the helper before DLC configuration is available. Keep the live bucket intact.
	if (default.LateRequiemPool.Units.Length != 6)
	{
		return;
	}

	Bucket = MissionManager.EncounterBuckets[BucketIndex];
	Bucket.EncounterIDs.Length = 0;
	foreach MissionManager.EncounterBuckets[BucketIndex].EncounterIDs(Candidate)
	{
		if (Left(string(Candidate.EncounterID), 5) ~= "FSLR_")
		{
			return;
		}

		EncounterIndex = MissionManager.ConfigurableEncounters.Find('EncounterID', Candidate.EncounterID);
		if (EncounterIndex == INDEX_NONE)
		{
			`log("FortressLateRequiem could not find a base encounter:" @ Candidate.EncounterID,, 'FortressLateRequiem');
			return;
		}

		BaseEncounter = MissionManager.ConfigurableEncounters[EncounterIndex];
		if (BaseEncounter.ForceSpawnTemplateNames.Length == 0
			|| BaseEncounter.ForceSpawnTemplateNames.Length != BaseEncounter.MaxSpawnCount)
		{
			`log("FortressLateRequiem expected a full fixed roster:" @ BaseEncounter.EncounterID,, 'FortressLateRequiem');
			return;
		}

		// Expand each existing draw entry by the same factor to preserve its relative odds.
		foreach default.LateRequiemPool.Units(UnitName)
		{
			Variant = BaseEncounter;
			Variant.EncounterID = name("FSLR_" $ string(BaseEncounter.EncounterID) $ "_" $ string(UnitName));
			Variant.ForceSpawnTemplateNames.AddItem(UnitName);
			Variant.MaxSpawnCount += 1;
			Variants.AddItem(Variant);

			VariantCandidate = Candidate;
			VariantCandidate.EncounterID = Variant.EncounterID;
			Bucket.EncounterIDs.AddItem(VariantCandidate);
		}
	}

	foreach Variants(Variant)
	{
		EncounterIndex = MissionManager.ConfigurableEncounters.Find('EncounterID', Variant.EncounterID);
		if (EncounterIndex == INDEX_NONE)
		{
			MissionManager.ConfigurableEncounters.AddItem(Variant);
		}
		else
		{
			MissionManager.ConfigurableEncounters[EncounterIndex] = Variant;
		}
	}

	MissionManager.EncounterBuckets[BucketIndex] = Bucket;
}

static function PostEncounterCreation(out name EncounterName, out PodSpawnInfo SpawnInfo, int ForceLevel, int AlertLevel, optional XComGameState_BaseObject SourceObject)
{
	local XComGameState_MissionSite MissionState;
	local string MissionFamily;

	// The original plugin matches the generic Forge rule first. Replace its boss slots here.
	if (InStr (EncounterName, "GP_Forge_BossGroup_Extreme") != INDEX_NONE)
	{
		SpawnInfo.SelectedCharacterTemplateNames[0] = 'AHWMechapede';
		SpawnInfo.SelectedCharacterTemplateNames[1] = 'AHWCyberdisc';
		SpawnInfo.SelectedCharacterTemplateNames[2] = 'AHWCyberdisc';
		if (`SecondWaveEnabled('ZeroSanity'))
		{
			SpawnInfo.SelectedCharacterTemplateNames[3] = 'ExaltedCustodian_Grandmaster';
			SpawnInfo.SelectedCharacterTemplateNames[4] = 'ExaltedCustodian';
			SpawnInfo.SelectedCharacterTemplateNames[5] = 'ExaltedCustodian';
		}
		return;
	}

	MissionState = XComGameState_MissionSite(SourceObject);
	if (MissionState == none)
	{
		return;
	}

	MissionFamily = MissionState.GeneratedMission.Mission.MissionFamily;

	// The original plugin has already set the protected Extreme Codex pod.
	if (MissionFamily == "GoldenPath4_LW"
		&& InStr(EncounterName, "GP_Broadcast_Codices_Extreme_LW_PROTECTED") == INDEX_NONE)
	{
		if (InStr (EncounterName, "Hard") != INDEX_NONE)
		{
			if (`SecondWaveEnabled('ZeroSanity'))
			{
				SpawnInfo.SelectedCharacterTemplateNames[0] = 'MutonM3_LW';
				SpawnInfo.SelectedCharacterTemplateNames[1] = 'DromeDome_Fire';
				SpawnInfo.SelectedCharacterTemplateNames[2] = 'DromeDome_Poison';
				SpawnInfo.SelectedCharacterTemplateNames[3] = 'DromeDome_Cryo';
				SpawnInfo.SelectedCharacterTemplateNames[4] = 'Andromedon';
				SpawnInfo.SelectedCharacterTemplateNames[5] = 'AHWAndromelidMagnaM3';
				SpawnInfo.SelectedCharacterTemplateNames[6] = 'NajaM3';
				SpawnInfo.SelectedCharacterTemplateNames[7] = 'NajaM3';
			}
			return;
		}

		if (InStr (EncounterName, "Extreme") != INDEX_NONE)
		{
			if (`SecondWaveEnabled('ZeroSanity'))
			{
				SpawnInfo.SelectedCharacterTemplateNames[0] = 'AHWBerserkerMagna';
				SpawnInfo.SelectedCharacterTemplateNames[1] = 'DromeDome_Fire';
				SpawnInfo.SelectedCharacterTemplateNames[2] = 'DromeDome_Poison';
				SpawnInfo.SelectedCharacterTemplateNames[3] = 'DromeDome_Cryo';
				SpawnInfo.SelectedCharacterTemplateNames[4] = 'Andromedon';
				SpawnInfo.SelectedCharacterTemplateNames[5] = 'AHWAndromelidMagnaM3';
				SpawnInfo.SelectedCharacterTemplateNames[6] = 'NajaM3';
				SpawnInfo.SelectedCharacterTemplateNames[7] = 'NajaM3';
			}
			return;
		}

		if (InStr (EncounterName, "Lone_Drone_LW") != INDEX_NONE)
		{
			SpawnInfo.SelectedCharacterTemplateNames[0] = 'AHWCyberdisc';
			return;
		}
	}

	if (MissionFamily == "GoldenPath3_LW")
	{
		if (InStr (EncounterName, "OPNx8") != INDEX_NONE)
		{
			if (`SecondWaveEnabled('ZeroSanity'))
			{
				SpawnInfo.SelectedCharacterTemplateNames[0] = 'ExaltedCustodian_Grandmaster';
				SpawnInfo.SelectedCharacterTemplateNames[1] = 'ExaltedCustodian';
				SpawnInfo.SelectedCharacterTemplateNames[2] = 'ExaltedCustodian';
				SpawnInfo.SelectedCharacterTemplateNames[3] = 'Muton_Prowler';
				SpawnInfo.SelectedCharacterTemplateNames[4] = 'Muton_Prowler';
			}
			return;
		}

		if (InStr (EncounterName, "ALNx8") != INDEX_NONE)
		{
			if (`SecondWaveEnabled('ZeroSanity'))
			{
				SpawnInfo.SelectedCharacterTemplateNames[0] = 'AHWHeavyMechtoid';
				SpawnInfo.SelectedCharacterTemplateNames[1] = 'MutonM3_LW';
				SpawnInfo.SelectedCharacterTemplateNames[2] = 'MutonM3_LW';
				SpawnInfo.SelectedCharacterTemplateNames[3] = 'DromeDome_Cryo';
				SpawnInfo.SelectedCharacterTemplateNames[4] = 'DromeDome_Cryo';
			}
			return;
		}

		if (InStr (EncounterName, "SolitaryHunter") != INDEX_NONE)
		{
			if (`SecondWaveEnabled('ZeroSanity'))
			{
				SpawnInfo.SelectedCharacterTemplateNames[0] = 'ExaltedPurgeArchbishop';
				SpawnInfo.SelectedCharacterTemplateNames[1] = 'ExaltedPurgePriest';
				SpawnInfo.SelectedCharacterTemplateNames[2] = 'ExaltedPurgePriest';
			}
			return;
		}

	}

	if (MissionFamily == "GoldenPath1_LW")
	{
		if (InStr (EncounterName, "ALNx") != INDEX_NONE)
		{
			if (`SecondWaveEnabled('ZeroSanity'))
			{
				SpawnInfo.SelectedCharacterTemplateNames[0] = 'AHWMutonMagnaElite';
				SpawnInfo.SelectedCharacterTemplateNames[1] = 'MutonM3_LW';
				SpawnInfo.SelectedCharacterTemplateNames[2] = 'MutonM3_LW';
			}
			return;
		}

		if (InStr (EncounterName, "OPNx") != INDEX_NONE)
		{
			if (`SecondWaveEnabled('ZeroSanity'))
			{
				SpawnInfo.SelectedCharacterTemplateNames[0] = 'Mk2_Custodian';
			}
			return;
		}

		if (InStr (EncounterName, "ADVx") != INDEX_NONE)
		{
			if (`SecondWaveEnabled('ZeroSanity'))
			{
				SpawnInfo.SelectedCharacterTemplateNames[0] = 'AdventCustodian';
				SpawnInfo.SelectedCharacterTemplateNames[1] = 'ARFMAdvKnightM3';
				SpawnInfo.SelectedCharacterTemplateNames[2] = 'ARFMAdvKnightM3';
				SpawnInfo.SelectedCharacterTemplateNames[3] = 'ARFMAdvArtilleryM3';
				SpawnInfo.SelectedCharacterTemplateNames[4] = 'ARFMAdvArtilleryM3';
			}
			return;
		}

		if (InStr (EncounterName, "Lone_Drone_LW") != INDEX_NONE)
		{
			if (`SecondWaveEnabled('ZeroSanity'))
			{
				SpawnInfo.SelectedCharacterTemplateNames[0] = 'AdventCustodian';
			}
			return;
		}
	}

	if (MissionFamily == "GoldenPath2_LW")
	{
		// Check the Forge terror pod before the broader OPN match.
		if (InStr (EncounterName, "WithTerror") != INDEX_NONE)
		{
			if (`SecondWaveEnabled('ZeroSanity'))
			{
				SpawnInfo.SelectedCharacterTemplateNames[0] = 'AHWHeavyFloater';
				SpawnInfo.SelectedCharacterTemplateNames[1] = 'AHWHeavyFloater';
				SpawnInfo.SelectedCharacterTemplateNames[2] = 'AdventCustodian';
				SpawnInfo.SelectedCharacterTemplateNames[3] = 'AdventCustodian';
			}
			return;
		}

		if (InStr (EncounterName, "OPN") != INDEX_NONE)
		{
			if (`SecondWaveEnabled('ZeroSanity'))
			{
				SpawnInfo.SelectedCharacterTemplateNames[0] = 'AHWHeavyMechtoid';
				SpawnInfo.SelectedCharacterTemplateNames[1] = 'MutonM3_LW';
				SpawnInfo.SelectedCharacterTemplateNames[2] = 'MutonM3_LW';
			}
			return;
		}

		if (InStr (EncounterName, "ADVx") != INDEX_NONE)
		{
			if (`SecondWaveEnabled('ZeroSanity'))
			{
				SpawnInfo.SelectedCharacterTemplateNames[0] = 'AdventCustodian';
			}
			return;
		}
		
		if (InStr (EncounterName, "Lone_Drone_LW") != INDEX_NONE)
		{
			if (`SecondWaveEnabled('ZeroSanity'))
			{
				SpawnInfo.SelectedCharacterTemplateNames[0] = 'AHWGunship';
			}
			return;
		}

	}
}

static function PostReinforcementCreation(out name EncounterName, out PodSpawnInfo Encounter, int ForceLevel, int AlertLevel, optional XComGameState_BaseObject SourceObject, optional XComGameState_BaseObject ReinforcementState)
{
	class'X2DLCInfo_CoarsePortalCapture'.static.RestoreRoster(Encounter, ReinforcementState);
}

static function IncludeOmegaInProtectedList(XComTacticalMissionManager Manager, name SourceList, name ProtectedList)
{
	local int Index, Destination;
	local SpawnDistributionList List;
	local SpawnDistributionListEntry Entry;
	local array<SpawnDistributionListEntry> SourceEntries, ExistingEntries;

	Destination = INDEX_NONE;
	foreach Manager.SpawnDistributionLists(List, Index)
	{
		if (List.ListID == SourceList || List.ListID == ProtectedList)
		{
			if (List.ListID == ProtectedList && Destination == INDEX_NONE)
			{
				Destination = Index;
			}
			foreach List.SpawnDistribution(Entry)
			{
				if (Entry.Template == 'BerserkerOmega')
				{
					if (List.ListID == SourceList)
					{
						SourceEntries.AddItem(Entry);
					}
					else
					{
						ExistingEntries.AddItem(Entry);
					}
				}
			}
		}
	}
	if (Destination == INDEX_NONE)
	{
		return;
	}

	// Match complete entries one for one. Different force bands and explicitly repeated
	// entries contribute separate draws, including when a protected list already has some.
	foreach SourceEntries(Entry)
	{
		Index = FindSpawnEntry(ExistingEntries, Entry);
		if (Index == INDEX_NONE)
		{
			Manager.SpawnDistributionLists[Destination].SpawnDistribution.AddItem(Entry);
		}
		else
		{
			ExistingEntries.Remove(Index, 1);
		}
	}
}

static function RestoreOmegaBossEntry(XComTacticalMissionManager Manager)
{
	local int Index, Destination;
	local SpawnDistributionList List;
	local SpawnDistributionListEntry Entry;

	// The Bridge's root config specifies this independent FL 16-99 entry; the FL 16-20
	// entry supplied in its subdirectory has a different group cap and remains in place.
	Entry.Template = 'BerserkerOmega';
	Entry.MinForceLevel = 16;
	Entry.MaxForceLevel = 99;
	Entry.MaxCharactersPerGroup = 1;
	Entry.SpawnWeight = 1;
	Destination = INDEX_NONE;
	foreach Manager.SpawnDistributionLists(List, Index)
	{
		if (List.ListID == 'ForcedBossLeader')
		{
			if (FindSpawnEntry(List.SpawnDistribution, Entry) != INDEX_NONE)
			{
				return;
			}
			if (Destination == INDEX_NONE)
			{
				Destination = Index;
			}
		}
	}
	if (Destination != INDEX_NONE)
	{
		Manager.SpawnDistributionLists[Destination].SpawnDistribution.AddItem(Entry);
	}
}

static private function int FindSpawnEntry(const out array<SpawnDistributionListEntry> Entries, SpawnDistributionListEntry Wanted)
{
	local SpawnDistributionListEntry Entry;
	local int Index;

	foreach Entries(Entry, Index)
	{
		if (Entry == Wanted)
		{
			return Index;
		}
	}
	return INDEX_NONE;
}
