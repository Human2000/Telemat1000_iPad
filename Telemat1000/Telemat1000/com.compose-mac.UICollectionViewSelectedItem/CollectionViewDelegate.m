//
//  CollectionViewDelegate.m
//
//

#import "CollectionViewDelegate.h"

@implementation CollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	[self notifyObserversForKeyPath:@"selectedItemIndex1"];
	[self.dataProvider setValue:[NSNumber numberWithInteger:indexPath.item] forKey:@"selectedItemIndex"];
}


- (NSNumber *)selectedItemIndex {
	NSArray * indexPaths = self.collectionView.indexPathsForSelectedItems;
	if (!indexPaths || !indexPaths.count) return @-1;
	NSIndexPath * firstIndexPath = (NSIndexPath *)indexPaths[0];
	return @(firstIndexPath.item);
}

- (NSNumber *)selectedItemIndex1 {
	return @(self.selectedItemIndex.integerValue+1);
}

- (void)setSelectedItemIndex:(NSNumber *)selectedItemIndex {
	if (selectedItemIndex.integerValue < 0) return;
	[self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:selectedItemIndex.integerValue inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally];
}

- (void)setSelectedItemIndex1:(NSNumber *)selectedItemIndex1 {
	[self setSelectedItemIndex:@(selectedItemIndex1.integerValue-1)];	
}


@end
