class UISL_CoarseTurnAudit extends UIScreenListener config(CoarseTurnAudit);

struct WatchRecord
{
 var X2AIBTBehavior Node;
 var int Owner,Stamp;
 var byte Status;
};

var array<name> RosterChecks;
var config int Scenario,Rounds;
var config bool DumpTables,DeepTables;
var int FlushShooter,FlushTarget,EightExtra,GemIndex,GemPhase;
var array<name> GemCaps,GemKeys,GemLodes,GemDeds,PyTags,PyCards,PyBaseTags;
struct PySubject { var int UnitID; var string Base; var array<int> Options; };
var array<PySubject> PyUnits;
var int PyPhase,PySolo,PyWho,PyFirst,PySecond;
var array<name> PyBaseUnlocks;
var bool PyPreviouslyUsedUnlock;
var X2AbilityTrigger_EventListener SavedSectoidListener;
var int LootDropID,LootItemID;
var X2CharacterTemplate SavedTemplate;
var string SavedTree;
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
 if(EightExtra>0)Actors.AddItem(EightExtra);EightExtra=0;
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
 LastSupportCodes="";GemPhase=0;PyPhase=0;++GroupIndex;SetSameBattleCase();
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
  if(MissionIndex>=0)Quick.BattleDataState.m_iMissionType=MissionIndex;
  LogInternal("R6|MISSION_PICK|"$MissionIndex);
 }
 if(Grouping && Quick.TacticalMissionManager!=none && Quick.BattleDataState!=none)
 {
  MissionIndex=Quick.TacticalMissionManager.arrMissions.Find('MissionName','RecoverExpedition');
  if(MissionIndex<0)MissionIndex=Quick.TacticalMissionManager.arrMissions.Find('MissionName','Recover_LW');
  if(MissionIndex<0)MissionIndex=Quick.TacticalMissionManager.arrMissions.Find('sType',"TroopManeuvers_LW");
  if(MissionIndex>=0)Quick.BattleDataState.m_iMissionType=MissionIndex;
  LogInternal("R6|MISSION_PICK|"$MissionIndex);
 }
 if(default.Scenario==27 && Quick.TacticalMissionManager!=none && Quick.BattleDataState!=none)
 {
  MissionIndex=Quick.TacticalMissionManager.arrMissions.Find('sType',"AvengerDefense_LW");
  if(MissionIndex<=0)MissionIndex=Quick.TacticalMissionManager.arrMissions.Find('sType',"AvengerDefense");
  if(MissionIndex>=0)Quick.BattleDataState.m_iMissionType=MissionIndex;
  LogInternal("R6|MISSION_PICK|"$MissionIndex);
 }
 if((default.Scenario==60 || default.Scenario==98 || default.Scenario==100) && Quick.TacticalMissionManager!=none)
 {
  MissionIndex=Quick.TacticalMissionManager.arrMissions.Find('MissionName',default.Scenario==98?'CompoundRescueOperative':'ExtractVIP_LW');
  if(MissionIndex>=0)Quick.BattleDataState.m_iMissionType=MissionIndex;
  LogInternal("R7|VIPMISSION|"$MissionIndex$"|"$Quick.TacticalMissionManager.arrMissions[MissionIndex].sType);
 }
 if(default.DumpTables)AuditTables(Quick.TacticalMissionManager);
 if(default.Scenario==27 || default.Scenario==98)AuditTaggedBuckets(Quick.TacticalMissionManager);
 if(default.DeepTables){AuditDetail(Quick.TacticalMissionManager);AuditStoryHooks(Quick.TacticalMissionManager);}
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
 HQ.ForceLevel=20;EightTags(S);GemWorld(S);PySamples(S);
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
 if(default.Scenario==27)
 {
  if(Origin.X<0)At.X+=96*21;else At.X-=96*21;
  if(Origin.Y<0)At.Y+=96*14;else At.Y-=96*14;
 }
 At.X+=96*(3+(Index%3)*2);At.Y+=96*(Index/3*3+1-(Index%2)*3);
 At=W.FindClosestValidLocation(At,false,true);
 Team=((default.Scenario==60 || default.Scenario==98 || default.Scenario==100) && (K=='CommanderVIP' || K=='StasisSuitVIP'))?eTeam_Neutral:eTeam_Alien;
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
 SetWorld();EightCatalog();
 if(default.Scenario==27 || default.Scenario==98)AuditStoryHooks(`TACTICALMISSIONMGR);
 if(default.Scenario==27 || default.Scenario==98)AuditFixedGroups(`TACTICALMISSIONMGR);
 if(!Grouping || GroupIndex==0)AuditPods();ObjectiveVIPs();
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
 if(default.Subjects.Length>0)SetDiagnosticRoot(default.Subjects[0]);
 foreach default.Subjects(K,I)SpawnSubject(K,I);EightSpawnExtra();
 LogInternal("R6|MISSION|"$default.Scenario$"|"$`BATTLE.m_kDesc.MapData.ActiveMission.sType);
 MakeCivilians();
 if(default.Scenario==31){Listener=self;`XEVENTMGR.RegisterForEvent(Listener,'UnitMoveFinished',WatchBloodMove,ELD_OnStateSubmitted,1);}
 if(Grouping||(default.Scenario==16||default.Scenario==18)||default.Scenario==31||default.Scenario>=21||default.Scenario==5||default.Scenario==7||default.Scenario==8)QuietField();
 LogInternal("R6|WORLD|"$default.Scenario$"|"$`CampaignDifficultySetting$"|"$`SecondWaveEnabled('ARFMPerilousYearning')$"|"$Actors.Length$"|"$Soldiers.Length);
 Pres.SetTimer(0.035,true,'Trace',self);
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

function bool IsAdderCase(){return default.Scenario==24 || default.Scenario==59 || default.Scenario==61;}
function SetupSingleBindEnemy(XComGameState S)
{
 local XComGameState_Unit T,V,First;
 local int ID,N;
 local vector Far;
 N=0;
 if(default.Scenario!=61||RoundNo!=1||Actors.Length==0||Soldiers.Length<1)return;
 First=Unit(Actors[0]);
 foreach Soldiers(ID)
 {
  if(ID==Soldiers[0])continue;T=Unit(ID);if(T==none)continue;
  V=XComGameState_Unit(S.GetGameStateForObjectID(ID));if(V==none)V=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',ID));
  Far=PlaceFrom(First.TileLocation,40+N%3,35+N/3);V.SetVisibilityLocationFromVector(Far);
  V.SetIndividualConcealment(true,S);++N;
 }
}
function InspectRush(XComGameStateContext_Ability AC,int Frame)
{
 local XComGameState_Unit U,T;
 local XComGameState_Ability Bind;
 local X2AbilityTemplate Rush,Tpl;
 local X2Effect E;
 local X2Effect_ImmediateAbilityActivation Next;
 local X2Condition C;
 local string List,Flags,AP;
 local name K;
 if(default.Scenario!=61 || AC.InputContext.AbilityTemplateName!='MZ_FDAdderRushAndBind')return;
 U=Unit(AC.InputContext.SourceObject.ObjectID,Frame);T=Unit(AC.InputContext.PrimaryTarget.ObjectID,Frame);
 if(U==none||T==none)return;
 Bind=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(U.FindAbility('MZ_FDAdderRushAndBind_Bind').ObjectID,,Frame));
 if(Bind==none)return;
 Rush=class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('MZ_FDAdderRushAndBind');
 foreach Rush.AbilityTargetEffects(E){Next=X2Effect_ImmediateAbilityActivation(E);if(Next!=none)Flags$="target:"$Next.AbilityName$","$Next.EffectTargetOnly$","$Next.ActivateAbilityOnTarget;}
 foreach Rush.AbilityShooterEffects(E){Next=X2Effect_ImmediateAbilityActivation(E);if(Next!=none)Flags$="shooter:"$Next.AbilityName$","$Next.EffectTargetOnly$","$Next.ActivateAbilityOnTarget;}
 Tpl=Bind.GetMyTemplate();foreach Tpl.AbilityTargetConditions(C)List$=C.Class.Name$":"$C.MeetsCondition(T)$"/"$C.MeetsConditionWithSource(T,U)$",";
 foreach U.ActionPoints(K)AP$=K$",";
 LogInternal("R6|RUSHNEXT|"$Frame$"|"$U.ObjectID$"|"$T.ObjectID$"|"$U.TileLocation.X$","$U.TileLocation.Y$","$U.TileLocation.Z$"|"$T.TileLocation.X$","$T.TileLocation.Y$","$T.TileLocation.Z$"|"$AP$"|"$Flags$"|"$Tpl.AbilityTargetStyle.ValidatePrimaryTargetOption(Bind,U,T)$"|"$Tpl.CheckTargetConditions(Bind,U,T)$"|"$List);
}
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
 if(!IsAdderCase()||Actors.Length==0||Soldiers.Length==0)return;
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
 if(default.Scenario==27 || default.Scenario==98 || default.Scenario==100)return;
 S=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Hold unrelated combatants for the controlled turn");
 foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit',U)
 {
  if(!U.IsAlive() || U.bDisabled || U.GetTeam()==eTeam_XCom || Actors.Find(U.ObjectID)!=INDEX_NONE || TrialCivilians.Find(U.ObjectID)!=INDEX_NONE || U.IsCivilian() || XGUnit(U.GetVisualizer())==none)continue;
  V=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',U.ObjectID));
  V.bDisabled=true;++N;
 }
 if(N>0)`TACTICALRULES.SubmitGameState(S);else `XCOMHISTORY.CleanupPendingGameState(S);
 CivilPlayer=XGBattle_SP(`BATTLE).GetCivilianPlayer();if(default.Scenario!=60 && CivilPlayer!=none)CivilPlayer.m_bSkipAI=(default.Scenario!=60);
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
 if(((default.Scenario<21 || default.Scenario>27) && default.Scenario!=31 && default.Scenario!=59 && default.Scenario!=61 && (default.Scenario<35 || default.Scenario>41)) || Actors.Length==0)return;
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
 if(default.Scenario==32 || (default.Scenario>=152&&default.Scenario<=154))
 {
  Template=class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('Flush');if(Template==none)return;
  foreach Soldiers(ID)
  {
   U=Unit(ID);if(U==none || !U.IsAlive() || U.GetPrimaryWeapon()==none)continue;
   U=XComGameState_Unit(S.GetGameStateForObjectID(ID));if(U==none)U=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',ID));
   if(U.ActionPoints.Length==0)U.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
   U.SetBaseMaxStat(eStat_Offense,160);U.SetCurrentStat(eStat_Offense,160);
   Primary=U.GetPrimaryWeapon();if(Primary==none)continue;
   Ref=U.FindAbility('Flush');if(Ref.ObjectID<=0)Ref=class'X2TacticalGameRuleset'.static.InitAbilityForUnit(Template,U,S,Primary.GetReference());
   LogInternal("R6|FLUSHEQUIP|"$ID$"|"$Ref.ObjectID);
  }
 }
 if((default.Scenario==28 || default.Scenario==95 || default.Scenario==96) && Actors.Length>=2)
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
 if((default.Scenario<152 || default.Scenario>154) && default.Scenario!=32 && default.Scenario!=31 && default.Scenario!=29 && default.Scenario!=27 && default.Scenario!=60)return;
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
function PlaceVIPControl(XComGameState S)
{
 local XComGameState_Unit U,T;
 local XComGameState_EvacZone Z;
 local vector Pos;
 local int I,Id;
 if(default.Scenario<100 || default.Scenario>102 || Actors.Length<2 || Soldiers.Length<1)return;
 U=Unit(Actors[0]);Pos=PlaceFrom(U.TileLocation,5,3);
 Z=class'XComGameState_EvacZone'.static.GetEvacZone(eTeam_XCom);
 if(Z==none)Z=class'XComGameState_EvacZone'.static.PlaceEvacZone(S,Pos,eTeam_XCom);
 foreach Actors(Id,I)
 {
  T=XComGameState_Unit(S.GetGameStateForObjectID(Id));if(T==none)continue;
  if(default.Scenario==101)T.SetCurrentStat(eStat_AlertLevel,0);
  else {T.SetCurrentStat(eStat_AlertLevel,2);T.SetCurrentStat(eStat_HP,Max(1,int(T.GetMaxStat(eStat_HP))/2));}
  LogInternal("R7|VIPCONTROL|"$default.Scenario$"|"$T.ObjectID$"|"$T.GetMyTemplateName()$"|"$T.GetTeam()$"|"$T.GetCurrentStat(eStat_AlertLevel)$"|"$T.IsUnconscious()$"|"$Z.ObjectID$"|"$T.TileLocation.X$","$T.TileLocation.Y);
 }
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
 PositionField(S);PositionSupport(S);PositionMeleeSubject(S);FieldStatus(S);MercyStatus(S);SetupSpecial(S);SetupSingleBindEnemy(S);SetupBindPoints(S);SetupNivenSight(S);SetupPlayerSight(S);SetupVIPThreat(S);SetShootingLane(S);StageSeven(S);PlaceVisibleGroup(S);ShotFixture(S);RangedCluster(S);PositionRole(S);PlaceVIPControl(S);EightPrepare(S);EightPrepareTargets(S);
 `TACTICALRULES.SubmitGameState(S);
 if(RoundNo==1 && !TerrorCase() && default.Scenario!=101 && default.Scenario!=100)foreach Actors(Id)
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
  AuditActor(U);LogShotCandidates(U);
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
  Node=SeenNodes[I].Node;if(Node.m_iLastInit<0)continue;
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
  if((default.Scenario==60||default.Scenario==98||(default.Scenario>=100 && default.Scenario<=102)) && Actors.Length>=2)
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
  AC=XComGameStateContext_Ability(F.GetContext());EightFrame(AC,I);EightPowerFrame(AC,I);GemHistory(AC,I);if(AC==none||AC.InterruptionStatus==eInterruptionStatus_Interrupt)continue;
  LogFlushCover(AC,I);
  Id=AC.InputContext.SourceObject.ObjectID;
  if(default.Scenario==31 && Soldiers.Find(Id)!=INDEX_NONE && AC.InputContext.AbilityTemplateName=='StandardMove')
   LogInternal("R6|XCOMMOVED|"$I$"|"$Id$"|"$SeenTurn);
  if((default.Scenario==32 || (default.Scenario>=152&&default.Scenario<=154)) && AC.InputContext.AbilityTemplateName=='Flush')LogInternal("R6|XCOMFLUSH|"$I$"|"$Id$"|"$AC.InputContext.PrimaryTarget.ObjectID$"|"$AC.ResultContext.HitResult);
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
  CastLocations(AC,U0,U1,I);InspectRush(AC,I);
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
function ProbeVisualizationGate()
{
 local XComGameStateVisualizationMgr VM;
 local XComGameState_Player P;
 local X2Action Action;
 local array<X2Action> Nodes;
 local StateObjectReference Ref;
 local int Count;
 VM=`XCOMVISUALIZATIONMGR;
 Ref=`TACTICALRULES.GetCachedUnitActionPlayerRef();
 P=XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));
 if(P==none || P.TeamFlag!=eTeam_XCom || !Sent || Pulse<PhaseFrame+120)return;
 VM.GetNodesOfType(VM.VisualizationTree,class'X2Action',Nodes);
 foreach Nodes(Action)
 {
  if(Action==none || Action.bCompleted || !Action.IsInState('Executing'))continue;
  LogInternal("R7|VIZGATE|"$default.Scenario$"|"$RoundNo$"|"$Action.Class.Name$"|"$Action.GetStateName());
  Action.ForceComplete();
  ++Count;
 }
 LogInternal("R7|VIZSTATUS|"$default.Scenario$"|"$Count$"|"$VM.GetStateName()$"|"$`TACTICALRULES.GetStateName()$"|"$Nodes.Length);
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
  ProbeVisualizationGate();
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
  if((default.Scenario==175||default.Scenario==177) && PyPhase==0){PyPhase=1;ProbeLanding();return;}
  if(default.Scenario>=238 && default.Scenario<=241)
  {
   if(PyPhase==0){PyPhase=1;LootStart();return;}
   if(PyPhase<6){++PyPhase;return;}
   if(PyPhase==6){++PyPhase;LootResult();return;}
  }
  if(default.Scenario>=210 && default.Scenario<220){if(PyPhase<3)PyMatrixStep();else CompleteField();return;}
  if(default.Scenario>=220 && default.Scenario<=237 && PyPhase==0){PyPhase=1;PyEquipment();return;}
  if(default.Scenario>=190 && default.Scenario<=199){if(GemPhase==0){GemPhase=1;GemPlaceCover();return;}if(GemPhase==1){GemPhase=2;GemCheckCover();return;}if(default.Scenario==190 && GemIndex<576){GemMatrixStep();return;}}
  if(default.Scenario>=170 && default.Scenario<=186 && MoveAttempts==0){++MoveAttempts;EightTestPower();return;}
  if((default.Scenario==16||default.Scenario==18) && RoundNo==1 && MatrixStep<5)
  {
   if(Pulse<LastMatrixPulse+3)return;
   if(MatrixStep>0)MeasureRadius();++MatrixStep;LastMatrixPulse=Pulse;
   if(MatrixStep<=4){ApplyMatrixLayout(MatrixStep);return;}
  }
  if((default.Scenario==16||default.Scenario==18) && RoundNo>1 && LastGeoRound!=RoundNo && LastMatrixPulse!=PhaseFrame)
  {ApplyMatrixLayout(4);LastMatrixPulse=PhaseFrame;return;}
  if((default.Scenario==32 || (default.Scenario>=152&&default.Scenario<=154)) && MoveAttempts<RoundNo)
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
  if(IsAdderCase())LogBoundState();
  if(LastGeoRound!=RoundNo){MeasureRadius();LastGeoRound=RoundNo;}
  if(`TACTICALRULES.WaitingForVisualizer() && Pulse<PhaseFrame+19)return;
  Inspect();
  if(`TACTICALRULES.GetLocalClientPlayerObjectID()==PR.ObjectID)Ok=Ctrl.PerformEndTurn(ePlayerEndTurnType_PlayerInput);
  else Ok=Ctrl.PerformEndTurn(ePlayerEndTurnType_AI);
  LastSent=Pulse;Sent=true;LogInternal("R6|END|"$RoundNo$"|"$Ok$"|"$PR.ObjectID);
 }
}


function AuditTables(XComTacticalMissionManager M)
{
 local int I,J,K,Idx;
 local array<name> Seen;
 local string V;
 local name ID,N;
 local MissionSchedule SC;
 local ConfigurableEncounter CE;
 local XComGameState Tmp;
 local XComGameState_MissionSite Site;
 local XComGameState_HeadquartersXCom HQ;
 local X2CharacterTemplateManager Ch;
 local X2AIBTBehaviorTree BT;
 local SpawnDistributionListEntry E;
 local bool A,B,C,D,F,G,H,Tag;
 if(M==none)return;
 Ch=class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
 BT=class'X2AIBTBehaviorTree'.static.GetBehaviorTreeManager();
 for(I=0;I<BT.Behaviors.Length;++I)
 {
  ID=BT.Behaviors[I].BehaviorName;Idx=BT.GetNodeIndex(ID);
  if(Idx!=I)continue;
  V="";foreach BT.Behaviors[I].Child(N)V$=string(N)$",";
  LogInternal("R7|BT|"$ID$"|"$BT.Behaviors[I].NodeType$"|"$V);
 }
 for(I=0;I<M.ConfigurableEncounters.Length;++I)
 {
  CE=M.ConfigurableEncounters[I];V="";
  foreach CE.ForceSpawnTemplateNames(N)V$=string(N)$":"$string(Ch.FindCharacterTemplate(N)!=none)$",";
  LogInternal("R7|ENC|"$I$"|"$CE.EncounterID$"|"$CE.MaxSpawnCount$"|"$CE.MinRequiredForceLevel$"|"$CE.MaxRequiredForceLevel$"|"$CE.MinRequiredAlertLevel$"|"$CE.MaxRequiredAlertLevel$"|"$CE.EncounterLeaderSpawnList$"|"$CE.EncounterFollowerSpawnList$"|"$V);
 }
 for(I=0;I<M.EncounterBuckets.Length;++I)
 {
  V="";for(J=0;J<M.EncounterBuckets[I].EncounterIDs.Length;++J)
  V$=string(M.EncounterBuckets[I].EncounterIDs[J].EncounterID)$":"$M.EncounterBuckets[I].EncounterIDs[J].IncludeTacticalTag$":"$M.EncounterBuckets[I].EncounterIDs[J].ExcludeTacticalTag$",";
  LogInternal("R7|BUCKET|"$I$"|"$M.EncounterBuckets[I].EncounterBucketID$"|"$M.EncounterBuckets[I].RandomizedSelection$"|"$V);
  ID=M.EncounterBuckets[I].EncounterBucketID;
  if(Left(string(ID),4)~="ETP_" || InStr(Caps(string(ID)),"FINALSHOWDOWN")>=0)
  {
   for(K=0;K<16;++K)
   {
    CE.EncounterID='';M.GetConfigurableEncounter(ID,CE,20,10);
    LogInternal("R7|DRAW|"$ID$"|20|10|"$CE.EncounterID);
   }
  }
 }
 for(I=0;I<M.SpawnDistributionLists.Length;++I)
 {
  V="";foreach M.SpawnDistributionLists[I].SpawnDistribution(E)
  V$=string(E.Template)$":"$E.MinForceLevel$":"$E.MaxForceLevel$":"$E.MaxCharactersPerGroup$":"$E.SpawnWeight$",";
  LogInternal("R7|LIST|"$I$"|"$M.SpawnDistributionLists[I].ListID$"|"$V);
 }
 Tmp=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Review schedule selection boundaries");
 Site=XComGameState_MissionSite(Tmp.CreateNewStateObject(class'XComGameState_MissionSite'));
 HQ=XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom',true));
 for(I=0;I<M.MissionSchedules.Length;++I)
 {
  SC=M.MissionSchedules[I];V="";
  for(J=0;J<SC.PrePlacedEncounters.Length;++J)V$=string(SC.PrePlacedEncounters[J].EncounterID)$",";
  LogInternal("R7|SCHED|"$I$"|"$SC.ScheduleID$"|"$SC.MinRequiredForceLevel$"|"$SC.MaxRequiredForceLevel$"|"$SC.MinRequiredAlertLevel$"|"$SC.MaxRequiredAlertLevel$"|"$SC.IncludeTacticalTag$"|"$SC.ExcludeTacticalTag$"|"$V);
  ID=SC.ScheduleID;if(Seen.Find(ID)!=INDEX_NONE)continue;Seen.AddItem(ID);M.GetMissionSchedule(ID,SC);
  Tag=(HQ==none || ((SC.IncludeTacticalTag=='' || HQ.TacticalGameplayTags.Find(SC.IncludeTacticalTag)!=INDEX_NONE)&&(SC.ExcludeTacticalTag=='' || HQ.TacticalGameplayTags.Find(SC.ExcludeTacticalTag)==INDEX_NONE)));
  Site.GeneratedMission.Mission.MissionSchedules.Length=0;Site.GeneratedMission.Mission.MissionSchedules.AddItem(ID);
  Site.SelectedMissionData.ForceLevel=SC.MinRequiredForceLevel;Site.SelectedMissionData.AlertLevel=SC.MinRequiredAlertLevel;A=M.ValidateMissionSchedule(string(ID),Site);
  Site.SelectedMissionData.ForceLevel=SC.MaxRequiredForceLevel;Site.SelectedMissionData.AlertLevel=SC.MaxRequiredAlertLevel;B=M.ValidateMissionSchedule(string(ID),Site);
  Site.SelectedMissionData.ForceLevel=SC.MinRequiredForceLevel-1;C=M.ValidateMissionSchedule(string(ID),Site);
  Site.SelectedMissionData.ForceLevel=SC.MaxRequiredForceLevel+1;D=M.ValidateMissionSchedule(string(ID),Site);
  Site.SelectedMissionData.ForceLevel=SC.MinRequiredForceLevel;Site.SelectedMissionData.AlertLevel=SC.MinRequiredAlertLevel-1;F=M.ValidateMissionSchedule(string(ID),Site);
  Site.SelectedMissionData.AlertLevel=SC.MaxRequiredAlertLevel+1;G=M.ValidateMissionSchedule(string(ID),Site);
  Site.SelectedMissionData.AlertLevel=SC.MinRequiredAlertLevel;Site.GeneratedMission.Mission.MissionSchedules.Length=0;H=M.ValidateMissionSchedule(string(ID),Site);
  LogInternal("R7|BOUND|"$ID$"|"$Tag$"|"$A$"|"$B$"|"$C$"|"$D$"|"$F$"|"$G$"|"$H);
 }
 `XCOMHISTORY.CleanupPendingGameState(Tmp);
 for(I=0;I<M.arrMissions.Length;++I)
 {
  V="";foreach M.arrMissions[I].MissionSchedules(N)V$=string(N)$",";
  LogInternal("R7|MISSION|"$M.arrMissions[I].MissionName$"|"$M.arrMissions[I].sType$"|"$V);
 }
 LogInternal("R7|TABLEEND|"$M.ConfigurableEncounters.Length$"|"$M.EncounterBuckets.Length$"|"$M.SpawnDistributionLists.Length$"|"$M.MissionSchedules.Length$"|"$M.arrMissions.Length);
}


