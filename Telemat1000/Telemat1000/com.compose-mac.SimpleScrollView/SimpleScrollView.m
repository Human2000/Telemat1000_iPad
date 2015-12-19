//
//  SimpleScrollView.m
//

#import "SimpleScrollView.h"

@interface UIView (FindLowestSubview)

- (UIView *)lowestSubview;
- (UIView *)rightestSubview;

- (float)maxContentX;
- (float)maxContentY;

@end

@implementation SimpleScrollView

- (void)updateContentSize {
	CGSize size = self.frame.size;
	
	if (self.canScrollHorizontally)
		size.width = [self maxContentX];
	
	if (self.canScrollVertically)
		size.height = [self maxContentY];
	
	self.contentSize = size;
	
	[self updateChildScrollViews];
}

- (void)updateContentSizeDelayed {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self updateContentSize];
		[self flashScrollIndicators];
	});
}

- (BOOL)needsUpdateConstraints {
	[self updateContentSize];
	return NO;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self updateContentSizeDelayed];
}

- (void)updateChildScrollViews {
	
	BOOL parentCanScroll =
	self.contentSize.width > self.frame.size.width ||
	self.contentSize.height > self.frame.size.height;
	
	BOOL childCanScroll = !parentCanScroll;
	
	for (UIScrollView * subview in self.subviews) {
		if ([subview respondsToSelector:@selector(setScrollsToTop:)]) {
			subview.scrollsToTop = childCanScroll;
		}
	}
	
}

@end

