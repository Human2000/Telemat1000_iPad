
#import <UIKit/UIKit.h>
#import "DataSourceBase.h"

@interface JSONDataSource : DataSourceBase {
	id _contents;
}

@property (nonatomic, copy) NSString * URLString;
@property (nonatomic, copy) NSString * dataString;
@property BOOL isEditable;

- (void)reset;


@end
