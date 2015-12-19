//
//  CollectionViewDelegate.h
//
//

#import <Foundation/Foundation.h>
#import "DataSourceBase.h"

@interface CollectionViewDelegate : DataSourceBase <UICollectionViewDelegate>

@property (nonatomic, weak)		IBOutlet UICollectionView * collectionView;
@property (nonatomic, strong)	IBOutlet DataSourceBase * dataProvider;

@end
