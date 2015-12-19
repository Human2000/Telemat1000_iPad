//
//  WebViewDataProvider.m
//

#import "WebViewDataProvider.h"

@implementation WebViewDataProvider

- (id)contents {
	return @{
			 @"canGoForward": _canGoForward ? @YES : @NO,
			 @"canGoBack": _canGoBack ? @YES : @NO,
			 };
}

@end

@implementation UIWebView (DataProvider)

- (void)setDataProvider:(WebViewDataProvider *)provider {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.00 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSObject * delegate = self.delegate;
		if ([NSStringFromClass(delegate.class) isEqualToString:@"WebViewDelegate"]) {
			[((NSObject *)self.delegate) setValue:provider forKey:@"dataProvider"];
		}
	});
}

@end
