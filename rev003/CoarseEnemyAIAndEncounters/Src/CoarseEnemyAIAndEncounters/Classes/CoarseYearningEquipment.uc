class CoarseYearningEquipment extends Object;

var private array<name> GeneralPool, ElitePool, UniquePool, MundanePool, Grenades;

static function name DrawBashar(string UnitName, array<name> Tags, int Living, int Force, int Roll)
{
	local bool Elite, Unique, EliteOption, UniqueOption, MundaneOption;

	Elite = InStr(UnitName, "M3_LW") >= 0 || InStr(UnitName, "Elite") >= 0 || InStr(UnitName, "Captain") >= 0 || InStr(UnitName, "Devastator") >= 0;
	Unique = InStr(UnitName, "M2_LW") >= 0 || InStr(UnitName, "Prowler") >= 0 || InStr(UnitName, "Hunter") >= 0
		|| InStr(UnitName, "Frost") >= 0 || InStr(UnitName, "Destroyer") >= 0;
	EliteOption = Tags.Find('ARFMPYP_EliteBashars') != INDEX_NONE;
	UniqueOption = Tags.Find('ARFMPYP_UniqueBashars') != INDEX_NONE;
	MundaneOption = Tags.Find('ARFMPYP_MundaneBashars') != INDEX_NONE;

	if ((Living < 3 || Force >= 20) && Roll <= 90)
	{
		if (EliteOption && Elite)
		{
			return default.ElitePool[`SYNC_RAND_STATIC(default.ElitePool.Length)];
		}
		if (UniqueOption && Unique)
		{
			return default.UniquePool[`SYNC_RAND_STATIC(default.UniquePool.Length)];
		}
		if (MundaneOption && !Elite && !Unique)
		{
			return default.MundanePool[`SYNC_RAND_STATIC(default.MundanePool.Length)];
		}
	}
	// The final general promotion still applies to other Mutons after all Chosen die.
	if ((Living == 0 && Roll <= 90) || (!EliteOption && !UniqueOption && !MundaneOption
		&& ((Living == 2 && Force >= 16 && Roll <= 15) || (Living == 1 && Force >= 12 && Roll <= 40))))
	{
		return default.GeneralPool[`SYNC_RAND_STATIC(default.GeneralPool.Length)];
	}
	return '';
}

static function GetChosenWeapons(name ChosenName, int Living, int Force, bool Blacksite, bool Avatar, int Roll, out array<name> Gear)
{
	local string Tier;
	local bool Alternate;

	if (Living > 2 && Force < 16)
	{
		return;
	}
	if ((Living <= 1 && Force >= 20) || Avatar)
	{
		Tier = "M3";
	}
	else if ((Living <= 1 && Force < 20) || (Blacksite && Force >= 16))
	{
		Tier = "M2";
	}
	Alternate = Roll >= 101;
	switch (ChosenName)
	{
	case 'Chosen_Warlock':
		Gear.AddItem(name((Alternate ? "YearningWarlockBoltSMG" : "YearningWarlockBeamRifle") $ Tier));
		break;
	case 'Chosen_Assassin':
		Gear.AddItem(name((Alternate ? "YearningAssassinBoltShotgun" : "YearningAssassinBeamShotgun") $ Tier));
		Gear.AddItem(name("YearningAssassinSword" $ Tier));
		break;
	case 'Chosen_Hunter':
		Gear.AddItem(name((Alternate ? "YearningHunterBeamSniper" : "YearningHunterBoltThrower") $ Tier));
		Gear.AddItem(name((Alternate ? "YearningHunterBoltPistol" : "YearningHunterBeamPistol") $ Tier));
		break;
	}
}

static function GetTaggedGear(string UnitName, array<name> Tags, out array<name> Gear)
{
	if (InStr(UnitName, "AdvPurifier") >= 0 && Tags.Find('ARFMDESW_CHAHellfireRockets') != INDEX_NONE)
	{
		Gear.AddItem('YearningHellstormLauncher');
	}
	if (InStr(UnitName, "Sectoid") >= 0 && Tags.Find('ARFMPYP_NinetiesBlues') != INDEX_NONE)
	{
		Gear.AddItem('YearningSectoidStunLauncher');
	}
	if (InStr(UnitName, "AdvShieldBearer") >= 0 && Tags.Find('ARFMPYP_PsiBearers') != INDEX_NONE)
	{
		Gear.AddItem('YearningPsiAmp');
	}
	if (InStr(UnitName, "AdvStunLancer") >= 0)
	{
		if (Tags.Find('ARFMPYP_PsiLancers') != INDEX_NONE)
		{
			Gear.AddItem('YearningPsiAmp');
		}
		if (Tags.Find('ARFMPYP_StartedBlasting') != INDEX_NONE)
		{
			Gear.AddItem('YearningPlasmaBlaster');
		}
		AddGrenade(Tags, "Stunlancer", Gear);
	}
	if (InStr(UnitName, "AdvTrooper") >= 0)
	{
		AddGrenade(Tags, "Trooper", Gear);
	}
	if (InStr(UnitName, "AdvCaptain") >= 0 || InStr(UnitName, "AdvColonel") >= 0 || InStr(UnitName, "AdvOutrider") >= 0)
	{
		if (Tags.Find('ARFMPYP_PsiCaptains') != INDEX_NONE)
		{
			Gear.AddItem('YearningPsiAmp');
		}
		if (Tags.Find('ARFMPYP_CaptainGrapeshot') != INDEX_NONE)
		{
			Gear.AddItem('YearningShredderGun');
		}
	}
	if (InStr(UnitName, "PsiWitch") >= 0)
	{
		Gear.AddItem('YearningAvatarRifle');
	}
	if (Tags.Find('ARFMPYP_BedlamBlasting') != INDEX_NONE)
	{
		if (InStr(UnitName, "Viper") >= 0 || InStr(UnitName, "Muton") >= 0)
		{
			Gear.AddItem('YearningGrenadeBooster');
		}
		if (InStr(UnitName, "Purifier") >= 0)
		{
			Gear.AddItem('YearningFlamethrowerBooster');
		}
	}
	if ((InStr(UnitName, "Rocketeer") >= 0 || InStr(UnitName, "AdventMec") >= 0) && Tags.Find('ARFMPYP_WeGotTheRockets') != INDEX_NONE)
	{
		Gear.AddItem('YearningRocketBooster');
	}
}

static private function AddGrenade(array<name> Tags, string UnitType, out array<name> Gear)
{
	if (Tags.Find(name("ARFMPYP_" $ UnitType $ "PlasmaGrenade")) != INDEX_NONE)
	{
		Gear.AddItem('AlienGrenade');
	}
	else if (Tags.Find(name("ARFMPYP_" $ UnitType $ "GasGrenade")) != INDEX_NONE)
	{
		Gear.AddItem('GasGrenade');
	}
	else if (Tags.Find(name("ARFMPYP_" $ UnitType $ "AcidGrenade")) != INDEX_NONE)
	{
		Gear.AddItem('AcidGrenade');
	}
}

static function EventListenerReturn OnUnitBeginPlay(Object Data, Object Source, XComGameState Submitted, name EventID, Object CallbackData)
{
	local XComGameState_HeadquartersXCom HQ;
	local XComGameState_HeadquartersAlien Aliens;
	local XComGameState_AdventChosen Chosen;
	local XComGameState_Unit Unit;
	local array<name> Gear;
	local string UnitName;
	local UnitValue Applied;
	local int Roll, Living, Force;
	local name Bashar;
	local bool PromotionRoll;

	if (!`SecondWaveEnabled('ARFMPerilousYearning'))
	{
		return ELR_NoInterrupt;
	}
	Unit = XComGameState_Unit(Source);
	if (Unit == none || Unit.GetTeam() == eTeam_XCom || Unit.GetTeam() == eTeam_Resistance)
	{
		return ELR_NoInterrupt;
	}
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Unit.ObjectID));
	HQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom', true));
	Aliens = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien', true));
	if (HQ == none || Aliens == none || Unit == none || Unit.GetUnitValue('CoarseYearningGearRolled', Applied))
	{
		return ELR_NoInterrupt;
	}
	UnitName = string(Unit.GetMyTemplateName());
	GetTaggedGear(UnitName, HQ.TacticalGameplayTags, Gear);
	Living = Aliens.GetNumLivingChosen();
	Force = Aliens.GetForceLevel();
	if (InStr(UnitName, "Muton") >= 0 && class'ARFM_Listener_PerilousYearning'.default.bAllowBasharUpgrades)
	{
		PromotionRoll = true;
		Roll = `SYNC_RAND_STATIC(200);
		Bashar = DrawBashar(UnitName, HQ.TacticalGameplayTags, Living, Force, Roll);
		if (Bashar != '')
		{
			Gear.AddItem(Bashar);
		}
	}
	if (Unit.IsChosen() && class'ARFM_Listener_PerilousYearning'.default.bAllowChosenWeaponUpgrades && (Living <= 2 || Force >= 16))
	{
		Chosen = Unit.GetChosenGameState();
		if (Chosen != none)
		{
			Roll = `SYNC_RAND_STATIC(200);
			GetChosenWeapons(Chosen.GetMyTemplateName(), Living, Force,
				class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('T2_M1_InvestigateBlacksite'),
				class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('T1_M6_KillAvatar'), Roll, Gear);
			Gear.AddItem(default.Grenades[`SYNC_RAND_STATIC(default.Grenades.Length)]);
		}
	}
	if (Gear.Length > 0 || PromotionRoll)
	{
		ApplyGear(Unit, Gear);
	}
	return ELR_NoInterrupt;
}

