//
//  WebViewDelegate.h
//
//

#import <Foundation/Foundation.h>

@interface WebViewDelegate : NSObject <UIWebViewDelegate>

@property BOOL openLinksInSafari;
@property BOOL showActivityIndicator;

@property (nonatomic, weak) NSObject * dataProvider;

@end
