class UISL_CoarseTurnAudit extends UIScreenListener config(CoarseTurnAudit);

struct WatchRecord
{
 var X2AIBTBehavior Node;
 var int Owner,Stamp;
 var byte Status;
};

var config int Scenario,Rounds;
var config array<name> Subjects,Observe,BlockedAbilities;
var XComPresentationLayerBase Pres;
var UITacticalQuickLaunch Quick;
var bool Travelling,Ready,Prepared,Sent,Finished;
var int Pulse,RoundNo,SeenTurn,LastFrame,LastSent,ActiveTeam,PhaseFrame;
var vector Origin;
var array<int> Actors,Soldiers,TrialCivilians;
var int LastGeoRound,MatrixStep,LastMatrixPulse,MoveAttempts;
var array<TTile> TestTiles;
var array<X2AIBTBehavior> Roots;
var array<WatchRecord> SeenNodes;


struct FieldCase
{
 var int Id;
 var int TurnCount;
 var string Units,Unavailable;
};
var array<FieldCase> Chain;
var config int ChainStep;
var config bool UsingChain;
var config bool Grouping;
var config int GroupNo;
var int GroupIndex;
var array<FieldCase> SameBattleA,SameBattleB,SameBattleC,SameBattleD;
var string LastSupportCodes;
function SetSameBattleCase()
{
 local FieldCase C;
 local array<string> Names;
 local string E;
 if(GroupNo==42)C=default.SameBattleA[GroupIndex];else if(GroupNo==49)C=default.SameBattleD[GroupIndex];else if(GroupNo==45)C=default.SameBattleC[GroupIndex];else C=default.SameBattleB[GroupIndex];
 class'UISL_CoarseTurnAudit'.default.Scenario=C.Id;class'UISL_CoarseTurnAudit'.default.Rounds=C.TurnCount;
 class'UISL_CoarseTurnAudit'.default.Subjects.Length=0;class'UISL_CoarseTurnAudit'.default.BlockedAbilities.Length=0;
 ParseStringIntoArray(C.Units,Names,"~",true);foreach Names(E)class'UISL_CoarseTurnAudit'.default.Subjects.AddItem(name(E));
 Names.Length=0;ParseStringIntoArray(C.Unavailable,Names,"~",true);foreach Names(E)class'UISL_CoarseTurnAudit'.default.BlockedAbilities.AddItem(name(E));
 LogInternal("R6|CASE|"$GroupIndex$"|"$default.Scenario$"|"$default.Rounds);
}
function NextSquad()
{
 local XComGameState S;
 local XComGameState_Unit U;
 local int Id,N;
 local vector RetiredAt;
 if(Pres==none)return;Pres.ClearTimer('Trace',self);
 S=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Retire the finished trial squad");
 foreach Actors(Id)
 {
  U=Unit(Id);if(U==none || !U.IsAlive())continue;
  U=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',Id));U.bDisabled=true;
  RetiredAt=PlaceFrom(U.TileLocation,32,25);U.SetVisibilityLocationFromVector(RetiredAt);++N;
 }
 if(N>0)`TACTICALRULES.SubmitGameState(S);else `XCOMHISTORY.CleanupPendingGameState(S);
 Actors.Length=0;Soldiers.Length=0;TrialCivilians.Length=0;Roots.Length=0;SeenNodes.Length=0;
 Ready=false;Prepared=false;Sent=false;Finished=false;Pulse=0;RoundNo=0;SeenTurn=0;PhaseFrame=0;LastSent=0;ActiveTeam=0;
 LastFrame=`XCOMHISTORY.GetCurrentHistoryIndex();LastGeoRound=0;MatrixStep=0;MoveAttempts=0;LastMatrixPulse=0;TestTiles.Length=0;
 LastSupportCodes="";++GroupIndex;SetSameBattleCase();
}

function SetChainCase()
{
 local FieldCase CaseData;
 local array<string> Names;
 local string E;
 if(default.Scenario==42||default.Scenario==43||default.Scenario==45||default.Scenario==49){Grouping=true;GroupNo=default.Scenario;GroupIndex=0;
  class'UISL_CoarseTurnAudit'.default.Grouping=true;
  class'UISL_CoarseTurnAudit'.default.GroupNo=GroupNo;SetSameBattleCase();return;}
 if(default.Scenario==6)class'UISL_CoarseTurnAudit'.default.UsingChain=true;
 if(!default.UsingChain || default.ChainStep>=default.Chain.Length)return;
 CaseData=default.Chain[default.ChainStep];
 class'UISL_CoarseTurnAudit'.default.Scenario=CaseData.Id;
 class'UISL_CoarseTurnAudit'.default.Rounds=CaseData.TurnCount;
 class'UISL_CoarseTurnAudit'.default.Subjects.Length=0;
 class'UISL_CoarseTurnAudit'.default.BlockedAbilities.Length=0;
 ParseStringIntoArray(CaseData.Units,Names,"~",true);
 foreach Names(E)class'UISL_CoarseTurnAudit'.default.Subjects.AddItem(name(E));
 Names.Length=0;
 ParseStringIntoArray(CaseData.Unavailable,Names,"~",true);
 foreach Names(E)class'UISL_CoarseTurnAudit'.default.BlockedAbilities.AddItem(name(E));
 LogInternal("R6|CASE|"$default.ChainStep$"|"$default.Scenario$"|"$default.Rounds);
}
function NextField()
{
 local XComPresentationLayerBase P;
 if(Pres==none)return;P=Pres;
 P.ClearTimer('FieldTick',self);P.ClearTimer('Trace',self);
 Actors.Length=0;Soldiers.Length=0;TrialCivilians.Length=0;Roots.Length=0;SeenNodes.Length=0;
 Ready=false;Prepared=false;Sent=false;Finished=false;Pulse=0;RoundNo=0;SeenTurn=0;PhaseFrame=0;LastSent=0;ActiveTeam=0;LastFrame=0;LastGeoRound=0;MatrixStep=0;MoveAttempts=0;LastMatrixPulse=0;TestTiles.Length=0;
 Pres=none;Quick=none;Travelling=true;
 P.ConsoleCommand("open TacticalQuickLaunch");
}
function CompleteField()
{
 Finished=true;LogInternal("R6|CASEFINISHED|"$default.Scenario$"|"$SeenTurn);
 if(Grouping)
 {
  if((GroupNo==42 && GroupIndex+1<default.SameBattleA.Length)||(GroupNo==43 && GroupIndex+1<default.SameBattleB.Length)||(GroupNo==45 && GroupIndex+1<default.SameBattleC.Length)||(GroupNo==49 && GroupIndex+1<default.SameBattleD.Length))
   Pres.SetTimer(1,false,'NextSquad',self);
  else LogInternal("R6|FINISHED|"$GroupNo$"|"$SeenTurn);
  return;
 }
 if(default.UsingChain && default.ChainStep+1<default.Chain.Length)
 {
  class'UISL_CoarseTurnAudit'.default.ChainStep++;
  Pres.SetTimer(1.2,false,'NextField',self);
 }
 else LogInternal("R6|FINISHED|"$default.Scenario$"|"$SeenTurn);
}

event OnInit(UIScreen Screen)
{
 if(UIShell(Screen)!=none && !Travelling){Pres=Screen.Movie.Pres;Pres.SetTimer(3,false,'OpenTrial',self);}
 if(UITacticalQuickLaunch(Screen)!=none){SetChainCase();Pres=Screen.Movie.Pres;Quick=UITacticalQuickLaunch(Screen);Pres.SetTimer(3,false,'StartField',self);}
 if(UITacticalHUD(Screen)!=none){if(default.Grouping && !Grouping){Grouping=true;GroupNo=default.GroupNo;GroupIndex=0;}Pres=Screen.Movie.Pres;Pres.SetTimer(1,true,'FieldTick',self);}
}
function OpenTrial()
{
 local XComPresentationLayerBase P;
 if(Travelling)return;
 Travelling=true;P=Pres;Pres=none;
 LogInternal("R6|SHELL|"$default.Scenario$"|"$default.Subjects.Length);
 P.ConsoleCommand("open TacticalQuickLaunch");
}
function StartField()
{
 local XComGameState_CampaignSettings C;
 local UITacticalQuickLaunch U;
 local int MissionIndex;
 if(Quick==none || Quick.Button_StartBattle==none)return;
 C=XComGameState_CampaignSettings(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings',true));
 if(C!=none){C.SetDifficulty(3);if(!C.IsSecondWaveOptionEnabled('ARFMPerilousYearning'))C.AddSecondWaveOption('ARFMPerilousYearning');}
 if(((default.Scenario>=13 && default.Scenario<=16)||default.Scenario==18) && Quick.TacticalMissionManager!=none && Quick.BattleDataState!=none)
 {
  MissionIndex=Quick.TacticalMissionManager.arrMissions.Find('sType',"Terror_LW");
  if(MissionIndex<=0)MissionIndex=Quick.TacticalMissionManager.arrMissions.Find('sType',"Terror");
  if(MissionIndex>0)Quick.BattleDataState.m_iMissionType=MissionIndex;
  LogInternal("R6|MISSION_PICK|"$MissionIndex);
 }
 if(Grouping && Quick.TacticalMissionManager!=none && Quick.BattleDataState!=none)
 {
  MissionIndex=Quick.TacticalMissionManager.arrMissions.Find('sType',"TroopManeuvers_LW");
  if(MissionIndex>0)Quick.BattleDataState.m_iMissionType=MissionIndex;
  LogInternal("R6|MISSION_PICK|"$MissionIndex);
 }
 if(default.Scenario==27 && Quick.TacticalMissionManager!=none && Quick.BattleDataState!=none)
 {
  MissionIndex=Quick.TacticalMissionManager.arrMissions.Find('sType',"AvengerDefense_LW");
  if(MissionIndex<=0)MissionIndex=Quick.TacticalMissionManager.arrMissions.Find('sType',"AvengerDefense");
  if(MissionIndex>0)Quick.BattleDataState.m_iMissionType=MissionIndex;
  LogInternal("R6|MISSION_PICK|"$MissionIndex);
 }
 U=Quick;Quick=none;Pres=none;U.Button_StartBattle.OnClickedDelegate(U.Button_StartBattle);
}
function XComGameState_Unit Unit(int Id,optional int Frame=-1)
{
 if(Id<=0)return none;
 return XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Id,,Frame));
}
function SetWorld()
{
 local XComGameState S;
 local XComGameState_CampaignSettings C;
 local XComGameState_HeadquartersAlien HQ;
 local XComGameState_HeadquartersXCom XHQ;
 S=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Legend TPY field conditions");
 C=XComGameState_CampaignSettings(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings',true));
 if(C==none)C=XComGameState_CampaignSettings(S.CreateNewStateObject(class'XComGameState_CampaignSettings'));
 else C=XComGameState_CampaignSettings(S.ModifyStateObject(class'XComGameState_CampaignSettings',C.ObjectID));
 C.SetDifficulty(3);if(!C.IsSecondWaveOptionEnabled('ARFMPerilousYearning'))C.AddSecondWaveOption('ARFMPerilousYearning');
 HQ=XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien',true));
 if(HQ==none)HQ=XComGameState_HeadquartersAlien(S.CreateNewStateObject(class'XComGameState_HeadquartersAlien'));
 else HQ=XComGameState_HeadquartersAlien(S.ModifyStateObject(class'XComGameState_HeadquartersAlien',HQ.ObjectID));
 HQ.ForceLevel=20;
 if(default.Scenario==31)
 {
  XHQ=XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom',true));
  if(XHQ==none)XHQ=XComGameState_HeadquartersXCom(S.CreateNewStateObject(class'XComGameState_HeadquartersXCom'));
  else XHQ=XComGameState_HeadquartersXCom(S.ModifyStateObject(class'XComGameState_HeadquartersXCom',XHQ.ObjectID));
  if(XHQ.TacticalGameplayTags.Find('ARFMDE_BloodTide')==INDEX_NONE)XHQ.TacticalGameplayTags.AddItem('ARFMDE_BloodTide');
  LogInternal("R6|TAG|ARFMDE_BloodTide|"$XHQ.TacticalGameplayTags.Find('ARFMDE_BloodTide'));
 }
 `TACTICALRULES.SubmitGameState(S);
}
function SpawnSubject(name K,int Index)
{
 local StateObjectReference Ref;
 local vector At;
 local XComGameState_Unit U;
 local XComWorldData W;
 local ETeam Team;
 if(class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate(K)==none){LogInternal("R6|NOTEMPLATE|"$K);return;}
 W=class'XComWorldData'.static.GetWorldData();At=Origin;
 At.X+=96*(3+(Index%3)*2);At.Y+=96*(Index/3*3+1-(Index%2)*3);
 At=W.FindClosestValidLocation(At,false,true);
 Team=(default.Scenario==60 && (K=='CommanderVIP' || K=='StasisSuitVIP'))?eTeam_Neutral:eTeam_Alien;
 Ref=`SPAWNMGR.CreateUnit(At,K,Team,false,,,,"",true);
 U=Unit(Ref.ObjectID);
 if(U==none || U.GetTeam()!=Team){LogInternal("R6|SPAWNFAIL|"$K);return;}
 Actors.AddItem(U.ObjectID);
 LogInternal("R6|SPAWN|"$K$"|"$U.GetMyTemplateName()$"|"$U.ObjectID$"|"$U.TileLocation.X$","$U.TileLocation.Y);
}
function EventListenerReturn WatchBloodMove(Object Data,Object Source,XComGameState State,Name EventID,Object Callback)
{
 local XComGameState_Unit M,U;
 local XComGameStateContext_Ability Context;
 local StateObjectReference Ref;
 local XComGameState_Ability A;
 local int ID;
 if(default.Scenario!=31||State==none)return ELR_NoInterrupt;
 M=XComGameState_Unit(Source);if(M==none||M.GetTeam()!=eTeam_XCom)return ELR_NoInterrupt;
 Context=XComGameStateContext_Ability(State.GetContext());if(Context==none)return ELR_NoInterrupt;
 foreach Actors(ID)
 {
  U=Unit(ID);if(U==none)continue;Ref=U.FindAbility('ARFMDEAbility_BloodTide');A=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));
  if(A!=none)LogInternal("R6|MOVEEND|"$State.HistoryIndex$"|"$M.ObjectID$"|"$Context.InputContext.AbilityTemplateName$"|"$ID$"|"$U.IsFlanked(,,,true)$"|"$A.iCharges$"|"$A.CanActivateAbilityForObserverEvent(U,U));
 }
 return ELR_NoInterrupt;
}
function InitBattle()
{
 local Object Listener;
 local XComGameState_Unit U,Leader;
 local XComGameState S;
 local int Id,I;
 local name K;
 foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit',U)
 {
  if(!U.IsAlive() || U.IsIncapacitated() || U.IsUnconscious() || U.IsBleedingOut() || U.IsUnitAffectedByEffectName(class'X2AbilityTemplateManager'.default.DazedName) || U.GetTeam()!=eTeam_XCom || XGUnit(U.GetVisualizer())==none || !U.IsSoldier())continue;
  if(Soldiers.Find(U.ObjectID)==INDEX_NONE)Soldiers.AddItem(U.ObjectID);
  if(Leader==none)Leader=U;
 }
 if(Leader==none)return;
 SetWorld();
 Ready=true;Origin=XGUnit(Leader.GetVisualizer()).Location;
 S=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Prepare living field targets");
 foreach Soldiers(Id)
 {
  U=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',Id));
  U.SetBaseMaxStat(eStat_HP,180);U.SetCurrentStat(eStat_HP,180);
  if(U.IsConcealed())U.SetIndividualConcealment(false,S);
 }
 `TACTICALRULES.SubmitGameState(S);
 LastFrame=`XCOMHISTORY.GetCurrentHistoryIndex();
 foreach default.Subjects(K,I)SpawnSubject(K,I);
 LogInternal("R6|MISSION|"$default.Scenario$"|"$`BATTLE.m_kDesc.MapData.ActiveMission.sType);
 MakeCivilians();
 if(default.Scenario==31){Listener=self;`XEVENTMGR.RegisterForEvent(Listener,'UnitMoveFinished',WatchBloodMove,ELD_OnStateSubmitted,1);}
 if(Grouping||(default.Scenario==16||default.Scenario==18)||default.Scenario==31||default.Scenario>=21||default.Scenario==5||default.Scenario==7||default.Scenario==8)QuietField();
 LogInternal("R6|WORLD|"$default.Scenario$"|"$`CampaignDifficultySetting$"|"$`SecondWaveEnabled('ARFMPerilousYearning')$"|"$Actors.Length$"|"$Soldiers.Length);
 Pres.SetTimer(0.22,true,'Trace',self);
}
function Cool(XComGameState S,XComGameState_Unit U,name K,int Turns)
{
 local StateObjectReference Ref;
 local XComGameState_Ability A;
 Ref=U.FindAbility(K);
 if(Ref.ObjectID<=0)return;
 A=XComGameState_Ability(S.GetGameStateForObjectID(Ref.ObjectID));
 if(A==none)A=XComGameState_Ability(S.ModifyStateObject(class'XComGameState_Ability',Ref.ObjectID));
 A.iCooldown=Turns;
}

function bool IsAdderCase(){return default.Scenario==24 || default.Scenario==59;}
function SetupBindPoints(XComGameState S)
{
 local XComGameState_Unit U;
 local XComGameState_Ability A;
 local X2AbilityCost C;
 local X2AbilityCost_ActionPoints AP;
 local name Kind;
 local int I;
 if(default.Scenario!=59 || RoundNo!=1 || Actors.Length==0)return;
 U=XComGameState_Unit(S.GetGameStateForObjectID(Actors[0]));
 if(U==none)return;
 A=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(U.FindAbility('MZ_FDAdderRushAndBind_Bind').ObjectID));
 if(A==none)return;
 foreach A.GetMyTemplate().AbilityCosts(C)
 {
  AP=X2AbilityCost_ActionPoints(C);if(AP==none)continue;
  foreach AP.AllowedTypes(Kind)
  {
   for(I=0;I<Max(AP.iNumPoints,1);++I)U.ActionPoints.AddItem(Kind);
   LogInternal("R6|BINDPOINTS|"$U.ObjectID$"|"$Kind$"|"$AP.iNumPoints);
  }
 }
}
function bool StageBind()
{
 local XComGameState_Unit U,T;
 local GameRulesCache_Unit Cache;
 local AvailableAction Act;
 local AvailableTarget Target;
 local StateObjectReference Ref;
 local int I;
 local bool OK;
 if(Actors.Length==0||Soldiers.Length==0)return false;
 U=Unit(Actors[0]);T=Unit(Soldiers[0]);if(U==none||T==none)return false;
 Ref=U.FindAbility('MZ_FDAdderRushAndBind_Bind');`TACTICALRULES.GetGameRulesCache_Unit(U.GetReference(),Cache);
 foreach Cache.AvailableActions(Act)
 {
  if(Act.AbilityObjectRef.ObjectID!=Ref.ObjectID)continue;
  LogInternal("R6|BINDREADY|"$U.ObjectID$"|"$T.ObjectID$"|"$Act.AvailableCode$"|"$Act.AvailableTargets.Length);
  if(Act.AvailableCode!='AA_Success')return false;
  foreach Act.AvailableTargets(Target,I)
   if(Target.PrimaryTarget.ObjectID==T.ObjectID)
   {
    OK=class'XComGameStateContext_Ability'.static.ActivateAbility(Act,I);
    LogInternal("R6|BINDINPUT|"$U.ObjectID$"|"$T.ObjectID$"|"$OK);
    return OK;
   }
 }
 return false;
}
function LogBoundState()
{
 local XComGameState_Unit U,V;
 local XComGameState_Effect E;
 local StateObjectReference R;
 local string Se,Te;
 if(default.Scenario!=59||Actors.Length==0||Soldiers.Length==0)return;
 U=Unit(Actors[0]);V=Unit(Soldiers[0]);if(U==none||V==none)return;
 foreach U.AffectedByEffects(R)
 {
  E=XComGameState_Effect(`XCOMHISTORY.GetGameStateForObjectID(R.ObjectID));if(E!=none && InStr(Caps(string(E.GetX2Effect().EffectName)),"BIND")>=0)Se$=E.GetX2Effect().EffectName$",";
 }
 foreach V.AffectedByEffects(R)
 {
  E=XComGameState_Effect(`XCOMHISTORY.GetGameStateForObjectID(R.ObjectID));if(E!=none && (InStr(Caps(string(E.GetX2Effect().EffectName)),"BIND")>=0||InStr(Caps(string(E.GetX2Effect().EffectName)),"BOUND")>=0))Te$=E.GetX2Effect().EffectName$",";
 }
 LogInternal("R6|BOUNDSTATE|"$RoundNo$"|"$SeenTurn$"|"$U.ObjectID$"|"$V.ObjectID$"|"$Se$"|"$Te$"|"$V.GetCurrentStat(eStat_HP));
}
function CheckBloodLevels()
{
 local XComGameState Temp;
 local XComGameState_Unit U,Copy;
 local XComGameState_Ability Ability;
 local X2Condition C;
 local X2Condition_UnitAlertStatus Alert;
 local int Level;
 if(default.Scenario!=31||Actors.Length==0)return;
 U=Unit(Actors[0]);if(U==none)return;
 Ability=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(U.FindAbility('ARFMDEAbility_BloodTide').ObjectID));if(Ability==none)return;
 foreach Ability.GetMyTemplate().AbilityShooterConditions(C)
 {
  Alert=X2Condition_UnitAlertStatus(C);if(Alert==none)continue;
  Temp=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Inspect red-alert threshold on unsaved copies");
  Copy=XComGameState_Unit(Temp.ModifyStateObject(class'XComGameState_Unit',U.ObjectID));
  for(Level=0;Level<=2;++Level)
  {
   Copy.SetCurrentStat(eStat_AlertLevel,Level);
   LogInternal("R6|BLOODLEVEL|"$U.ObjectID$"|"$Level$"|"$Copy.GetCurrentStat(eStat_AlertLevel)$"|"$Alert.MeetsCondition(Copy));
  }
  `XCOMHISTORY.CleanupPendingGameState(Temp);
 }
}
function bool TerrorCase(){return ((default.Scenario>=13 && default.Scenario<=16)||default.Scenario==18);}
function vector PlaceFrom(TTile Source,int DX,int DY)
{
 local XComWorldData W;
 local vector At;
 W=class'XComWorldData'.static.GetWorldData();
 if(Source.X>W.NumX/2)DX=-DX;
 if(Source.Y>W.NumY/2)DY=-DY;
 Source.X=Clamp(Source.X+DX,1,W.NumX-2);
 Source.Y=Clamp(Source.Y+DY,1,W.NumY-2);
 At=W.GetPositionFromTileCoordinates(Source);
 return W.FindClosestValidLocation(At,false,true);
}

function QuietField()
{
 local XComGameState S;
 local XComGameState_Unit U,V;
 local int N;
 local XGAIPlayer_Civilian CivilPlayer;
 S=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Hold unrelated combatants for the controlled turn");
 foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit',U)
 {
  if(!U.IsAlive() || U.bDisabled || U.GetTeam()==eTeam_XCom || Actors.Find(U.ObjectID)!=INDEX_NONE || TrialCivilians.Find(U.ObjectID)!=INDEX_NONE || U.IsCivilian() || XGUnit(U.GetVisualizer())==none)continue;
  V=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',U.ObjectID));
  V.bDisabled=true;++N;
 }
 if(N>0)`TACTICALRULES.SubmitGameState(S);else `XCOMHISTORY.CleanupPendingGameState(S);
 CivilPlayer=XGBattle_SP(`BATTLE).GetCivilianPlayer();if(CivilPlayer!=none)CivilPlayer.m_bSkipAI=(default.Scenario!=60);
 LogInternal("R6|ISOLATED|"$N);
}
function BuildVisibleTestTiles(XComGameState_Unit Source)
{
 local XComWorldData W;
 local TTile T,F,Used;
 local vector V;
 local int Ring,DX,DY;
 local bool Exists;
 W=class'XComWorldData'.static.GetWorldData();
 TestTiles.Length=0;
 for(Ring=1;Ring<=5 && TestTiles.Length<7;++Ring)
  for(DX=-Ring;DX<=Ring && TestTiles.Length<7;++DX)
   for(DY=-Ring;DY<=Ring && TestTiles.Length<7;++DY)
   {
    if(Abs(DX)!=Ring && Abs(DY)!=Ring)continue;
    T=Source.TileLocation;T.X+=DX;T.Y+=DY;
    V=W.GetPositionFromTileCoordinates(T);
    if(!W.GetFloorTileForPosition(V,F,true)||Abs(F.Z-Source.TileLocation.Z)>1||!W.CanUnitsEnterTile(F))continue;
    if(!class'X2TacticalVisibilityHelpers'.static.CanUnitSeeLocation(Source.ObjectID,F))continue;
    Exists=false;foreach TestTiles(Used)if(Used.X==F.X && Used.Y==F.Y && Used.Z==F.Z){Exists=true;break;}
    if(!Exists)TestTiles.AddItem(F);
   }
 LogInternal("R6|SLOTS|"$TestTiles.Length$"|"$Source.TileLocation.X$","$Source.TileLocation.Y);
}
function ApplyMatrixLayout(int Stage)
{
 local XComGameState S;
 local XComGameState_Unit U,V,Src;
 local TTile T,Chosen;
 local int J,Index,N,CloseCount;
 local vector At;
 Src=Unit(Actors[0]);if(Src==none)return;T=Src.TileLocation;
 BuildVisibleTestTiles(Src);
 if(TestTiles.Length<5)return;
 S=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Set counted civilians and one friendly");
 N=0;CloseCount=(Stage==1)?3:4;
 foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit',U)
 {
  if(!U.IsAlive() || U.ObjectID==Src.ObjectID || XGUnit(U.GetVisualizer())==none)continue;
  J=TrialCivilians.Find(U.ObjectID);Index=Actors.Find(U.ObjectID);
  V=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',U.ObjectID));
  if(J>=0 && J<CloseCount)
  {
   Chosen=TestTiles[J];At=`XWORLD.GetPositionFromTileCoordinates(Chosen);
   V.SetIndividualConcealment(false,S);
  }
  else if(Stage==3 && Index==1){Chosen=TestTiles[4];At=`XWORLD.GetPositionFromTileCoordinates(Chosen);}
  else
  {
   At=PlaceFrom(T,35+(N%7),27+((N/7)%6));++N;
   if(U.GetTeam()==eTeam_XCom||U.GetTeam()==eTeam_Resistance)V.SetIndividualConcealment(true,S);
  }
  V.SetVisibilityLocationFromVector(At);
 }
 `TACTICALRULES.SubmitGameState(S);
 LogInternal("R6|MATRIXLAYOUT|"$Stage$"|"$CloseCount);
}
function bool TryPlayerMove(XComTacticalController Ctrl)
{
 local XComGameState_Unit U,Threat;
 local XGUnit Pawn;
 local XComWorldData W;
 local TTile Dest;
 local array<TTile> Tiles;
 local int ID,DX,DY;
 local bool Ok,CanMove;
 local GameRulesCache_Unit Cache;
 local AvailableAction NativeMove;
 local StateObjectReference MoveRef;
 local float CoverAngle;
 local vector TargetAt,DestAt;
 if(Actors.Length==0)return false;
 W=class'XComWorldData'.static.GetWorldData();Threat=Unit(Actors[0]);TargetAt=W.GetPositionFromTileCoordinates(Threat.TileLocation);
 foreach Soldiers(ID)
 {
  U=Unit(ID);if(U==none||!U.IsAlive()||U.IsIncapacitated()||U.IsBleedingOut()||U.ActionPoints.Length==0)continue;
  MoveRef=U.FindAbility('StandardMove');CanMove=false;`TACTICALRULES.GetGameRulesCache_Unit(U.GetReference(),Cache);
  foreach Cache.AvailableActions(NativeMove)if(NativeMove.AbilityObjectRef.ObjectID==MoveRef.ObjectID && NativeMove.AvailableCode=='AA_Success'){CanMove=true;break;}
  if(!CanMove)continue;
  Pawn=XGUnit(U.GetVisualizer());if(Pawn==none)continue;
  for(DX=-2;DX<=2;++DX)for(DY=-2;DY<=2;++DY)
  {
   if(DX==0 && DY==0)continue;Dest=U.TileLocation;Dest.X+=DX;Dest.Y+=DY;
   if(!W.CanUnitsEnterTile(Dest)||!class'X2TacticalVisibilityHelpers'.static.CanUnitSeeLocation(Threat.ObjectID,Dest))continue;
   DestAt=W.GetPositionFromTileCoordinates(Dest);
   if(class'XComWorldData'.static.GetCoverTypeForTarget(DestAt,TargetAt,CoverAngle)!=CT_None)continue;
   Tiles.Length=0;
   if(!class'X2PathSolver'.static.BuildPath(U,U.TileLocation,Dest,Tiles,true)||Tiles.Length<2||Tiles.Length>6)continue;
   Ok=Ctrl.GameStateMoveUnitSingle(Pawn,Tiles,true);
   LogInternal("R6|PLAYMOVE|"$RoundNo$"|"$ID$"|"$Threat.ObjectID$"|"$Threat.IsFlanked(,,,true)$"|"$Dest.X$","$Dest.Y$"|"$Ok);
   if(Ok)return true;
  }
 }
 return false;
}
function MakeCivilians()
{
 local XComGameState_Unit Source;
 local int I,N;
 local StateObjectReference Ref;
 if(!TerrorCase()||Actors.Length==0)return;
 Source=Unit(Actors[0]);N=default.Scenario==13?3:4;
 for(I=0;I<N;++I)
 {
  Ref=`SPAWNMGR.CreateUnit(PlaceFrom(Source.TileLocation,2+I%2,1+I/2),'Civilian',eTeam_Neutral,false,,,,"",true);
  if(Unit(Ref.ObjectID)!=none){TrialCivilians.AddItem(Ref.ObjectID);LogInternal("R6|CIV|"$Ref.ObjectID$"|"$Unit(Ref.ObjectID).GetTeam());}
 }
}
function PositionField(XComGameState S)
{
 local XComGameState_Unit U,V,Src;
 local TTile T;
 local vector At;
 local int N,J,ID,Dist;
 if(((default.Scenario<11 || default.Scenario>16) && default.Scenario!=18) || Actors.Length==0)return;
 Src=Unit(Actors[0]);if(Src==none)return;T=Src.TileLocation;N=0;
 foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit',U)
 {
  if(!U.IsAlive() || U.ObjectID==Src.ObjectID || XGUnit(U.GetVisualizer())==none)continue;
  ID=U.ObjectID;J=TrialCivilians.Find(ID);
  V=XComGameState_Unit(S.GetGameStateForObjectID(ID));if(V==none)V=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',ID));
  if(J!=INDEX_NONE){At=PlaceFrom(T,2+J%2,1+J/2);}
  else if(default.Scenario==15 && Actors.Find(ID)>0){At=PlaceFrom(T,1,2);}
  else if(default.Scenario==11 && ID==Soldiers[0])
  {
   Dist=RoundNo==1?4:18;
   At=PlaceFrom(T,Dist,0);V.SetIndividualConcealment(false,S);
  }
  else
  {
   At=PlaceFrom(T,33+(N%7),26+((N/7)%8));++N;
   if(U.GetTeam()==eTeam_XCom || U.GetTeam()==eTeam_Resistance)V.SetIndividualConcealment(true,S);
  }
  V.SetVisibilityLocationFromVector(At);
 }
 LogInternal("R6|LAYOUT|"$default.Scenario$"|"$RoundNo$"|"$TrialCivilians.Length$"|"$Src.TileLocation.X$","$Src.TileLocation.Y$"|"$`BATTLE.m_kDesc.MapData.ActiveMission.sType);
}

