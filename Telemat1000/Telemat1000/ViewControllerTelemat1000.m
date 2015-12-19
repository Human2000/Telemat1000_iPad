//
//  ViewControllerTelemat1000.m
//  Telemat1000
//

#import "ViewControllerTelemat1000.h"
#import "UIViewControllerSharedMethods.h"
#import "BindingsHandler.h"
#import "UINavigationBar+DefaultTint.h"

@implementation ViewControllerTelemat1000 {
	NSDictionary * _bindings;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self configureNavigationBarAnimated:animated];
	[self.moviePlayerView viewWillAppear:animated];
	[UIViewControllerSharedMethods unselectAllCellsInView:self.view animated:animated];
	[self prepareForBindings];
}

- (void)prepareForBindings {

	if (!_bindings) _bindings = @{
			[NSNumber numberWithUnsignedInteger:[self.filteredDataSource2 hash]]:
			    @{
					@"contents.StreamURL": @[@{
						@"object": self.moviePlayerView,
						@"keyPath": @"movieURLString",
						@"transformer": @"TO_STRING",
					}],
					@"contents.ProgrammURL": @[@{
						@"object": self.webView,
						@"keyPath": @"URLString",
						@"transformer": @"TO_STRING",
					}],
					@"filterKeyPath": @[@{
						@"object": self.collectionViewDataProvider,
						@"keyPath": @"contents.selectedItemIndex",
					}],
				},
			[NSNumber numberWithUnsignedInteger:[self.collectionViewDataProvider hash]]:
			    @{
					@"contents.selectedItemIndex": @[@{
						@"object": self.filteredDataSource2,
						@"keyPath": @"filterKeyPath",
						@"transformer": @"TO_STRING",
					}],
				},
		};

	[self.filteredDataSource2 addObserver:self];
	[self.collectionViewDataProvider addObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id<BindingsKeyValueCoding>)object change:(NSDictionary *)change context:(void *)context {
	[BindingsHandler applyBindings:_bindings forKeyPath:keyPath ofObject:object];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self.filteredDataSource2 removeObserver:self];
	[self.collectionViewDataProvider removeObserver:self];
}

- (void)configureNavigationBarAnimated:(BOOL)animated {
	UINavigationBar * navigationBar = self.navigationController.navigationBar;
	[self.navigationController setNavigationBarHidden:NO animated:animated];
	navigationBar.tintColorOrUseDefault = nil;
	navigationBar.barStyle = UIBarStyleDefault;
	navigationBar.translucent = NO;
	if ([navigationBar respondsToSelector:@selector(setBarTintColor:)]) [navigationBar setBarTintColor:nil];
	[navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

@end
