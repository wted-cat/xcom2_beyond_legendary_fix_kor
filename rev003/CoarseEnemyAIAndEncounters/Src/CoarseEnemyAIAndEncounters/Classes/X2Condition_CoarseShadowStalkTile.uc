class X2Condition_CoarseShadowStalkTile extends X2Condition;

static function bool FindLandingTile(XComGameState_Unit Target, out TTile Destination)
{
	return Target != none && Target.FindAvailableNeighborTileWeighted(vect(1,0,0), Destination, IsValidLanding);
}

static private function bool IsValidLanding(const out TTile Candidate, const out TTile Center, const out Object Context)
{
	local XComWorldData World;
	local array<StateObjectReference> Occupants;
	local StateObjectReference Ref;
	local XComGameState_Unit Unit;

	World = `XWORLD;
	if (Candidate == Center || World.IsTileOccupied(Candidate) || !World.IsFloorTileAndValidDestination(Candidate))
	{
		return false;
	}
	Occupants = World.GetUnitsOnTile(Candidate);
	foreach Occupants(Ref)
	{
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));
		if (Unit != none && Unit.IsAlive() && !Unit.GetMyTemplate().bIsCosmetic)
		{
			return false;
		}
	}
	return true;
}

event name CallMeetsCondition(XComGameState_BaseObject Target)
{
	local TTile Destination;

	if (FindLandingTile(XComGameState_Unit(Target), Destination))
	{
		return 'AA_Success';
	}
	return 'AA_TileIsBlocked';
}
