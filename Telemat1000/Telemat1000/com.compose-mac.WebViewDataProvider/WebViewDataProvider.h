//
//  WebViewDataProvider.h
//

#import "DataSourceBase.h"

@interface WebViewDataProvider : DataSourceBase

@property (nonatomic, weak)		IBOutlet UIWebView * view;

@property BOOL canGoBack;
@property BOOL canGoForward;

@end


@interface UIWebView (DataProvider)

- (void)setDataProvider:(WebViewDataProvider *)provider;

@end
