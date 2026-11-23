class X2AIBTConditions_ReviewBranch extends X2AIBTDefaultConditions;
static event bool FindBTConditionDelegate(name ConditionName, optional out delegate<BTConditionDelegate> ConditionFn, optional out name NameParam)
{
 if(Left(string(ConditionName),10)~="R7Witness-")
 {ConditionFn=Witness;NameParam=name(Mid(string(ConditionName),10));return true;}
 return super.FindBTConditionDelegate(ConditionName,ConditionFn,NameParam);
}
function bt_status Witness()
{
 if(m_kUnitState!=none)LogInternal("R7|WITNESS|"$`XCOMHISTORY.GetCurrentHistoryIndex()$"|"$m_kUnitState.ObjectID$"|"$m_kUnitState.GetMyTemplateName()$"|"$SplitNameParam);
 return BTS_SUCCESS;
}
