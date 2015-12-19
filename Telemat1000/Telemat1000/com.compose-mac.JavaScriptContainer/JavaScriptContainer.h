//
//  JavaScriptContainer.h
//
//

#import "DataSourceBase.h"

@interface JavaScriptContainer : DataSourceBase

@property (nonatomic, strong) NSString * script;
@property (nonatomic, weak) DataSourceBase * inputDataSource;
@property (nonatomic, weak) DataSourceBase * inputDataSource2;
@property BOOL evaluatesImmediately;

- (void)evaluate;
- (void)evaluateWithData:(id)data;

@end
