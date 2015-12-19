//
//  UIViewControllerSharedMethods.h
//
//

#import <Foundation/Foundation.h>

@interface UIViewControllerSharedMethods : NSObject

+ (void)unselectAllCellsInView:(UIView *)view animated:(BOOL)animated;

+ (void)prepareViewController:(UIViewController *)viewController forSegue:(UIStoryboardSegue *)segue sender:(id)sender;

@end
