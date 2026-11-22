class X2AIBTActions_CoarseRadial extends X2AIBTDefaultActions;

static event bool FindBTActionDelegate(name ActionName, optional out delegate<BTActionDelegate> ActionFn, optional out name NameParam, optional out name MoveProfile)
{
	local name ActionPrefix, ProfileName;

	if (SplitNameAtHyphen(ActionName, ActionPrefix, ProfileName) && ActionPrefix == 'CoarseSelectOrigin' && IsValidAoEProfile(ProfileName))
	{
		ActionFn = SelectShooterLocation;
		NameParam = ProfileName;
		return true;
	}
	return super.FindBTActionDelegate(ActionName, ActionFn, NameParam, MoveProfile);
}

function bt_status SelectShooterLocation()
{
	local AoETarget PreviousTarget, ShooterTarget;

	if (m_kBehavior == none || m_kBehavior.m_kUnit == none)
	{
		return BTS_FAILURE;
	}
	ShooterTarget.Profile = SplitNameParam;
	ShooterTarget.Ability = m_kBehavior.GetAbilityFromTargetingProfile(SplitNameParam);
	ShooterTarget.Location = m_kBehavior.m_kUnit.GetGameStateLocation();

	PreviousTarget = m_kBehavior.TopAoETarget;
	m_kBehavior.TopAoETarget = ShooterTarget;
	if (m_kBehavior.BT_SelectAoETarget(SplitNameParam))
	{
		return BTS_SUCCESS;
	}
	// A failed shot must leave the search result available to the movement branch.
	m_kBehavior.TopAoETarget = PreviousTarget;
	return BTS_FAILURE;
}
