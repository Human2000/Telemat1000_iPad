//
//  WebViewDelegate.m
//
//

#import "WebViewDelegate.h"

@protocol DataSourceBase
- (void)notifyObservers;
@end

@implementation WebViewDelegate {
	//UIProgressView *
	UIView * _progressView;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
    if (navigationType == UIWebViewNavigationTypeLinkClicked && self.openLinksInSafari) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		if (self.dataProvider) {
			[self.dataProvider setValue:(webView.canGoBack ? @YES:@NO) forKey:@"canGoBack"];
			[self.dataProvider setValue:(webView.canGoForward ? @YES:@NO) forKey:@"canGoForward"];
			[self.dataProvider performSelector:@selector(notifyObservers)];
		}
	});


    return YES;

}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	
	if (_showActivityIndicator) {
		[self showProgressIndicatorForWebView:webView];
	}
	if (!_showActivityIndicator) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	if (_progressView) [self hideProgressIndicatorForWebView:webView];
	else if (!_showActivityIndicator) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	if (_progressView) [self hideProgressIndicatorForWebView:webView];
	else if (!_showActivityIndicator) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)showProgressIndicatorForWebView:(UIWebView *)webView {
	if (_progressView) return;
	
	if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
		// iOS 7
		_progressView = [UIToolbar.alloc initWithFrame:CGRectMake(0,0,80,80)];
		((UIToolbar *)_progressView).barStyle = UIBarStyleBlackTranslucent;
	}
	else {
		// iOS 5, 6
		_progressView = [UIView.alloc initWithFrame:CGRectMake(0,0,80,80)];
		_progressView.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.85];
	}

	_progressView.layer.cornerRadius = 10;
	_progressView.opaque = NO;
	_progressView.clipsToBounds = YES;
	
	UIActivityIndicatorView * av = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	av.center = CGPointMake(_progressView.frame.size.width/2, _progressView.frame.size.height/2);
	[_progressView addSubview:av];
	_progressView.alpha = 0;
	[av startAnimating];
	_progressView.center = webView.center;
	[UIView animateWithDuration:0.5 animations:^{
		_progressView.alpha = 1;
		webView.alpha = 0.75;
	} completion:^(BOOL finished) {
	}];
	
	
	[webView.superview addSubview:_progressView];
}

- (void)hideProgressIndicatorForWebView:(UIWebView *)webView {
	if (!_progressView) return;
	UIView * __block progressView = _progressView;
	_progressView = nil;
	[UIView animateWithDuration:0.2 animations:^{
		progressView.alpha = 0;
		webView.alpha = 1.0;
	} completion:^(BOOL finished) {
		[progressView removeFromSuperview];
		progressView = nil;
	}];
	
}

@end
