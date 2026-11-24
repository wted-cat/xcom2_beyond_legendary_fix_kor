class X2AIBTConditions_CoarseYearning extends X2AIBTDefaultConditions;

static event bool FindBTConditionDelegate(name ConditionName, optional out delegate<BTConditionDelegate> ConditionFn, optional out name NameParam)
{
	if (ConditionName == 'CoarseHasBasharEquipment')
	{
		ConditionFn = CoarseHasBasharEquipment;
		return true;
	}
	return super.FindBTConditionDelegate(ConditionName, ConditionFn, NameParam);
}

function bt_status CoarseHasBasharEquipment()
{
	if (m_kUnitState != none && class'CoarseYearningEquipment'.static.HasBasharEquipment(m_kUnitState))
	{
		return BTS_SUCCESS;
	}
	return BTS_FAILURE;
}
