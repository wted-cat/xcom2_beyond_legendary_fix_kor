class CoarseYearningCards extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local ARFMYearningTemplate Card;
	local array<X2DataTemplate> Cards;

	// The object name also selects the per-object localization and remains the saved card identity.
	`CREATE_X2TEMPLATE(class'ARFMYearningTemplate', Card, 'YMTriParteNineteen');
	Card.Category = "YearningMutator";
	Card.ImagePath = "img:///ARFMDE_UILibrary.PYP_Alert";
	Card.RequiredMonths = 3;
	Card.OnActivatedFn = class'ARFM_SE_YearningMutators'.static.Beaglebusting;
	Card.OnSecondaryActivatedFn = class'ARFM_SE_YearningMutators'.static.Battleborn;
	Card.OnTrinaryActivatedFn = class'ARFM_SE_YearningMutators'.static.Battlehaunt;
	Cards.AddItem(Card);
	return Cards;
}
