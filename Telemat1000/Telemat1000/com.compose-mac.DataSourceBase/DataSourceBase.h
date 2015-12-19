//
//  DataSourceBase.h
//

#import <Foundation/Foundation.h>
#import "CellGenerator.h"

@interface DataSourceBase : NSObject <UITableViewDataSource, UICollectionViewDataSource>

@property (copy, nonatomic) NSString * identifier;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSDictionary *)datasetForItemAtIndexPath:(NSIndexPath *)indexPath;
- (id)contents;
- (NSArray *)items;

- (void)refresh;
- (void)refreshFromControl:(id)sender;

- (void)addLoadingIndicators;
- (void)removeAllLoadingIndicators;

- (void)addObserver:(id)observer;
- (void)removeObserver:(id)observer;
- (void)notifyObservers;
- (void)notifyObserversForKeyPath:(NSString *)keyPath;
- (void)notifyObserversWithUpdate:(BOOL)update;

- (void)sendRequestForURLFromString:(NSString *)URLString completion:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError))completionHandler;

@property BOOL usesCellGenerator;

- (BOOL)canLoadMore;
- (void)loadMore;

- (BOOL)isEditable;
- (BOOL)deleteItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface NSString (URLEscapedQuery)
+ (NSString *)urlEscapeString:(NSString *)unencodedString;
+ (NSString *)queryStringFromDictionary:(NSDictionary *)dict;
@end
