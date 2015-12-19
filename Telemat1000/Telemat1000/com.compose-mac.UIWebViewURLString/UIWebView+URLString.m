//
//  UIWebView+URLString.m
//


#import "UIWebView+URLString.h"
#import "NSStringPunycodeAdditions.h"

@implementation UIWebView (URLString)

- (void)setURLString:(NSString *)string {
	if ([[self.request.URL absoluteString] isEqualToString:string]) return;
	if (!string.length) return;
	//NSLog(@"self.request.URL.absoluteString: %@\nstring: %@", self.request.URL.absoluteString, string);
	NSURL * url = [NSURL URLWithUnicodeString:string];
	if (!url) return;
	NSURLRequest * request = [NSURLRequest requestWithURL:url];
	[self loadRequest:request];
}

@end