function MeasureSelected(XGAIBehavior B,XComGameState_Unit U,name PointName)
{
 local XComGameState_Ability A;
 local StateObjectReference Ref;
 local AoETargetingInfo P;
 local AoETarget Chosen,SelfPoint;
 local TTile From,To;
 local XComGameState_Unit RequiredTarget;
 local array<TTile> Enemies,Danger,Empty;
 local int EnemyTop,AllyTop,EnemySelf,AllySelf,AbilityID;
 local float MinDist,MaxDist;
 local bool HasAbility,TopOK,SelfOK;
 local UnitValue Gate;
 local name Profile;
 if(U==none||B==none)return;
 if(U.GetMyTemplateName()=='AHWCyberdisc')Profile='AHWDeathBlossomProfile';
 else if(U.GetMyTemplateName()=='AHWAltar')Profile=TerrorCase()?'AHWAltarDesolateTerrorProfile':'AHWAltarDesolateProfile';
 else return;
 if(B.GetAbilityFromTargetingProfile(Profile,P)=='')return;
 Ref=U.FindAbility(P.Ability);
 A=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));if(A==none)return;
 HasAbility=B.HasAoEAbility(AbilityID,P.Ability);Chosen=B.TopAoETarget;SelfPoint=Chosen;
 SelfPoint.Location=B.m_kUnit.GetGameStateLocation();From=`XWORLD.GetTileCoordinatesFromPosition(SelfPoint.Location);To=`XWORLD.GetTileCoordinatesFromPosition(Chosen.Location);
 A.GetValidWeaponRange(MinDist,MaxDist);
 B.GetAllAoETargets(Enemies,P,RequiredTarget);B.GetAoEAvoidancePoints(Danger,P);
 B.TestAoEHits(Chosen.Location,A.GetMyTemplate().AbilityMultiTargetStyle,A,Enemies,Danger,EnemyTop,AllyTop,Empty);
 B.TestAoEHits(SelfPoint.Location,A.GetMyTemplate().AbilityMultiTargetStyle,A,Enemies,Danger,EnemySelf,AllySelf,Empty);
 TopOK=B.CanHitAoETarget(Ref.ObjectID,Chosen,P,true);SelfOK=B.CanHitAoETarget(Ref.ObjectID,SelfPoint,P,true);
 U.GetUnitValue(class'X2Ability_Gatekeeper'.default.OpenCloseAbilityName,Gate);
 LogInternal("R6|SELECTCHECK|"$RoundNo$"|"$SeenTurn$"|"$U.ObjectID$"|"$P.Ability$"|"$PointName$"|"$B.TopAoETarget.Ability$"|"$From.X$","$From.Y$","$From.Z$"|"$To.X$","$To.Y$","$To.Z$"|"$HasAbility$"|"$A.CanActivateAbility(U)$"|"$A.GetCooldownRemaining()$"|"$MaxDist$"|"$VSize(Chosen.Location-SelfPoint.Location)$"|"$EnemyTop$","$AllyTop$"|"$EnemySelf$","$AllySelf$"|"$TopOK$"|"$SelfOK$"|"$Gate.fValue$"|"$U.IsUnitAffectedByEffectName('GatekeeperClosedEffect'));
}
function MeasureRadius()
{
 local XComGameState_Unit U,Other,Req;
 local XComGameState_Ability A;
 local XGAIBehavior B;
 local XGUnit Pawn;
 local AoETargetingInfo P,Alt,Old;
 local AoETarget Point,SavedTop;
 local bool Found;
 local bool BeforeOk,AfterOk;
 local array<TTile> Enemies,Bad,BadAlt,Empty;
 local array<int> IDs;
 local StateObjectReference Ref,Hit;
 local vector Center;
 local int En,BadHits,OtherHits,AltHits,Civs,Foes,Allies;
 local AvailableTarget At;
 local name K;
 if(Actors.Length==0)return;
 U=Unit(Actors[0]);if(U==none||!U.IsAlive())return;
 if(U.GetMyTemplateName()=='AHWAltar')K=TerrorCase()?'AHWAltarDesolateTerrorProfile':'AHWAltarDesolateProfile';
 else if(U.GetMyTemplateName()=='AHWCyberdisc')K='AHWDeathBlossomProfile';else return;
 Pawn=XGUnit(U.GetVisualizer());if(Pawn==none||Pawn.m_kBehavior==none)return;
 B=Pawn.m_kBehavior;
 if(B.GetAbilityFromTargetingProfile(K,P)=='')return;
 Ref=U.FindAbility(P.Ability);A=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));if(A==none)return;
 Center=class'XComWorldData'.static.GetWorldData().GetPositionFromTileCoordinates(U.TileLocation);
 A.GatherAdditionalAbilityTargetsForLocation(Center,At);
 foreach At.AdditionalTargets(Hit)
 {
  Other=Unit(Hit.ObjectID);
  if(Other==none||!Other.IsAlive()||Other.ObjectID==U.ObjectID)continue;
  if(Other.GetTeam()==eTeam_Neutral)++Civs;else if(Other.GetTeam()==U.GetTeam())++Allies;else ++Foes;
 }
 if(default.Scenario==35 || default.Scenario==18)
 {
  SavedTop=B.TopAoETarget;Found=B.FindAoETarget(K);
  if(Found)MeasureSelected(B,U,'NativeSearchReplay');
  B.TopAoETarget=SavedTop;
 }
 B.GetAllAoETargets(Enemies,P,Req,IDs);
 B.GetAoEAvoidancePoints(Bad,P);
 B.TestAoEHits(Center,A.GetMyTemplate().AbilityMultiTargetStyle,A,Enemies,Bad,En,BadHits,Empty);
 Alt=P;Alt.bIgnoreSelfDamage=true;B.GetAoEAvoidancePoints(BadAlt,Alt);
 B.TestAoEHits(Center,A.GetMyTemplate().AbilityMultiTargetStyle,A,Enemies,BadAlt,OtherHits,AltHits,Empty);
 if((default.Scenario==16||default.Scenario==18))
 {
  Old=P;Old.bIgnoreSelfDamage=false;Point.Location=Center;
  BeforeOk=B.CanHitAoETarget(Ref.ObjectID,Point,Old,true);Point.Location=Center;
  AfterOk=B.CanHitAoETarget(Ref.ObjectID,Point,Alt,true);
  LogInternal("R6|PAIR|"$MatrixStep$"|"$RoundNo$"|"$SeenTurn$"|"$En$"|"$Civs$"|"$Allies$"|"$BeforeOk$"|"$AfterOk$"|"$P.bIgnoreSelfDamage);
 }
 LogInternal("R6|GEOM|"$RoundNo$"|"$SeenTurn$"|"$K$"|"$En$"|"$BadHits$"|"$AltHits$"|"$Civs$"|"$Foes$"|"$Allies$"|"$P.MinTargets$"|"$P.bIgnoreSelfDamage$"|"$U.GetCurrentStat(eStat_AlertLevel));
}