function StageSeven(XComGameState S)
{
 local int I,ID,Count;
 local XComGameState_Unit U,T,V;
 local XComGameState_Player Pl;
 local TTile F;
 local vector Pos;
 local array<TTile> Tiles;
 local TTile Cell;
 if(Actors.Length==0||Soldiers.Length==0)return;
 U=Unit(Actors[0]);if(U==none)return;
 if(default.Scenario==61 && RoundNo==1)
 {
  V=XComGameState_Unit(S.GetGameStateForObjectID(U.ObjectID));if(V==none)return;
  BuildVisibleTestTiles(V);
  foreach TestTiles(Cell)
  {
   if(Abs(Cell.X-V.TileLocation.X)+Abs(Cell.Y-V.TileLocation.Y)<2)continue;
   Tiles.AddItem(Cell);
  }
  for(I=1;I<Min(3,Soldiers.Length)&&I<=Tiles.Length;++I)
  {
   T=XComGameState_Unit(S.GetGameStateForObjectID(Soldiers[I]));if(T==none)T=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',Soldiers[I]));
   F=Tiles[I-1];Pos=`XWORLD.GetPositionFromTileCoordinates(F);T.SetVisibilityLocationFromVector(Pos);T.SetIndividualConcealment(false,S);
   LogInternal("R7|BINDVISIBLE|"$T.ObjectID$"|"$F.X$","$F.Y);
  }
 }
 if(default.Scenario>=62 && default.Scenario<=69)
 {
  Pl=XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(Unit(Soldiers[0]).ControllingPlayer.ObjectID));
  if(Pl!=none)Pl.SetSquadConcealmentNewGameState(false,S);
  BuildVisibleTestTiles(U);Count=0;
  foreach Soldiers(ID)
  {
   T=Unit(ID);if(T==none||!T.IsAlive()||T.IsIncapacitated())continue;
   V=XComGameState_Unit(S.GetGameStateForObjectID(ID));if(V==none)V=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',ID));
   if(Count<Min(4,TestTiles.Length)){F=TestTiles[Count];Pos=`XWORLD.GetPositionFromTileCoordinates(F);V.SetVisibilityLocationFromVector(Pos);V.SetIndividualConcealment(false,S);}
   ++Count;
  }
  V=XComGameState_Unit(S.GetGameStateForObjectID(U.ObjectID));if(V!=none && !V.IsUnitAffectedByEffectName('CoarseAuditLastPoint'))ApplyLastPoint(S,V);
 }
}
function AuditActor(XComGameState_Unit U)
{
 local StateObjectReference Ref;
 local XComGameState_Ability AB;
 local XComGameState_Item Item;
 local XGUnit Pawn;
 local string Names;
 foreach U.Abilities(Ref)
 {
  AB=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));if(AB==none)continue;
  Item=AB.GetSourceWeapon();Names$=string(AB.GetMyTemplateName())$":"$(Item==none?'None':Item.GetMyTemplateName())$",";
 }
 Pawn=XGUnit(U.GetVisualizer());
 LogInternal("R7|ACTOR|"$default.Scenario$"|"$RoundNo$"|"$U.ObjectID$"|"$U.GetMyTemplateName()$"|"$U.GetMyTemplate().strBehaviorTree$"|"$((Pawn!=none && Pawn.m_kBehavior!=none)?Pawn.m_kBehavior.GetBehaviorTreeRoot():'None')$"|"$Names);
}
function LogFlushCover(XComGameStateContext_Ability AC,int Frame)
{
 local XComGameState_Unit FromU,ToU,Source;
 local float Angle;
 local ECoverType OldCover,NewCover;
 local vector P0,P1,PS;
 if(default.Scenario!=32 && (default.Scenario<152 || default.Scenario>154))return;
 if(AC.InputContext.AbilityTemplateName=='Flush'){FlushShooter=AC.InputContext.SourceObject.ObjectID;FlushTarget=AC.InputContext.PrimaryTarget.ObjectID;}
 if(FlushTarget<=0||AC.InputContext.SourceObject.ObjectID!=FlushTarget)return;
 FromU=Unit(FlushTarget,Frame-1);ToU=Unit(FlushTarget,Frame);Source=Unit(FlushShooter,Frame);
 if(FromU==none||ToU==none||Source==none||(FromU.TileLocation.X==ToU.TileLocation.X&&FromU.TileLocation.Y==ToU.TileLocation.Y))return;
 P0=`XWORLD.GetPositionFromTileCoordinates(FromU.TileLocation);
 P1=`XWORLD.GetPositionFromTileCoordinates(ToU.TileLocation);
 PS=`XWORLD.GetPositionFromTileCoordinates(Source.TileLocation);
 OldCover=class'XComWorldData'.static.GetCoverTypeForTarget(PS,P0,Angle);
 NewCover=class'XComWorldData'.static.GetCoverTypeForTarget(PS,P1,Angle);
 LogInternal("R7|COVER|"$Frame$"|"$FlushShooter$"|"$FlushTarget$"|"$OldCover$"|"$NewCover$"|"$FromU.GetCoverTypeFromLocation()$"|"$ToU.GetCoverTypeFromLocation());
}


function AuditFixedGroups(XComTacticalMissionManager M)
{
 local X2CharacterTemplate CT;
 local XComAISpawnManager SM;
 local XComGameState_BattleData BD;
 
 local array<X2CharacterTemplate> Chars;
 local array<name> EmptySitreps;
 local PodSpawnInfo Pod,Empty;
 local ConfigurableEncounter CE;
 local MissionSchedule MS;
 local MissionDefinition MD;
 local float Leader,Follower;
 local int I,J,F,A,Mod,Count,Index;
 local name ID,N;
 local string Templates,Selected;
 SM=class'XComAISpawnManager'.static.GetSpawnManager();
 BD=XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData',true));
 if(BD==none||SM==none)return;
 M.GetActiveMissionSchedule(MS);MD=BD.MapData.ActiveMission;
 for(I=0;I<default.RosterChecks.Length;++I)
 {
  ID=default.RosterChecks[I];Index=M.ConfigurableEncounters.Find('EncounterID',ID);
  if(Index<0){LogInternal("R7|GROUPMISSING|"$ID);continue;}
  CE=M.ConfigurableEncounters[Index];
  for(J=0;J<2;++J)
  {
   F=J==0?Max(1,CE.MinRequiredForceLevel):Min(99,CE.MaxRequiredForceLevel);
   A=J==0?Max(1,CE.MinRequiredAlertLevel):Min(20,CE.MaxRequiredAlertLevel);
   Pod=Empty;Pod.EncounterID=ID;Pod.Team=eTeam_Alien;Chars.Length=0;Leader=0;Follower=0;Mod=0;
   SM.SelectSpawnGroup(Pod,MD,MS,EmptySitreps,CE,F,A,Chars,Leader,Follower,Mod);
   Templates="";foreach Chars(CT){if(CT!=none)Templates$=string(CT.DataName)$",";else Templates$="None,";}
   Selected="";foreach Pod.SelectedCharacterTemplateNames(N)Selected$=string(N)$",";
   LogInternal("R7|GROUPDRAW|"$ID$"|"$J$"|"$F$"|"$A$"|"$CE.MaxSpawnCount$"|"$CE.ForceSpawnTemplateNames.Length$"|"$Templates$"|"$Selected);
   ++Count;
  }
 }
 LogInternal("R7|GROUPEND|"$Count);
}

function AuditTaggedBuckets(XComTacticalMissionManager M)
{
 local XComGameState Temp;
 local XComGameState_HeadquartersXCom HQ, Current;
 local array<name> Done;
 local EncounterBucket B;
 local ConditionalEncounter Can;
 local ConfigurableEncounter E,Draw,Empty;
 local name T;
 local string Tags;
 local int I,J,K,Idx,Count,Pass;
 Current=XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom',true));
 if(Current!=none){foreach Current.TacticalGameplayTags(T)Tags$=string(T)$",";}
 LogInternal("R7|GRIDHQ|"$string(Current!=none)$"|"$Tags);
 Temp=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Encounter tag selection observations");
 HQ=XComGameState_HeadquartersXCom(Temp.CreateNewStateObject(class'XComGameState_HeadquartersXCom'));
 for(I=0;I<M.EncounterBuckets.Length;++I)
 {
  B=M.EncounterBuckets[I];
  if(Left(string(B.EncounterBucketID),4)!="ETP_" || Done.Find(B.EncounterBucketID)!=INDEX_NONE)continue;
  Done.AddItem(B.EncounterBucketID);
  for(J=0;J<B.EncounterIDs.Length;++J)
  {
   Can=B.EncounterIDs[J];if(Can.IncludeTacticalTag=='' && Can.ExcludeTacticalTag=='')continue;
   Idx=M.ConfigurableEncounters.Find('EncounterID',Can.EncounterID);
   if(Idx<0)
   {
    if(M.EncounterBuckets.Find('EncounterBucketID',Can.EncounterID)<0)continue;
    E=Empty;E.MinRequiredForceLevel=20;E.MaxRequiredForceLevel=99;E.MinRequiredAlertLevel=10;E.MaxRequiredAlertLevel=99;
   }
   else E=M.ConfigurableEncounters[Idx];
   if(E.MinRequiredForceLevel>E.MaxRequiredForceLevel || E.MinRequiredAlertLevel>E.MaxRequiredAlertLevel)continue;
   for(K=0;K<4;++K)
   {
    Tags="";HQ.TacticalGameplayTags.Length=0;
    if((K==1 || K==3) && Can.IncludeTacticalTag!='')HQ.TacticalGameplayTags.AddItem(Can.IncludeTacticalTag);
    if((K==2 || K==3) && Can.ExcludeTacticalTag!='')HQ.TacticalGameplayTags.AddItem(Can.ExcludeTacticalTag);
    foreach HQ.TacticalGameplayTags(T)Tags$=string(T)$",";
    for(Pass=0;Pass<3;++Pass)
    {
     Draw=Empty;M.GetConfigurableEncounter(B.EncounterBucketID,Draw,Max(1,E.MinRequiredForceLevel),Max(1,E.MinRequiredAlertLevel),HQ);
     LogInternal("R7|TAGDRAW|"$B.EncounterBucketID$"|"$J$"|"$K$"|"$Pass$"|"$Max(1,E.MinRequiredForceLevel)$"|"$Max(1,E.MinRequiredAlertLevel)$"|"$Tags$"|"$Draw.EncounterID);
     ++Count;
    }
   }
  }
 }
 `XCOMHISTORY.CleanupPendingGameState(Temp);
 LogInternal("R7|TAGEND|"$Count);
}

function AuditDetail(XComTacticalMissionManager M)
{
 local int I,J,K,F,BaseIndex,N;
 local string S,BaseName;
 local name ID;
 local ConfigurableEncounter V,Base,Empty;
 local EncounterBucket B;
 local PrePlacedEncounterPair P;
 local MissionSchedule MS;
 local XComGameState_HeadquartersXCom HQ;
 local X2AIBTBehaviorTree BT;
 local array<name> Done;
 local int Forces[27];
 if(M==none)return;
 HQ=XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom',true));
 for(I=0;I<M.MissionSchedules.Length;++I)
 {
  MS=M.MissionSchedules[I];
  LogInternal("R7|SBASE|"$I$"|"$MS.ScheduleID$"|"$MS.IdealXComSpawnDistance$"|"$MS.MinXComSpawnDistance$"|"$MS.EncounterZonePatrolDepth$"|"$MS.AlienToAdventFollowerRatio$"|"$MS.AlienToAdventLeaderRatio$"|"$MS.MaxTurrets$"|"$MS.XComSquadStartsConcealed$"|"$MS.DefaultEncounterLeaderSpawnList$"|"$MS.DefaultEncounterFollowerSpawnList);
  for(J=0;J<MS.PrePlacedEncounters.Length;++J)
  {
   P=MS.PrePlacedEncounters[J];
   LogInternal("R7|SLOT|"$I$"|"$J$"|"$P.EncounterID$"|"$P.EncounterZoneWidth$"|"$P.EncounterZoneDepthOverride$"|"$P.EncounterZoneOffsetFromLOP$"|"$P.EncounterZoneOffsetAlongLOP$"|"$P.EncounterZoneVolumeTag$"|"$P.SpawnLocationActorTag$"|"$P.IncludeTacticalTag$"|"$P.ExcludeTacticalTag$"|"$P.PrePlacedEncounterTag$"|"$P.StrategyUnitTag);
  }
 }
 for(I=0;I<M.ConfigurableEncounters.Length;++I)
 {
  V=M.ConfigurableEncounters[I];
  LogInternal("R7|EXTRAENC|"$I$"|"$V.EncounterID$"|"$V.OffsetForceLevel$"|"$V.OffsetAlertLevel$"|"$V.ReinforcementCountdown$"|"$V.bGroupDoesNotAwardLoot);
 }
 for(I=0;I<25;++I)Forces[I]=I;
 Forces[25]=98;Forces[26]=99;
 for(I=0;I<M.EncounterBuckets.Length;++I)
 {
  B=M.EncounterBuckets[I];ID=B.EncounterBucketID;
  if((Left(string(ID),4)!="ETP_" && InStr(Caps(string(ID)),"FINALSHOWDOWN")<0)||Done.Find(ID)!=INDEX_NONE)continue;
  Done.AddItem(ID);
  BaseName=Mid(string(ID),4,Len(string(ID))-11);
  BaseIndex=M.ConfigurableEncounters.Find('EncounterID',name(BaseName));
  for(J=0;J<27;++J)
  {
   F=Forces[J];
   for(K=0;K<4;++K)
   {
    N=K==0?1:(K==1?10:(K==2?20:99));V=Empty;
    M.GetConfigurableEncounter(ID,V,F,N,HQ);
    S="";if(BaseIndex!=INDEX_NONE){Base=M.ConfigurableEncounters[BaseIndex];S=string(Base.EncounterID)$","$Base.MinRequiredForceLevel$","$Base.MaxRequiredForceLevel$","$Base.MinRequiredAlertLevel$","$Base.MaxRequiredAlertLevel;}
    LogInternal("R7|GRID|"$ID$"|"$F$"|"$N$"|"$V.EncounterID$"|"$S);
   }
  }
 }
 BT=class'X2AIBTBehaviorTree'.static.GetBehaviorTreeManager();
 for(I=0;I<BT.EquivalentAbilities.Length;++I)
 {
  S="";foreach BT.EquivalentAbilities[I].EquivalentAbilityName(ID)S$=string(ID)$",";
  LogInternal("R7|EQUIV|"$BT.EquivalentAbilities[I].KeyName$"|"$S);
 }
 LogInternal("R7|DETAILEND|"$M.MissionSchedules.Length$"|"$Done.Length);
}
function AuditPods()
{
 local XComGameState_AIGroup G;
 local XComGameState_Unit U;
 local StateObjectReference R;
 local string S;
 local MissionSchedule MS;
 `TACTICALMISSIONMGR.GetActiveMissionSchedule(MS);
 foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_AIGroup',G)
 {
  S="";foreach G.m_arrMembers(R){U=Unit(R.ObjectID);if(U!=none)S$=string(U.GetMyTemplateName())$", ";}
  LogInternal("R7|POD|"$`BATTLE.m_kDesc.MapData.ActiveMission.sType$"|"$MS.ScheduleID$"|"$G.EncounterID$"|"$G.ObjectID$"|"$S);
 }
}
function PlaceVisibleGroup(XComGameState S)
{
 local XComGameState_Unit U,T,V,Leader;
 local XComGameState_Player Pl;
 local XComWorldData W;
 local TTile Center,Cell,Picked[5],Tr;
 local vector A,B;
 local int Ring,DX,DY,Z,N,I,Want,Subject,Gap,Step;
 local bool Found,IsBind,IsOut,IsDefense,IsSupport;
 if(Actors.Length==0||Soldiers.Length<2)return;
 IsBind=default.Scenario==61;IsOut=default.Scenario==55 || default.Scenario==67 || default.Scenario==85;IsDefense=default.Scenario==27;IsSupport=default.Scenario==65 || default.Scenario==91;
 if(!IsBind&&!IsOut&&!IsDefense&&!IsSupport && default.Scenario!=32 && !(default.Scenario>=62 && default.Scenario<=69) && !(default.Scenario>=80 && default.Scenario<=96) && default.Scenario<110)return;
 if(IsBind && RoundNo!=1)return;
 U=Unit(Actors[default.Scenario==96?1:0]);if(U==none)return;W=`XWORLD;Leader=Unit(Soldiers[0]);
 Want=Min(3,Soldiers.Length);Pl=XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(Leader.ControllingPlayer.ObjectID));
 if(Pl!=none)Pl.SetSquadConcealmentNewGameState(false,S);
 for(Ring=0;Ring<11 && !Found;++Ring)for(DX=-Ring;DX<=Ring && !Found;++DX)for(DY=-Ring;DY<=Ring && !Found;++DY)
 {
  if(Abs(DX)!=Ring && Abs(DY)!=Ring)continue;
  Center=U.TileLocation;Center.X+=DX;Center.Y+=DY;if(Center.X<3||Center.Y<3||Center.X>=W.NumX-3||Center.Y>=W.NumY-3)continue;
  for(Z=0;Z<20 && !Found;++Z)
  {
   Center.Z=Z;if(!W.IsFloorTileAndValidDestination(Center,U)||!W.CanUnitsEnterTile(Center))continue;
   A=W.GetPositionFromTileCoordinates(Center);N=0;
   for(Gap=1;Gap<4 && N<5;++Gap)for(Step=0;Step<8 && N<5;++Step)
   {
    Cell=Center;
    if(Step==0||Step==4||Step==5)Cell.X+=Gap;
    if(Step==1||Step==6||Step==7)Cell.X-=Gap;
    if(Step==2||Step==4||Step==6)Cell.Y+=Gap;
    if(Step==3||Step==5||Step==7)Cell.Y-=Gap;
    if(!W.IsFloorTileAndValidDestination(Cell,Leader)||!W.CanUnitsEnterTile(Cell))continue;
    B=W.GetPositionFromTileCoordinates(Cell);
    if(!W.IsAdjacentTileVisible(A,B)|| (Gap==1 && W.IsAdjacentTileBlocked(Center,Cell)))continue;
    Picked[N++]=Cell;
   }
   if(N>=Want+1)Found=true;
  }
 }
 if(!Found){LogInternal("R7|GRIDFAILED|"$default.Scenario);return;}
 V=XComGameState_Unit(S.GetGameStateForObjectID(U.ObjectID));if(V==none)V=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',U.ObjectID));
 A=W.GetPositionFromTileCoordinates(Center);V.SetVisibilityLocationFromVector(A);
 for(I=0;I<Want;++I)
 {
  Subject=Soldiers[I];T=XComGameState_Unit(S.GetGameStateForObjectID(Subject));if(T==none)T=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',Subject));
  Tr=Picked[I];B=W.GetPositionFromTileCoordinates(Tr);T.SetVisibilityLocationFromVector(B);T.SetIndividualConcealment(false,S);
 }
 if(Actors.Length>1 && (IsOut||IsSupport||IsDefense))
 {
  Subject=Actors[1];T=XComGameState_Unit(S.GetGameStateForObjectID(Subject));if(T==none)T=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',Subject));
  Tr=Picked[Want];B=W.GetPositionFromTileCoordinates(Tr);T.SetVisibilityLocationFromVector(B);
  if(IsSupport)T.SetCurrentStat(eStat_HP,Max(2,int(T.GetMaxStat(eStat_HP))/2));
 }
 LogInternal("R7|PLACED|"$default.Scenario$"|"$RoundNo$"|"$U.ObjectID$"|"$Center.X$","$Center.Y$","$Center.Z$"|"$Soldiers[0]$","$Soldiers[1]$","$Soldiers[2]);
}


function SetDiagnosticRoot(name K)
{
 local X2CharacterTemplate T;
 local name Requested;
 if(SavedTemplate!=none){SavedTemplate.strBehaviorTree=SavedTree;SavedTemplate=none;}
 switch(default.Scenario)
 {
 case 242:case 243:case 244:case 245:Requested='ShootIfAvailable';break;
 case 246:Requested='TryMindSpinOption';break;
 case 247:case 248:Requested='TrySuppressClosest';break;
 case 110: Requested='TryARFMAdvKnightShield';break;
 case 111: Requested='TryARFMAdvKnightShield';break;
 case 113: Requested='TryARFMAdvKnightShield';break;
 case 114: Requested='TryARFMAdvKnightShield';break;
 case 115: Requested='TryARFMAdvKnightBow';break;
 case 116: Requested='TryTrackingShotLW';break;
 case 117: Requested='TryTrackingShotLW';break;
 case 118: Requested='ShootIfAvailable';break;
 case 119: Requested='TrySlash';break;
 case 122: Requested='TPYDuplicateUnit';break;
 case 123: Requested='TPYDuplicateUnit';break;
 case 124: Requested='TPYDuplicateUnit';break;
 case 125: Requested='TPYChosenCommand';break;
 case 126: Requested='TPYChosenCommand';break;
 case 127: Requested='TPYChosenCommand';break;
 case 128: Requested='TryScythingClaws';break;
 case 129: Requested='TryScythingClaws';break;
 case 130: Requested='TryScythingClaws';break;
 case 131: Requested='TPYBlindingGloryOptions';break;
 case 132: Requested='TPYBlindingGloryOptions';break;
 case 133: Requested='TPYBlindingGloryOptions';break;
 case 134: Requested='TPYChosenTeleportDefensive';break;
 case 135: Requested='TPYChosenTeleportDefensive';break;
 case 136: Requested='TPYChosenTeleportDefensive';break;
 case 148: Requested='TPYTryStunlauncher';break;
 case 149: Requested='TPYTryStunlauncher';break;
 case 150: Requested='TryStasis';break;
 case 151: case 182: Requested='TryHorror';break;
 case 179: case 181: Requested='R8MoveThenStasis';break;
 case 180: Requested='TryStasis';break;
 case 183: case 184: Requested='TryARFMShadowhorde';break;
 case 155: Requested='TryARFMTorcherGrapple';break;
 case 156: Requested='TryMicroMissiles';break;
 case 157: Requested='TryStandardMelee';break;
 case 158: Requested='TryStandardMelee';break;
 case 159: Requested='TryARFMAdvKnightBow';break;
 case 82: Requested='AdventSniperTryKillShot';break;
 case 83: Requested='PsiOpsTryKillShot';break;
 case 84: Requested='CoarseOutriderTryEquippedMelee';break;
 case 85: Requested='TryMarkTargetOption';break;
 case 86: Requested='AdventDuelistTryLightningHands';break;
 case 87: Requested='AdventDuelistTryFanFire';break;
 case 88: Requested='TryFaceoff';break;
 case 89: Requested='TryPoisonSpit';break;
 case 90: Requested='TryMicroMissiles';break;
 case 91: Requested='TryFrostTechProtocolMJ';break;
 default:return;
 }
 T=class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate(K);if(T==none)return;
 if(!`BEHAVIORTREEMGR.IsValidBehavior(Requested)){LogInternal("R7|MISSINGROOT|"$default.Scenario$"|"$Requested);return;}
 SavedTemplate=T;SavedTree=T.strBehaviorTree;T.strBehaviorTree=string(Requested);
 LogInternal("R7|SCOPED|"$default.Scenario$"|"$K$"|"$SavedTree$"|"$Requested);
}
function ShotFixture(XComGameState S)
{
 local int I;
 local XComGameState_Unit U;
 if(default.Scenario<80||default.Scenario>93||Actors.Length==0 || Soldiers.Length<3)return;
 U=XComGameState_Unit(S.GetGameStateForObjectID(Actors[0]));if(U==none)return;
 if(default.Scenario>=80 && default.Scenario<=83)
 {
  U.SetBaseMaxStat(eStat_Offense,default.Scenario==82?0:200);U.SetCurrentStat(eStat_Offense,default.Scenario==82?0:200);
  if(!U.IsUnitAffectedByEffectName('CoarseAuditLastPoint'))ApplyLastPoint(S,U);
  for(I=0;I<3;++I)
  {
   U=XComGameState_Unit(S.GetGameStateForObjectID(Soldiers[I]));if(U==none)continue;
   U.SetCurrentStat(eStat_HP,(I==1 && default.Scenario!=81)?1.0:U.GetMaxStat(eStat_HP));
   if(default.Scenario==82){U.SetBaseMaxStat(eStat_Defense,90);U.SetCurrentStat(eStat_Defense,90);}
  }
 }
}
function LogShotCandidates(XComGameState_Unit U)
{
 local StateObjectReference R;
 local XComGameState_Ability B;
 local XComGameState_Unit T;
 local AvailableTarget V;
 local array<AvailableTarget> Targets;
 local ShotBreakdown D;
 local name N;
 if(default.Scenario<80||default.Scenario>83)return;
 foreach U.Abilities(R)
 {
  B=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(R.ObjectID));if(B==none)continue;
  N=B.GetMyTemplateName();if(N!='StandardShot'&&N!='AdvRaptorStandardFire'&&N!='SniperStandardFire')continue;
  B.GatherAbilityTargets(Targets);
  foreach Targets(V)
  {
   T=Unit(V.PrimaryTarget.ObjectID);if(T==none)continue;B.GetShotBreakdown(V,D);
   LogInternal("R7|SHOT|"$default.Scenario$"|"$RoundNo$"|"$U.ObjectID$"|"$N$"|"$T.ObjectID$"|"$T.GetCurrentStat(eStat_HP)$"|"$T.GetMaxStat(eStat_HP)$"|"$D.FinalHitChance);
  }
 }
}


