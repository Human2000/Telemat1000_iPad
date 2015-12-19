//
//  DataSourceBase.m
//

#import "DataSourceBase.h"
#import "NSStringPunycodeAdditions.h"

@protocol DataSourceObserver <NSObject>
- (void)dataSourceDidLoad:(id)dataSource;
@end

@protocol CellWithInputData <NSObject>
- (void)setInputData:(id)inputData;
@end

static const int kTimeoutInSeconds = 30;

@implementation DataSourceBase {
	NSMutableArray * _loadingIndicatorViews;
	NSMutableSet * observers;
	NSOperationQueue * _downloadQueue;
	BOOL _isLoading;
	BOOL _isLoadingMoreFromButton;
}

- (id)init {
	self = [super init];
	if (self) {
		observers = [NSMutableSet set];
	}
	return self;
}

- (void)awakeFromNib {
}

- (void)refreshFromControl:(id)sender {
	[self refresh];
}

- (void)refresh {
	[self clear];
	[self load];
}

- (void)clear {
	// To be overwritten.
}

- (void)load {
	// To be overwritten.
}

- (BOOL)didLoad {
	// to be overwritten
	return YES;
}

- (id)contents {
	// must be overwritten
	return nil;
}

- (id)items {
	// must be overwritten
	return nil;
}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
	
	if ([keyPath length] == 0) {
		[self addObserver:observer];
	}
	else {
		[super addObserver:observer forKeyPath:keyPath options:options context:context];
	}
	
}

#pragma mark - Showing activity indicators

- (void)addLoadingIndicators {
	
	_loadingIndicatorViews = @[].mutableCopy;
	
	for (NSObject * observer in observers) {
		
		if ([observer isKindOfClass:[UIView class]]) {
			
			if ([self refreshControlForObserver:observer].isRefreshing) continue;
			
			UIView * view = (UIView *)observer;
			UIView * loadingIndicator = [self createLoadingIndicator];
			loadingIndicator.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
			[view addSubview:loadingIndicator];
			
			[_loadingIndicatorViews addObject:loadingIndicator];
			
		}
	}
	
}

- (void)removeAllLoadingIndicators {
	
	for (UIView * loadingIndicator in _loadingIndicatorViews) {
		[loadingIndicator removeFromSuperview];
	}
	
	[_loadingIndicatorViews removeAllObjects];
	
}

- (NSString *)stringForLoadingLabel {
	return NSLocalizedStringFromTable(@"Loading", @"DataSourceBaseLocalized", nil);
}

- (UIView *)createLoadingIndicator {
	
	int height = 20;
	
	NSString * labelText = self.stringForLoadingLabel;
	UILabel * label = [UILabel.alloc initWithFrame:CGRectMake(30,0,1000,height)];
	label.text = labelText;
	label.textColor = [UIColor grayColor];
	label.backgroundColor = [UIColor clearColor];
	
	CGSize s;
#if  __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
	s = [labelText sizeWithFont:label.font];
#else
	s = [labelText sizeWithAttributes:[NSDictionary dictionaryWithObject:label.font forKey:NSFontAttributeName]];
#endif
	
	int width = s.width + 30;
	
	UIView * loadingIndicatorView = [UIView.alloc initWithFrame:CGRectMake(0,0,width,height)];
	loadingIndicatorView.autoresizingMask = 45;
	
	UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[activityIndicator startAnimating];
	[loadingIndicatorView addSubview:activityIndicator];
	
	[loadingIndicatorView addSubview:label];
	
	loadingIndicatorView.alpha = 0;
	[UIView beginAnimations:@"Fade-in loading indicator" context:0];
	[UIView setAnimationDuration:1];
	loadingIndicatorView.alpha = 1;
	[UIView commitAnimations];
	
	return loadingIndicatorView;
	
}

#pragma mark - Handling refresh controls

- (UIRefreshControl *)refreshControlForObserver:(NSObject *)observer {
	if ([observer isKindOfClass:[UIView class]]) {
		// look for a UIRefreshControl and tell it to stop reloading
		for (UIView * subview in ((UIView *)observer).subviews) {
			if ([subview isKindOfClass:[UIRefreshControl class]]) {
				return (UIRefreshControl *)subview;
			}
		}
	}
	return nil;
}


#pragma mark - Managing observers

- (void)addObserver:(id)observer {
	//NSLog(@"addObserver (%@): %@", NSStringFromClass([self class]), observer);
	if (![observers containsObject:observer]) {
		[observers addObject:observer];
		if (self.didLoad) {
			[self notifyObserver:observer forKeyPath:@"" update:NO];
		}
	}
}

- (void)removeObserver:(id)observer {
	//NSLog(@"removeObserver (%@): %@", NSStringFromClass([self class]), observer);
	[observers removeObject:observer];
}

