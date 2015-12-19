//
//  UIView+FindLowestSubview.m
//
//

#import "UIView+FindLowestSubview.h"

@implementation UIView (FindLowestSubview)

- (UIView *)lowestSubview {
	
	float maxY = 0;
	UIView * result = nil;
	
	long c = self.subviews.count;
	
	if ([self isKindOfClass:[UIScrollView class]]) {
		c -= 2; // Skip the scroll indicators
	}
	
	for (long i = 0; i < c; i++) {
		UIView * subview = [self.subviews objectAtIndex:i];
		float test = subview.frame.origin.y + subview.frame.size.height;
		if (test > maxY) {
			maxY = test;
			result = subview;
		}
	}
	
	return result;
}

- (UIView *)rightestSubview {
	
	float maxX = 0;
	UIView * result = nil;
	
	long c = self.subviews.count;
	
	if ([self isKindOfClass:[UIScrollView class]])
		c -= 2; // Skip the scroll indicators
	
	for (long i = 0; i < c; i++) {
		UIView * subview = [self.subviews objectAtIndex:i];
		float test = subview.frame.origin.x + subview.frame.size.width;
		if (test > maxX) {
			maxX = test;
			result = subview;
		}
	}
	
	return result;
}

- (float)maxContentY {
	UIView * lowestSubview = [self lowestSubview];
	float y = lowestSubview.frame.origin.y + lowestSubview.frame.size.height;
	return y;
}

- (float)maxContentX {
	UIView * rightestSubview = [self rightestSubview];
	float y = rightestSubview.frame.origin.x + rightestSubview.frame.size.width;
	return y;
}

@end
