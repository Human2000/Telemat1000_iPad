//
//  UIView+FindLowestSubview.h
//
//

#import <UIKit/UIKit.h>

@interface UIView (FindLowestSubview)

- (UIView *)lowestSubview;
- (UIView *)rightestSubview;

- (float)maxContentX;
- (float)maxContentY;

@end