- (void)notifyObservers {
	[self notifyObserversWithUpdate:NO];
}

- (void)notifyObserversWithUpdate:(BOOL)update {

	if ([[NSThread currentThread] isMainThread]) {
		for (NSObject * observer in observers) {
			[self notifyObserver:observer forKeyPath:@"" update:update];
		}
	}
	else {
		dispatch_async(dispatch_get_main_queue(), ^{
			for (NSObject * observer in observers) {
				[self notifyObserver:observer forKeyPath:@"" update:update];
			}
		});
	}
	
}

- (void)notifyObserversForKeyPath:(NSString *)keyPath {
	[self notifyObserversForKeyPath:keyPath update:NO];
}

- (void)notifyObserversForKeyPath:(NSString *)keyPath update:(BOOL)update {

	for (NSObject * observer in observers) {
		[self notifyObserver:observer forKeyPath:keyPath update:update];
	}

}

- (void)notifyObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath update:(BOOL)update {
	
	if ([observer respondsToSelector:@selector(reloadData)]) {
		if (update && [observer respondsToSelector:@selector(performBatchUpdates:completion:)]) {
			UICollectionView * cv = (UICollectionView *)observer;
			[cv performBatchUpdates:^{
				if ([cv numberOfSections] == 1)
					[cv reloadSections:[NSIndexSet indexSetWithIndex:0]];
				else
					[cv reloadData];
			} completion:^(BOOL finished) {}];
		}
		else {
			[observer performSelector:@selector(reloadData)];
		}
	}
	else if ([observer respondsToSelector:@selector(dataSourceDidLoad:)]) {
		[observer performSelector:@selector(dataSourceDidLoad:) withObject:self];
	}
	else {
		[observer observeValueForKeyPath:keyPath ofObject:self change:nil context:0];
	}
	
	UIRefreshControl * refreshControl = [self refreshControlForObserver:observer];
	if (refreshControl) [refreshControl endRefreshing];

}

#pragma mark - Requesting data by URL

- (void)sendRequestForURLFromString:(NSString *)URLString completion:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError))completionHandler {
	
	NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithUnicodeString:URLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTimeoutInSeconds];
	
	if (!_downloadQueue) _downloadQueue = [NSOperationQueue.alloc init];
	else [_downloadQueue cancelAllOperations];
	
	_isLoading = YES;
	[NSURLConnection sendAsynchronousRequest:request queue:_downloadQueue completionHandler:^(NSURLResponse * response, NSData * data, NSError * error) {
		_isLoading = NO;
		
		[self removeAllLoadingIndicators];
		
		if (error) {
			[self notifyObserversWithUpdate:NO];
			NSLog(@"Error requesting data: %@", error);
		}

		if (completionHandler) completionHandler(response, data, error);
		
	}];
	
	[self performSelector:@selector(checkIfDidLoad) withObject:nil afterDelay:0.5];
	
}

- (void)checkIfDidLoad {
	if (_isLoading && !_isLoadingMoreFromButton) {
		[self addLoadingIndicators];
	}
}


#pragma mark - Generic data source methods

- (NSInteger)numberOfSections {
	// To be overwritten.
	return 0;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
	// To be overwritten.
	return 0;
}

- (NSDictionary *)datasetForItemAtIndexPath:(NSIndexPath *)indexPath {
	// To be overwritten.
	return nil;
}


#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	[self addObserver:tableView];
	return self.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rowCount = [self numberOfItemsInSection:section];
	if (self.canLoadMore) rowCount += 1;
	return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSObject<CellGenerator> * cellGenerator = nil;
	if (self.usesCellGenerator) cellGenerator = [tableView valueForKey:@"cellGenerator"];

	static NSString * cellIdentifier = @"Cell";
	UITableViewCell * cell = nil;
	
	if (cellGenerator) {
		[cellGenerator generateTableViewCell:&cell withIdentifier:cellIdentifier indexPath:indexPath];
	}
	else {
		cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		//if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		[cell performSelector:@selector(setInputData:) withObject:[self datasetForItemAtIndexPath:indexPath]];
	}
	[self prepareCellForPagination:cell withIndexPath:indexPath inItemsView:tableView];
	
	
	return cell;
}


#pragma mark - UICollectionView data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	[self addObserver:collectionView];
	return self.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	NSInteger cellCount = [self numberOfItemsInSection:section];
	if (self.canLoadMore) cellCount += 1;
	return cellCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	NSObject<CellGenerator> * cellGenerator = nil;
	if (self.usesCellGenerator) cellGenerator = [collectionView valueForKey:@"cellGenerator"];

	static NSString * cellIdentifier = @"Cell";
	UICollectionViewCell * cell = nil;
	
	if (cellGenerator) {
		[cellGenerator generateCollectionViewCell:&cell forCollectionView:collectionView withIdentifier:cellIdentifier indexPath:indexPath];
	}
	else {
		cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

		NSDictionary * dataset = [self datasetForItemAtIndexPath:indexPath];

		[cell performSelector:@selector(setInputData:) withObject:dataset];
	}
		
	[self prepareCellForPagination:cell withIndexPath:indexPath inItemsView:collectionView];

	return cell;
	
}