static private function ApplyGear(XComGameState_Unit Unit, array<name> Gear)
{
	local XComGameState Pending;
	local X2EquipmentTemplate Template;
	local XComGameState_Item Item, OldItem;
	local XComGameState_Ability Ability;
	local XComGameState_Player Player;
	local array<AbilitySetupData> Abilities;
	local array<int> AddedItems, RemovedItems;
	local array<XComGameState_Ability> RemovedAbilities;
	local StateObjectReference Ref;
	local XGUnit Visualizer;
	local XGItem ItemActor;
	local bool IgnoreRestrictions;
	local name ItemName;
	local int Index, ObjectID;

	Pending = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Apply Yearning equipment");
	Unit = XComGameState_Unit(Pending.ModifyStateObject(class'XComGameState_Unit', Unit.ObjectID));
	IgnoreRestrictions = Unit.bIgnoreItemEquipRestrictions;
	Unit.bIgnoreItemEquipRestrictions = true;
	foreach Gear(ItemName)
	{
		Template = X2EquipmentTemplate(class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate(ItemName));
		if (Template == none || Unit.HasItemOfTemplateType(ItemName, Pending))
		{
			continue;
		}
		if (Template.InventorySlot == eInvSlot_PrimaryWeapon || Template.InventorySlot == eInvSlot_SecondaryWeapon || Template.InventorySlot == eInvSlot_HeavyWeapon)
		{
			OldItem = Unit.GetItemInSlot(Template.InventorySlot, Pending);
			if (OldItem != none)
			{
				OldItem = XComGameState_Item(Pending.ModifyStateObject(class'XComGameState_Item', OldItem.ObjectID));
				if (!Unit.RemoveItemFromInventory(OldItem, Pending))
				{
					`XCOMHISTORY.CleanupPendingGameState(Pending);
					return;
				}
				RemovedItems.AddItem(OldItem.ObjectID);
				AddedItems.RemoveItem(OldItem.ObjectID);
			}
		}
		Item = Template.CreateInstanceFromTemplate(Pending);
		if (!Unit.AddItemToInventory(Item, Template.InventorySlot, Pending))
		{
			`XCOMHISTORY.CleanupPendingGameState(Pending);
			return;
		}
		AddedItems.AddItem(Item.ObjectID);
	}
	Unit.bIgnoreItemEquipRestrictions = IgnoreRestrictions;
	Unit.SetUnitFloatValue('CoarseYearningGearRolled', 1, eCleanup_BeginTactical);
	for (Index = Unit.Abilities.Length - 1; Index >= 0; --Index)
	{
		Ref = Unit.Abilities[Index];
		Ability = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));
		if (Ability != none && (RemovedItems.Find(Ability.SourceWeapon.ObjectID) != INDEX_NONE || RemovedItems.Find(Ability.SourceAmmo.ObjectID) != INDEX_NONE))
		{
			Unit.Abilities.Remove(Index, 1);
			RemovedAbilities.AddItem(Ability);
		}
	}
	if (AddedItems.Length > 0)
	{
		Player = XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(Unit.ControllingPlayer.ObjectID));
		Abilities = Unit.GatherUnitAbilitiesForInit(Pending, Player);
		for (Index = 0; Index < Abilities.Length; ++Index)
		{
			if (Abilities[Index].Template != none && AddedItems.Find(Abilities[Index].SourceWeaponRef.ObjectID) != INDEX_NONE)
			{
				class'X2TacticalGameRuleset'.static.InitAbilityForUnit(Abilities[Index].Template, Unit, Pending, Abilities[Index].SourceWeaponRef, Abilities[Index].SourceAmmoRef);
			}
		}
	}
	foreach RemovedAbilities(Ability)
	{
		`XEVENTMGR.UnRegisterFromAllEvents(Ability);
	}
	`TACTICALRULES.SubmitGameState(Pending);
	foreach RemovedItems(ObjectID)
	{
		ItemActor = XGItem(`XCOMHISTORY.GetVisualizer(ObjectID));
		if (ItemActor != none)
		{
			ItemActor.Destroy();
			`XCOMHISTORY.SetVisualizer(ObjectID, none);
		}
	}
	Visualizer = XGUnit(Unit.GetVisualizer());
	if (Visualizer != none && AddedItems.Length > 0)
	{
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Unit.ObjectID));
		Visualizer.ApplyLoadoutFromGameState(Unit, Pending);
	}
}