function AuditStoryHooks(XComTacticalMissionManager M)
{
 local array<X2DownloadableContentInfo> Hook;
 local XComGameState Temp;
 local XComGameState_CampaignSettings C;
 local XComGameState_MissionSite Site;
 local XComGameState_BattleData Battle;
 local XComGameState_AIReinforcementSpawner Spawner;
 local PodSpawnInfo Pod,Empty;
 local ConfigurableEncounter Draw;
 local string Names,Families[20],Roster,S0,S1;
 local name ID,IDs[20],N,Portal[6];
 local int I,J,K,H,Mode;
 local bool WasOn;
 C=XComGameState_CampaignSettings(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings',true));
 if(C==none)return;
 WasOn=C.IsSecondWaveOptionEnabled('ZeroSanity');
 LogInternal("R7|STORYENV|"$C.DifficultySetting$"|"$C.IsSecondWaveOptionEnabled('ARFMPerilousYearning')$"|"$WasOn);
 Temp=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Compare Golden Path and portal hooks");
 Site=XComGameState_MissionSite(Temp.CreateNewStateObject(class'XComGameState_MissionSite'));
 Battle=XComGameState_BattleData(Temp.CreateNewStateObject(class'XComGameState_BattleData'));
 Spawner=XComGameState_AIReinforcementSpawner(Temp.CreateNewStateObject(class'XComGameState_AIReinforcementSpawner'));
 IDs[0]='ALNx4_Standard';IDs[1]='OPNx4_Standard';IDs[2]='ADVx4_Standard';IDs[3]='Lone_Drone_LW';
 IDs[4]='OPNx6_WithTerror';IDs[5]='OPNx6_Standard';IDs[6]='ADVx4_Standard';IDs[7]='Lone_Drone_LW';
 IDs[8]='OPNx8_Standard';IDs[9]='ALNx8_Standard';IDs[10]='SolitaryHunter';
 IDs[11]='GP_Broadcast_Codices_LW_PROTECTED';IDs[12]='GP_Broadcast_Codices_Extreme_LW_PROTECTED';IDs[13]='Lone_Drone_LW';IDs[14]='GoldenPath_Hard';IDs[15]='GoldenPath_Extreme';
 IDs[16]='GP_Forge_BossGroup';IDs[17]='GP_Forge_BossGroup_Easy';IDs[18]='GP_Forge_BossGroup_Extreme';IDs[19]='OPNx4_Standard';
 for(I=0;I<20;++I)Families[I]=I<4?"GoldenPath1_LW":(I<8?"GoldenPath2_LW":(I<11?"GoldenPath3_LW":(I<16?"GoldenPath4_LW":(I<19?"GoldenPath2_LW":"GuerillaOps_LW"))));
 Portal[0]='LIST_FinalShowdown_T1RNF';Portal[1]='LIST_FinalShowdown_T2RNF';Portal[2]='LIST_FinalShowdown_T3RNF';Portal[3]='LIST_FinalShowdown_PurgeTeam';Portal[4]='LIST_FinalShowdown_AvatarTeam';Portal[5]='LIST_FinalShowdown_DualAvatarTeam';
 for(Mode=0;Mode<2;++Mode)
 {
  if(Mode==1 && !C.IsSecondWaveOptionEnabled('ZeroSanity'))C.AddSecondWaveOption('ZeroSanity');
  if(Mode==0 && C.IsSecondWaveOptionEnabled('ZeroSanity'))C.RemoveSecondWaveOption('ZeroSanity');
  Hook=`DLCHOOKMGR.GetDLCInfos('PostEncounterCreation');Names="";
  for(H=0;H<Hook.Length;++H)Names$=string(Hook[H].Class.Name)$",";
  LogInternal("R7|STORYORDER|"$Mode$"|"$Names);
  for(I=0;I<20;++I)
  {
   Site.GeneratedMission.Mission.MissionFamily=Families[I];ID=IDs[I];Pod=Empty;
   for(J=0;J<8;++J)Pod.SelectedCharacterTemplateNames.AddItem('AdvTrooperM1');
   for(H=0;H<Hook.Length;++H)
   {
    Roster="";foreach Pod.SelectedCharacterTemplateNames(N)Roster$=string(N)$",";
    Hook[H].PostEncounterCreation(ID,Pod,20,10,Site);
    S0="";foreach Pod.SelectedCharacterTemplateNames(N)S0$=string(N)$",";
    LogInternal("R7|STORYHOOK|"$Mode$"|"$Families[I]$"|"$IDs[I]$"|"$Hook[H].Class.Name$"|"$Roster$"|"$S0);
   }
   Roster="";foreach Pod.SelectedCharacterTemplateNames(N)Roster$=string(N)$",";
   LogInternal("R7|STORY|"$Mode$"|"$C.IsSecondWaveOptionEnabled('ZeroSanity')$"|"$Families[I]$"|"$IDs[I]$"|"$Roster);
  }
  Hook=`DLCHOOKMGR.GetDLCInfos('PostReinforcementCreation');Names="";
  for(H=0;H<Hook.Length;++H)Names$=string(Hook[H].Class.Name)$",";
  LogInternal("R7|PORTALORDER|"$Mode$"|"$Names);
  Battle.MapData.ActiveMission.sType="GP_FortressShowdown_LW";Spawner.bKismetInitiatedReinforcements=true;
  for(I=0;I<6;++I)for(K=0;K<5;++K)
  {
   ID=Portal[I];M.GetConfigurableEncounter(ID,Draw,20,15);
   Pod=Empty;Pod.EncounterID=Draw.EncounterID;Pod.SelectedCharacterTemplateNames=Draw.ForceSpawnTemplateNames;
   Spawner.SpawnInfo.EncounterID=ID;S0="";foreach Pod.SelectedCharacterTemplateNames(N)S0$=string(N)$",";
   for(H=0;H<Hook.Length;++H)Hook[H].PostReinforcementCreation(Pod.EncounterID,Pod,20,15,Battle,Spawner);
   S1="";foreach Pod.SelectedCharacterTemplateNames(N)S1$=string(N)$",";
   LogInternal("R7|PORTAL|"$Mode$"|"$ID$"|"$Draw.EncounterID$"|"$S0$"|"$S1);
  }
 }
 if(WasOn && !C.IsSecondWaveOptionEnabled('ZeroSanity'))C.AddSecondWaveOption('ZeroSanity');
 if(!WasOn && C.IsSecondWaveOptionEnabled('ZeroSanity'))C.RemoveSecondWaveOption('ZeroSanity');
 `XCOMHISTORY.CleanupPendingGameState(Temp);
 LogInternal("R7|STORYEND|"$C.IsSecondWaveOptionEnabled('ZeroSanity')$"|"$WasOn);
}


function RangedCluster(XComGameState S)
{
 local XComWorldData W;
 local XComGameState_Unit U,T,V;
 local TTile C,F,Good[4];
 local vector P;
 local GameRulesCache_VisibilityInfo Vis;
 local int DX,DY,Z,J,N,I,Id;
 if(default.Scenario!=89 && default.Scenario!=90 && default.Scenario!=62 && default.Scenario!=63 && !(default.Scenario==115 || default.Scenario==116 || default.Scenario==117 || default.Scenario==118 || default.Scenario==148 || default.Scenario==149 || default.Scenario==156))return;
 if(Actors.Length==0||Soldiers.Length<3)return;
 U=XComGameState_Unit(S.GetGameStateForObjectID(Actors[0]));if(U==none)return;
 W=`XWORLD;C=U.TileLocation;T=Unit(Soldiers[0]);
 for(DX=-9;DX<=9;++DX)for(DY=-9;DY<=9;++DY)
 {
  if(Max(Abs(DX),Abs(DY))<6 || Max(Abs(DX),Abs(DY))>9)continue;
  F=C;F.X+=DX;F.Y+=DY;if(F.X<2||F.Y<2||F.X>=W.NumX-2||F.Y>=W.NumY-2)continue;
  for(Z=Max(0,C.Z-2);Z<=C.Z+2;++Z)
  {
   N=0;
   for(J=0;J<4;++J){F=C;F.X+=DX+(J%2);F.Y+=DY+(J/2);F.Z=Z;
    if(!W.IsFloorTileAndValidDestination(F,T)||!W.CanUnitsEnterTile(F)||!W.CanSeeTileToTile(C,F,Vis))break;
    Good[N++]=F;}
   if(N!=4)continue;
   for(I=0;I<Min(4,Soldiers.Length);++I){Id=Soldiers[I];V=XComGameState_Unit(S.GetGameStateForObjectID(Id));if(V==none)V=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',Id));F=Good[I];P=W.GetPositionFromTileCoordinates(F);V.SetVisibilityLocationFromVector(P);V.SetIndividualConcealment(false,S);}
   LogInternal("R7|RANGED|"$default.Scenario$"|"$RoundNo$"|"$U.ObjectID$"|"$DX$","$DY$","$Z);return;
  }
 }
 LogInternal("R7|NORANGED|"$default.Scenario);
}
function PositionRole(XComGameState S)
{
 local XComGameState_Unit U,Other;
 local XComWorldData W;
 local TTile C,D;
 local vector P;
 local int X,Y,Z,I,ID;
 if((default.Scenario!=95 && default.Scenario!=96)||Actors.Length<2)return;
 I=default.Scenario==96?1:0;
 U=XComGameState_Unit(S.GetGameStateForObjectID(Actors[I]));if(U==none)return;
 ID=Actors[1-I];Other=XComGameState_Unit(S.GetGameStateForObjectID(ID));if(Other==none)Other=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',ID));
 C=U.TileLocation;W=`XWORLD;U.SetCurrentStat(eStat_HP,Max(3,int(U.GetMaxStat(eStat_HP)*0.63)));
 for(X=2;X<W.NumX-2;X+=3)for(Y=2;Y<W.NumY-2;Y+=3)
 {
  if(Max(Abs(X-C.X),Abs(Y-C.Y))<35)continue;
  for(Z=0;Z<15;++Z){D.X=X;D.Y=Y;D.Z=Z;if(!W.IsFloorTileAndValidDestination(D,Other)||!W.CanUnitsEnterTile(D))continue;
   P=W.GetPositionFromTileCoordinates(D);Other.SetVisibilityLocationFromVector(P);LogInternal("R7|ROLE|"$default.Scenario$"|"$U.ObjectID$"|"$ID$"|"$U.GetGroupMembership().ObjectID$"|"$Other.GetGroupMembership().ObjectID$"|"$U.GetCurrentStat(eStat_HP)$"|"$C.X$","$C.Y$"|"$X$","$Y);return;}
 }
}
function ObjectiveVIPs()
{
 local XComGameState_Unit U;
 local XComGameState_EvacZone E;
 local int Count;
 if(default.Scenario!=60 && default.Scenario!=98 && default.Scenario!=100)return;
 foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_EvacZone',E){++Count;LogInternal("R7|EVAC|"$E.ObjectID);}
 foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit',U)
 {
  if(U.GetMyTemplateName()=='CommanderVIP'||U.GetMyTemplateName()=='StasisSuitVIP' || InStr(Caps(string(U.GetMyTemplateName())),"VIP")>=0)
   LogInternal("R7|OBJVIP|"$U.ObjectID$"|"$U.GetMyTemplateName()$"|"$U.GetTeam()$"|"$U.IsUnconscious()$"|"$U.GetMyTemplate().bCanBeCarried$"|"$U.GetMyTemplate().strBehaviorTree);
 }
 LogInternal("R7|VIPOBJECTIVE|"$`BATTLE.m_kDesc.MapData.ActiveMission.sType$"|"$Count);
}


function MarkEdge(name Parent,name Edge,name Label,optional bool Replace)
{
 local X2AIBTBehaviorTree T;
 local int I,J;
 T=class'X2AIBTBehaviorTree'.static.GetBehaviorTreeManager();
 I=T.GetNodeIndex(Parent);if(I<0 || I>=T.Behaviors.Length || T.Behaviors[I].BehaviorName!=Parent)return;
 if(T.GetNodeIndex(Label)<0||T.Behaviors[I].Child.Find(Label)!=INDEX_NONE)return;
 J=T.Behaviors[I].Child.Find(Edge);if(J<0)return;
 if(Replace)T.Behaviors[I].Child[J]=Label;else T.Behaviors[I].Child.InsertItem(J,Label);
 LogInternal("R7|EDGE|"$Parent$"|"$Edge$"|"$Label);
}
function ObserveRoutes()
{
 MarkEdge('NightmareAlwaysRevealOnAvengerDefenseLW','TryAHWUnLurk','R7Witness-NightmareDefense');
 MarkEdge('CoarseTryRequiemLeaderJob','AHWRequiemPodLeaderJobs','R7Witness-Leader');
 MarkEdge('CoarseTryRequiemFollowerJob','AHWRequiemPodFollowerJobs','R7Witness-Follower');
 MarkEdge('TryRequiemPodLeaderJobs','AHWRequiemPodLeaderJobs','R7Witness-Leader');
 MarkEdge('TryRequiemPodFollowerJobs','AHWRequiemPodFollowerJobs','R7Witness-Follower');
 MarkEdge('TryRequiemSpiteShoot','SelectAbility-StandardShot','R7Witness-SpiteShot');
 MarkEdge('AdventSniperTryKillShot','SelectAbility-StandardShot','R7Witness-SniperFinish');
 MarkEdge('PsiOpsTryKillShot','SelectAbility-StandardShot','R7Witness-RaptorFinish');
 MarkEdge('VIPRoot','SkipMove','R7WitnessVIPFinal',true);
 MarkEdge('SkipTurnifGreenAlert','SkipMove','R7Witness-GreenSkip');
 MarkEdge('AdventDuelistTryLightningHands','SelectAbility-LightningHands','R7Witness-Lightning');
 MarkEdge('AdventDuelistTryFanFire','SelectAbility-Fanfire','R7Witness-Fan');
}

function bool EightRelated(X2DataTemplate D)

{

 return Left(Caps(string(D.DataName)),4)=="ARFM" || Left(Caps(string(D.DataName)),3)=="TPY" || InStr(Caps(string(D.ClassThatCreatedUs)), "ARFM")>=0;

}

function EightTags(XComGameState S)
{
 local XComGameState_HeadquartersXCom HQ;
 local name K;
 local array<name> Changed;
 local int C;
 C=default.Scenario;
 if(C<140)return;
 HQ=XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom',true));
 if(HQ==none)HQ=XComGameState_HeadquartersXCom(S.CreateNewStateObject(class'XComGameState_HeadquartersXCom'));
 else HQ=XComGameState_HeadquartersXCom(S.ModifyStateObject(class'XComGameState_HeadquartersXCom',HQ.ObjectID));
 Changed.AddItem('ARFMPYP_GhostSignal');Changed.AddItem('ARFMPYP_Paynonets');Changed.AddItem('ARFMPYP_TimeWar');Changed.AddItem('ARFMDESW_CHAShadowhorde');
 foreach Changed(K)HQ.TacticalGameplayTags.RemoveItem(K);
 if(C>=238 && C<=248)
 {
  HQ.TacticalGameplayTags.RemoveItem('ARFMPYP_MassiveDay');HQ.TacticalGameplayTags.RemoveItem('ARFMPYP_AndromedonDoubleTap');HQ.TacticalGameplayTags.RemoveItem('ARFMPYP_SuperSectoids');HQ.TacticalGameplayTags.RemoveItem('ARFMPYP_MutonSuppressionShot');
  if(C<=241){LootOriginal(C==238);if(C!=240)HQ.TacticalGameplayTags.AddItem('ARFMPYP_MassiveDay');}
  if(C==242)HQ.TacticalGameplayTags.AddItem('ARFMPYP_AndromedonDoubleTap');
  if(C==244 || C==246)HQ.TacticalGameplayTags.AddItem('ARFMPYP_SuperSectoids');
  if(C==247)HQ.TacticalGameplayTags.AddItem('ARFMPYP_MutonSuppressionShot');
 }
 if(C==170||C==171||C==174||C==151||C==182)HQ.TacticalGameplayTags.AddItem('ARFMPYP_GhostSignal');
 if(C==171||C==172)HQ.TacticalGameplayTags.AddItem('ARFMPYP_Paynonets');
 if((C>=175 && C<=181) || C==150 || C==185 || C==186)HQ.TacticalGameplayTags.AddItem('ARFMPYP_TimeWar');
 if(C==183||C==184)HQ.TacticalGameplayTags.AddItem('ARFMDESW_CHAShadowhorde');
 LogInternal("R8|TAGS|"$C$"|"$HQ.TacticalGameplayTags.Find('ARFMPYP_GhostSignal')$"|"$HQ.TacticalGameplayTags.Find('ARFMPYP_Paynonets')$"|"$HQ.TacticalGameplayTags.Find('ARFMPYP_TimeWar'));
}
function EightSpawnExtra()
{
 local XComGameState_Unit U;
 local vector At;
 local StateObjectReference Ref;
 local name Template;
 local int C;
 C=default.Scenario;EightExtra=0;
 if(Actors.Length==0)return;
 if((C>=170 && C<=173)||C==151||C==182)Template='AdvMEC_M1';
 if(C==183)Template='AdvTrooperM1';
 if(Template=='')return;
 U=Unit(Actors[0]);At=PlaceFrom(U.TileLocation,2,1);
 Ref=`SPAWNMGR.CreateUnit(At,Template,eTeam_XCom,false,,,,"",true);EightExtra=Ref.ObjectID;
 LogInternal("R8|EXTRA|"$C$"|"$Template$"|"$EightExtra);
}
function EightPrepareTargets(XComGameState S)
{
 local XComGameState_Unit U,T,E;
 local XComGameState_Item W;
 local DamageResult D;
 local vector At;
 local TTile BeforeTile,Landing;
 local array<StateObjectReference> Occ;
 local int C;
 C=default.Scenario;if(C<150||Actors.Length==0||Soldiers.Length==0)return;
 U=XComGameState_Unit(S.GetGameStateForObjectID(Actors[0]));if(U==none)return;
 if(EightExtra>0)
 {
  E=XComGameState_Unit(S.GetGameStateForObjectID(EightExtra));if(E==none)E=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',EightExtra));
  At=PlaceFrom(U.TileLocation,2,1);E.SetVisibilityLocationFromVector(At);
  E.SetBaseMaxStat(eStat_HP,150);E.SetCurrentStat(eStat_HP,C==183?0:150);
  E.SetBaseMaxStat(eStat_Will,1);E.SetCurrentStat(eStat_Will,1);
 }
 if(C<170 || C>186)return;
 U.GiveStandardActionPoints();U.SetBaseMaxStat(eStat_PsiOffense,200);U.SetCurrentStat(eStat_PsiOffense,200);
 if(C<=174||C==182)
 {
  Cool(S,U,'Horror',6);
  LogInternal("R8|NATURALGRANT|"$C$"|"$U.FindAbility('ARFMPYP_GhostSignal').ObjectID);
 }
 if((C>=175 && C<=181) || C==185 || C==186)
 {
  LogInternal("R8|NATURALGRANT|"$C$"|"$U.FindAbility('ARFMPYP_TimeShift').ObjectID);
  BeforeTile=U.TileLocation;BuildVisibleTestTiles(Unit(U.ObjectID));Landing=BeforeTile;
  if(C!=176 && C!=180)
  {
   foreach TestTiles(Landing){Occ=`XWORLD.GetUnitsOnTile(Landing);if(Occ.Length==0 && !`XWORLD.IsTileOccupied(Landing) && `XWORLD.IsFloorTileAndValidDestination(Landing))break;}
   if(Landing==BeforeTile){At=PlaceFrom(BeforeTile,2,1);Landing=`XWORLD.GetTileCoordinatesFromPosition(At);}
   U.SetVisibilityLocation(Landing);
  }
  U.CHL_SetupActionsForBeginTurn(false,false,false,false,false,true,false);
  U.SetVisibilityLocation(BeforeTile);
  if(C==177)U.DamageResults.Length=0;
  if(C==185 || C==186)
  {
   E=XComGameState_Unit(S.GetGameStateForObjectID(Soldiers[C==185?1:0]));
   if(E==none)E=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',Soldiers[C==185?1:0]));
   E.SetVisibilityLocation(Landing);
  }

  if(C!=177){D.DamageAmount=7;U.DamageResults.AddItem(D);U.SetCurrentStat(eStat_HP,U.GetMaxStat(eStat_HP)-7);}
  T=XComGameState_Unit(S.GetGameStateForObjectID(Soldiers[0]));if(T==none)T=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',Soldiers[0]));
  D.DamageAmount=3;T.DamageResults.AddItem(D);T.SetCurrentStat(eStat_HP,170);
  Cool(S,U,'Stasis',6);Cool(S,U,'PriestStasis',6);
  if(C==178)Cool(S,U,'ARFMPYP_TimeShift',5);
 }
 if(C>=165&&C<=167){W=U.GetPrimaryWeapon();if(W!=none)LogInternal("R8|WEAPON|"$W.GetMyTemplateName());}
}
function EightTestPower()
{
 local XComGameState_Unit U,T;
 local X2AbilityTemplate B;
 local X2Condition Cond;
 local X2Condition_GameplayTag Tag;
 local XComGameState_Ability AB;
 local StateObjectReference Ref;
 local GameRulesCache_Unit Cache;
 local AvailableAction Act;
 local AvailableTarget Target;
 local name K;
 local int C,Index;
 local bool Ok;
 if(Actors.Length==0 || Soldiers.Length==0)return;
 C=default.Scenario;
 if(C>=170&&C<=174 || C==182)K='ARFMPYP_GhostSignal';
 else if((C>=175&&C<=181)||C==185||C==186)K='ARFMPYP_TimeShift';
 else if(C==183||C==184)K='ARFMDESW_Shadowhorde';
 else return;
 U=Unit(Actors[0]);T=Unit((EightExtra>0 && (C<=174||C>=182))?EightExtra:Soldiers[0]);
 if(U==none||T==none)return;
 B=class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(K);
 if(B==none)return;
 Ref=U.FindAbility(K); if(Ref.ObjectID>0)AB=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));
 foreach B.AbilityShooterConditions(Cond){Tag=X2Condition_GameplayTag(Cond);if(Tag!=none)LogInternal("R8|GATE|"$C$"|"$K$"|"$Tag.RequiredGameplayTag$"|"$Tag.CanEverBeValid(U,false));}
 LogInternal("R8|POWER|"$C$"|"$K$"|"$U.ObjectID$"|"$Ref.ObjectID$"|"$T.ObjectID$"|"$T.GetMyTemplateName()$"|"$U.TurnStartLocation.X$","$U.TurnStartLocation.Y$","$U.TurnStartLocation.Z$"|"$U.TileLocation.X$","$U.TileLocation.Y$","$U.TileLocation.Z$"|"$T.TileLocation.X$","$T.TileLocation.Y$","$T.TileLocation.Z$"|"$T.GetCurrentStat(eStat_HP));
 if(AB==none)return;
 foreach B.AbilityTargetConditions(Cond){if(Cond!=none && InStr(string(Cond.Class.Name),"CoarseTimeShift")>=0)LogInternal("R8|LANDING|"$C$"|"$Cond.CallMeetsConditionWithSource(T,U));}
 LogInternal("R8|VALID|"$C$"|"$B.CheckShooterConditions(AB,U)$"|"$B.CheckTargetConditions(AB,U,T)$"|"$AB.CanActivateAbility(U));
 `TACTICALRULES.GetGameRulesCache_Unit(U.GetReference(),Cache);
 foreach Cache.AvailableActions(Act){if(Act.AbilityObjectRef.ObjectID!=Ref.ObjectID)continue;
 LogInternal("R8|CACHE|"$C$"|"$Act.AvailableCode$"|"$Act.AvailableTargets.Length);
 if(Act.AvailableCode!='AA_Success')return;
 foreach Act.AvailableTargets(Target,Index){if(Target.PrimaryTarget.ObjectID==T.ObjectID){
 if(C==170||C==171||C==174||C==175||C==176||C==177||C==178||C==183||C==185||C==186){
 Ok=class'XComGameStateContext_Ability'.static.ActivateAbility(Act,Index);LogInternal("R8|INPUT|"$C$"|"$K$"|"$Ok);}
 return;}}
 if((C==175||C==177) && Act.AvailableTargets.Length>0){Ok=class'XComGameStateContext_Ability'.static.ActivateAbility(Act,0);LogInternal("R8|INPUTALTERNATE|"$C$"|"$Act.AvailableTargets[0].PrimaryTarget.ObjectID$"|"$Ok);}
 }
}
function EightPowerFrame(XComGameStateContext_Ability AC,int F)
{
 local XComGameState_Unit U,Before,After;
 local name K;
 if(AC==none||AC.InterruptionStatus==eInterruptionStatus_Interrupt)return;
 K=AC.InputContext.AbilityTemplateName;
 if(K!='ARFMPYP_TimeShift' && K!='ARFMPYP_GhostSignal' && K!='ARFMDESW_Shadowhorde')return;
 U=Unit(AC.InputContext.SourceObject.ObjectID,F-1);Before=Unit(AC.InputContext.PrimaryTarget.ObjectID,F-1);After=Unit(AC.InputContext.PrimaryTarget.ObjectID,F);
 if(U==none||Before==none||After==none)return;
 LogInternal("R8|POWERFRAME|"$default.Scenario$"|"$F$"|"$K$"|"$U.ObjectID$"|"$Before.ObjectID$"|"$U.TurnStartLocation.X$","$U.TurnStartLocation.Y$","$U.TurnStartLocation.Z$"|"$Before.TileLocation.X$","$Before.TileLocation.Y$","$Before.TileLocation.Z$"|"$After.TileLocation.X$","$After.TileLocation.Y$","$After.TileLocation.Z$"|"$Before.GetCurrentStat(eStat_HP)$"|"$After.GetCurrentStat(eStat_HP)$"|"$Before.DamageResults.Length$"|"$After.DamageResults.Length$"|"$Before.GetTeam()$"|"$After.GetTeam());
}

function GemSet(XComGameState_AdventChosen CS, int CI,int KI,int LI)
{
 local name K;
 foreach default.GemCaps(K)CS.Strengths.RemoveItem(K);
 foreach default.GemKeys(K)CS.Strengths.RemoveItem(K);
 foreach default.GemLodes(K)CS.Strengths.RemoveItem(K);
 CS.Strengths.AddItem(default.GemCaps[CI]);CS.Strengths.AddItem(default.GemKeys[KI]);CS.Strengths.AddItem(default.GemLodes[LI]);
}
function GemWorld(XComGameState S)
{
 local X2StrategyElementTemplateManager M;local X2DataTemplate D;local X2AdventChosenTemplate T;local X2CharacterTemplate RoleTemplate;
 local XComGameState_HeadquartersAlien HQ;local XComGameState_AdventChosen CS;local array<name> Seen;
 local int C,N,CI,KI,LI;local name K;
 C=default.Scenario;if(C<190||C>199)return;
 foreach S.IterateByClassType(class'XComGameState_HeadquartersAlien',HQ)break;
 if(HQ==none)return;
 M=class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
 foreach M.IterateTemplates(D)
 {
  T=X2AdventChosenTemplate(D);if(T==none)continue;RoleTemplate=class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate(T.GetProgressionTemplate(2));if(RoleTemplate==none||Seen.Find(RoleTemplate.CharacterGroupName)!=INDEX_NONE)continue;Seen.AddItem(RoleTemplate.CharacterGroupName);
  CS=HQ.GetChosenOfTemplate(RoleTemplate.CharacterGroupName);
  if(CS==none){CS=T.CreateInstanceFromTemplate(S);HQ.AdventChosen.AddItem(CS.GetReference());}
  else CS=XComGameState_AdventChosen(S.ModifyStateObject(class'XComGameState_AdventChosen',CS.ObjectID));
  CS.Level=2;CS.NumVictories=3;CS.NumEncounters=5;CS.NumDefeats=8;
  N=InStr(Caps(string(RoleTemplate.CharacterGroupName)),"ASSASSIN")>=0?0:(InStr(Caps(string(RoleTemplate.CharacterGroupName)),"WARLOCK")>=0?2:1);
  CI=(C-190+N*3)%8;KI=(C-190+N)%8;LI=(C-190+N*2)%9;
  if(C==199){CI=0;KI=7;LI=N==1?2:3;}
  if(C==198){CI=3;KI=7;LI=N==1?2:3;}
  GemSet(CS,CI,KI,LI);foreach default.GemDeds(K)CS.Strengths.RemoveItem(K);
  CS.Strengths.AddItem(default.GemDeds[(C-190+N)%5]);
  LogInternal("R8|GEMWORLD|"$C$"|"$T.DataName$"|"$RoleTemplate.CharacterGroupName$"|"$CS.ObjectID$"|"$default.GemCaps[CI]$"|"$default.GemKeys[KI]$"|"$default.GemLodes[LI]$"|"$default.GemDeds[(C-190+N)%5]);
 }
}
function GemMatrixStep()
{
 local int I,J,CI,KI,LI,ID,NC,NK,NL,Other,Missing,Before;
 local name K,Extra;
 local XComGameState_Unit U,CopyUnit;local XComGameState S,Probe;
 local XComGameState_AdventChosen CS;local XComGameState_Player Pl;
 local array<AbilitySetupData> Data;local AbilitySetupData D;
 local array<XComGameState_Item> Items;local XComGameState_Item Item;
 for(I=0;I<5 && GemIndex<576;++I)
 {
  Before=GemIndex;CI=Before/72;KI=(Before/9)%8;LI=Before%9;
  S=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Assign one set of Chosen strengths");
  foreach Actors(ID)
  {
   U=Unit(ID);if(U==none)continue;CS=U.GetChosenGameState();if(CS==none)continue;
   CS=XComGameState_AdventChosen(S.ModifyStateObject(class'XComGameState_AdventChosen',CS.ObjectID));GemSet(CS,CI,KI,LI);
  }
  if(S.GetNumGameStateObjects()>0)`TACTICALRULES.SubmitGameState(S);else `XCOMHISTORY.CleanupPendingGameState(S);
  foreach Actors(ID)
  {
   U=Unit(ID);if(U==none)continue;Pl=XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(U.ControllingPlayer.ObjectID));
   Probe=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Gather tactical abilities for one Chosen loadout");
   CopyUnit=XComGameState_Unit(Probe.ModifyStateObject(class'XComGameState_Unit',ID));CopyUnit.Abilities.Length=0;
   Items=U.GetAllInventoryItems();foreach Items(Item)Probe.ModifyStateObject(Item.Class,Item.ObjectID);
   Data=CopyUnit.GatherUnitAbilitiesForInit(Probe,Pl);NC=0;NK=0;NL=0;Other=0;Missing=0;
   foreach Data(D)
   {
    K=D.TemplateName;
    if(K==default.GemCaps[CI])++NC;else if(K==default.GemKeys[KI])++NK;else if(K==default.GemLodes[LI])++NL;
    else if(default.GemCaps.Find(K)!=INDEX_NONE || default.GemKeys.Find(K)!=INDEX_NONE || default.GemLodes.Find(K)!=INDEX_NONE){++Other;continue;}else continue;
    if(D.Template==none){++Missing;continue;}
    foreach D.Template.AdditionalAbilities(Extra)if(Data.Find('TemplateName',Extra)==INDEX_NONE){++Missing;LogInternal("R8|GEMCHILD|"$Before$"|"$U.GetMyTemplateName()$"|"$K$"|"$Extra);}
   }
   J=U.GetPrimaryWeapon().ObjectID;
   LogInternal("R8|COMBO|"$Before$"|"$U.GetMyTemplateName()$"|"$default.GemCaps[CI]$"|"$default.GemKeys[KI]$"|"$default.GemLodes[LI]$"|"$NC$","$NK$","$NL$"|"$Other$"|"$Missing$"|"$Data.Length$"|"$J);
   `XCOMHISTORY.CleanupPendingGameState(Probe);
  }
  ++GemIndex;
 }
 if(GemIndex==576)
 {
  S=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Restore field strengths after matrix");foreach Actors(ID,J)
  {
   U=Unit(ID);if(U==none)continue;CS=U.GetChosenGameState();if(CS==none)continue;
   CS=XComGameState_AdventChosen(S.ModifyStateObject(class'XComGameState_AdventChosen',CS.ObjectID));
   GemSet(CS,(J*3)%8,J%8,(J*2)%9);
  }
  if(S.GetNumGameStateObjects()>0)`TACTICALRULES.SubmitGameState(S);else `XCOMHISTORY.CleanupPendingGameState(S);
 }
}

function GemPlaceCover()
{
 local XComWorldData W;local XComGameState S;local XComGameState_Unit U,T;
 local TTile Base,F,Cell;local vector ShooterAt,P;
 local int R,DX,DY,Mask,Bit,Index;local float Angle;local ECoverType Cover;
 if(Actors.Length==0 || Soldiers.Length<3)return;
 U=Unit(Actors[0]);if(U==none)return;
 W=`XWORLD;Base=U.TileLocation;ShooterAt=W.GetPositionFromTileCoordinates(Base);
 S=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Place three opponents in directional cover");
 for(R=2;R<=12 && Mask!=7;++R)for(DX=-R;DX<=R && Mask!=7;++DX)for(DY=-R;DY<=R && Mask!=7;++DY)
 {
  if(Abs(DX)!=R && Abs(DY)!=R)continue;
  Cell=Base;Cell.X+=DX;Cell.Y+=DY;if(Cell.X<1||Cell.Y<1||Cell.X>=W.NumX-1||Cell.Y>=W.NumY-1)continue;
  P=W.GetPositionFromTileCoordinates(Cell);if(!W.GetFloorTileForPosition(P,F,true) || Abs(Base.Z-F.Z)>1 || !W.CanUnitsEnterTile(F) || W.IsTileOccupied(F))continue;
  if(!class'X2TacticalVisibilityHelpers'.static.CanUnitSeeLocation(U.ObjectID,F))continue;
  P=W.GetPositionFromTileCoordinates(F);Cover=class'XComWorldData'.static.GetCoverTypeForTarget(ShooterAt,P,Angle);
  Index=Cover==CT_Standing?2:(Cover==CT_Midlevel?1:0);Bit=1<<Index;if((Mask&Bit)!=0)continue;
  T=Unit(Soldiers[Index]);if(T==none || !T.IsAlive() || T.IsIncapacitated())continue;
  T=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',T.ObjectID));T.SetVisibilityLocation(F);Mask=Mask|Bit;
 }
 if(Mask>0)`TACTICALRULES.SubmitGameState(S);else `XCOMHISTORY.CleanupPendingGameState(S);
 LogInternal("R8|GEMLAYOUT|"$default.Scenario$"|"$Mask);
}
function GemCheckCover()
{
 local int ID,TID,I,Hits,Crits,OH,OC;
 local XComGameState_Unit U,T;local XComGameState_AdventChosen CS;
 local X2AbilityTemplate B;local X2Effect_Persistent E,O;local X2Effect Eff;local name K;
 local GameRulesCache_VisibilityInfo Info;local array<ShotModifierInfo> Mods,Orig;local ShotModifierInfo M;
 local XComGameState_Effect EState;local StateObjectReference R;
 foreach Actors(ID)
 {
  U=Unit(ID);if(U==none || !U.IsChosen())continue;CS=U.GetChosenGameState();if(CS==none){LogInternal("R8|NOCHOSEN|"$ID);continue;}
  foreach CS.Strengths(K)if(default.GemCaps.Find(K)!=INDEX_NONE || default.GemKeys.Find(K)!=INDEX_NONE ||default.GemLodes.Find(K)!=INDEX_NONE || default.GemDeds.Find(K)!=INDEX_NONE)
    LogInternal("R8|GEMKIT|"$default.Scenario$"|"$U.GetMyTemplateName()$"|"$K$"|"$U.FindAbility(K).ObjectID);
  foreach U.AffectedByEffects(R){EState=XComGameState_Effect(`XCOMHISTORY.GetGameStateForObjectID(R.ObjectID));if(EState!=none && EState.GetX2Effect()!=none)LogInternal("R8|GEMEFFECT|"$default.Scenario$"|"$U.GetMyTemplateName()$"|"$EState.GetX2Effect().Class.Name$"|"$EState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID);}
  for(I=0;I<2;++I)
  {
   K=I==0?'ARFMDedicationPower':'ARFMDedicationChange';B=class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(K);
   if(I==0)O=new class'ARFM_Dedication_Power';else O=new class'ARFM_Dedication_Change';
   E=none;foreach B.AbilityTargetEffects(Eff)if(X2Effect_Persistent(Eff)!=none)E=X2Effect_Persistent(Eff);
   if(E==none)continue;
   foreach Soldiers(TID)
   {
    T=Unit(TID);if(T==none || !T.IsAlive() || !`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(ID,TID,Info) || !Info.bVisibleGameplay)continue;
    Mods.Length=0;Orig.Length=0;E.GetToHitModifiers(none,U,T,none,class'X2AbilityToHitCalc_StandardAim',false,false,false,Mods);
    O.GetToHitModifiers(none,U,T,none,class'X2AbilityToHitCalc_StandardAim',false,false,false,Orig);
    Hits=0;Crits=0;OH=0;OC=0;foreach Mods(M){if(M.ModType==eHit_Success)Hits+=M.Value;if(M.ModType==eHit_Crit)Crits+=M.Value;}
    foreach Orig(M){if(M.ModType==eHit_Success)OH+=M.Value;if(M.ModType==eHit_Crit)OC+=M.Value;}
    LogInternal("R8|DEDCOVER|"$default.Scenario$"|"$U.GetMyTemplateName()$"|"$K$"|"$Info.TargetCover$"|"$CS.NumVictories$","$CS.NumEncounters$"|"$U.CanFlank()$","$T.CanTakeCover()$"|"$OH$","$OC$"|"$Hits$","$Crits$"|"$E.Class.Name);
   }
  }
 }
}
function GemHistory(XComGameStateContext_Ability AC,int F)
{
 local XComGameState_Unit U,V,T0,T1;local int H0,H1;
 if(default.Scenario<190 || default.Scenario>199 || AC==none || RoundNo==0 || AC.InterruptionStatus==eInterruptionStatus_Interrupt || Actors.Find(AC.InputContext.SourceObject.ObjectID)==INDEX_NONE)return;
 U=Unit(AC.InputContext.SourceObject.ObjectID,F-1);V=Unit(AC.InputContext.SourceObject.ObjectID,F);if(U==none||V==none)return;
 if(AC.InputContext.PrimaryTarget.ObjectID>0){T0=Unit(AC.InputContext.PrimaryTarget.ObjectID,F-1);T1=Unit(AC.InputContext.PrimaryTarget.ObjectID,F);}
 if(T0!=none)H0=T0.GetCurrentStat(eStat_HP);if(T1!=none)H1=T1.GetCurrentStat(eStat_HP);
 LogInternal("R8|GEMACT|"$default.Scenario$"|"$F$"|"$U.GetMyTemplateName()$"|"$AC.InputContext.AbilityTemplateName$"|"$AC.InputContext.PrimaryTarget.ObjectID$"|"$H0$","$H1$"|"$U.ActionPoints.Length$","$V.ActionPoints.Length$"|"$U.ReserveActionPoints.Length$","$V.ReserveActionPoints.Length$"|"$AC.ResultContext.HitResult);
}

function name PyUnlock(int Choice)
{
 switch(Choice)
 {
 case 57:return 'PYPDroneOverlordsUnlock';
 case 64:return 'PYPExecutionUnlock';
 case 65:return 'PYPMarkedForDeathUnlock';
 }
 return '';
}
function PyDebuff(XComGameState S,XComGameState_Unit T,name Status)
{
 local XComGameState_Effect_ReviewStatus E;
 E=XComGameState_Effect_ReviewStatus(S.CreateNewStateObject(class'XComGameState_Effect_ReviewStatus'));
 E.StatusTemplate=new class'X2Effect_Persistent';E.StatusTemplate.EffectName=Status;T.AddAffectingEffect(E);
}
function PyUnlockModifiers(XComGameState S,XComGameState_Unit T, array<AbilitySetupData> Data, array<int> Choices)
{
 local int Stage,Sum,Dmg;local bool HasUnlock;local name K;local AbilitySetupData D;
 local X2Effect E;local X2Effect_Persistent Buff;local EffectAppliedData Context;
 local array<ShotModifierInfo> Mods; local ShotModifierInfo M;
 if(T.GetTeam()!=eTeam_XCom || Choices.Length>2)return;
 foreach Data(D)if(D.TemplateName=='ARFMPYP_DroneOverlords' || D.TemplateName=='ARFMPYP_SummaryExecution' || D.TemplateName=='ARFMPYP_MarkedForDeath')HasUnlock=true;
 if(!HasUnlock && Choices.Length!=0)return;
 for(Stage=0;Stage<3;++Stage)
 {
  if(Stage==1){PyDebuff(S,T,'MarkedTarget');PyDebuff(S,T,'Disoriented');}
  if(Stage==2){PyDebuff(S,T,'MindControl');PyDebuff(S,T,'Stunned');T.StunnedActionPoints=2;}
  Sum=0;Dmg=0;
  foreach Data(D)
  {
   K=D.TemplateName;if(K!='ARFMPYP_DroneOverlords' && K!='ARFMPYP_SummaryExecution' && K!='ARFMPYP_MarkedForDeath')continue;
   foreach D.Template.AbilityTargetEffects(E)
   {
    Buff=X2Effect_Persistent(E);if(Buff==none)continue;
    Mods.Length=0;Buff.GetToHitAsTargetModifiers(none,Unit(Actors[0]),T,none,none,false,false,false,Mods);
    foreach Mods(M)if(M.ModType==eHit_Success)Sum+=M.Value;
    Dmg+=Buff.GetDefendingDamageModifier(none,Unit(Actors[0]),T,none,Context,10,none,S);
   }
  }
  LogInternal("R8|PYUNLOCKMOD|"$default.Scenario$"|"$JoinPoison(Choices)$"|"$Stage$"|"$T.IsDisoriented()$","$T.IsStunned()$","$T.IsUnitAffectedByEffectName('MarkedTarget')$","$T.IsUnitAffectedByEffectName('MindControl')$"|"$Sum$"|"$Dmg);
 }
}
function ProbeLanding()
{
 local XComGameState_Unit U,T;
 local XComGameState S;
 local XComWorldData W;
 local int R,DX,DY,DZ,Floors,Passable,Clear;
 local TTile D,At;local array<StateObjectReference> Refs;
 local X2Condition Co;local X2AbilityTemplate B;
 if(Actors.Length==0 || Soldiers.Length==0)return;
 U=Unit(Actors[0]);T=Unit(Soldiers[0]);W=`XWORLD;At=U.TileLocation;
 for(R=1;R<=8;++R)for(DZ=-1;DZ<=1;++DZ)for(DX=-R;DX<=R;++DX)for(DY=-R;DY<=R;++DY)
 {
  if(Max(Abs(DX),Abs(DY))!=R)continue;
  D=At;D.X+=DX;D.Y+=DY;D.Z+=DZ;
  if(!W.IsFloorTileAndValidDestination(D,T))continue;++Floors;
  if(!W.CanUnitsEnterTile(D))continue;++Passable;
  Refs=W.GetUnitsOnTile(D);if(W.IsTileOccupied(D) || Refs.Length>0)continue;++Clear;
  S=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Free starting tile for Time Shift");
  U=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',U.ObjectID));
  U.SetVisibilityLocation(D);U.CHL_SetupActionsForBeginTurn(false,false,false,false,false,true,false);U.SetVisibilityLocation(At);
  `TACTICALRULES.SubmitGameState(S);U=Unit(Actors[0]);D=U.TurnStartLocation;Refs=W.GetUnitsOnTile(D);
  B=class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('ARFMPYP_TimeShift');
  foreach B.AbilityTargetConditions(Co)if(InStr(string(Co.Class.Name),"CoarseTimeShift")>=0)
  {
   LogInternal("R8|LANDSCAN|"$default.Scenario$"|"$D.X$","$D.Y$","$D.Z$"|"$At.X$","$At.Y$","$At.Z$"|"$W.IsFloorTileAndValidDestination(D)$","$W.IsFloorTileAndValidDestination(D,T)$","$W.CanUnitsEnterTile(D)$","$W.IsTileOccupied(D)$","$Refs.Length$"|"$Co.CallMeetsConditionWithSource(T,U));
   if(Co.CallMeetsConditionWithSource(T,U)=='AA_Success')return;
  }
  if(Clear>=10){LogInternal("R8|LANDNONE|"$default.Scenario$"|"$Floors$","$Passable$","$Clear);return;}
 }
 LogInternal("R8|LANDNONE|"$default.Scenario$"|"$Floors$","$Passable$","$Clear);
}
function LootOriginal(bool Revert)
{
 local X2AbilityTemplate B;local X2AbilityTrigger_EventListener L;local int I;
 B=class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('ARFMPYP_MassiveDay');
 if(B==none)return;
 for(I=0;I<B.AbilityTriggers.Length;++I)
 {
  L=X2AbilityTrigger_EventListener(B.AbilityTriggers[I]);if(L==none || L.ListenerData.EventID!='UnitMoveFinished')continue;
  if(SavedSectoidListener==none)SavedSectoidListener=L;
  if(Revert){L=new class'X2AbilityTrigger_EventListener'(SavedSectoidListener);L.ListenerData.EventFn=class'XComGameState_Ability'.static.AbilityTriggerEventListener_EndOfMoveLoot;B.AbilityTriggers[I]=L;}
  else B.AbilityTriggers[I]=SavedSectoidListener;
 }
}
function LootStart()
{
 local XComGameState_Unit U;local XComTacticalController Ctrl;local XComWorldData W;local XGUnit Pawn;local XComGameState S;
 local XComGameState_LootDrop D;local XComGameState_Item Item;local X2ItemTemplate IT;local array<XComGameState_Item> Items;
 local int R,DX,DY,DZ;local bool Found;local TTile Dest,DropAt;local array<TTile> Tiles;
 U=Unit(Actors[0]);W=`XWORLD;Ctrl=XComTacticalController(class'Engine'.static.GetCurrentWorldInfo().GetALocalPlayerController());Pawn=XGUnit(U.GetVisualizer());
 LootDropID=0;LootItemID=0;
 for(R=1;R<=4 && !Found;++R)for(DX=-R;DX<=R && !Found;++DX)for(DY=-R;DY<=R && !Found;++DY)for(DZ=-1;DZ<=1 && !Found;++DZ)
 {
  if(Max(Abs(DX),Abs(DY))!=R)continue;Dest=U.TileLocation;Dest.X+=DX;Dest.Y+=DY;Dest.Z+=DZ;
  if(!W.CanUnitsEnterTile(Dest) || W.IsTileOccupied(Dest) || !W.IsFloorTileAndValidDestination(Dest,U))continue;
  Tiles.Length=0;if(!class'X2PathSolver'.static.BuildPath(U,U.TileLocation,Dest,Tiles,true) || Tiles.Length<2 || Tiles.Length>6)continue;Found=true;
 }
 if(!Found){LogInternal("R8|LOOTNOPATH|"$default.Scenario);return;}
 DropAt=Dest;if(default.Scenario==241)DropAt.X+=24;
 S=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Place a tracked dropped Elerium Core");
 IT=class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate('EleriumCore');
 if(IT==none){`XCOMHISTORY.CleanupPendingGameState(S);return;}
 Item=IT.CreateInstanceFromTemplate(S);Items.AddItem(Item);LootItemID=Item.ObjectID;
 class'XComGameState_LootDrop'.static.CreateLootDrop(S,Items,U,false);
 foreach S.IterateByClassType(class'XComGameState_LootDrop',D){D.TileLocation=DropAt;LootDropID=D.ObjectID;break;}
 `TACTICALRULES.SubmitGameState(S);
 LogInternal("R8|LOOTMOVE|"$default.Scenario$"|"$U.ObjectID$"|"$LootDropID$"|"$LootItemID$"|"$U.FindAbility('Loot').ObjectID$"|"$U.FindAbility('ARFMPYP_MassiveDay').ObjectID$"|"$Dest.X$","$Dest.Y$","$Dest.Z$"|"$DropAt.X$","$DropAt.Y$","$DropAt.Z$"|"$Ctrl.GameStateMoveUnitSingle(Pawn,Tiles,true));
}
function LootResult()
{
 local XComGameState_Unit U;local XComGameState_LootDrop D;local XComGameState_Item Item;local XComGameState_Ability AB;local GameRulesCache_Unit Cache;local AvailableAction A;local int Left,InPack;local array<StateObjectReference> Items;
 U=Unit(Actors[0]);D=XComGameState_LootDrop(`XCOMHISTORY.GetGameStateForObjectID(LootDropID));Item=XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(LootItemID));
 if(D!=none){Items=D.GetAvailableLoot();Left=Items.Length;}else Left=-1;
 if(Item!=none && U.InventoryItems.Find('ObjectID',LootItemID)!=INDEX_NONE)InPack=1;
 AB=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(U.FindAbility('ARFMPYP_MassiveDay').ObjectID));
 if(AB!=none && D!=none){`TACTICALRULES.GetGameRulesCache_Unit(U.GetReference(),Cache);foreach Cache.AvailableActions(A)if(A.AbilityObjectRef.ObjectID==AB.ObjectID)LogInternal("R8|LOOTVALID|"$default.Scenario$"|"$AB.GetMyTemplate().CheckTargetConditions(AB,U,D)$"|"$A.AvailableCode$"|"$A.AvailableTargets.Length);}
 LogInternal("R8|LOOTRESULT|"$default.Scenario$"|"$U.ObjectID$"|"$U.TileLocation.X$","$U.TileLocation.Y$","$U.TileLocation.Z$"|"$Left$"|"$InPack$"|"$Item.OwnerStateObject.ObjectID$"|"$Item.InventorySlot);
}
function PySetTags(array<int> Choices)
{
 local XComGameState S;
 local XComGameState_HeadquartersXCom HQ;
 local int I;local name Unlock;local bool WithUnlock;local XComGameState_Player Pl;local XComGameState UnlockState;local XComGameState_HeadquartersXCom Offered;
 S=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Set recorded PYP choices in order");
 HQ=XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
 HQ=XComGameState_HeadquartersXCom(S.ModifyStateObject(class'XComGameState_HeadquartersXCom',HQ.ObjectID));
 HQ.TacticalGameplayTags=PyBaseTags;
 foreach Choices(I)if(PyUnlock(I)!='')WithUnlock=true;
 if(WithUnlock)UnlockState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Check health penalties on the HQ soldier unlock list");
 foreach Choices(I)
 {
  Unlock=PyUnlock(I);
  if(Unlock!=''){class'ARFM_SE_YearningMutators'.static.AddChosenUnlock(UnlockState,Unlock);continue;}
  if(default.PyTags[I]!='' && HQ.TacticalGameplayTags.Find(default.PyTags[I])==INDEX_NONE)HQ.TacticalGameplayTags.AddItem(default.PyTags[I]);
 }
 if(WithUnlock || PyPreviouslyUsedUnlock)
 {
  if(WithUnlock)Offered=XComGameState_HeadquartersXCom(UnlockState.GetGameStateForObjectID(HQ.ObjectID));
  foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Player',Pl)
   if(Pl.TeamFlag==eTeam_XCom){Pl=XComGameState_Player(S.ModifyStateObject(class'XComGameState_Player',Pl.ObjectID));if(Offered!=none){Pl.SoldierUnlockTemplates=Offered.SoldierUnlockTemplates;}else Pl.SoldierUnlockTemplates=PyBaseUnlocks;break;}
 }
 if(UnlockState!=none)`XCOMHISTORY.CleanupPendingGameState(UnlockState);
 PyPreviouslyUsedUnlock=WithUnlock;
 `TACTICALRULES.SubmitGameState(S);
}
function string PyRead(int ID, array<int> Choices)
{
 local XComGameState S;local XComGameState_Unit U,T;local XComGameState_Player Pl;
 local array<AbilitySetupData> Data;local AbilitySetupData D;local array<XComGameState_Item> Items;local XComGameState_Item Item;
 local X2EquipmentTemplate GearTemplate;local XComGameState_Item Other,Added,Binding;
 local array<name> Tags,Gear;local name K;local int I;local string Sig;
 U=Unit(ID);if(U==none)return "MISSING";
 Pl=XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(U.ControllingPlayer.ObjectID));
 S=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Gather PYP grants on unit and equipment");
 T=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',ID));T.Abilities.Length=0;Items=U.GetAllInventoryItems();foreach Items(Item)S.ModifyStateObject(Item.Class,Item.ObjectID);
 Tags=PyBaseTags;foreach Choices(I)if(default.PyTags[I]!='')Tags.AddItem(default.PyTags[I]);
 class'CoarseYearningEquipment'.static.GetTaggedGear(string(U.GetMyTemplateName()),Tags,Gear);
 T.bIgnoreItemEquipRestrictions=true;
 foreach Gear(K)
 {
  GearTemplate=X2EquipmentTemplate(class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate(K));
  if(GearTemplate==none || T.HasItemOfTemplateType(K,S))continue;
  if(GearTemplate.InventorySlot==eInvSlot_PrimaryWeapon || GearTemplate.InventorySlot==eInvSlot_SecondaryWeapon || GearTemplate.InventorySlot==eInvSlot_HeavyWeapon)
  {
   Other=T.GetItemInSlot(GearTemplate.InventorySlot,S);
   if(Other!=none && !T.RemoveItemFromInventory(Other,S)){LogInternal("R8|PYGEARFAIL|"$U.GetMyTemplateName()$"|"$K$"|remove");continue;}
  }
  Added=GearTemplate.CreateInstanceFromTemplate(S);
  if(!T.AddItemToInventory(Added,GearTemplate.InventorySlot,S))LogInternal("R8|PYGEARFAIL|"$U.GetMyTemplateName()$"|"$K$"|add");
 }
 T.bIgnoreItemEquipRestrictions=U.bIgnoreItemEquipRestrictions;
 Data=T.GatherUnitAbilitiesForInit(S,Pl);
 foreach Data(D){Binding=none;
  if(D.SourceWeaponRef.ObjectID>0){Binding=XComGameState_Item(S.GetGameStateForObjectID(D.SourceWeaponRef.ObjectID));if(Binding==none)Binding=XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(D.SourceWeaponRef.ObjectID));}
  Sig$=string(D.TemplateName)$(Binding==none?"":"@"$Binding.GetMyTemplateName())$",";
 }
 foreach Gear(K)Sig$="gear:"$string(K)$",";
 if(U.GetTeam()==eTeam_XCom)PyUnlockModifiers(S,T,Data,Choices);
 `XCOMHISTORY.CleanupPendingGameState(S);
 return Sig$"!END!";
}
function PyMatrixStep()
{
 local XComGameState_HeadquartersXCom HQ;local int I,J,ID,A,B,K;local name T;
 local array<int> Selected;local string Sig;local PySubject PS;local bool Repeat;
 if(PyPhase==0)
 {
  PyUnits.Length=0;PySolo=0;PyWho=0;PyFirst=0;PySecond=1;
  HQ=XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));PyBaseTags=HQ.TacticalGameplayTags;
  PyBaseUnlocks=HQ.SoldierUnlockTemplates;PyBaseUnlocks.RemoveItem('PYPDroneOverlordsUnlock');PyBaseUnlocks.RemoveItem('PYPExecutionUnlock');PyBaseUnlocks.RemoveItem('PYPMarkedForDeathUnlock');PyPreviouslyUsedUnlock=true;
  foreach default.PyTags(T)if(T!='')PyBaseTags.RemoveItem(T);
  PySetTags(Selected);
  foreach Actors(ID){if(Unit(ID).GetMyTemplateName()=='Soldier' && Soldiers.Length>0)ID=Soldiers[0];PS.UnitID=ID;LogInternal("R8|PYTEAM|"$default.Scenario$"|"$Unit(ID).GetMyTemplateName()$"|"$Unit(ID).GetTeam());PS.Base=PyRead(ID,Selected);PS.Options.Length=0;PyUnits.AddItem(PS);LogInternal("R8|PYBASE|"$default.Scenario$"|"$Unit(ID).GetMyTemplateName()$"|"$PS.Base);}
  PyPhase=1;return;
 }
 if(PyPhase==1)
 {
  for(I=0;I<6 && PySolo<default.PyTags.Length;++I)
  {
   A=PySolo++;if(default.PyTags[A]=='' && PyUnlock(A)=='')continue;Selected.Length=0;Selected.AddItem(A);PySetTags(Selected);
   foreach PyUnits(PS,J){Sig=PyRead(PS.UnitID,Selected);if(Sig==PS.Base)continue;PyUnits[J].Options.AddItem(A);LogInternal("R8|PYSINGLE|"$default.Scenario$"|"$Unit(PS.UnitID).GetMyTemplateName()$"|"$A$"|"$Sig);}
  }
  if(PySolo>=default.PyTags.Length)PyPhase=2;return;
 }
 for(K=0;K<10 && PyWho<PyUnits.Length;++K)
 {
  PS=PyUnits[PyWho];if(PyFirst>=PS.Options.Length-1){++PyWho;PyFirst=0;PySecond=1;continue;}
  if(PySecond>=PS.Options.Length){++PyFirst;PySecond=PyFirst+1;continue;}
  A=PS.Options[PyFirst];B=PS.Options[PySecond++];if(default.PyCards[A]==default.PyCards[B])continue;
  for(I=0;I<2;++I){Selected.Length=0;Selected.AddItem(I==0?A:B);Selected.AddItem(I==0?B:A);PySetTags(Selected);Sig=PyRead(PS.UnitID,Selected);LogInternal("R8|PYPAIR|"$default.Scenario$"|"$Unit(PS.UnitID).GetMyTemplateName()$"|"$Selected[0]$"|"$Selected[1]$"|"$Sig);}
 }
 if(PyWho<PyUnits.Length)return;
 foreach PyUnits(PS)
 {
  Selected.Length=0;
  foreach PS.Options(A){Repeat=false;foreach Selected(B)if(default.PyCards[A]==default.PyCards[B])Repeat=true;if(!Repeat)Selected.AddItem(A);}
  if(Selected.Length<3)continue;
  for(I=0;I<2;++I)
  {
   if(I==1){for(J=0;J<Selected.Length/2;++J){A=Selected[J];Selected[J]=Selected[Selected.Length-1-J];Selected[Selected.Length-1-J]=A;}}
   PySetTags(Selected);Sig=PyRead(PS.UnitID,Selected);LogInternal("R8|PYMULTI|"$default.Scenario$"|"$Unit(PS.UnitID).GetMyTemplateName()$"|"$I$"|"$JoinPoison(Selected)$"|"$Sig);
  }
 }
 Selected.Length=0;PySetTags(Selected);PyPhase=3;LogInternal("R8|PYDONE|"$default.Scenario$"|"$PyUnits.Length);
}
function string JoinPoison(array<int> Values)
{
 local string OutText;local int I;foreach Values(I)OutText$=string(I)$",";return OutText;
}
function PySamples(XComGameState S)
{
 local XComGameState_HeadquartersXCom HQ;local array<int> Choices;local int I,J;local name K;
 if(default.Scenario<220 || default.Scenario>237)return;
 foreach S.IterateByClassType(class'XComGameState_HeadquartersXCom',HQ)break;
 if(HQ==none)return;
 foreach default.PyTags(K)if(K!='')HQ.TacticalGameplayTags.RemoveItem(K);
 if(default.Scenario<=221){Choices.AddItem(10);Choices.AddItem(14);Choices.AddItem(165);Choices.AddItem(132);Choices.AddItem(157);Choices.AddItem(21);}
 else if(default.Scenario<=223){Choices.AddItem(9);Choices.AddItem(13);Choices.AddItem(3);}
 else if(default.Scenario<=225){Choices.AddItem(24);Choices.AddItem(144);Choices.AddItem(135);Choices.AddItem(117);}
 else if(default.Scenario<=227){Choices.AddItem(83);Choices.AddItem(96);Choices.AddItem(72);}
 else if(default.Scenario<=229){Choices.AddItem(7);Choices.AddItem(12);Choices.AddItem(18);Choices.AddItem(79);Choices.AddItem(153);}
 else if(default.Scenario<=231){Choices.AddItem(32);Choices.AddItem(70);}
 else if(default.Scenario<=233){Choices.AddItem(19);Choices.AddItem(28);Choices.AddItem(37);}
 else if(default.Scenario<=235){Choices.AddItem(38);Choices.AddItem(159);Choices.AddItem(75);}
 else if(default.Scenario<=237){Choices.AddItem(36);Choices.AddItem(125);}
 for(J=0;J<Choices.Length;++J){I=Choices[default.Scenario%2==0?J:Choices.Length-1-J];HQ.TacticalGameplayTags.AddItem(default.PyTags[I]);}
 LogInternal("R8|PYSTACK|"$default.Scenario$"|"$JoinPoison(Choices));
}
function PyEquipment()
{
 local XComGameState_Unit U;local int ID;local array<XComGameState_Item> Items;local XComGameState_Item Item;local StateObjectReference Ref;
 local XComGameState_Ability AB;local XComGameState_Effect E;local string A,G,P,Values;local int J;
 foreach Actors(ID)
 {
  U=Unit(ID);if(U==none)continue;A="";G="";P="";
  Items=U.GetAllInventoryItems();foreach Items(Item)G$=string(Item.GetMyTemplateName())$":"$Item.InventorySlot$",";
  foreach U.Abilities(Ref){AB=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));if(AB!=none)A$=string(AB.GetMyTemplateName())$",";}
  foreach U.AffectedByEffects(Ref){E=XComGameState_Effect(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));if(E!=none && E.GetX2Effect()!=none)
   {
    P$=string(E.GetX2Effect().EffectName)$",";
    AB=XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(E.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
    if(AB!=none){Values="";for(J=0;J<E.StatChanges.Length;++J)Values$=string(E.StatChanges[J].StatType)$":"$E.StatChanges[J].StatAmount$":"$E.StatChanges[J].ModOp$",";
     LogInternal("R8|PYEFFECTSRC|"$default.Scenario$"|"$U.GetMyTemplateName()$"|"$AB.GetMyTemplateName()$"|"$E.GetX2Effect().EffectName$"|"$Values);}
   }}
  LogInternal("R8|PYEQUIP|"$default.Scenario$"|"$U.GetMyTemplateName()$"|"$G$"|"$A$"|"$P$"|"$U.GetCurrentStat(eStat_Mobility)$","$U.GetCurrentStat(eStat_Offense)$","$U.GetCurrentStat(eStat_PsiOffense)$","$U.GetMaxStat(eStat_HP)$","$U.GetCurrentStat(eStat_Will)$","$U.GetCurrentStat(eStat_CritChance)$","$U.GetCurrentStat(eStat_ArmorMitigation));
 }
}

