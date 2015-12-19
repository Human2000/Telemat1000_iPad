#import <UIKit/UIKit.h>
#import "DataSourceBase.h"

@interface FilteredDataSource : DataSourceBase

@property (nonatomic, weak) IBOutlet DataSourceBase * originalDataSource;
@property BOOL shouldFilterWithKeyPath;
@property BOOL shouldFilterWithQuery;
@property BOOL searchesCaseSensitive;
@property BOOL showsAllItemsOnEmptyQuery;
@property (nonatomic, copy) NSString * filterKeyPath;
@property (nonatomic, copy) NSString * filterQuery;

@end