#pragma mark - Pagination

#define CELL_HAD_INDICATOR

- (void)prepareCellForPagination:(id)aCell withIndexPath:(NSIndexPath *)indexPath inItemsView:(UIView *)itemsView {
	
	UITableViewCell * cell = (UITableViewCell *)aCell;
	
	[[cell.contentView viewWithTag:999999] removeFromSuperview];
	if (indexPath.row == [self numberOfItemsInSection:0] && self.canLoadMore) {
		UIButton * backgroundView = [UIButton buttonWithType:UIButtonTypeSystem];
		backgroundView.frame = cell.bounds;
		backgroundView.userInteractionEnabled = YES;
		backgroundView.showsTouchWhenHighlighted = NO;
		backgroundView.tag = 999999;
		[cell.contentView addSubview:backgroundView];
		[backgroundView addTarget:self action:@selector(loadMoreFromButton:) forControlEvents:UIControlEventTouchUpInside];
		
		UILabel * label = [UILabel.alloc initWithFrame:backgroundView.bounds];
		label.text = NSLocalizedStringFromTable(@"Load more entries", @"DataSourceBaseLocalized", nil);
		label.font = [UIFont boldSystemFontOfSize:13];
		label.numberOfLines = 0;
		label.textAlignment = 1;//UITextAlignmentCenter;
		label.textColor = [UIColor colorWithWhite:0 alpha:0.6];
		[backgroundView addSubview:label];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			backgroundView.backgroundColor = itemsView.backgroundColor;
			if (!backgroundView.backgroundColor) backgroundView.backgroundColor = UIColor.whiteColor;
			if ([cell isKindOfClass:[UITableViewCell class]]) {
				// store the accessory type in the tag
				if (cell.accessoryType) cell.tag = cell.accessoryType;
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		});
	}
	else {
		if ([cell isKindOfClass:[UITableViewCell class]]) {
			// restore the accessory type from the tag
			if (cell.tag) cell.accessoryType = cell.tag;
		}
	}
}

- (BOOL)canLoadMore {
	return NO;
}

- (void)loadMore {
	// To be overwritten.
}

- (void)loadMoreFromButton:(UIButton *)button {
	[button removeTarget:self action:@selector(loadMoreFromButton:) forControlEvents:UIControlEventTouchUpInside];
	UILabel * label = [button.subviews objectAtIndex:0];
	UIActivityIndicatorView * aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[aiv startAnimating];
	if (button.bounds.size.height > 44) {
		label.text = self.stringForLoadingLabel;
		label.center = CGPointMake(label.center.x, label.center.y + 15);
		aiv.center = CGPointMake(label.center.x, label.center.y - 22);
	}
	else {
		//label.center = CGPointMake(label.center.x, label.center.y + 15);
		[UIView animateWithDuration:0.25 animations:^{
			label.alpha = 0;
		}];
		aiv.center = label.center;
	}
	aiv.alpha = 0;
	[UIView animateWithDuration:0.25 animations:^{
		aiv.alpha = 1;
	}];
	[button addSubview:aiv];
	_isLoadingMoreFromButton = YES;
	[self loadMore];
}

#pragma mark - Editing

- (BOOL)isEditable {
	return NO;
}

- (BOOL)deleteItemAtIndexPath:(NSIndexPath *)indexPath {
	// To be overwritten.
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.isEditable;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		if ([self deleteItemAtIndexPath:indexPath]) {
			[tableView beginUpdates];
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[tableView endUpdates];
		}
    }
}



@end



@implementation NSString (URLEscapedQuery)

+ (NSString *)urlEscapeString:(NSString *)unencodedString {
    CFStringRef originalStringRef = (__bridge_retained CFStringRef)unencodedString;
    NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL,kCFStringEncodingUTF8);
    CFRelease(originalStringRef);
    return s;
}

+ (NSString *)queryStringFromDictionary:(NSDictionary *)dict {
	BOOL begin = YES;
	NSString * result = @"";
	for (id key in dict) {
        NSString * keyString = [key description];
        NSString * valueString = [[dict objectForKey:key] description];
		if (begin) {
			result = [result stringByAppendingString:@"&"];
			begin = NO;
		}
		result = [result stringByAppendingFormat:@"&%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
    }
	return result;
}


@end
