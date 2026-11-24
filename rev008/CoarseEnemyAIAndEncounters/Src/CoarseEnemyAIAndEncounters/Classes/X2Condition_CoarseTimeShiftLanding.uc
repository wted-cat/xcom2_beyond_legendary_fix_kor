class X2Condition_CoarseTimeShiftLanding extends X2Condition;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	local XComGameState_Unit Target, Source, Occupant;
	local XComWorldData World;
	local StateObjectReference Ref;
	local array<StateObjectReference> Occupants;
	local TTile Destination;

	Target = XComGameState_Unit(kTarget);
	Source = XComGameState_Unit(kSource);
	if (Target == none || Source == none)
	{
		return 'AA_NotAUnit';
	}
	Destination = Source.TurnStartLocation;
	if (Source.ObjectID != Target.ObjectID && Source.TileLocation == Destination)
	{
		return 'AA_TileIsBlocked';
	}
	World = `XWORLD;
	if (Target.TileLocation != Destination && (!World.IsFloorTileAndValidDestination(Destination)
		|| !World.CanUnitsEnterTile(Destination) || World.IsTileOccupied(Destination)))
	{
		return 'AA_TileIsBlocked';
	}
	Occupants = World.GetUnitsOnTile(Destination);
	foreach Occupants(Ref)
	{
		if (Ref.ObjectID != Target.ObjectID)
		{
			Occupant = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Ref.ObjectID));
			if (Occupant != none && Occupant.IsAlive() && !Occupant.GetMyTemplate().bIsCosmetic)
			{
				return 'AA_TileIsBlocked';
			}
		}
	}
	return 'AA_Success';
}