defaultproperties
{
	GeneralPool(0)=YearningGigatankBashar
	GeneralPool(1)=YearningGigatankBashar
	GeneralPool(2)=YearningHyperRegenBashar
	GeneralPool(3)=YearningMassFireBashar
	GeneralPool(4)=YearningSoulborneBashar
	GeneralPool(5)=YearningOppressorBashar
	GeneralPool(6)=YearningGrailBashar
	GeneralPool(7)=YearningBrookiteBashar
	GeneralPool(8)=YearningBloodBashar
	GeneralPool(9)=YearningDawnBashar
	GeneralPool(10)=YearningKnockBashar
	GeneralPool(11)=YearningAzuriteBashar
	GeneralPool(12)=YearningElbaiteBashar
	GeneralPool(13)=YearningGrenadierBashar
	GeneralPool(14)=YearningErythriteBashar
	GeneralPool(15)=YearningFlintBashar
	GeneralPool(16)=YearningShigaiteBashar
	GeneralPool(17)=YearningTanzaniteBashar
	GeneralPool(18)=YearningSkyBashar
	GeneralPool(19)=YearningSpeedBashar
	GeneralPool(20)=YearningMothBashar
	GeneralPool(21)=YearningAllSeeingBashar
	ElitePool(0)=YearningBrookiteBashar
	ElitePool(1)=YearningBrookiteBashar
	ElitePool(2)=YearningShigaiteBashar
	ElitePool(3)=YearningErythriteBashar
	ElitePool(4)=YearningAzuriteBashar
	ElitePool(5)=YearningTanzaniteBashar
	ElitePool(6)=YearningFlintBashar
	UniquePool(0)=YearningMothBashar
	UniquePool(1)=YearningMothBashar
	UniquePool(2)=YearningKnockBashar
	UniquePool(3)=YearningBloodBashar
	UniquePool(4)=YearningDawnBashar
	UniquePool(5)=YearningGrailBashar
	UniquePool(6)=YearningSkyBashar
	UniquePool(7)=YearningSoulborneBashar
	UniquePool(8)=YearningOppressorBashar
	MundanePool(0)=YearningGigatankBashar
	MundanePool(1)=YearningHyperRegenBashar
	MundanePool(2)=YearningMassFireBashar
	MundanePool(3)=YearningGigatankBashar
	MundanePool(4)=YearningGrenadierBashar
	MundanePool(5)=YearningSpeedBashar
	MundanePool(6)=YearningAllSeeingBashar
	Grenades(0)=YearningMeltyLove
	Grenades(1)=YearningMeltyLove
	Grenades(2)=YearningMeltyLove
	Grenades(3)=YearningMeltyLove
	Grenades(4)=YearningMeltyLove
	Grenades(5)=YearningPlague
	Grenades(6)=YearningHellfire
	Grenades(7)=YearningBlasty
	Grenades(8)=YearningShockatron
	Grenades(9)=YearningPlasmad
}
