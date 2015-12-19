//
//  LayoutResolver.h
//
//

#import <UIKit/UIKit.h>
@class ObjectContext;

@protocol ViewControllerWithLayoutConstraints <NSObject>

- (NSArray *)layoutConstraints;
- (UIView *)view;

@end

@interface LayoutResolver : NSObject

+ (void)layoutView:(UIView *)view constraints:(NSArray *)constraints;
+ (void)layoutView:(UIView *)subject relativeToView:(UIView *)object withRelationType:(NSString *)type offset:(CGFloat)offset;

+ (void)layoutViewController:(NSObject <ViewControllerWithLayoutConstraints> *)viewController;

@end

