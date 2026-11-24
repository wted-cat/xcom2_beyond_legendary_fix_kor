class XGAIBehavior_CoarseFrost extends XGAIBehavior;

function name GetBehaviorTreeRoot()
{
	local name RootName;

	RootName = super.GetBehaviorTreeRoot();
	if (RootName == '' && UnitState != none && UnitState.GetMyTemplate() != none)
	{
		// GenericAIRoot dispatches ::CharacterRoot using the current unit's character group.
		return 'GenericAIRoot';
	}
	return RootName;
}

static function InstallForTemplate(X2CharacterTemplateManager Manager, name TemplateName, string OptionalRoot)
{
	local array<X2DataTemplate> Variants;
	local X2DataTemplate Variant;
	local X2CharacterTemplate Character;

	Manager.FindDataTemplateAllDifficulties(TemplateName, Variants);
	foreach Variants(Variant)
	{
		Character = X2CharacterTemplate(Variant);
		if (Character != none && Character.BehaviorClass == class'XGAIBehavior'
			&& Character.strBehaviorTree ~= OptionalRoot)
		{
			Character.BehaviorClass = class'XGAIBehavior_CoarseFrost';
		}
	}
}
