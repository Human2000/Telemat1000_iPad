//
//  LayoutResolver.m
//
//

#import "LayoutResolver.h"


@implementation LayoutResolver

+ (void)layoutView:(UIView *)view constraints:(NSArray *)constraints {

	for (NSDictionary * lc in constraints) {

		UIView * subject = lc[@"subject"];
		UIView * object = lc[@"object"];
		NSString * type = lc[@"type"];
		CGFloat offset = [lc[@"offset"] floatValue];
		
		[self layoutView:subject relativeToView:object withRelationType:type offset:offset];

	}

	if ([view respondsToSelector:@selector(needsUpdateConstraints)]) {
		[view needsUpdateConstraints]; // Updates the contentSize of a scroll view.
	}
}

+ (void)layoutView:(UIView *)subject relativeToView:(UIView *)object withRelationType:(NSString *)type offset:(CGFloat)offset {

	CGRect frame = subject.frame;
	
	if ([type isEqualToString:@"below"]) {
		frame.origin.y = object.frame.origin.y + object.frame.size.height + offset;
	}
	else if ([type isEqualToString:@"right"]) {
		frame.origin.x = object.frame.origin.x + object.frame.size.width + offset;
	}
	else if ([type isEqualToString:@"y"]) {
		frame.origin.y = object.frame.origin.y + offset;
	}
	else if ([type isEqualToString:@"y"]) {
		frame.origin.x = object.frame.origin.x + offset;
	}
	
	subject.frame = frame;

}

+ (void)layoutViewController:(NSObject <ViewControllerWithLayoutConstraints> *)viewController {
	NSArray * constraints = viewController.layoutConstraints;
	[self layoutView:viewController.view constraints:constraints];
}


@end
