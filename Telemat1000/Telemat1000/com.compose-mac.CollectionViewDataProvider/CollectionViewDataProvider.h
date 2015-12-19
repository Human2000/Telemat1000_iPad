
#import "DataSourceBase.h"

@interface CollectionViewDataProvider : DataSourceBase

@property (nonatomic, weak) IBOutlet UICollectionView * control;

@property (nonatomic) NSInteger selectedItemIndex;

@end
