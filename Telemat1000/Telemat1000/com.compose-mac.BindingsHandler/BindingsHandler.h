//
//  BindingsHandler.h
//
//

#import <Foundation/Foundation.h>

@protocol BindingsKeyValueCoding <NSObject>

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath;
- (id)valueForKeyPath:(NSString *)keyPath;

@end

@interface BindingsContext : NSObject

- (BOOL)shouldApplyBindingsForObject:(id)object;
- (void)addCallingObject:(id)object;

@end

@interface BindingsHandler : NSObject

+ (void)applyBindings:(NSDictionary *)_bindings forKeyPath:(NSString *)keyPath ofObject:(id<BindingsKeyValueCoding>)object;

+ (id)transformValue:(id)value withTransformer:(NSString *)transformer;
+ (BindingsContext *)sharedContext;

@end
