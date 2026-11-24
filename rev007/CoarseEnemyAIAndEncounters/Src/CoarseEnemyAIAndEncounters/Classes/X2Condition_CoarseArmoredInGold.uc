class X2Condition_CoarseArmoredInGold extends X2Condition;

function bool CanEverBeValid(XComGameState_Unit SourceUnit, bool bStrategyCheck)
{
	local XComGameState_HeadquartersAlien AlienHQ;

	if (SourceUnit == none || !SourceUnit.IsSoldier())
	{
		return false;
	}
	AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien', true));
	return AlienHQ != none && AlienHQ.IsDarkEventActive('ARFMDE_ArmoredInGold');
}

event name CallMeetsCondition(XComGameState_BaseObject Target)
{
	local XComGameState_Unit Unit;

	Unit = XComGameState_Unit(Target);
	if (Unit == none || Unit.GetTeam() != eTeam_XCom || !CanEverBeValid(Unit, false))
	{
		return 'AA_AbilityUnavailable';
	}
	return 'AA_Success';
}
