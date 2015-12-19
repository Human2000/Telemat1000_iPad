
#import "CollectionViewDataProvider.h"

@implementation CollectionViewDataProvider

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex {
	_selectedItemIndex = selectedItemIndex;
	[self notifyObserversForKeyPath:@"contents.selectedItemIndex"];
}

- (id)contents {
	return @{
			 @"selectedItemIndex": [NSNumber numberWithInteger:_selectedItemIndex]
			 };
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
	if ([keyPath hasPrefix:@"contents."]) {
		if ([keyPath isEqualToString:@"contents.selectedItemIndex"]) {
			if (value != nil) {
				NSInteger index = [value integerValue];
				NSArray * currentIndexPaths = [self.control indexPathsForSelectedItems];
				if (currentIndexPaths.count != 1 || [(NSIndexPath *)currentIndexPaths[0] item] != index) {
					for (NSIndexPath * ip in currentIndexPaths) {
						[self.control deselectItemAtIndexPath:ip animated:YES];
					}
					[self.control selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:YES scrollPosition:(UICollectionViewScrollPositionNone)];
					_selectedItemIndex = index;
					[self notifyObserversForKeyPath:@"contents.selectedItemIndex"];
				}
			}
		}
		return;
	}
	[super setValue:value forKeyPath:keyPath];
}


@end