function string PyRuleTags(array<X2Condition> Conditions)
{
 local X2Condition C;local X2Condition_GameplayTag Tag;local string S;
 foreach Conditions(C)
 {
  Tag=X2Condition_GameplayTag(C);if(Tag==none)continue;
  if(Tag.RequiredGameplayTag!='' && default.PyTags.Find(Tag.RequiredGameplayTag)!=INDEX_NONE)S$="+"$Tag.RequiredGameplayTag$",";
  if(Tag.DisallowGameplayTag!='' && default.PyTags.Find(Tag.DisallowGameplayTag)!=INDEX_NONE)S$="-"$Tag.DisallowGameplayTag$",";
 }
 return S;
}
function PyCatalogAbility(X2AbilityTemplate B)
{
 local X2Effect E;local X2Effect_Persistent P;local string Gates,Effects,S;local int I;
 if(B==none)return;
 Gates=PyRuleTags(B.AbilityShooterConditions);S=PyRuleTags(B.AbilityTargetConditions)$PyRuleTags(B.AbilityMultiTargetConditions);
 for(I=0;I<B.AbilityTargetEffects.Length+B.AbilityMultiTargetEffects.Length;++I)
 {
  E=I<B.AbilityTargetEffects.Length?B.AbilityTargetEffects[I]:B.AbilityMultiTargetEffects[I-B.AbilityTargetEffects.Length];if(E==none)continue;
  P=X2Effect_Persistent(E);S$=PyRuleTags(E.TargetConditions);
  Effects$=string(E.Class.Name)$":"$(P==none?"":string(P.EffectName)$":"$P.DuplicateResponse$":"$P.bDupeForSameSourceOnly)$",";
 }
 if(Len(Gates)>0 || Len(S)>0 || InStr(Caps(string(B.DataName)),"ARFM")==0)LogInternal("R8|PYRULE|"$B.DataName$"|"$Gates$"|"$S$"|"$Effects);
}

