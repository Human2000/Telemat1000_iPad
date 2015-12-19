//
//  SimpleScrollView.h
//

#import <UIKit/UIKit.h>

@interface SimpleScrollView : UIScrollView

@property BOOL canScrollVertically;
@property BOOL canScrollHorizontally;

- (void)updateContentSize;
- (void)updateContentSizeDelayed;

@end