function PositionSupport(XComGameState S)
{
 local XComGameState_Unit U,V,Src;
 local TTile T;
 local vector At;
 local int I,J,N,Tgt,CloseCount;
 if(((default.Scenario<21 || default.Scenario>27) && default.Scenario!=31 && default.Scenario!=59 && (default.Scenario<35 || default.Scenario>41)) || Actors.Length==0)return;
 Src=Unit(Actors[0]);if(Src==none)return;T=Src.TileLocation;N=0;
 if((IsAdderCase() || default.Scenario==26 || (default.Scenario>=38&&default.Scenario<=40)) && RoundNo>1)return;
 CloseCount=2;if(default.Scenario==25 && RoundNo==1)CloseCount=1;
 foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit',U)
 {
  if(!U.IsAlive() || U.ObjectID==Src.ObjectID || XGUnit(U.GetVisualizer())==none)continue;
  I=Soldiers.Find(U.ObjectID);J=Actors.Find(U.ObjectID);
  V=XComGameState_Unit(S.GetGameStateForObjectID(U.ObjectID));if(V==none)V=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',U.ObjectID));
  if((default.Scenario==22 || (default.Scenario==23||default.Scenario==36||default.Scenario==37)) && J>0)
  {
   At=PlaceFrom(T,J==1?1:0,J==1?0:J-1);V.SetBaseMaxStat(eStat_HP,38);
   if(RoundNo==1 && J==Actors.Length-1)V.SetCurrentStat(eStat_HP,8);else V.SetCurrentStat(eStat_HP,38);
   LogInternal("R6|ALLY|"$RoundNo$"|"$U.ObjectID$"|"$V.GetCurrentStat(eStat_HP));
  }
  else if(I>=0 && I<CloseCount && default.Scenario!=22 && (default.Scenario!=23&&default.Scenario!=36&&default.Scenario!=37))
  {
   At=PlaceFrom(T,IsAdderCase()?1:2,I==0?0:1);V.SetIndividualConcealment(false,S);
  }
  else if(I==0 && (default.Scenario==22||(default.Scenario==23||default.Scenario==36||default.Scenario==37)))
  {At=PlaceFrom(T,8,1);V.SetIndividualConcealment(false,S);}
  else{At=PlaceFrom(T,32+N%5,25+((N/5)%7));++N;if(U.GetTeam()==eTeam_XCom||U.GetTeam()==eTeam_Resistance)V.SetIndividualConcealment(true,S);}
  V.SetVisibilityLocationFromVector(At);
 }
 Tgt=Actors[0];V=XComGameState_Unit(S.GetGameStateForObjectID(Tgt));
 if(default.Scenario==21 && RoundNo==2 && V!=none)Cool(S,V,'AHWCyberdiscDeathBlossom',5);
}


