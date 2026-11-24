class X2DLCInfo_CoarsePortalCapture extends X2DownloadableContentInfo;

struct PortalRoster
{
    var XComGameState_AIReinforcementSpawner Spawner;
    var array<name> Units;
};

var private transient array<PortalRoster> PendingRosters;

static function bool IsFortressPortal(name Bucket)
{
    switch (Bucket)
    {
        case 'LIST_FinalShowdown_T1RNF':
        case 'LIST_FinalShowdown_T2RNF':
        case 'LIST_FinalShowdown_T3RNF':
        case 'LIST_FinalShowdown_PurgeTeam':
        case 'LIST_FinalShowdown_AvatarTeam':
        case 'LIST_FinalShowdown_DualAvatarTeam':
            return true;
    }
    return false;
}

static function PostReinforcementCreation(out name EncounterName, out PodSpawnInfo Encounter, int ForceLevel, int AlertLevel, optional XComGameState_BaseObject SourceObject, optional XComGameState_BaseObject ReinforcementState)
{
    local XComGameState_BattleData Battle;
    local XComGameState_AIReinforcementSpawner Spawner;
    local X2DLCInfo_CoarsePortalCapture Storage;
    local PortalRoster Roster;

    Battle = XComGameState_BattleData(SourceObject);
    Spawner = XComGameState_AIReinforcementSpawner(ReinforcementState);
    if (Battle == none || Spawner == none || !Spawner.bKismetInitiatedReinforcements
        || Battle.MapData.ActiveMission.sType != "GP_FortressShowdown_LW"
        || Encounter.SelectedCharacterTemplateNames.Length == 0)
    {
        return;
    }

    // SelectPodAtLocation operates on the new state. The callback also receives the
    // original spawner, which still has the requested bucket if native code resolved a variant.
    if (IsFortressPortal(Spawner.SpawnInfo.EncounterID) || IsFortressPortal(EncounterName))
    {
        Roster.Spawner = Spawner;
        Roster.Units = Encounter.SelectedCharacterTemplateNames;
        Storage = GetStorage();
        Storage.PendingRosters.AddItem(Roster);
    }
}

static function RestoreRoster(out PodSpawnInfo Encounter, XComGameState_BaseObject ReinforcementState)
{
    local int Index;
    local X2DLCInfo_CoarsePortalCapture Storage;

    // The two hooks bracket the same synchronous spawner invocation, including nested spawns.
    Storage = GetStorage();
    for (Index = Storage.PendingRosters.Length - 1; Index >= 0; --Index)
    {
        if (Storage.PendingRosters[Index].Spawner == ReinforcementState)
        {
            Encounter.SelectedCharacterTemplateNames = Storage.PendingRosters[Index].Units;
            Storage.PendingRosters.Remove(Index, 1);
            return;
        }
    }
}

static private function X2DLCInfo_CoarsePortalCapture GetStorage()
{
    return X2DLCInfo_CoarsePortalCapture(class'XComEngine'.static.GetClassDefaultObject(class'X2DLCInfo_CoarsePortalCapture'));
}
