class X2Ability_CoarseAuditFixture extends X2Ability;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local X2AbilityTemplate Template;
	local X2Effect_TurnStartActionPoints Cost;

	Template = PurePassive('CoarseAuditDazedFixture', "", false);
	Template.AddTargetEffect(class'X2StatusEffects_XPack'.static.CreateDazedStatusEffect(3, 100));
	Templates.AddItem(Template);
	Template = PurePassive('CoarseAuditLastPointFixture', "", false);
	Cost = new class'X2Effect_TurnStartActionPoints';
	Cost.EffectName = 'CoarseAuditLastPoint';
	Cost.BuildPersistentEffect(1, true, false);
	Cost.DuplicateResponse = eDupe_Ignore;
	Cost.ActionPointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	Cost.NumActionPoints = 2;
	Cost.bActionPointsRemoved = true;
	Template.AddTargetEffect(Cost);
	Templates.AddItem(Template);
	return Templates;
}