function SetupSpecial(XComGameState S)
{
 local XComGameState_Unit U,Leader,Follower;
 local XComGameState_AIGroup A,B;
 local X2AbilityTemplate Template;
 local XComGameState_Item Primary;
 local X2Effect E;
 local EffectAppliedData Data;
 local StateObjectReference Ref;
 local name Applied;
 local int I,ID;
 if(RoundNo!=1 || Actors.Length==0)return;
 if(default.Scenario==27)
 {
  U=XComGameState_Unit(S.GetGameStateForObjectID(Actors[0]));
  Template=class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('ChryssalidBurrow');
  if(U==none||Template==none||U.IsUnitAffectedByEffectName('Burrowed'))return;
  foreach Template.AbilityTargetEffects(E,I)
  {
   if(X2Effect_Burrowed(E)==none)continue;
   Ref=U.FindAbility('ChryssalidBurrow');
   Data.AbilityStateObjectRef=Ref;Data.PlayerStateObjectRef=U.ControllingPlayer;Data.SourceStateObjectRef=U.GetReference();Data.TargetStateObjectRef=U.GetReference();
   Data.EffectRef.LookupType=TELT_AbilityTargetEffects;Data.EffectRef.SourceTemplateName=Template.DataName;Data.EffectRef.TemplateEffectLookupArrayIndex=I;Data.EffectRef.ApplyOnTickIndex=INDEX_NONE;
   Applied=E.ApplyEffect(Data,U,S);
   LogInternal("R6|BURROWSETUP|"$U.ObjectID$"|"$Applied$"|"$U.IsUnitAffectedByEffectName('Burrowed'));
  }
 }
 if(default.Scenario==32)
 {
  Template=class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('Flush');if(Template==none)return;
  foreach Soldiers(ID)
  {
   U=Unit(ID);if(U==none || !U.IsAlive() || U.GetPrimaryWeapon()==none)continue;
   U=XComGameState_Unit(S.GetGameStateForObjectID(ID));if(U==none)U=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',ID));
   U.SetBaseMaxStat(eStat_Offense,160);U.SetCurrentStat(eStat_Offense,160);
   Primary=U.GetPrimaryWeapon();if(Primary==none)continue;
   Ref=U.FindAbility('Flush');if(Ref.ObjectID<=0)Ref=class'X2TacticalGameRuleset'.static.InitAbilityForUnit(Template,U,S,Primary.GetReference());
   LogInternal("R6|FLUSHEQUIP|"$ID$"|"$Ref.ObjectID);
  }
 }
 if(default.Scenario==28 && Actors.Length>=2)
 {
  Leader=Unit(Actors[0]);Follower=Unit(Actors[1]);A=Leader.GetGroupMembership();B=Follower.GetGroupMembership();
  if(A==none || B==none)return;
  if(A.ObjectID!=B.ObjectID)
  {
   A=XComGameState_AIGroup(S.ModifyStateObject(class'XComGameState_AIGroup',A.ObjectID));B=XComGameState_AIGroup(S.ModifyStateObject(class'XComGameState_AIGroup',B.ObjectID));
   B.RemoveUnitFromGroup(Follower.ObjectID,S);A.AddUnitToGroup(Follower.ObjectID,S);
  }
  LogInternal("R6|PODROLES|"$Leader.ObjectID$"|"$Follower.ObjectID$"|"$A.ObjectID$"|"$A.m_arrMembers.Length);
 }
}
function bool FireFlush()
{
 local GameRulesCache_Unit Cache;
 local AvailableAction Act;
 local AvailableTarget T;
 local XComGameState_Unit U,Threat;
 local StateObjectReference Ref;
 local int ID,Index,Enemy;
 local bool Ok;
 if(Actors.Length<1)return false;
 Enemy=(RoundNo-1)%Actors.Length;Threat=Unit(Actors[Enemy]);if(Threat==none)return false;
 foreach Soldiers(ID)
 {
  U=Unit(ID);if(U==none||!U.IsAlive())continue;Ref=U.FindAbility('Flush');if(Ref.ObjectID<=0)continue;
  `TACTICALRULES.GetGameRulesCache_Unit(U.GetReference(),Cache);
  foreach Cache.AvailableActions(Act)
  {
   if(Act.AbilityObjectRef.ObjectID!=Ref.ObjectID)continue;
   LogInternal("R6|FLUSHVALID|"$RoundNo$"|"$U.ObjectID$"|"$Threat.ObjectID$"|"$U.IsConcealed()$"|"$Act.AvailableCode$"|"$Act.AvailableTargets.Length);
   if(Act.AvailableCode!='AA_Success')continue;
   foreach Act.AvailableTargets(T,Index)
    if(T.PrimaryTarget.ObjectID==Threat.ObjectID)
    {
     Ok=class'XComGameStateContext_Ability'.static.ActivateAbility(Act,Index);
     LogInternal("R6|FLUSHINPUT|"$RoundNo$"|"$ID$"|"$Threat.ObjectID$"|"$Ok);if(Ok)return true;
    }
  }
 }
 return false;
}

function PositionMeleeSubject(XComGameState S)
{
 local XComGameState_Unit U,T,V;
 local XComGameState_Player Pl;
 local XComWorldData W;
 local TTile A,B;
 local vector AV,BV;
 local int Ring,DX,DY,Z,I;
 if((default.Scenario<38 || default.Scenario>41) && !IsAdderCase())return;
 if(RoundNo!=1 || Actors.Length==0 || Soldiers.Length==0)return;
 U=Unit(Actors[0]);W=`XWORLD;
 Pl=XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(Unit(Soldiers[0]).ControllingPlayer.ObjectID));if(Pl!=none)Pl.SetSquadConcealmentNewGameState(false,S);
 T=XComGameState_Unit(S.GetGameStateForObjectID(Soldiers[0]));if(T==none)T=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',Soldiers[0]));
 V=XComGameState_Unit(S.GetGameStateForObjectID(U.ObjectID));if(V==none)V=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',U.ObjectID));
 for(Ring=0;Ring<=12;++Ring)for(DX=-Ring;DX<=Ring;++DX)for(DY=-Ring;DY<=Ring;++DY)
 {
  if(Abs(DX)!=Ring&&Abs(DY)!=Ring)continue;
  A=U.TileLocation;A.X+=DX;A.Y+=DY;if(A.X<1||A.Y<1||A.X>=W.NumX-1||A.Y>=W.NumY-1)continue;
  for(Z=0;Z<16;++Z)
  {
   A.Z=Z;if(!W.IsFloorTileAndValidDestination(A,U)||!W.CanUnitsEnterTile(A))continue;
   AV=W.GetPositionFromTileCoordinates(A);
   for(I=0;I<4;++I)
   {
    B=A;if(I==0)++B.X;else if(I==1)--B.X;else if(I==2)++B.Y;else --B.Y;
    if(!W.IsFloorTileAndValidDestination(B,T)||!W.CanUnitsEnterTile(B)||W.IsAdjacentTileBlocked(A,B))continue;
    BV=W.GetPositionFromTileCoordinates(B);if(!W.IsAdjacentTileVisible(AV,BV))continue;
    V.SetVisibilityLocationFromVector(AV);T.SetVisibilityLocationFromVector(BV);T.SetIndividualConcealment(false,S);
    LogInternal("R6|MELEEPLACED|"$default.Scenario$"|"$U.ObjectID$"|"$T.ObjectID$"|"$A.X$","$A.Y$","$A.Z$"|"$B.X$","$B.Y$","$B.Z);
    return;
   }
  }
 }
 LogInternal("R6|NOMELEESLOT|"$default.Scenario$"|"$U.ObjectID);
}
function SetShootingLane(XComGameState S)
{
 local XComGameState_Unit U,T,V;
 local XComGameState_Player Pl;
 local XComWorldData W;
 local int I,N,DX,DY,Ring,Start,End;
 local float Angle;
 local vector A,B;
 local TTile F,Tile,Chosen;
 local bool Found;
 if(default.Scenario<51 || default.Scenario>55 || Actors.Length==0 || Soldiers.Length==0)return;
 U=Unit(Actors[0]);W=`XWORLD;if(U==none)return;
 Pl=XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(Unit(Soldiers[0]).ControllingPlayer.ObjectID));if(Pl!=none)Pl.SetSquadConcealmentNewGameState(false,S);
 N=0;Start=default.Scenario==52?13:4;End=Start+4;B=W.GetPositionFromTileCoordinates(U.TileLocation);
 for(Ring=Start;Ring<=End&&!Found;++Ring)for(DX=-Ring;DX<=Ring&&!Found;++DX)for(DY=-Ring;DY<=Ring&&!Found;++DY)
 {
  if(Abs(DX)!=Ring && Abs(DY)!=Ring)continue;
  Tile=U.TileLocation;Tile.X+=DX;Tile.Y+=DY;A=W.GetPositionFromTileCoordinates(Tile);
  if(!W.GetFloorTileForPosition(A,F,true)||Abs(F.Z-U.TileLocation.Z)>1||!W.CanUnitsEnterTile(F))continue;
  if(!class'X2TacticalVisibilityHelpers'.static.CanUnitSeeLocation(U.ObjectID,F))continue;
  A=W.GetPositionFromTileCoordinates(F);
  if(class'XComWorldData'.static.GetCoverTypeForTarget(A,B,Angle)!=CT_None)continue;
  Chosen=F;Found=true;
 }
 if(!Found){BuildVisibleTestTiles(U);if(TestTiles.Length==0)return;Chosen=TestTiles[0];}
 foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit',T)
 {
  if(!T.IsAlive() || Actors.Find(T.ObjectID)!=INDEX_NONE || XGUnit(T.GetVisualizer())==none)continue;
  V=XComGameState_Unit(S.GetGameStateForObjectID(T.ObjectID));if(V==none)V=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',T.ObjectID));
  I=Soldiers.Find(T.ObjectID);
  if(I==0)
  {
   A=W.GetPositionFromTileCoordinates(Chosen);V.SetIndividualConcealment(false,S);
   V.SetCurrentStat(eStat_HP,(default.Scenario==52&&RoundNo==1)?1:150);
  }
  else{A=PlaceFrom(U.TileLocation,35+N%5,28+N/5);++N;if(T.GetTeam()==eTeam_XCom)V.SetIndividualConcealment(true,S);}
  V.SetVisibilityLocationFromVector(A);
 }
 U=XComGameState_Unit(S.GetGameStateForObjectID(Actors[0]));
 if(U!=none&&default.Scenario==52){U.SetBaseMaxStat(eStat_Offense,140);U.SetCurrentStat(eStat_Offense,140);}
 if(U!=none && default.Scenario==53 && RoundNo>1)Cool(S,U,'LightningHands',4);
 LogInternal("R6|SHOTLANE|"$default.Scenario$"|"$RoundNo$"|"$Actors[0]$"|"$Soldiers[0]$"|"$Chosen.X$","$Chosen.Y$","$Chosen.Z$"|"$Found);
}
function SetupVIPThreat(XComGameState S)
{
 local XComGameState_Unit V,First;
 local int J,ID;
 local vector Pos;
 local TTile Floor;
 if(default.Scenario!=60||Actors.Length<3)return;
 First=Unit(Actors[0]);BuildVisibleTestTiles(First);if(TestTiles.Length<4)return;
 for(J=1;J<3;++J)
 {
  ID=Actors[J];V=XComGameState_Unit(S.GetGameStateForObjectID(ID));if(V==none)V=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',ID));
  Floor=TestTiles[J+1];Pos=`XWORLD.GetPositionFromTileCoordinates(Floor);V.SetVisibilityLocationFromVector(Pos);
  if(J==2)V.SetIndividualConcealment(false,S);
 }
}
function SetupNivenSight(XComGameState S)
{
 local XComGameState_Unit N,V;
 local XComGameState_Player Pl;
 local TTile At;
 local vector Pos;
 local int J,ID;
 if(default.Scenario!=23 && default.Scenario!=36 && default.Scenario!=37)return;
 if(Actors.Length<3 || Soldiers.Length<1)return;
 N=Unit(Actors[0]);if(N==none)return;
 BuildVisibleTestTiles(N);if(TestTiles.Length<3)return;
 Pl=XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(Unit(Soldiers[0]).ControllingPlayer.ObjectID));
 if(Pl!=none)Pl.SetSquadConcealmentNewGameState(false,S);
 for(J=0;J<3;++J)
 {
  ID=J<2?Actors[J+1]:Soldiers[0];
  V=XComGameState_Unit(S.GetGameStateForObjectID(ID));
  if(V==none)V=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',ID));
  At=TestTiles[J];Pos=`XWORLD.GetPositionFromTileCoordinates(At);V.SetVisibilityLocationFromVector(Pos);
  if(J==2)V.SetIndividualConcealment(false,S);
 }
}
function SetupPlayerSight(XComGameState S)
{
 local XComGameState_Unit T,U;
 local XComGameState_Player PlayerState;
 local TTile Tile;
 local vector At;
 local int I,Index;
 if(default.Scenario!=32 && default.Scenario!=31 && default.Scenario!=29 && default.Scenario!=27 && default.Scenario!=60)return;
 if(Actors.Length==0 || Soldiers.Length==0)return;
 Index=default.Scenario==32?(RoundNo-1)%Actors.Length:0;T=Unit(Actors[Index]);if(T==none)return;
 BuildVisibleTestTiles(T);if(TestTiles.Length<1)return;
 PlayerState=XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(Unit(Soldiers[0]).ControllingPlayer.ObjectID));
 if(PlayerState!=none)PlayerState.SetSquadConcealmentNewGameState(false,S);
 for(I=0;I<Min(3,Min(Soldiers.Length,TestTiles.Length));++I)
 {
  U=XComGameState_Unit(S.GetGameStateForObjectID(Soldiers[I]));if(U==none)U=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',Soldiers[I]));
  if(U.IsIncapacitated()||!U.IsAlive())continue;
  Tile=TestTiles[I];At=`XWORLD.GetPositionFromTileCoordinates(Tile);
  U.SetVisibilityLocationFromVector(At);U.SetIndividualConcealment(false,S);
 }
}
function ApplyLastPoint(XComGameState S,XComGameState_Unit U)
{
 local X2AbilityTemplate T;
 local X2Effect E;
 local EffectAppliedData D;
 local name Code;
 local int I;
 if(U.IsUnitAffectedByEffectName('CoarseAuditLastPoint'))return;
 T=class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('CoarseAuditLastPointFixture');
 if(T==none)return;
 foreach T.AbilityTargetEffects(E,I){if(X2Effect_TurnStartActionPoints(E)!=none)break;}
 if(X2Effect_TurnStartActionPoints(E)==none)return;
 D.SourceStateObjectRef=U.GetReference();D.TargetStateObjectRef=U.GetReference();D.PlayerStateObjectRef=U.ControllingPlayer;
 D.EffectRef.LookupType=TELT_AbilityTargetEffects;D.EffectRef.SourceTemplateName=T.DataName;D.EffectRef.TemplateEffectLookupArrayIndex=I;D.EffectRef.ApplyOnTickIndex=INDEX_NONE;
 Code=E.ApplyEffect(D,U,S);LogInternal("R6|APFIXTURE|"$RoundNo$"|"$U.ObjectID$"|"$Code$"|"$U.IsUnitAffectedByEffectName('CoarseAuditLastPoint'));
}
function MercyStatus(XComGameState S)
{
 local XComGameState_Unit U;
 local X2AbilityTemplate T;
 local X2Effect E,AppliedEffect;
 local X2Effect_Persistent P;
 local EffectAppliedData D;
 local name Wanted,Code,Ability;
 local int I;
 if(default.Scenario<38||default.Scenario>40||RoundNo!=1||Soldiers.Length==0)return;
 U=XComGameState_Unit(S.GetGameStateForObjectID(Soldiers[0]));
 if(U==none)U=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',Soldiers[0]));
 D.SourceStateObjectRef=U.GetReference();D.TargetStateObjectRef=U.GetReference();D.PlayerStateObjectRef=U.ControllingPlayer;
 if(default.Scenario==38)
 {
  D.EffectRef.LookupType=TELT_BleedOutEffect;
  AppliedEffect=class'X2StatusEffects'.static.CreateBleedingOutStatusEffect();
  U.SetCurrentStat(eStat_HP,1);Wanted=class'X2StatusEffects'.default.BleedingOutName;Code=AppliedEffect.ApplyEffect(D,U,S);
 }
 else
 {
  if(default.Scenario==39){Wanted=class'X2AbilityTemplateManager'.default.DazedName;Ability='CoarseAuditDazedFixture';D.SourceStateObjectRef=Unit(Actors[0]).GetReference();D.PlayerStateObjectRef=Unit(Actors[0]).ControllingPlayer;}
  else{Wanted=class'X2StatusEffects'.default.UnconsciousName;Ability='Knockout';}
  T=class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(Ability);
  if(T!=none)foreach T.AbilityTargetEffects(E,I)
  {
   P=X2Effect_Persistent(E);if(P==none||P.EffectName!=Wanted)continue;
   D.EffectRef.LookupType=TELT_AbilityTargetEffects;D.EffectRef.SourceTemplateName=T.DataName;D.EffectRef.TemplateEffectLookupArrayIndex=I;D.EffectRef.ApplyOnTickIndex=INDEX_NONE;
   AppliedEffect=E;Code=AppliedEffect.ApplyEffect(D,U,S);break;
  }
 }
 LogInternal("R6|MERCYSTATE|"$default.Scenario$"|"$U.ObjectID$"|"$Wanted$"|"$Code$"|"$U.IsUnitAffectedByEffectName(Wanted));
}
function ObserveMercy(XGAIBehavior B,XComGameState_Unit U)
{
 local XComGameState_Ability AB;
 local XComGameState_Unit M;
 local X2AbilityTemplate Tpl;
 local X2Condition C;
 local StateObjectReference R;
 local string Cond,Detail,Role;
 local int N,H;
 local X2AIBTBehavior Node,Root;
 local AvailableAction First,Second;
 local name Original,Unified;
 local string Codes;
 local AvailableTarget T;
 local string TA,TB;
 if(default.Scenario<38||default.Scenario>41||Actors.Length==0||Actors[0]!=U.ObjectID)return;
 First=B.FindAbilityByName('AHWShinanimMercy1');Second=B.FindAbilityByName('AHWShinanimMercy2');
 if(First.AbilityObjectRef.ObjectID<=0||Second.AbilityObjectRef.ObjectID<=0)return;
 Original='AHWShinanimMercy1';Unified='AHWShinanimMercy2';
 class'X2AIBTLeafNode'.static.ResolveAbilityNameWithUnit(Original,B);
 class'X2AIBTLeafNode'.static.ResolveAbilityNameWithUnit(Unified,B);
 foreach First.AvailableTargets(T)TA$=T.PrimaryTarget.ObjectID$",";
 foreach Second.AvailableTargets(T)TB$=T.PrimaryTarget.ObjectID$",";
 Codes=string(First.AvailableCode)$"|"$TA$"|"$Second.AvailableCode$"|"$TB$"|"$Original$"|"$Unified;
 if(LastSupportCodes!=Codes)
 {
  LastSupportCodes=Codes;LogInternal("R6|MERCYCHOICE|"$RoundNo$"|"$SeenTurn$"|"$U.ObjectID$"|"$Codes);
  if(Soldiers.Length==0)return;M=Unit(Soldiers[0]);if(M==none)return;
  Root=B.m_kBehaviorTree;
  if(Root!=none)for(N=0;N<=Root.GetSubNodeCount();++N)
  {
   Node=Root.GetNodeIndex(N);if(Node==none)continue;
   if(InStr(Caps(string(Node.m_strName)),"CHARACTERROOT")>=0 || Node.m_strName=='AHWArchonMagnaRedAlert' || Node.m_strName=='TryAHWShinanimMercy' || Node.m_strName=='GenericRedAlert')Role$=Node.m_strName$",";
  }
  LogInternal("R6|MERCYROUTE|"$RoundNo$"|"$U.ObjectID$"|"$U.GetMyTemplate().CharacterGroupName$"|"$B.GetBehaviorTreeRoot()$"|"$Role);
  for(H=0;H<2;++H)
  {
   R=H==0?First.AbilityObjectRef:Second.AbilityObjectRef;AB=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(R.ObjectID));if(AB==none)continue;
   Tpl=AB.GetMyTemplate();Cond="";
   foreach Tpl.AbilityTargetConditions(C) Cond$=C.Class.Name$":"$C.MeetsCondition(M)$"/"$C.MeetsConditionWithSource(M,U)$"/"$C.AbilityMeetsCondition(AB,M)$",";
   Detail=M.ObjectID$"|"$M.TileLocation.X$","$M.TileLocation.Y$","$M.TileLocation.Z$"|"$M.IsBleedingOut()$","$M.IsUnitAffectedByEffectName(class'X2AbilityTemplateManager'.default.DazedName)$","$M.IsUnconscious()$"|"$Tpl.AbilityTargetStyle.ValidatePrimaryTargetOption(AB,U,M)$"|"$Tpl.CheckTargetConditions(AB,U,M)$"|"$Cond;
   LogInternal("R6|MERCYVALID|"$RoundNo$"|"$U.ObjectID$"|"$AB.GetMyTemplateName()$"|"$Detail);
  }
 }
}
function FieldStatus(XComGameState S)
{
 local XComGameState_Unit Target;
 local X2Effect E;
 local EffectAppliedData EP;
 local name Code;
 if(default.Scenario!=26 || RoundNo!=1 || Soldiers.Length==0)return;
 Target=XComGameState_Unit(S.GetGameStateForObjectID(Soldiers[0]));
 if(Target==none)Target=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',Soldiers[0]));
 EP.PlayerStateObjectRef=Target.ControllingPlayer;EP.SourceStateObjectRef=Target.GetReference();EP.TargetStateObjectRef=Target.GetReference();EP.EffectRef.LookupType=TELT_BleedOutEffect;
 E=class'X2StatusEffects'.static.CreateBleedingOutStatusEffect();Code=E.ApplyEffect(EP,Target,S);LogInternal("R6|BLEEDOUT|"$Target.ObjectID$"|"$Code);
}
function PrepareRound()
{
 local XComGameState S;
 local XComGameState_Unit U;
 local XComGameState_AIGroup G;
 local int Id,J;
 local name K;
 S=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Prepare logged field conditions");
 foreach Actors(Id,J)
 {
  U=Unit(Id);if(U==none||!U.IsAlive())continue;
  U=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',Id));
  U.SetCurrentStat(eStat_AlertLevel,TerrorCase()?0:2);
  if(default.Scenario==18 && RoundNo>1 && J==0 && U.IsUnitAffectedByEffectName('AHWDawnbreaker'))
  {
   ApplyLastPoint(S,U);
  }
  if(default.Scenario==3 && U.GetMyTemplateName()=='AdvTrooperM1' && J==Actors.Length-1 && RoundNo==1)
  {U.SetBaseMaxStat(eStat_HP,30);U.SetCurrentStat(eStat_HP,7);}
  foreach default.BlockedAbilities(K)Cool(S,U,K,6);
 }
 PositionField(S);PositionSupport(S);PositionMeleeSubject(S);FieldStatus(S);MercyStatus(S);SetupSpecial(S);SetupBindPoints(S);SetupNivenSight(S);SetupPlayerSight(S);SetupVIPThreat(S);SetShootingLane(S);
 `TACTICALRULES.SubmitGameState(S);
 if(RoundNo==1 && !TerrorCase())foreach Actors(Id)
 {
  U=Unit(Id);if(U==none||!U.IsAlive())continue;G=U.GetGroupMembership();
  if(G!=none && !G.bProcessedScamper)G.InitiateReflexMoveActivate(Unit(Soldiers[0]),eAC_SeesSpottedUnit);
 }
 Prepared=true;
}
function Inspect()
{
 local array<XComGameState_Unit> Playable;
 local XGUnit Viewer;
 local int Id;
 local XComGameState_Unit U;
 local XComGameState_Ability A;
 local StateObjectReference Ref,TRef;
 local array<StateObjectReference> Visible;
 local array<AvailableTarget> Targets;
 local AvailableTarget Target;
 local string Vis,Tg;
 local name K;
 foreach Actors(Id)
 {
  U=Unit(Id);if(U==none||!U.IsAlive())continue;
  if(default.Scenario==27 || default.Scenario==29 || default.Scenario==60)
  {
   Viewer=XGUnit(U.GetVisualizer());Playable.Length=0;
   if(Viewer!=none && Viewer.m_kBehavior!=none && Viewer.m_kPlayer!=none)
   {
    Viewer.m_kPlayer.GetPlayableUnits(Playable);
    LogInternal("R6|FIELDROOT|"$RoundNo$"|"$Id$"|"$U.GetMyTemplateName()$"|"$U.GetMyTemplate().strBehaviorTree$"|"$Viewer.m_kBehavior.GetBehaviorTreeRoot()$"|"$Playable.Length$"|"$U.IsUnitAffectedByEffectName('Burrowed'));
   }
  }
  Visible.Length=0;Vis="";
  class'X2TacticalVisibilityHelpers'.static.GetAllVisibleEnemyUnitsForUnit(Id,Visible);
  foreach Visible(TRef)Vis$=TRef.ObjectID$",";
  LogInternal("R6|BEFORE|"$RoundNo$"|"$Id$"|"$U.GetMyTemplateName()$"|"$U.TileLocation.X$","$U.TileLocation.Y$"|"$U.GetCurrentStat(eStat_HP)$"|"$U.IsUnitAffectedByEffectName('AHWDawnbreaker')$"|"$Vis);
  foreach U.Abilities(Ref)
  {
   A=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));if(A==none)continue;K=A.GetMyTemplateName();
   if(default.Observe.Find(K)==INDEX_NONE)continue;
   Targets.Length=0;Tg="";A.GatherAbilityTargets(Targets);
   foreach Targets(Target)Tg$=Target.PrimaryTarget.ObjectID$",";
   LogInternal("R6|AVAIL|"$RoundNo$"|"$Id$"|"$K$"|"$A.GetCooldownRemaining()$"|"$A.CanActivateAbility(U)$"|"$Tg);
  }
 }
}

function ObserveNiven(XGAIBehavior B,XComGameState_Unit U)
{
 local AvailableAction Guard,Heal;
 local AvailableTarget Target;
 local name Grade,Original,Unified;
 local string TargetIDs,Codes;
 if((default.Scenario!=36&&default.Scenario!=37)||U==none||B==none ||Actors.Length==0||U.ObjectID!=Actors[0])return;
 Grade=default.Scenario==36?'AHWNivenHeal':'AHWNivenHealM2';
 Guard=B.FindAbilityByName('AHWNivenProtect');Heal=B.FindAbilityByName(Grade);
 if(Guard.AbilityObjectRef.ObjectID<=0||Heal.AbilityObjectRef.ObjectID<=0)return;
 if(Heal.AvailableCode!='AA_Success' && Guard.AvailableCode!='AA_Success')return;
 Original='AHWNivenProtect';Unified='CoarseNivenRestore';
 class'X2AIBTLeafNode'.static.ResolveAbilityNameWithUnit(Original,B);
 class'X2AIBTLeafNode'.static.ResolveAbilityNameWithUnit(Unified,B);
 foreach Heal.AvailableTargets(Target)TargetIDs$=Target.PrimaryTarget.ObjectID$",";
 Codes=string(Guard.AvailableCode)$"|"$Grade$"|"$Heal.AvailableCode$"|"$TargetIDs$"|"$Original$"|"$Unified;
 if(LastSupportCodes!=Codes){LastSupportCodes=Codes;LogInternal("R6|SUPPORTCHOICE|"$RoundNo$"|"$SeenTurn$"|"$U.ObjectID$"|"$Codes);}
}
function Trace()
{
 local X2AIBTBehavior Root,Node;
 local XComGameState_Unit U;
 local XGUnit Pawn;
 local WatchRecord Rec;
 local int Id,J,I,N;
 if(!Ready||Finished)return;
 foreach Actors(Id,J)
 {
  U=Unit(Id);if(U==none||!U.IsAlive())continue;Pawn=XGUnit(U.GetVisualizer());
  if(Pawn==none||Pawn.m_kBehavior==none)continue;ObserveNiven(Pawn.m_kBehavior,U);ObserveMercy(Pawn.m_kBehavior,U);Root=Pawn.m_kBehavior.m_kBehaviorTree;if(Root==none)continue;
  if(Roots.Length<=J)Roots.Length=J+1;
  if(Roots[J]!=Root)
  {
   Roots[J]=Root;for(I=SeenNodes.Length-1;I>=0;--I){if(SeenNodes[I].Owner==Id)SeenNodes.Remove(I,1);}
   N=Root.GetSubNodeCount();
   for(I=0;I<=N;++I){Node=Root.GetNodeIndex(I);if(Node!=none && default.Observe.Find(Node.m_strName)!=INDEX_NONE){Rec.Node=Node;Rec.Owner=Id;Rec.Stamp=-1;Rec.Status=255;SeenNodes.AddItem(Rec);}}
  }
 }
 for(I=0;I<SeenNodes.Length;++I)
 {
  Node=SeenNodes[I].Node;if(Node.m_iLastInit<=0)continue;
  if(SeenNodes[I].Stamp!=Node.m_iLastInit || SeenNodes[I].Status!=Node.m_eStatus)
  {SeenNodes[I].Stamp=Node.m_iLastInit;SeenNodes[I].Status=Node.m_eStatus;
   if((Node.m_eStatus==BTS_FAILURE||Node.m_eStatus==BTS_SUCCESS) && (Node.m_strName=='SelectAoETarget-AHWDeathBlossomProfile'||Node.m_strName=='SelectAoETarget-AHWAltarDesolateTerrorProfile'||Node.m_strName=='SelectAoETarget-AHWAltarDesolateProfile'))
   {
    U=Unit(SeenNodes[I].Owner);if(U!=none){Pawn=XGUnit(U.GetVisualizer());if(Pawn!=none)MeasureSelected(Pawn.m_kBehavior,U,Node.m_strName);}
   }
   LogInternal("R6|NODE|"$RoundNo$"|"$SeenNodes[I].Owner$"|"$Node.m_iLastInit$"|"$Node.m_strName$"|"$Node.m_eStatus);}
 }
}

function CastLocations(XComGameStateContext_Ability AC,XComGameState_Unit Before,XComGameState_Unit After,int Frame)
{
 local XComGameState_Ability A;
 local X2AbilityMultiTargetStyle Style;
 local vector V,Center;
 local TTile L,ST;
 local array<TTile> Area,UnitTiles;
 local StateObjectReference Ref;
 local XComGameState_Unit T0,T1;
 local int N,Outside,Inside;
 local bool InRadius;
 local string Locations;
 if(AC.InputContext.AbilityTemplateName!='AHWAltarDesolate' && AC.InputContext.AbilityTemplateName!='AHWCyberdiscDeathBlossom')return;
 A=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AC.InputContext.AbilityRef.ObjectID,,Frame-1));if(A==none)return;
 Style=A.GetMyTemplate().AbilityMultiTargetStyle;Center=`XWORLD.GetPositionFromTileCoordinates(After.TileLocation);
 Style.GetValidTilesForLocation(A,Center,Area);
 foreach AC.InputContext.TargetLocations(V){L=`XWORLD.GetTileCoordinatesFromPosition(V);Locations$=L.X$","$L.Y$","$L.Z$"/";}
 foreach AC.InputContext.MultiTargets(Ref)
 {
  T0=Unit(Ref.ObjectID,Frame-1);T1=Unit(Ref.ObjectID,Frame);
  if(T0==none||T1==none||T0.GetCurrentStat(eStat_HP)<=T1.GetCurrentStat(eStat_HP))continue;
  ++N;UnitTiles.Length=0;T0.GetVisibilityLocation(UnitTiles);InRadius=false;
  foreach UnitTiles(ST)if(class'Helpers'.static.FindTileInList(ST,Area)!=INDEX_NONE){InRadius=true;break;}
  if(InRadius)++Inside;else ++Outside;
 }
 LogInternal("R6|CASTLOC|"$Frame$"|"$AC.InputContext.AbilityTemplateName$"|"$Before.TileLocation.X$","$Before.TileLocation.Y$"|"$After.TileLocation.X$","$After.TileLocation.Y$"|"$Locations$"|"$N$"|"$Inside$"|"$Outside);
}
function History()
{
 local XComGameState F;
 local XComGameStateContext_Ability AC;
 local XComGameStateContext_TacticalGameRule Rule;
 local XComGameState_Player Pl;
 local XComGameState_Unit U0,U1,T0,T1;
 local XComGameState_Ability OldAbility,NewAbility;
 local int I,H,Id;
 local StateObjectReference Rf;
 local string Hits;
 H=`XCOMHISTORY.GetCurrentHistoryIndex();
 for(I=LastFrame+1;I<=H;++I)
 {
  F=`XCOMHISTORY.GetGameStateFromHistory(I);if(F==none)continue;
  if(default.Scenario==60 && Actors.Length>=2)
  {
   foreach Actors(Id)
   {
    U1=XComGameState_Unit(F.GetGameStateForObjectID(Id));
    if(U1==none || U1.GetTeam()!=eTeam_Neutral)continue;
    U0=Unit(Id,I-1);if(U0==none)continue;
    if(U0.ActionPoints.Length!=U1.ActionPoints.Length||U0.TileLocation.X!=U1.TileLocation.X||U0.TileLocation.Y!=U1.TileLocation.Y)
     LogInternal("R6|VIPSTEP|"$I$"|"$ActiveTeam$"|"$Id$"|"$U1.GetMyTemplateName()$"|"$U0.ActionPoints.Length$","$U1.ActionPoints.Length$"|"$U0.TileLocation.X$","$U0.TileLocation.Y$">"$U1.TileLocation.X$","$U1.TileLocation.Y$"|"$F.GetContext().SummaryString());
   }
  }
  if(default.Scenario==18 && Actors.Length>0)
  {
   U1=XComGameState_Unit(F.GetGameStateForObjectID(Actors[0]));
   if(U1!=none && U1.IsUnitAffectedByEffectName('CoarseAuditLastPoint'))
   {
    U0=Unit(Actors[0],I-1);
    if(U0!=none && U0.ActionPoints.Length!=U1.ActionPoints.Length)LogInternal("R6|APCHANGE|"$I$"|"$RoundNo$"|"$Actors[0]$"|"$U0.ActionPoints.Length$","$U1.ActionPoints.Length$"|"$U1.GetCurrentStat(eStat_AlertLevel));
   }
  }
  Rule=XComGameStateContext_TacticalGameRule(F.GetContext());
  if(Rule!=none && Rule.GameRuleType==eGameRule_PlayerTurnBegin)
  {
   Pl=XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(Rule.PlayerRef.ObjectID,,I));
   if(Pl!=none){ActiveTeam=int(Pl.TeamFlag);if(Pl.TeamFlag==eTeam_Alien)++SeenTurn;}
   LogInternal("R6|TEAM|"$I$"|"$SeenTurn$"|"$ActiveTeam);
  }
  AC=XComGameStateContext_Ability(F.GetContext());if(AC==none||AC.InterruptionStatus==eInterruptionStatus_Interrupt)continue;
  Id=AC.InputContext.SourceObject.ObjectID;
  if(default.Scenario==31 && Soldiers.Find(Id)!=INDEX_NONE && AC.InputContext.AbilityTemplateName=='StandardMove')
   LogInternal("R6|XCOMMOVED|"$I$"|"$Id$"|"$SeenTurn);
  if(default.Scenario==32 && AC.InputContext.AbilityTemplateName=='Flush')LogInternal("R6|XCOMFLUSH|"$I$"|"$Id$"|"$AC.InputContext.PrimaryTarget.ObjectID$"|"$AC.ResultContext.HitResult);
  if((AC.InputContext.AbilityTemplateName=='AHWShinanimMercy1'||AC.InputContext.AbilityTemplateName=='AHWShinanimMercy2') && AC.InputContext.PrimaryTarget.ObjectID>0)
  {
   T0=Unit(AC.InputContext.PrimaryTarget.ObjectID,I-1);T1=Unit(AC.InputContext.PrimaryTarget.ObjectID,I);
   if(T0!=none&&T1!=none)LogInternal("R6|MERCYEND|"$I$"|"$Id$"|"$T1.ObjectID$"|"$T0.IsDead()$","$T1.IsDead()$"|"$T0.GetCurrentStat(eStat_HP)$","$T1.GetCurrentStat(eStat_HP));
  }
  if(AC.InputContext.AbilityTemplateName=='ARFMDEAbility_BloodTide')
  {
   OldAbility=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AC.InputContext.AbilityRef.ObjectID,,I-1));
   NewAbility=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AC.InputContext.AbilityRef.ObjectID,,I));
   if(OldAbility!=none&&NewAbility!=none)LogInternal("R6|BLOODACT|"$I$"|"$Id$"|"$AC.InputContext.PrimaryTarget.ObjectID$"|"$OldAbility.iCharges$","$NewAbility.iCharges);
  }
  if(Actors.Find(Id)==INDEX_NONE)continue;
  U0=Unit(Id,I-1);U1=Unit(Id,I);if(U0==none||U1==none)continue;
  T0=Unit(AC.InputContext.PrimaryTarget.ObjectID,I-1);T1=Unit(AC.InputContext.PrimaryTarget.ObjectID,I);
  Hits="";foreach AC.InputContext.MultiTargets(Rf){Hits$=Rf.ObjectID$",";}
  LogInternal("R6|ACT|"$I$"|"$RoundNo$"|"$SeenTurn$"|"$ActiveTeam$"|"$Id$"|"$U1.GetMyTemplateName()$"|"$AC.InputContext.AbilityTemplateName$"|"$AC.InputContext.PrimaryTarget.ObjectID$"|"$Hits$"|"$U0.ActionPoints.Length$","$U1.ActionPoints.Length$"|"$U0.TileLocation.X$","$U0.TileLocation.Y$">"$U1.TileLocation.X$","$U1.TileLocation.Y$"|"$U0.IsUnitAffectedByEffectName('AHWDawnbreaker')$","$U1.IsUnitAffectedByEffectName('AHWDawnbreaker')$"|"$AC.ResultContext.HitResult);
  CastLocations(AC,U0,U1,I);
  if(default.Scenario==27 && (AC.InputContext.AbilityTemplateName=='ChryssalidUnburrow'||AC.InputContext.AbilityTemplateName=='AHWMagnalidUnburrow'))
   LogInternal("R6|UNBURROW|"$I$"|"$Id$"|"$U0.IsUnitAffectedByEffectName('Burrowed')$"|"$U1.IsUnitAffectedByEffectName('Burrowed'));
  if(T0!=none && T1!=none && default.Observe.Find(AC.InputContext.AbilityTemplateName)!=INDEX_NONE)
   LogInternal("R6|TARGET|"$I$"|"$T1.ObjectID$"|"$T1.GetMyTemplateName()$"|"$T0.GetCurrentStat(eStat_HP)$","$T1.GetCurrentStat(eStat_HP));
  if(default.Observe.Find(AC.InputContext.AbilityTemplateName)!=INDEX_NONE)foreach AC.InputContext.MultiTargets(Rf)
  {
   T0=Unit(Rf.ObjectID,I-1);T1=Unit(Rf.ObjectID,I);
   if(T0!=none && T1!=none)LogInternal("R6|MULTI|"$I$"|"$Rf.ObjectID$"|"$T1.GetMyTemplateName()$"|"$T0.GetCurrentStat(eStat_HP)$","$T1.GetCurrentStat(eStat_HP));
  }
 }
 LastFrame=H;
}
function FieldTick()
{
 local XComTacticalController Ctrl;
 local XComGameState_Player Pl;
 local StateObjectReference PR;
 local bool Ok;
 if(Finished || Pres==none)return;
 Ctrl=XComTacticalController(Pres.WorldInfo.GetALocalPlayerController());if(Ctrl==none)return;
 ++Pulse;
 if(Pulse==10)Ctrl.ConsoleCommand("slomo 4");
 if(Pulse%60==0 && `TACTICALRULES.WaitingForVisualizer())
 {
  LogInternal("R6|VISCLEAR|"$default.Scenario$"|"$RoundNo$"|"$Pulse$"|"$`XCOMVISUALIZATIONMGR.GetCurrenHistoryFrame()$"|"$`XCOMHISTORY.GetCurrentHistoryIndex());
  `XCOMVISUALIZATIONMGR.DebugClearHangs();
 }
 if(!Ready && Pulse>=6)
 {
  if(`TACTICALRULES.GetStateName()!='TurnPhase_UnitActions' || (Pulse<46 && `TACTICALRULES.WaitingForVisualizer()))return;
  InitBattle();return;
 }
 if(!Ready)return;
 if(`TACTICALRULES.GetStateName()=='EndTacticalGame'){History();LogInternal("R6|MISSIONEND|"$default.Scenario$"|"$SeenTurn);CompleteField();return;}
 History();PR=`TACTICALRULES.GetCachedUnitActionPlayerRef();Pl=XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(PR.ObjectID));
 if(Pulse<12||Pl==none||Pl.TeamFlag!=eTeam_XCom)return;
 if(RoundNo==0 || (SeenTurn>=RoundNo && Pulse>PhaseFrame+4))
 {
  if(SeenTurn>=default.Rounds){CompleteField();return;}
  ++RoundNo;Prepared=false;Sent=false;LastSent=0;PhaseFrame=Pulse;
 }
 if(!Prepared){PrepareRound();return;}
 if(Sent && SeenTurn<RoundNo && LastSent>0 && Pulse>=LastSent+70)Sent=false;
 if(!Sent && Pulse>=PhaseFrame+4 && (LastSent==0 || Pulse>=LastSent+9))
 {
  if((default.Scenario==16||default.Scenario==18) && RoundNo==1 && MatrixStep<5)
  {
   if(Pulse<LastMatrixPulse+3)return;
   if(MatrixStep>0)MeasureRadius();++MatrixStep;LastMatrixPulse=Pulse;
   if(MatrixStep<=4){ApplyMatrixLayout(MatrixStep);return;}
  }
  if((default.Scenario==16||default.Scenario==18) && RoundNo>1 && LastGeoRound!=RoundNo && LastMatrixPulse!=PhaseFrame)
  {ApplyMatrixLayout(4);LastMatrixPulse=PhaseFrame;return;}
  if(default.Scenario==32 && MoveAttempts<RoundNo)
  {
   if(FireFlush()){++MoveAttempts;return;}
   if(Pulse<PhaseFrame+16)return;++MoveAttempts;
  }
  if(default.Scenario==31 && MoveAttempts<RoundNo)
  {
   if(RoundNo==1 && MoveAttempts==0)CheckBloodLevels();
   if(TryPlayerMove(Ctrl)){++MoveAttempts;return;}
   if(Pulse<PhaseFrame+13)return;
   ++MoveAttempts;LogInternal("R6|NOLEGALMOVE|"$RoundNo);
  }
  if(default.Scenario==59 && RoundNo==1 && MoveAttempts==0)
  {
   if(StageBind()){++MoveAttempts;return;}
   if(Pulse<PhaseFrame+17)return;++MoveAttempts;
  }
  if(default.Scenario==59)LogBoundState();
  if(LastGeoRound!=RoundNo){MeasureRadius();LastGeoRound=RoundNo;}
  if(`TACTICALRULES.WaitingForVisualizer() && Pulse<PhaseFrame+19)return;
  Inspect();
  if(`TACTICALRULES.GetLocalClientPlayerObjectID()==PR.ObjectID)Ok=Ctrl.PerformEndTurn(ePlayerEndTurnType_PlayerInput);
  else Ok=Ctrl.PerformEndTurn(ePlayerEndTurnType_AI);
  LastSent=Pulse;Sent=true;LogInternal("R6|END|"$RoundNo$"|"$Ok$"|"$PR.ObjectID);
 }
}

defaultproperties
{
 SameBattleD(0)=(Id=31,TurnCount=3,Units="AdvTrooperM2~AdvTrooperM3",Unavailable="")
 SameBattleD(1)=(Id=59,TurnCount=3,Units="FrostAdder_M3",Unavailable="MZ_FDFrostSpit~StandardShot")
 SameBattleD(2)=(Id=38,TurnCount=1,Units="AHWArchonMagnaM4",Unavailable="AHWArchonReaction")
 SameBattleD(3)=(Id=36,TurnCount=1,Units="AHWNiven~AdvTrooperM1~AdvTrooperM3",Unavailable="AHWNivenProtect~AHWNivenSuppression")
 SameBattleD(4)=(Id=60,TurnCount=2,Units="CommanderVIP~StasisSuitVIP~AdvTrooperM2",Unavailable="")
 SameBattleA(0)=(Id=21,TurnCount=3,Units="AHWCyberdisc",Unavailable="AHWCyberdiscOpen~AHWCyberdiscBombard~AHWCyberdiscBombardT2~AHWCyberdiscStandardShot")
 SameBattleA(1)=(Id=22,TurnCount=2,Units="AdvMedicM2~AdvTrooperM1~AdvTrooperM2~AdvTrooperM3",Unavailable="F_DisablingShot~ThrowGrenade")
 SameBattleA(2)=(Id=23,TurnCount=2,Units="AHWNiven~AdvTrooperM2~AHWOutsiderMagna",Unavailable="AHWNivenSuppression")
 SameBattleA(3)=(Id=24,TurnCount=3,Units="FrostAdder_M3",Unavailable="MZ_FDFrostSpit~StandardShot")
 SameBattleA(4)=(Id=25,TurnCount=3,Units="AdventCryoPriestM3",Unavailable="AdvPurifierFlamethrower~IceThrower~MZIcethrower~Flamethrower~MZ_CryoLaunch")
 SameBattleA(5)=(Id=26,TurnCount=2,Units="AHWArchonMagnaM1",Unavailable="AHWArchonReaction")
 SameBattleA(6)=(Id=31,TurnCount=2,Units="AdvTrooperM2~AdvTrooperM3",Unavailable="")
 SameBattleB(0)=(Id=35,TurnCount=2,Units="AHWCyberdisc",Unavailable="AHWCyberdiscOpen~AHWCyberdiscBombard~AHWCyberdiscBombardT2~AHWCyberdiscStandardShot~AHWCyberdiscOverwatch")
 SameBattleB(1)=(Id=36,TurnCount=2,Units="AHWNiven~AdvTrooperM1~AdvTrooperM3",Unavailable="AHWNivenProtect~AHWNivenSuppression")
 SameBattleB(2)=(Id=37,TurnCount=2,Units="AHWNivenT3~AdvTrooperM1~AdvTrooperM3",Unavailable="AHWNivenProtect~AHWNivenSuppression")
 SameBattleB(3)=(Id=38,TurnCount=1,Units="AHWArchonMagnaM4",Unavailable="AHWArchonReaction")
 SameBattleB(4)=(Id=39,TurnCount=1,Units="AHWArchonMagnaM4",Unavailable="AHWArchonReaction")
 SameBattleB(5)=(Id=40,TurnCount=1,Units="AHWArchonMagnaM4",Unavailable="AHWArchonReaction")
 SameBattleB(6)=(Id=11,TurnCount=3,Units="AHWAltar",Unavailable="Teleport~AHWOutsiderTeleport~AHWAltarMassBuff~AHWLegateMassBuff")
 SameBattleB(7)=(Id=12,TurnCount=2,Units="AHWAltar",Unavailable="Teleport~AHWOutsiderTeleport~AHWAltarMassBuff~AHWLegateMassBuff")
 SameBattleB(8)=(Id=5,TurnCount=2,Units="AdventSniperM3~AdventDuelistM3~AdvWraithM3~ARFMAdvOutriderM3",Unavailable="")
 SameBattleB(9)=(Id=6,TurnCount=3,Units="FrostAdder_M3~FrostTech_M3~FrostCobra~FrostHardliner_M3~FrostHitman_M3",Unavailable="")
 SameBattleC(0)=(Id=36,TurnCount=2,Units="AHWNiven~AdvTrooperM1~AdvTrooperM3",Unavailable="AHWNivenProtect~AHWNivenSuppression")
 SameBattleC(1)=(Id=37,TurnCount=2,Units="AHWNivenT3~AdvTrooperM1~AdvTrooperM3",Unavailable="AHWNivenProtect~AHWNivenSuppression")
 SameBattleC(2)=(Id=35,TurnCount=2,Units="AHWCyberdisc",Unavailable="AHWCyberdiscOpen~AHWCyberdiscBombard~AHWCyberdiscBombardT2~AHWCyberdiscStandardShot~AHWCyberdiscOverwatch")
 SameBattleB(10)=(Id=29,TurnCount=2,Units="HostileVIPCivilian",Unavailable="")
 SameBattleB(11)=(Id=32,TurnCount=2,Units="ChosenWarlockM3~AdvTrooperM2",Unavailable="")
 SameBattleB(12)=(Id=28,TurnCount=2,Units="AHWOutsiderMagna~AHWOutsiderMagna~FrostLancer_M1~FrostLancer_M2~FrostLancer_M3",Unavailable="")
 SameBattleC(3)=(Id=38,TurnCount=1,Units="AHWArchonMagnaM4",Unavailable="AHWArchonReaction")
 SameBattleC(4)=(Id=39,TurnCount=1,Units="AHWArchonMagnaM4",Unavailable="AHWArchonReaction")
 SameBattleC(5)=(Id=40,TurnCount=1,Units="AHWArchonMagnaM4",Unavailable="AHWArchonReaction")
 SameBattleC(6)=(Id=41,TurnCount=1,Units="AHWArchonMagnaM4",Unavailable="AHWArchonReaction")
 SameBattleC(7)=(Id=24,TurnCount=3,Units="FrostAdder_M3",Unavailable="SlugShot~FrostSpit~StandardShot~PoisonSpit")
 SameBattleC(8)=(Id=31,TurnCount=2,Units="AdvTrooperM2~AdvTrooperM3",Unavailable="")
 SameBattleC(9)=(Id=32,TurnCount=2,Units="ChosenWarlockM3~AdvTrooperM2",Unavailable="")
 SameBattleC(10)=(Id=29,TurnCount=1,Units="HostileVIPCivilian",Unavailable="")
 Chain(0)=(Id=14,TurnCount=4,Units="AHWAltar",Unavailable="Teleport~AHWOutsiderTeleport~AHWAltarMassBuff~AHWLegateMassBuff")
 Chain(1)=(Id=13,TurnCount=4,Units="AHWAltar",Unavailable="Teleport~AHWOutsiderTeleport~AHWAltarMassBuff~AHWLegateMassBuff")
 Chain(2)=(Id=15,TurnCount=4,Units="AHWAltar~AdvTrooperM1",Unavailable="Teleport~AHWOutsiderTeleport~AHWAltarMassBuff~AHWLegateMassBuff")
 Chain(3)=(Id=11,TurnCount=4,Units="AHWAltar",Unavailable="Teleport~AHWOutsiderTeleport~AHWAltarMassBuff~AHWLegateMassBuff")
 Chain(4)=(Id=12,TurnCount=2,Units="AHWAltar",Unavailable="Teleport~AHWOutsiderTeleport~AHWAltarMassBuff~AHWLegateMassBuff")
 Chain(5)=(Id=21,TurnCount=3,Units="AHWCyberdisc",Unavailable="AHWCyberdiscOpen~AHWCyberdiscBombard~AHWCyberdiscBombardT2~AHWCyberdiscStandardShot")
 Chain(6)=(Id=22,TurnCount=2,Units="AdvMedicM2~AdvTrooperM1~AdvTrooperM2~AdvTrooperM3",Unavailable="F_DisablingShot~ThrowGrenade")
 Chain(7)=(Id=23,TurnCount=2,Units="AHWNiven~AdvTrooperM2~AHWOutsiderMagna",Unavailable="AHWNivenSuppression")
 Chain(8)=(Id=24,TurnCount=3,Units="FrostAdder_M3",Unavailable="MZ_FDFrostSpit~StandardShot")
 Chain(9)=(Id=25,TurnCount=3,Units="AdventCryoPriestM3",Unavailable="AdvPurifierFlamethrower~IceThrower~MZIcethrower~Flamethrower~MZ_CryoLaunch")
 Chain(10)=(Id=6,TurnCount=3,Units="FrostAdder_M3~FrostTech_M3~FrostCobra~FrostHardliner_M3~FrostHitman_M3",Unavailable="")
 Chain(11)=(Id=26,TurnCount=2,Units="AHWArchonMagnaM1",Unavailable="AHWArchonReaction")
 Chain(12)=(Id=27,TurnCount=2,Units="AHWChryssalidMagna~AdvTrooperM1",Unavailable="")
 Chain(13)=(Id=29,TurnCount=2,Units="HostileVIPCivilian",Unavailable="")

}