function EightCatalog()

{

 local X2DataTemplate D;

 local X2AbilityTemplate B;

 local X2AbilityTrigger Tr;

 local X2AbilityTrigger_EventListener E;

 local X2CharacterTemplate C;

 local X2AIBTBehaviorTree Tree;

 local name K;

 local int I;

 local string A,L,U;
 local array<name> MissingChildren;

 if(GroupIndex!=0 || RoundNo>0)return;

 foreach class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().IterateTemplates(D)

 {

  B=X2AbilityTemplate(D);

  PyCatalogAbility(B);if(B!=none)LogInternal("R8|ABILITYID|"$B.DataName);
  if(B==none || (!EightRelated(D) && InStr(Caps(string(B.DataName)),"TRACKINGSHOT")<0 && B.DataName!='StandardShot' && B.DataName!='StandardMelee' && B.DataName!='HunterRifleShot' && B.DataName!='ChosenSwordSlice'))continue;

  A="";L="";U="";

  foreach B.AbilityTriggers(Tr){if(Tr!=none){E=X2AbilityTrigger_EventListener(Tr);A$=string(Tr.Class.Name)$(E==none?"":"=" $ string(E.ListenerData.EventID))$",";}}

  foreach B.PostActivationEvents(K)L$=string(K)$",";

  foreach B.AdditionalAbilities(K)U$=string(K)$",";

  LogInternal("R8|ABILITY|"$B.DataName$"|"$D.ClassThatCreatedUs$"|"$D.TemplateAvailability$"|"$B.bIsPassive$"|"$A$"|"$L$"|"$U$"|"$B.AbilityTargetStyle);

 }

 foreach class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().IterateTemplates(D)

 {

  C=X2CharacterTemplate(D);if(C==none)continue;A="";

  foreach C.Abilities(K)A$=string(K)$",";

  LogInternal("R8|CHARGROUP|"$C.DataName$"|"$C.CharacterGroupName$"|"$C.bIsSoldier);
  LogInternal("R8|CHAR|"$C.DataName$"|"$C.strBehaviorTree$"|"$D.ClassThatCreatedUs$"|"$C.DefaultLoadout$"|"$C.bIsSoldier$"|"$A);

 }

 foreach class'X2ItemTemplateManager'.static.GetItemTemplateManager().IterateTemplates(D)

  if(EightRelated(D))LogInternal("R8|ITEM|"$D.DataName$"|"$D.ClassThatCreatedUs$"|"$D.Class.Name);

 foreach class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().IterateTemplates(D)

  if(EightRelated(D))LogInternal("R8|STRATEGY|"$D.DataName$"|"$D.ClassThatCreatedUs$"|"$D.Class.Name);

 Tree=class'X2AIBTBehaviorTree'.static.GetBehaviorTreeManager();

 for(I=0;I<Tree.Behaviors.Length;++I)

 {

  if(Tree.GetNodeIndex(Tree.Behaviors[I].BehaviorName)!=I)continue;

  A="";foreach Tree.Behaviors[I].Child(K){A$=string(K)$",";if((Tree.GetNodeIndex(K)<0 || InStr(Caps(string(K)),"SCORE_")>=0) && MissingChildren.Find(K)==INDEX_NONE){MissingChildren.AddItem(K);LogInternal("R8|CHILD|"$K$"|"$Tree.IsScoringBehavior(K)$"|"$Tree.IsValidBehavior(K));}}

  LogInternal("R8|NODEDEF|"$Tree.Behaviors[I].BehaviorName$"|"$Tree.Behaviors[I].NodeType$"|"$A);

 }

 for(I=0;I<Tree.EquivalentAbilities.Length;++I){A="";foreach Tree.EquivalentAbilities[I].EquivalentAbilityName(K)A$=string(K)$",";LogInternal("R8|ALIAS|"$Tree.EquivalentAbilities[I].KeyName$"|"$A);}
 LogInternal("R8|CATDONE|"$Tree.Behaviors.Length);

}

function EightGive(XComGameState S,XComGameState_Unit U,name K)

{

 local X2AbilityTemplate B;

 local XComGameState_Item Weap;

 local StateObjectReference Ref,Item;

 if(U.FindAbility(K).ObjectID>0)return;

 B=class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(K);if(B==none){LogInternal("R8|NOGRANT|"$K);return;}

 Weap=U.GetPrimaryWeapon();if(Weap!=none)Item=Weap.GetReference();

 Ref=class'X2TacticalGameRuleset'.static.InitAbilityForUnit(B,U,S,Item);

 LogInternal("R8|GRANT|"$default.Scenario$"|"$U.ObjectID$"|"$K$"|"$Ref.ObjectID);

}

function EightPrepare(XComGameState S)

{

 local XComGameState_Unit U,T;

 local XComGameState_Player Pl;

 local X2AbilityTemplate Bow;

 local StateObjectReference Ref;

 local int Id,C;

 local UnitValue PV;
 local vector FarAt;

 if(default.Scenario<110 || Actors.Length==0)return;

 C=default.Scenario;U=XComGameState_Unit(S.GetGameStateForObjectID(Actors[0]));if(U==none)return;

 if(C==110 || C==111 || C==114 || C==159)Cool(S,U,'ARFMKnightPsiBow',5);

 if(C==111 || C==114 || C==159)

 {

  Pl=XComGameState_Player(`XCOMHISTORY.GetGameStateForObjectID(Unit(Soldiers[0]).ControllingPlayer.ObjectID));

  if(Pl!=none)Pl.SetSquadConcealmentNewGameState(true,S);

  foreach Soldiers(Id){T=XComGameState_Unit(S.GetGameStateForObjectID(Id));if(T==none)T=XComGameState_Unit(S.ModifyStateObject(class'XComGameState_Unit',Id));

   FarAt=PlaceFrom(U.TileLocation,38,35);T.SetVisibilityLocationFromVector(FarAt);T.SetIndividualConcealment(true,S);}

  U.SetCurrentStat(eStat_SightRadius,0);

 }

 if(C==116 || C==118 || C==119 || C==152 || C==153 || C==154)EightGive(S,U,'ARFMCapstoneRoselite');

 if(C==122||C==123||C==124)EightGive(S,U,'TPYDuplicateUnit');

 if(C==125||C==126||C==127)EightGive(S,U,'TPYChosenCommand');

 if(C>=128 && C<=130)EightGive(S,U,'TPYChosenWave');

 if(C>=131 && C<=133)EightGive(S,U,'TPYChosenGroundpound');

 if(C>=134 && C<=136){EightGive(S,U,'TPYChosenTeleport');U.SetCurrentStat(eStat_HP,Max(2,int(U.GetMaxStat(eStat_HP)*0.29)));}

 if(C==148 || C==149)EightGive(S,U,'ARFMPYP_SectoidLauncher');

 if(C==149)Cool(S,U,'ARFMPYP_SectoidLauncher',5);

 if(C==150)EightGive(S,U,'ARFMPYP_TimeShift');

 if(C==151)EightGive(S,U,'ARFMPYP_GhostSignal');

 if(C==120 || C==160)

 {

  U.SetBaseMaxStat(eStat_Offense,200);U.SetCurrentStat(eStat_Offense,200);

  if(!U.IsUnitAffectedByEffectName('CoarseAuditLastPoint'))ApplyLastPoint(S,U);

  if(Soldiers.Length>1){T=XComGameState_Unit(S.GetGameStateForObjectID(Soldiers[1]));if(T!=none)T.SetCurrentStat(eStat_HP,1);}

 }

 if(C==121 || C==161){Cool(S,U,'MarkTarget',5);U.SetCurrentStat(eStat_Mobility,0);U.SetCurrentStat(eStat_Offense,160);}

 if(C==158)Cool(S,U,'ARFMKnightPsiBow',5);

 U.GetUnitValue('Parry',PV);

 Bow=class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('ARFMKnightPsiBow');if(Bow!=none)Ref=U.FindAbility(Bow.DataName);

 LogInternal("R8|PREP|"$C$"|"$RoundNo$"|"$U.GetMyTemplateName()$"|"$U.ObjectID$"|"$Ref.ObjectID$"|"$PV.fValue);

}

function EightFrame(XComGameStateContext_Ability AC,int F)

{

 local XComGameState_Unit U;

 local UnitValue OldV,NewV;

 if(AC==none || AC.InterruptionStatus==eInterruptionStatus_Interrupt)return;

 if(AC.InputContext.AbilityTemplateName=='ARFMKnightParryActivate')

 {

  U=Unit(AC.InputContext.SourceObject.ObjectID,F-1);if(U!=none)U.GetUnitValue('Parry',OldV);

  U=Unit(AC.InputContext.SourceObject.ObjectID,F);if(U!=none)U.GetUnitValue('Parry',NewV);

  LogInternal("R8|PARRY|"$default.Scenario$"|"$F$"|"$AC.InputContext.SourceObject.ObjectID$"|"$AC.InputContext.PrimaryTarget.ObjectID$"|"$OldV.fValue$"|"$NewV.fValue);

 }

}



defaultproperties
{
 SameBattleC(12)=(Id=152,TurnCount=1,Units="ChosenSniperM3",Unavailable="")
 SameBattleC(13)=(Id=153,TurnCount=1,Units="ChosenWarlockM3",Unavailable="")
 SameBattleC(14)=(Id=154,TurnCount=1,Units="ChosenAssassinM3",Unavailable="")
 SameBattleC(15)=(Id=155,TurnCount=1,Units="ARFMAdvTorcherM3",Unavailable="")
 SameBattleC(16)=(Id=156,TurnCount=1,Units="ARFMAdvArtilleryM3",Unavailable="")
 SameBattleC(17)=(Id=157,TurnCount=1,Units="ARFMAdvRunnerM3",Unavailable="")
 SameBattleC(18)=(Id=158,TurnCount=1,Units="ARFMAdvKnightM3",Unavailable="")
 SameBattleC(19)=(Id=159,TurnCount=1,Units="ARFMAdvKnightM3",Unavailable="")
 SameBattleC(20)=(Id=160,TurnCount=1,Units="AdvRaptorM3",Unavailable="")
 SameBattleC(21)=(Id=161,TurnCount=1,Units="ARFMAdvOutriderM3",Unavailable="")
 SameBattleC(22)=(Id=162,TurnCount=1,Units="ARFMAdvColonel",Unavailable="")
 SameBattleC(23)=(Id=163,TurnCount=1,Units="ARFMFeralChryssalidHP2~ARFMFeralChryssalidHP4~ARFMFeralChryssalidHP6",Unavailable="")
 SameBattleC(24)=(Id=164,TurnCount=1,Units="ARFMFeralChryssalidHP8~ARFMFeralChryssalidHP10~ARFMFeralChryssalidHP12",Unavailable="")
 GemCaps(0)=ARFMCapstoneRoselite
 GemCaps(1)=ARFMCapstoneFlint
 GemCaps(2)=ARFMCapstoneTanzanite
 GemCaps(3)=ARFMCapstoneAugelite
 GemCaps(4)=ARFMCapstoneBrookite
 GemCaps(5)=ARFMCapstoneZoisite
 GemCaps(6)=ARFMCapstoneAlmandine
 GemCaps(7)=ARFMCapstoneAzurite
 GemKeys(0)=ARFMKeystoneCavansite
 GemKeys(1)=ARFMKeystoneGahnite
 GemKeys(2)=ARFMKeystoneIolite
 GemKeys(3)=ARFMKeystoneRhodolite
 GemKeys(4)=ARFMKeystoneTinzenite
 GemKeys(5)=ARFMKeystoneCreedite
 GemKeys(6)=ARFMKeystoneBaryte
 GemKeys(7)=ARFMKeystoneEuclase
 GemLodes(0)=ARFMLodestoneAdamite
 GemLodes(1)=ARFMLodestoneAegirine
 GemLodes(2)=ARFMLodestoneAmethyst
 GemLodes(3)=ARFMLodestoneCitrine
 GemLodes(4)=ARFMLodestoneCovellite
 GemLodes(5)=ARFMLodestoneElbaite
 GemLodes(6)=ARFMLodestoneLazurite
 GemLodes(7)=ARFMLodestoneDemantoid
 GemLodes(8)=ARFMLodestoneErythrite
 GemDeds(0)=ARFMDedicationChange
 GemDeds(1)=ARFMDedicationEnlightenment
 GemDeds(2)=ARFMDedicationSensation
 GemDeds(3)=ARFMDedicationRememberance
 GemDeds(4)=ARFMDedicationPower
 SameBattleB(0)=(Id=190,TurnCount=1,Units="ChosenAssassinM3~ChosenSniperM3~ChosenWarlockM3",Unavailable="")
 SameBattleB(1)=(Id=191,TurnCount=1,Units="ChosenAssassinM3~ChosenSniperM3~ChosenWarlockM3",Unavailable="")
 SameBattleB(2)=(Id=192,TurnCount=1,Units="ChosenAssassinM3~ChosenSniperM3~ChosenWarlockM3",Unavailable="")
 SameBattleB(3)=(Id=193,TurnCount=1,Units="ChosenAssassinM3~ChosenSniperM3~ChosenWarlockM3",Unavailable="")
 SameBattleB(4)=(Id=194,TurnCount=1,Units="ChosenAssassinM3~ChosenSniperM3~ChosenWarlockM3",Unavailable="")
 SameBattleB(5)=(Id=195,TurnCount=1,Units="ChosenAssassinM3~ChosenSniperM3~ChosenWarlockM3",Unavailable="")
 SameBattleB(6)=(Id=196,TurnCount=1,Units="ChosenAssassinM3~ChosenSniperM3~ChosenWarlockM3",Unavailable="")
 SameBattleB(7)=(Id=197,TurnCount=1,Units="ChosenAssassinM3~ChosenSniperM3~ChosenWarlockM3",Unavailable="")
 SameBattleB(8)=(Id=198,TurnCount=1,Units="ChosenAssassinM3~ChosenSniperM3~ChosenWarlockM3",Unavailable="")
 SameBattleB(9)=(Id=199,TurnCount=1,Units="ChosenAssassinM3~ChosenSniperM3~ChosenWarlockM3",Unavailable="")
 SameBattleA(0)=(Id=175,TurnCount=1,Units="AdvPriestM3",Unavailable="")
 SameBattleA(1)=(Id=176,TurnCount=1,Units="AdvPriestM3",Unavailable="")
 SameBattleA(2)=(Id=177,TurnCount=1,Units="AdvPriestM3",Unavailable="")
 SameBattleA(3)=(Id=178,TurnCount=1,Units="AdvPriestM3",Unavailable="")
 SameBattleA(4)=(Id=179,TurnCount=1,Units="AdvPriestM3",Unavailable="")
 SameBattleA(5)=(Id=180,TurnCount=1,Units="AdvPriestM3",Unavailable="")
 SameBattleA(6)=(Id=181,TurnCount=1,Units="AdvPriestM3",Unavailable="")
 SameBattleA(7)=(Id=185,TurnCount=1,Units="AdvPriestM3",Unavailable="")
 SameBattleA(8)=(Id=186,TurnCount=1,Units="AdvPriestM3",Unavailable="")
 SameBattleA(9)=(Id=170,TurnCount=1,Units="SpectreM2",Unavailable="")
 SameBattleA(10)=(Id=182,TurnCount=1,Units="SpectreM2",Unavailable="")
 SameBattleA(11)=(Id=110,TurnCount=1,Units="ARFMAdvKnightM3",Unavailable="")
 SameBattleA(12)=(Id=111,TurnCount=1,Units="ARFMAdvKnightM3",Unavailable="")
 SameBattleA(13)=(Id=135,TurnCount=1,Units="ChosenAssassinM3",Unavailable="")
 PyTags(0)=ARFMPYP_DemocracyProtects
 PyCards(0)=YMTriParteThirtySeven
 PyTags(1)=ARFMPYP_DemocracyLiberates
 PyCards(1)=YMTriParteThirtySeven
 PyTags(2)=ARFMPYP_DemocracyUnifies
 PyCards(2)=YMTriParteThirtySeven
 PyTags(3)=ARFMPYP_Pinpoint
 PyCards(3)=YMTriParteThirtySix
 PyTags(4)=ARFMPYP_StubbornMule
 PyCards(4)=YMTriParteThirtySix
 PyTags(5)=ARFMPYP_SlickerThanOil
 PyCards(5)=YMTriParteThirtySix
 PyTags(6)=ARFMPYP_ShieldbearerArmor
 PyCards(6)=YMTriParteThirtyFive
 PyTags(7)=ARFMPYP_SectoidFortress
 PyCards(7)=YMTriParteThirtyFive
 PyTags(8)=ARFMPYP_StationaryTyrants
 PyCards(8)=YMTriParteThirtyFive
 PyTags(9)=ARFMPYP_PsiCaptains
 PyCards(9)=YMTriParteThirtyFour
 PyTags(10)=ARFMPYP_PsiLancers
 PyCards(10)=YMTriParteThirtyFour
 PyTags(11)=ARFMPYP_PsiBearers
 PyCards(11)=YMTriParteThirtyFour
 PyTags(12)=ARFMPYP_NinetiesBlues
 PyCards(12)=YMTriParteThirtyThree
 PyTags(13)=ARFMPYP_CaptainGrapeshot
 PyCards(13)=YMTriParteThirtyThree
 PyTags(14)=ARFMPYP_StartedBlasting
 PyCards(14)=YMTriParteThirtyThree
 PyTags(15)=ARFMPYP_MotivationalExecutions
 PyCards(15)=YMTriParteThirtyTwo
 PyTags(16)=ARFMPYP_PuddingEmpire
 PyCards(16)=YMTriParteThirtyTwo
 PyTags(17)=ARFMPYP_MassiveDay
 PyCards(17)=YMTriParteThirtyTwo
 PyTags(18)=ARFMPYP_SectoidTeaParty
 PyCards(18)=YMTriParteThirtyOne
 PyTags(19)=ARFMPYP_SnakeOilers
 PyCards(19)=YMTriParteThirtyOne
 PyTags(20)=ARFMPYP_LiddyBoxing
 PyCards(20)=YMTriParteThirtyOne
 PyTags(21)=ARFMPYP_PoliceBrutality
 PyCards(21)=YMTriParteThirty
 PyTags(22)=ARFMPYP_SaltAndPepper
 PyCards(22)=YMTriParteThirty
 PyTags(23)=ARFMPYP_SillyLittleBleeder
 PyCards(23)=YMTriParteThirty
 PyTags(24)=ARFMPYP_TimeWar
 PyCards(24)=YMTriParteTwentyNine
 PyTags(25)=ARFMPYP_AvoidSnipes
 PyCards(25)=YMTriParteTwentyNine
 PyTags(26)=ARFMPYP_NoOrdinaryRabbit
 PyCards(26)=YMTriParteTwentyNine
 PyTags(27)=ARFMPYP_CodexSadness
 PyCards(27)=YMTriParteTwentyEight
 PyTags(28)=ARFMPYP_ViperShields
 PyCards(28)=YMTriParteTwentyEight
 PyTags(29)=ARFMPYP_IndomitableForce
 PyCards(29)=YMTriParteTwentyEight
 PyTags(30)=ARFMPYP_Soulfuse
 PyCards(30)=YMTriParteTwentySeven
 PyTags(31)=ARFMPYP_Paynonets
 PyCards(31)=YMTriParteTwentySeven
 PyTags(32)=ARFMPYP_GhostSignal
 PyCards(32)=YMTriParteTwentySeven
 PyTags(33)=ARFMPYP_EliteBashars
 PyCards(33)=YMTriParteTwentySix
 PyTags(34)=ARFMPYP_UniqueBashars
 PyCards(34)=YMTriParteTwentySix
 PyTags(35)=ARFMPYP_MundaneBashars
 PyCards(35)=YMTriParteTwentySix
 PyTags(36)=ARFMPYP_WeGotTheRockets
 PyCards(36)=YMTriParteTwentyFive
 PyTags(37)=ARFMPYP_BedlamBlasting
 PyCards(37)=YMTriParteTwentyFive
 PyTags(38)=ARFMPYP_NightmareFuel
 PyCards(38)=YMTriParteTwentyFive
 PyTags(39)=ARFMPYP_PainTrain
 PyCards(39)=YMTriParteTwentyFour
 PyTags(40)=ARFMPYP_HighCaliber
 PyCards(40)=YMTriParteTwentyFour
 PyTags(41)=ARFMPYP_WillToSurvive
 PyCards(41)=YMTriParteTwentyFour
 PyTags(42)=ARFMPYP_HereticBane
 PyCards(42)=YMTriParteTwentyThree
 PyTags(43)=ARFMPYP_BetrayerBane
 PyCards(43)=YMTriParteTwentyThree
 PyTags(44)=ARFMPYP_UnbelieverBane
 PyCards(44)=YMTriParteTwentyThree
 PyTags(45)=ARFMPYP_Dreadnaughts
 PyCards(45)=YMTriParteTwentyTwo
 PyTags(46)=ARFMPYP_Spinebreakers
 PyCards(46)=YMTriParteTwentyTwo
 PyTags(47)=ARFMPYP_AdventCrits
 PyCards(47)=YMTriParteTwentyTwo
 PyTags(48)=ARFMPYP_EdgeOfMind
 PyCards(48)=YMTriParteTwentyOne
 PyTags(49)=ARFMPYP_PyresOfDawn
 PyCards(49)=YMTriParteTwentyOne
 PyTags(50)=ARFMPYP_GrailCurse
 PyCards(50)=YMTriParteTwentyOne
 PyTags(51)=ARFMPYP_StunningField
 PyCards(51)=YMTriParteTwenty
 PyTags(52)=ARFMPYP_BlindingRockets
 PyCards(52)=YMTriParteTwenty
 PyTags(53)=ARFMPYP_ArchonSteroid
 PyCards(53)=YMTriParteTwenty
 PyTags(54)=ARFMPYP_Beaglebusting
 PyCards(54)=YMTriParteNineteen
 PyTags(55)=ARFMPYP_Battleborn
 PyCards(55)=YMTriParteNineteen
 PyTags(56)=ARFMPYP_Battlehaunt
 PyCards(56)=YMTriParteNineteen
 PyTags(57)=None
 PyCards(57)=YMTriParteEighteen
 PyTags(58)=ARFMPYP_ChemicalPinions
 PyCards(58)=YMTriParteEighteen
 PyTags(59)=ARFMPYP_SoulPyres
 PyCards(59)=YMTriParteEighteen
 PyTags(60)=ARFMPYP_DeepPenetration
 PyCards(60)=YMTriParteSeventeen
 PyTags(61)=ARFMPYP_BackBreakers
 PyCards(61)=YMTriParteSeventeen
 PyTags(62)=ARFMPYP_BewilderingShocks
 PyCards(62)=YMTriParteSeventeen
 PyTags(63)=ARFMPYP_DeathCurse
 PyCards(63)=YMTriParteSixteen
 PyTags(64)=None
 PyCards(64)=YMTriParteSixteen
 PyTags(65)=None
 PyCards(65)=YMTriParteSixteen
 PyTags(66)=ARFMPYP_SectopodGymrats
 PyCards(66)=YMSectopodEmpowerment
 PyTags(67)=ARFMPYP_SectopodMania
 PyCards(67)=YMSectopodEmpowerment
 PyTags(68)=ARFMPYP_SectopodShoes
 PyCards(68)=YMSectopodEmpowerment
 PyTags(69)=ARFMPYP_SpectreFifthEye
 PyCards(69)=YMSpectreEmpowerment
 PyTags(70)=ARFMPYP_SpectreRegen
 PyCards(70)=YMSpectreEmpowerment
 PyTags(71)=ARFMPYP_DarkEmbrace
 PyCards(71)=YMSpectreEmpowerment
 PyTags(72)=ARFMPYP_BlindingAcid
 PyCards(72)=YMAndromedonEmpowerment
 PyTags(73)=ARFMPYP_StunningStrikes
 PyCards(73)=YMAndromedonEmpowerment
 PyTags(74)=ARFMPYP_AndromedonWarpBeacon
 PyCards(74)=YMAndromedonEmpowerment
 PyTags(75)=ARFMPYP_SpookyFlame
 PyCards(75)=YMPurifierEmpowerment
 PyTags(76)=ARFMPYP_CripplingFlame
 PyCards(76)=YMPurifierEmpowerment
 PyTags(77)=ARFMPYP_RuinousFlame
 PyCards(77)=YMPurifierEmpowerment
 PyTags(78)=ARFMPYP_SpectreTeleport
 PyCards(78)=YMTriParteFifteen
 PyTags(79)=ARFMPYP_SuperSectoids
 PyCards(79)=YMTriParteFifteen
 PyTags(80)=ARFMPYP_MutonSuppressionShot
 PyCards(80)=YMTriParteFifteen
 PyTags(81)=ARFMPYP_SolidSectopod
 PyCards(81)=YMTriParteFourteen
 PyTags(82)=ARFMPYP_GatekeeperSupershell
 PyCards(82)=YMTriParteFourteen
 PyTags(83)=ARFMPYP_AndromedonPlating
 PyCards(83)=YMTriParteFourteen
 PyTags(84)=ARFMPYP_PurifierUnicorn
 PyCards(84)=YMTriParteThirteen
 PyTags(85)=ARFMPYP_MutonTapdancer
 PyCards(85)=YMTriParteThirteen
 PyTags(86)=ARFMPYP_Stunmancy
 PyCards(86)=YMTriParteThirteen
 PyTags(87)=ARFMDESW_CHAGatekeeperGirlboss
 PyCards(87)=YMTriParteTwelve
 PyTags(88)=ARFMPYP_MurderDrool
 PyCards(88)=YMTriParteTwelve
 PyTags(89)=ARFMPYP_Zerkernaut
 PyCards(89)=YMTriParteTwelve
 PyTags(90)=ARFMDESW_CHAMutonReposition
 PyCards(90)=YMTriParteEleven
 PyTags(91)=ARFMDESW_CHASnekSnuggles
 PyCards(91)=YMTriParteEleven
 PyTags(92)=ARFMPYP_ZombieRoids
 PyCards(92)=YMTriParteEleven
 PyTags(93)=ARFMDESW_CHASpectreTrouble
 PyCards(93)=YMTriParteTen
 PyTags(94)=ARFMDESW_CHAAndromedonGigachad
 PyCards(94)=YMTriParteTen
 PyTags(95)=ARFMDESW_CHAEnhancedWarframes
 PyCards(95)=YMTriParteTen
 PyTags(96)=ARFMPYP_AndromedonDoubleTap
 PyCards(96)=YMTriParteNine
 PyTags(97)=ARFMDESW_CHAAwakenMyPoddies
 PyCards(97)=YMTriParteNine
 PyTags(98)=ARFMDESW_CHALiddyRoids
 PyCards(98)=YMTriParteNine
 PyTags(99)=ARFMDESW_CHARestorationProtocols
 PyCards(99)=YMTriParteEight
 PyTags(100)=ARFMDESW_CHAMutonBrutal
 PyCards(100)=YMTriParteEight
 PyTags(101)=ARFMDESW_CHASuperArchons
 PyCards(101)=YMTriParteEight
 PyTags(102)=ARFMDESW_CHASafetyProtocols
 PyCards(102)=YMTriParteSeven
 PyTags(103)=ARFMDESW_CHAPriorityTargeting
 PyCards(103)=YMTriParteSeven
 PyTags(104)=ARFMDESW_CHAAdvancedTraining
 PyCards(104)=YMTriParteSeven
 PyTags(105)=ARFMDESW_CHARoboArmor
 PyCards(105)=YMTriParteSix
 PyTags(106)=ARFMDESW_CHAAlienSealedArmor
 PyCards(106)=YMTriParteSix
 PyTags(107)=ARFMDESW_CHAPsychicScreens
 PyCards(107)=YMTriParteSix
 PyTags(108)=ARFMDESW_CHARoboMadness
 PyCards(108)=YMTriParteFive
 PyTags(109)=ARFMDESW_CHAWoodpecker
 PyCards(109)=YMTriParteFive
 PyTags(110)=ARFMDESW_CHANetworkRepairs
 PyCards(110)=YMTriParteFive
 PyTags(111)=ARFMDESW_CHAArchonTurbo
 PyCards(111)=YMTriParteFour
 PyTags(112)=ARFMDESW_CHATacticalAnal
 PyCards(112)=YMTriParteFour
 PyTags(113)=ARFMDESW_CHAStunlancerCounter
 PyCards(113)=YMTriParteFour
 PyTags(114)=ARFMDESW_CHASlipperyStalkers
 PyCards(114)=YMTriParteThree
 PyTags(115)=ARFMDESW_CHAFacelessJelly
 PyCards(115)=YMTriParteThree
 PyTags(116)=ARFMDESW_CHAMutonSkin
 PyCards(116)=YMTriParteThree
 PyTags(117)=ARFMDESW_CHAPriestProtein
 PyCards(117)=YMTriParteTwo
 PyTags(118)=ARFMDESW_CHAICEProtocols
 PyCards(118)=YMTriParteTwo
 PyTags(119)=ARFMDESW_CHAMutonCQC
 PyCards(119)=YMTriParteTwo
 PyTags(120)=ARFMDESW_CHATroopyFace
 PyCards(120)=YMTriParteOne
 PyTags(121)=ARFMDESW_CHAIncinerationPods
 PyCards(121)=YMTriParteOne
 PyTags(122)=ARFMDESW_CHASpeedyGonzales
 PyCards(122)=YMTriParteOne
 PyTags(123)=ARFMPYP_MacroMissiles
 PyCards(123)=YMMECEnhancement
 PyTags(124)=ARFMPYP_TerrainMapping
 PyCards(124)=YMMECEnhancement
 PyTags(125)=ARFMPYP_MECArmor
 PyCards(125)=YMMECEnhancement
 PyTags(126)=ARFMPYP_HitterMuton
 PyCards(126)=YMMutonEnhancement
 PyTags(127)=ARFMPYP_BrutalistMuton
 PyCards(127)=YMMutonEnhancement
 PyTags(128)=ARFMPYP_ReactiveMuton
 PyCards(128)=YMMutonEnhancement
 PyTags(129)=ARFMPYP_ShieldbearerPerceptionLink
 PyCards(129)=YMShieldbearerMindLink
 PyTags(130)=ARFMPYP_ShieldbearerPrecisionLink
 PyCards(130)=YMShieldbearerMindLink
 PyTags(131)=ARFMPYP_ShieldbearerTacticLink
 PyCards(131)=YMShieldbearerMindLink
 PyTags(132)=ARFMPYP_LancerPerceptionLink
 PyCards(132)=YMLancerMindLink
 PyTags(133)=ARFMPYP_LancerPrecisionLink
 PyCards(133)=YMLancerMindLink
 PyTags(134)=ARFMPYP_LancerTacticLink
 PyCards(134)=YMLancerMindLink
 PyTags(135)=ARFMPYP_PriestPerceptionLink
 PyCards(135)=YMPriestMindLink
 PyTags(136)=ARFMPYP_PriestPrecisionLink
 PyCards(136)=YMPriestMindLink
 PyTags(137)=ARFMPYP_PriestTacticLink
 PyCards(137)=YMPriestMindLink
 PyTags(138)=ARFMPYP_OfficerPerceptionLink
 PyCards(138)=YMOfficerMindLink
 PyTags(139)=ARFMPYP_OfficerPrecisionLink
 PyCards(139)=YMOfficerMindLink
 PyTags(140)=ARFMPYP_OfficerTacticLink
 PyCards(140)=YMOfficerMindLink
 PyTags(141)=ARFMPYP_TrooperPerceptionLink
 PyCards(141)=YMTrooperMindLink
 PyTags(142)=ARFMPYP_TrooperPrecisionLink
 PyCards(142)=YMTrooperMindLink
 PyTags(143)=ARFMPYP_TrooperTacticLink
 PyCards(143)=YMTrooperMindLink
 PyTags(144)=ARFMPYP_VoidPriest
 PyCards(144)=YMPriestEnhancement
 PyTags(145)=ARFMPYP_BattlePriest
 PyCards(145)=YMPriestEnhancement
 PyTags(146)=ARFMPYP_UmbraPriest
 PyCards(146)=YMPriestEnhancement
 PyTags(147)=ARFMPYP_OfficerDefense
 PyCards(147)=YMOfficerEnhancement
 PyTags(148)=ARFMPYP_OfficerDamage
 PyCards(148)=YMOfficerEnhancement
 PyTags(149)=ARFMPYP_OfficerAim
 PyCards(149)=YMOfficerEnhancement
 PyTags(150)=ARFMPYP_TrooperDefense
 PyCards(150)=YMTrooperEnhancement
 PyTags(151)=ARFMPYP_TrooperDamage
 PyCards(151)=YMTrooperEnhancement
 PyTags(152)=ARFMPYP_TrooperAim
 PyCards(152)=YMTrooperEnhancement
 PyTags(153)=ARFMPYP_SectoidPsi
 PyCards(153)=YMSectoidEnhancement
 PyTags(154)=ARFMPYP_SectoidDamage
 PyCards(154)=YMSectoidEnhancement
 PyTags(155)=ARFMPYP_SectoidAim
 PyCards(155)=YMSectoidEnhancement
 PyTags(156)=ARFMPYP_StunlancerDefense
 PyCards(156)=YMStunlancerEnhancement
 PyTags(157)=ARFMPYP_StunlancerMove
 PyCards(157)=YMStunlancerEnhancement
 PyTags(158)=ARFMPYP_StunlancerAim
 PyCards(158)=YMStunlancerEnhancement
 PyTags(159)=ARFMPYP_PurifierCranialReinforcement
 PyCards(159)=YMPurifierEnhancement
 PyTags(160)=ARFMPYP_PurifierRegeneration
 PyCards(160)=YMPurifierEnhancement
 PyTags(161)=ARFMPYP_PurifierArmor
 PyCards(161)=YMPurifierEnhancement
 PyTags(162)=ARFMPYP_TrooperPlasmaGrenade
 PyCards(162)=YMTrooperGrenades
 PyTags(163)=ARFMPYP_TrooperGasGrenade
 PyCards(163)=YMTrooperGrenades
 PyTags(164)=ARFMPYP_TrooperAcidGrenade
 PyCards(164)=YMTrooperGrenades
 PyTags(165)=ARFMPYP_StunlancerPlasmaGrenade
 PyCards(165)=YMStunlancerGrenades
 PyTags(166)=ARFMPYP_StunlancerGasGrenade
 PyCards(166)=YMStunlancerGrenades
 PyTags(167)=ARFMPYP_StunlancerAcidGrenade
 PyCards(167)=YMStunlancerGrenades
 SameBattleD(0)=(Id=175,TurnCount=1,Units="AdvPriestM3",Unavailable="")
 SameBattleD(1)=(Id=177,TurnCount=1,Units="AdvPriestM3",Unavailable="")
 SameBattleD(2)=(Id=238,TurnCount=1,Units="Sectoid",Unavailable="")
 SameBattleD(3)=(Id=239,TurnCount=1,Units="Sectoid",Unavailable="")
 SameBattleD(4)=(Id=240,TurnCount=1,Units="Sectoid",Unavailable="")
 SameBattleD(5)=(Id=241,TurnCount=1,Units="Sectoid",Unavailable="")
 SameBattleD(6)=(Id=242,TurnCount=1,Units="Andromedon",Unavailable="")
 SameBattleD(7)=(Id=243,TurnCount=1,Units="Andromedon",Unavailable="")
 SameBattleD(8)=(Id=244,TurnCount=1,Units="Sectoid",Unavailable="")
 SameBattleD(9)=(Id=245,TurnCount=1,Units="Sectoid",Unavailable="")
 SameBattleD(10)=(Id=246,TurnCount=1,Units="Sectoid",Unavailable="")
 SameBattleD(11)=(Id=247,TurnCount=1,Units="Muton",Unavailable="")
 SameBattleD(12)=(Id=248,TurnCount=1,Units="Muton",Unavailable="")
 SameBattleD(13)=(Id=210,TurnCount=1,Units="AdvTrooperM3~AdvCaptainM3~AdvStunLancerM3~AdvPriestM3~AdvShieldBearerM3~AdvPurifierM3~AdvRocketeerM3~LWDroneM2",Unavailable="")
 SameBattleD(14)=(Id=211,TurnCount=1,Units="AdvMEC_M2~AdvTurretM3~Sectoid~Viper~Muton~Chryssalid~Faceless~Berserker",Unavailable="")
 SameBattleD(15)=(Id=212,TurnCount=1,Units="Archon~Andromedon~AndromedonRobot~Cyberus~Gatekeeper~Sectopod~SpectreM2~AdvRaptorM3",Unavailable="")
 SameBattleD(16)=(Id=213,TurnCount=1,Units="ChosenAssassinM3~ChosenSniperM3~ChosenWarlockM3~Soldier~MutonM3_LW~AdvPsiWitchM3~AdvDestroyerM3~AdvCounterOpM3",Unavailable="")
 SameBattleD(17)=(Id=214,TurnCount=1,Units="AshAdvWarlockM3~FrostSpectre_M3~ARFMAdvKnightM3~AshFlameViperM3~FrostHardliner_M3~FrostPsiLancer_M3~AshRisenTrooperM3~AHWMechtoidMagnaM3",Unavailable="")
 SameBattleD(18)=(Id=215,TurnCount=1,Units="ARFMAbandonedWretchM3~FrostShadowbindUnit_M3~BioLost~AHWElder~AHWLegate~ViperKing~BioZerker~AHWSeeker",Unavailable="")
 SameBattleD(19)=(Id=216,TurnCount=1,Units="AHWMechapede~AHWMutonMagna~Muton_Harrier~AdvPsiWitchM2~Mk2_Custodian~ShadowbindUnit~FrostAndromedon~AdventCustodian",Unavailable="")
 SameBattleD(20)=(Id=217,TurnCount=1,Units="AHWOutsiderMagna~FrostAbomination~AHWAdvPraetorian~AdventPathfinder~AHWArchonMagnaM2~AHWBerserkerMagna~AHWIncubatorMagna~AHWChryssalidMagna",Unavailable="")
 SameBattleD(21)=(Id=218,TurnCount=1,Units="AdventTroopTransport~Muton_Harrier_Captain~AHWPraetorianSectopod~AHWAdvPraetorianCaptain~AdventPathfinderCaptain~FrostZombie_M3~M31_SpectralLancer_M3~Civilian",Unavailable="")
 SameBattleD(22)=(Id=219,TurnCount=1,Units="ChryssalidCocoon",Unavailable="")
 SameBattleD(23)=(Id=220,TurnCount=1,Units="AdvStunLancerM3",Unavailable="")
 SameBattleD(24)=(Id=221,TurnCount=1,Units="AdvStunLancerM3",Unavailable="")
 SameBattleD(25)=(Id=222,TurnCount=1,Units="AdvCaptainM3",Unavailable="")
 SameBattleD(26)=(Id=223,TurnCount=1,Units="AdvCaptainM3",Unavailable="")
 SameBattleD(27)=(Id=224,TurnCount=1,Units="AdvPriestM3",Unavailable="")
 SameBattleD(28)=(Id=225,TurnCount=1,Units="AdvPriestM3",Unavailable="")
 SameBattleD(29)=(Id=226,TurnCount=1,Units="Andromedon",Unavailable="")
 SameBattleD(30)=(Id=227,TurnCount=1,Units="Andromedon",Unavailable="")
 SameBattleD(31)=(Id=228,TurnCount=1,Units="Sectoid",Unavailable="")
 SameBattleD(32)=(Id=229,TurnCount=1,Units="Sectoid",Unavailable="")
 SameBattleD(33)=(Id=230,TurnCount=1,Units="SpectreM2",Unavailable="")
 SameBattleD(34)=(Id=231,TurnCount=1,Units="SpectreM2",Unavailable="")
 SameBattleD(35)=(Id=232,TurnCount=1,Units="Viper",Unavailable="")
 SameBattleD(36)=(Id=233,TurnCount=1,Units="Viper",Unavailable="")
 SameBattleD(37)=(Id=234,TurnCount=1,Units="AdvPurifierM3",Unavailable="")
 SameBattleD(38)=(Id=235,TurnCount=1,Units="AdvPurifierM3",Unavailable="")
 SameBattleD(39)=(Id=236,TurnCount=1,Units="AdvMEC_M2",Unavailable="")
 SameBattleD(40)=(Id=237,TurnCount=1,Units="AdvMEC_M2",Unavailable="")
 SameBattleC(0)=(Id=140,TurnCount=1,Units="ARFMAdvKnightM1~ARFMAdvKnightM2~ARFMAdvKnightM3",Unavailable="")
 SameBattleC(1)=(Id=141,TurnCount=1,Units="ARFMAdvOutriderM1~ARFMAdvOutriderM2~ARFMAdvOutriderM3",Unavailable="")
 SameBattleC(2)=(Id=142,TurnCount=1,Units="ARFMAdvRunnerM1~ARFMAdvRunnerM2~ARFMAdvRunnerM3",Unavailable="")
 SameBattleC(3)=(Id=143,TurnCount=1,Units="ARFMAdvArtilleryM1~ARFMAdvArtilleryM2~ARFMAdvArtilleryM3",Unavailable="")
 SameBattleC(4)=(Id=144,TurnCount=1,Units="ARFMAdvKriegsmarineM1~ARFMAdvKriegsmarineM2~ARFMAdvKriegsmarineM3",Unavailable="")
 SameBattleC(5)=(Id=145,TurnCount=1,Units="ARFMAdvTorcherM1~ARFMAdvTorcherM2~ARFMAdvTorcherM3",Unavailable="")
 SameBattleC(6)=(Id=146,TurnCount=1,Units="ARFMAbandonedM1~ARFMAbandonedM2~ARFMAbandonedM3",Unavailable="")
 SameBattleC(7)=(Id=147,TurnCount=1,Units="ARFMAbandonedWretchM1~ARFMAbandonedWretchM2~ARFMAbandonedWretchM3",Unavailable="")
 SameBattleC(8)=(Id=148,TurnCount=1,Units="Sectoid",Unavailable="")
 SameBattleC(9)=(Id=149,TurnCount=1,Units="Sectoid",Unavailable="")
 SameBattleC(10)=(Id=150,TurnCount=1,Units="AdvPriestM3",Unavailable="")
 SameBattleC(11)=(Id=151,TurnCount=1,Units="SpectreM2",Unavailable="")


 RosterChecks(0)="alnx6_troopmaneuvers_alienpodlate"
 RosterChecks(1)="dlc2_lg_vprx2x4"
 RosterChecks(2)="dlc2_lg_vprx3x3"
 RosterChecks(3)="dlc2_lg_vprx4x2"
 RosterChecks(4)="dlc2_md_vprx2x1"
 RosterChecks(5)="dlc2_md_vprx2x2"
 RosterChecks(6)="dlc2_sm_vprx2x0"
 RosterChecks(7)="dlc2_sm_vprx2x1"
 RosterChecks(8)="etp_advx2_flightdevice_fl12_12"
 RosterChecks(9)="etp_advx2_flightdevice_fl13_99"
 RosterChecks(10)="etp_advx2_flightdevice_fl1_5"
 RosterChecks(11)="etp_advx2_flightdevice_fl6_6"
 RosterChecks(12)="etp_advx2_flightdevice_fl7_11"
 RosterChecks(13)="etp_advx3_early_rpgteam_lw_fl1_5"
 RosterChecks(14)="etp_advx3_early_rpgteam_lw_fl6_7"
 RosterChecks(15)="etp_advx3_flightdevice_fl12_12"
 RosterChecks(16)="etp_advx3_flightdevice_fl13_99"
 RosterChecks(17)="etp_advx3_flightdevice_fl1_5"
 RosterChecks(18)="etp_advx3_flightdevice_fl6_6"
 RosterChecks(19)="etp_advx3_flightdevice_fl7_11"
 RosterChecks(20)="etp_advx3_flightdeviceboss_fl12_99"
 RosterChecks(21)="etp_advx3_flightdeviceboss_fl1_5"
 RosterChecks(22)="etp_advx3_flightdeviceboss_fl6_11"
 RosterChecks(23)="etp_advx3_mid_rpgteam_lw_fl12_13"
 RosterChecks(24)="etp_advx3_mid_rpgteam_lw_fl8_11"
 RosterChecks(25)="etp_advx4_standard_fireteam_lw_fl12_12"
 RosterChecks(26)="etp_advx4_standard_fireteam_lw_fl13_13"
 RosterChecks(27)="etp_advx4_standard_fireteam_lw_fl8_11"
 RosterChecks(28)="etp_advx4_standard_patrol_lw_fl12_12"
 RosterChecks(29)="etp_advx4_standard_patrol_lw_fl8_11"
 RosterChecks(30)="etp_advx4_weak_fireteam_lw_protected_fl1_5"
 RosterChecks(31)="etp_advx4_weak_fireteam_lw_protected_fl6_6"
 RosterChecks(32)="etp_advx4_weak_fireteam_lw_protected_fl7_7"
 RosterChecks(33)="etp_advx4_weak_patrol_lw_fl1_5"
 RosterChecks(34)="etp_advx4_weak_patrol_lw_fl6_6"
 RosterChecks(35)="etp_advx4_weak_patrol_lw_fl7_7"
 RosterChecks(36)="etp_advx6_standard_rocketteam_lw_fl12_12"
 RosterChecks(37)="etp_advx6_standard_rocketteam_lw_fl13_13"
 RosterChecks(38)="etp_advx6_standard_rocketteam_lw_fl8_11"
 RosterChecks(39)="etp_advx6_weak_rocketteam_lw_fl1_5"
 RosterChecks(40)="etp_advx6_weak_rocketteam_lw_fl6_6"
 RosterChecks(41)="etp_advx6_weak_rocketteam_lw_fl7_7"
 RosterChecks(42)="etp_advx8_early_squad_lw_fl1_5"
 RosterChecks(43)="etp_advx8_early_squad_lw_fl6_6"
 RosterChecks(44)="etp_advx8_early_squad_lw_fl7_7"
 RosterChecks(45)="etp_advx8_early_squad_lw_fl8_8"
 RosterChecks(46)="etp_advx8_mid_squad_lw_fl12_12"
 RosterChecks(47)="etp_advx8_mid_squad_lw_fl13_13"
 RosterChecks(48)="etp_advx8_mid_squad_lw_fl14_14"
 RosterChecks(49)="etp_advx8_mid_squad_lw_fl9_11"
 RosterChecks(50)="etp_alnx6_troopmaneuvers_alienpodmidlate_fl14_14"
 RosterChecks(51)="etp_alnx6_troopmaneuvers_alienpodmidlate_fl15_17"
 RosterChecks(52)="etp_celx3_standard_fl13_99"
 RosterChecks(53)="etp_celx3_standard_fl1_5"
 RosterChecks(54)="etp_celx3_standard_fl6_12"
 RosterChecks(55)="etp_celx4_standard_fl13_99"
 RosterChecks(56)="etp_celx4_standard_fl1_5"
 RosterChecks(57)="etp_celx4_standard_fl6_12"
 RosterChecks(58)="etp_dkvx1_chryssalid_fl14_99"
 RosterChecks(59)="etp_dkvx1_chryssalid_fl7_13"
 RosterChecks(60)="etp_dlc2_archonkingx2_fl15_99"
 RosterChecks(61)="etp_dlc2_archonkingx2_fl1_14"
 RosterChecks(62)="etp_dlc2_archonkingx3_fl15_99"
 RosterChecks(63)="etp_dlc2_archonkingx3_fl1_14"
 RosterChecks(64)="etp_dlc2_archonkingx4_fl15_99"
 RosterChecks(65)="etp_dlc2_archonkingx4_fl1_14"
 RosterChecks(66)="etp_dlc2_berserkerqueenx2_fl13_99"
 RosterChecks(67)="etp_dlc2_berserkerqueenx2_fl1_7"
 RosterChecks(68)="etp_dlc2_berserkerqueenx2_fl8_12"
 RosterChecks(69)="etp_dlc2_berserkerqueenx3_fl13_99"
 RosterChecks(70)="etp_dlc2_berserkerqueenx3_fl1_7"
 RosterChecks(71)="etp_dlc2_berserkerqueenx3_fl8_12"
 RosterChecks(72)="etp_dlc2_berserkerqueenx4_fl13_99"
 RosterChecks(73)="etp_dlc2_berserkerqueenx4_fl1_7"
 RosterChecks(74)="etp_dlc2_berserkerqueenx4_fl8_12"
 RosterChecks(75)="etp_dlc2_lg_vprx2x2_fl5_6"
 RosterChecks(76)="etp_dlc2_lg_vprx2x2_fl7_7"
 RosterChecks(77)="etp_dlc2_viperkingx2_fl12_99"
 RosterChecks(78)="etp_dlc2_viperkingx2_fl1_6"
 RosterChecks(79)="etp_dlc2_viperkingx2_fl7_11"
 RosterChecks(80)="etp_dlc2_viperkingx3_fl12_99"
 RosterChecks(81)="etp_dlc2_viperkingx3_fl1_6"
 RosterChecks(82)="etp_dlc2_viperkingx3_fl7_11"
 RosterChecks(83)="etp_dlc2_viperkingx4_fl12_99"
 RosterChecks(84)="etp_dlc2_viperkingx4_fl1_6"
 RosterChecks(85)="etp_dlc2_viperkingx4_fl7_11"
 RosterChecks(86)="etp_forge_sectoid_team_protected_fl12_99"
 RosterChecks(87)="etp_forge_sectoid_team_protected_fl1_11"
 RosterChecks(88)="etp_gp_blacksite_bossgroup_easy_fl12_15"
 RosterChecks(89)="etp_gp_blacksite_bossgroup_easy_fl16_99"
 RosterChecks(90)="etp_gp_blacksite_bossgroup_easy_fl1_5"
 RosterChecks(91)="etp_gp_blacksite_bossgroup_easy_fl6_7"
 RosterChecks(92)="etp_gp_blacksite_bossgroup_easy_fl8_11"
 RosterChecks(93)="etp_gp_blacksite_bossgroup_extreme_fl12_15"
 RosterChecks(94)="etp_gp_blacksite_bossgroup_extreme_fl16_99"
 RosterChecks(95)="etp_gp_blacksite_bossgroup_extreme_fl1_5"
 RosterChecks(96)="etp_gp_blacksite_bossgroup_extreme_fl6_7"
 RosterChecks(97)="etp_gp_blacksite_bossgroup_extreme_fl8_11"
 RosterChecks(98)="etp_gp_blacksite_bossgroup_fl12_15"
 RosterChecks(99)="etp_gp_blacksite_bossgroup_fl16_99"
 RosterChecks(100)="etp_gp_blacksite_bossgroup_fl1_5"
 RosterChecks(101)="etp_gp_blacksite_bossgroup_fl6_7"
 RosterChecks(102)="etp_gp_blacksite_bossgroup_fl8_11"
 RosterChecks(103)="etp_gp_broadcast_guards_extreme_fl15_99"
 RosterChecks(104)="etp_gp_broadcast_guards_extreme_fl1_14"
 RosterChecks(105)="etp_gp_broadcast_guards_hard_fl15_15"
 RosterChecks(106)="etp_gp_broadcast_guards_hard_fl16_99"
 RosterChecks(107)="etp_gp_broadcast_guards_hard_fl1_14"
 RosterChecks(108)="etp_gp_forge_bossgroup_extreme_fl16_99"
 RosterChecks(109)="etp_gp_forge_bossgroup_extreme_fl1_7"
 RosterChecks(110)="etp_gp_forge_bossgroup_extreme_fl8_15"
 RosterChecks(111)="etp_gp_fortress_midboss_01c_fl14_99"
 RosterChecks(112)="etp_gp_fortress_midboss_01c_fl1_13"
 RosterChecks(113)="etp_gp_fortress_midboss_01c_lw_tj_fl14_99"
 RosterChecks(114)="etp_gp_fortress_midboss_01c_lw_tj_fl1_13"
 RosterChecks(115)="etp_gp_fortress_midboss_01d_fl13_15"
 RosterChecks(116)="etp_gp_fortress_midboss_01d_fl16_99"
 RosterChecks(117)="etp_gp_fortress_midboss_01d_fl1_7"
 RosterChecks(118)="etp_gp_fortress_midboss_01d_fl8_12"
 RosterChecks(119)="etp_gp_fortress_midboss_01d_lw_tj_fl1_7"
 RosterChecks(120)="etp_gp_fortress_midboss_01d_lw_tj_fl8_99"
 RosterChecks(121)="etp_gp_fortress_midboss_02b_fl16_99"
 RosterChecks(122)="etp_gp_fortress_midboss_02b_fl1_15"
 RosterChecks(123)="etp_gp_fortress_midboss_02b_lw_tj_fl16_99"
 RosterChecks(124)="etp_gp_fortress_midboss_02b_lw_tj_fl1_15"
 RosterChecks(125)="etp_gp_fortress_midboss_02c_fl13_99"
 RosterChecks(126)="etp_gp_fortress_midboss_02c_fl1_7"
 RosterChecks(127)="etp_gp_fortress_midboss_02c_fl8_12"
 RosterChecks(128)="etp_gp_fortress_midboss_02c_lw_tj_fl13_99"
 RosterChecks(129)="etp_gp_fortress_midboss_02c_lw_tj_fl1_7"
 RosterChecks(130)="etp_gp_fortress_midboss_02c_lw_tj_fl8_12"
 RosterChecks(131)="etp_gp_fortress_midboss_02d_fl12_14"
 RosterChecks(132)="etp_gp_fortress_midboss_02d_fl15_99"
 RosterChecks(133)="etp_gp_fortress_midboss_02d_fl1_6"
 RosterChecks(134)="etp_gp_fortress_midboss_02d_fl7_11"
 RosterChecks(135)="etp_gp_fortress_midbossadds_a_fl13_14"
 RosterChecks(136)="etp_gp_fortress_midbossadds_a_fl15_99"
 RosterChecks(137)="etp_gp_fortress_midbossadds_a_fl1_7"
 RosterChecks(138)="etp_gp_fortress_midbossadds_a_fl8_12"
 RosterChecks(139)="etp_gp_fortress_midbossadds_a_lw_tj_fl13_99"
 RosterChecks(140)="etp_gp_fortress_midbossadds_a_lw_tj_fl1_12"
 RosterChecks(141)="etp_gp_fortress_midbossadds_d_fl13_99"
 RosterChecks(142)="etp_gp_fortress_midbossadds_d_fl1_7"
 RosterChecks(143)="etp_gp_fortress_midbossadds_d_fl8_12"
 RosterChecks(144)="etp_gp_fortress_midbossadds_d_lw_tj_fl13_99"
 RosterChecks(145)="etp_gp_fortress_midbossadds_d_lw_tj_fl1_7"
 RosterChecks(146)="etp_gp_fortress_midbossadds_d_lw_tj_fl8_12"
 RosterChecks(147)="etp_gp_fortress_midbossadds_e_fl15_99"
 RosterChecks(148)="etp_gp_fortress_midbossadds_e_fl1_14"
 RosterChecks(149)="etp_gp_fortress_midbossadds_f_fl14_99"
 RosterChecks(150)="etp_gp_fortress_midbossadds_f_fl1_13"
 RosterChecks(151)="etp_gp_fortress_midbossadds_f_lw_tj_fl14_99"
 RosterChecks(152)="etp_gp_fortress_midbossadds_f_lw_tj_fl1_13"
 RosterChecks(153)="etp_gp_fortress_midbossadds_g_fl16_99"
 RosterChecks(154)="etp_gp_fortress_midbossadds_g_fl1_7"
 RosterChecks(155)="etp_gp_fortress_midbossadds_g_fl8_15"
 RosterChecks(156)="etp_gp_fortress_midbossadds_g_lw_tj_fl12_15"
 RosterChecks(157)="etp_gp_fortress_midbossadds_g_lw_tj_fl16_99"
 RosterChecks(158)="etp_gp_fortress_midbossadds_g_lw_tj_fl1_7"
 RosterChecks(159)="etp_gp_fortress_midbossadds_g_lw_tj_fl8_11"
 RosterChecks(160)="etp_gp_fortress_midbossadds_h_fl12_99"
 RosterChecks(161)="etp_gp_fortress_midbossadds_h_fl1_6"
 RosterChecks(162)="etp_gp_fortress_midbossadds_h_fl7_11"
 RosterChecks(163)="etp_gp_fortress_midbossadds_i_fl12_99"
 RosterChecks(164)="etp_gp_fortress_midbossadds_i_fl1_11"
 RosterChecks(165)="etp_gp_fortress_midswarm_a_fl13_99"
 RosterChecks(166)="etp_gp_fortress_midswarm_a_fl1_7"
 RosterChecks(167)="etp_gp_fortress_midswarm_a_fl8_12"
 RosterChecks(168)="etp_gp_fortress_midswarm_a_lw_tj_fl1_7"
 RosterChecks(169)="etp_gp_fortress_midswarm_a_lw_tj_fl8_99"
 RosterChecks(170)="etp_gp_fortress_midswarm_b_fl15_99"
 RosterChecks(171)="etp_gp_fortress_midswarm_b_fl1_14"
 RosterChecks(172)="etp_gp_fortress_midswarm_b_lw_tj_fl15_99"
 RosterChecks(173)="etp_gp_fortress_midswarm_b_lw_tj_fl1_14"
 RosterChecks(174)="etp_gp_fortress_midswarm_c_fl16_99"
 RosterChecks(175)="etp_gp_fortress_midswarm_c_fl1_7"
 RosterChecks(176)="etp_gp_fortress_midswarm_c_fl8_15"
 RosterChecks(177)="etp_gp_fortress_midswarm_c_lw_tj_fl16_99"
 RosterChecks(178)="etp_gp_fortress_midswarm_c_lw_tj_fl1_15"
 RosterChecks(179)="etp_gp_psigate_chryssalids_fl14_99"
 RosterChecks(180)="etp_gp_psigate_chryssalids_fl1_13"
 RosterChecks(181)="etp_gp_psigate_solitaryhunter_fl14_99"
 RosterChecks(182)="etp_gp_psigate_solitaryhunter_fl1_13"
 RosterChecks(183)="etp_hq_drone_patrol_fl1_7"
 RosterChecks(184)="etp_hq_drone_patrol_fl8_99"
 RosterChecks(185)="etp_lna_purifierteamx2_fl15_99"
 RosterChecks(186)="etp_lna_purifierteamx2_fl1_7"
 RosterChecks(187)="etp_lna_purifierteamx2_fl8_14"
 RosterChecks(188)="etp_lone_dronem1_fl1_7"
 RosterChecks(189)="etp_lone_dronem1_fl8_14"
 RosterChecks(190)="etp_muton_warband_early_protected_fl7_7"
 RosterChecks(191)="etp_muton_warband_early_protected_fl8_9"
 RosterChecks(192)="etp_muton_warband_mid_protected_fl10_12"
 RosterChecks(193)="etp_muton_warband_mid_protected_fl13_14"
 RosterChecks(194)="etp_original_advx2_veryweak_lw"
 RosterChecks(195)="etp_original_advx2_weak_lw"
 RosterChecks(196)="etp_original_dlc2_archonkingx2"
 RosterChecks(197)="etp_original_dlc2_archonkingx3"
 RosterChecks(198)="etp_original_dlc2_archonkingx4"
 RosterChecks(199)="etp_original_dlc2_berserkerqueenx2"
 RosterChecks(200)="etp_original_dlc2_berserkerqueenx3"
 RosterChecks(201)="etp_original_dlc2_berserkerqueenx4"
 RosterChecks(202)="etp_original_dlc2_viperkingx2"
 RosterChecks(203)="etp_original_dlc2_viperkingx3"
 RosterChecks(204)="etp_original_dlc2_viperkingx4"
 RosterChecks(205)="etp_original_terx1_chryssalid"
 RosterChecks(206)="etp_original_terx2_chryssalids"
 RosterChecks(207)="etp_original_terx2_standard"
 RosterChecks(208)="etp_original_terx3_chryssalids"
 RosterChecks(209)="etp_original_terx3_standard"
 RosterChecks(210)="etp_sabotagecc_guardx3_fl12_12"
 RosterChecks(211)="etp_sabotagecc_guardx3_fl13_99"
 RosterChecks(212)="etp_sabotagecc_guardx3_fl1_5"
 RosterChecks(213)="etp_sabotagecc_guardx3_fl6_6"
 RosterChecks(214)="etp_sabotagecc_guardx3_fl7_11"
 RosterChecks(215)="etp_sabotagecc_patrolx2_fl12_99"
 RosterChecks(216)="etp_sabotagecc_patrolx2_fl1_5"
 RosterChecks(217)="etp_sabotagecc_patrolx2_fl6_11"
 RosterChecks(218)="etp_sabotagecc_patrolx3_fl12_99"
 RosterChecks(219)="etp_sabotagecc_patrolx3_fl1_5"
 RosterChecks(220)="etp_sabotagecc_patrolx3_fl6_11"
 RosterChecks(221)="etp_small_supply_command_pod_midlate_protected_fl13_13"
 RosterChecks(222)="etp_small_supply_command_pod_midlate_protected_fl14_15"
 RosterChecks(223)="etp_small_supply_command_pod_midlate_protected_fl16_16"
 RosterChecks(224)="etp_terx1_chryssalid_fl14_99"
 RosterChecks(225)="etp_terx1_chryssalid_fl1_13"
 RosterChecks(226)="etp_terx2_chryssalids_fl14_99"
 RosterChecks(227)="etp_terx2_chryssalids_fl1_13"
 RosterChecks(228)="etp_terx3_chryssalids_fl14_99"
 RosterChecks(229)="etp_terx3_chryssalids_fl1_13"
 RosterChecks(230)="etp_verysmall_supply_command_pod_midlate_protected_fl13_13"
 RosterChecks(231)="etp_verysmall_supply_command_pod_midlate_protected_fl14_16"
 RosterChecks(232)="gp_fortress_avatarteam_c_lw_tj_finaltier"
 RosterChecks(233)="gp_fortress_avatarteam_c_lw_tj_finaltier_extraroll"
 RosterChecks(234)="gp_fortress_avatarteam_f_lw_finaltier"
 RosterChecks(235)="gp_fortress_avatarteam_f_lw_finaltier_extraroll"
 RosterChecks(236)="gp_fortress_avatarteam_g_lw_finaltier"
 RosterChecks(237)="gp_fortress_avatarteam_g_lw_finaltier_extraroll"
 RosterChecks(238)="gp_fortress_dualavatarteam_a_finaltier"
 RosterChecks(239)="gp_fortress_dualavatarteam_b_finaltier"
 RosterChecks(240)="gp_fortress_dualavatarteam_c_finaltier"
 RosterChecks(241)="gp_fortress_dualavatarteam_d_finaltier"
 RosterChecks(242)="gp_fortress_dualavatarteam_e_finaltier"
 RosterChecks(243)="gp_fortress_dualavatarteam_f_finaltier"
 RosterChecks(244)="gp_fortress_dualavatarteam_g_finaltier"
 RosterChecks(245)="muton_warband_late_protected"
 RosterChecks(246)="showdown_t1rnf_chryssalidswarm_lw_tj_req_finaltier"
 RosterChecks(247)="showdown_t1rnf_chryssalidswarm_lw_tj_req_finaltier_extraroll"
 RosterChecks(248)="showdown_t1rnf_codexswarm_lw_tj_req_finaltier"
 RosterChecks(249)="showdown_t1rnf_codexswarm_lw_tj_req_finaltier_extraroll"
 RosterChecks(250)="showdown_t1rnf_mutonswarm_lw_tj_finaltier"
 RosterChecks(251)="showdown_t1rnf_mutonswarm_lw_tj_finaltier_extraroll"
 RosterChecks(252)="showdown_t1rnf_sectoidswarm_lw_tj_finaltier"
 RosterChecks(253)="showdown_t1rnf_sectoidswarm_lw_tj_finaltier_extraroll"
 RosterChecks(254)="showdown_t1rnf_shieldtroopers_lw_tj_finaltier"
 RosterChecks(255)="showdown_t1rnf_shieldtroopers_lw_tj_finaltier_extraroll"
 RosterChecks(256)="showdown_t1rnf_taipanswarm_lw_tj_req_finaltier"
 RosterChecks(257)="showdown_t1rnf_taipanswarm_lw_tj_req_finaltier_extraroll"
 RosterChecks(258)="showdown_t2rnf_andromelidswarm_lw_tj_req_finaltier"
 RosterChecks(259)="showdown_t2rnf_andromelidswarm_lw_tj_req_finaltier_extraroll"
 RosterChecks(260)="showdown_t2rnf_archonswarm_lw_tj_req_finaltier"
 RosterChecks(261)="showdown_t2rnf_archonswarm_lw_tj_req_finaltier_extraroll"
 RosterChecks(262)="showdown_t2rnf_berserkerswarm_lw_tj_finaltier"
 RosterChecks(263)="showdown_t2rnf_berserkerswarm_lw_tj_finaltier_extraroll"
 RosterChecks(264)="showdown_t2rnf_mectoidswarm_lw_tj_req_finaltier"
 RosterChecks(265)="showdown_t2rnf_mectoidswarm_lw_tj_req_finaltier_extraroll"
 RosterChecks(266)="showdown_t2rnf_priestswarm_lw_finaltier"
 RosterChecks(267)="showdown_t2rnf_priestswarm_lw_finaltier_extraroll"
 RosterChecks(268)="showdown_t2rnf_spectreswarm_lw_finaltier"
 RosterChecks(269)="showdown_t2rnf_spectreswarm_lw_finaltier_extraroll"
 RosterChecks(270)="showdown_t3rnf_gatekeeperseta_lw_tj_finaltier"
 RosterChecks(271)="showdown_t3rnf_gatekeeperseta_lw_tj_finaltier_extraroll"
 RosterChecks(272)="showdown_t3rnf_sectopodsetc_lw_tj_finaltier"
 RosterChecks(273)="showdown_t3rnf_sectopodsetc_lw_tj_finaltier_extraroll"
 RosterChecks(274)="small_supply_command_pod_mid_protected"
 RosterChecks(275)="SabotageCC_Patrolx3"
 RosterChecks(276)="GP_Broadcast_Guards_Hard"
 RosterChecks(277)="GP_Fortress_MidBoss_01c_LW_TJ"

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
