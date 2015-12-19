//
//  ViewControllerTelemat1000.h
//  Telemat1000
//

#import <UIKit/UIKit.h>
#import "LayoutResolver.h"
#import "UIImageView+URL.h"
#import "NSStringPunycodeAdditions.h"
#import "CollectionViewDelegate.h"
#import "CollectionViewDataProvider.h"
#import "MoviePlayerView.h"
#import "FileURLHelper.h"
#import "WebViewDataProvider.h"
#import "FilteredDataSource.h"
#import "JavaScriptContainer.h"
#import "JSONDataSource.h"

@interface ViewControllerTelemat1000 : UIViewController <ViewControllerWithLayoutConstraints>

@property (nonatomic) BOOL prefersStatusBarHidden;
@property (nonatomic, strong) NSArray * layoutConstraints;
@property (nonatomic, strong) NSString * originalSceneID;
@property (weak, nonatomic) IBOutlet UICollectionView * collectionView;
@property (weak, nonatomic) IBOutlet MoviePlayerView * moviePlayerView;
@property (weak, nonatomic) IBOutlet UIWebView * webView;
@property (weak, nonatomic) IBOutlet UIScrollView * contentView;
@property (weak, nonatomic) IBOutlet WebViewDataProvider * webViewDataProvider;
@property (weak, nonatomic) IBOutlet MoviePlayerDataProvider * moviePlayerDataProvider;
@property (weak, nonatomic) IBOutlet CollectionViewDelegate * collectionViewDelegate;
@property (weak, nonatomic) IBOutlet CollectionViewDataProvider * collectionViewDataProvider;
@property (weak, nonatomic) IBOutlet FilteredDataSource * filteredDataSource;
@property (weak, nonatomic) IBOutlet JavaScriptContainer * javaScriptContainer;
@property (weak, nonatomic) IBOutlet JSONDataSource * jsonDataSource;
@property (weak, nonatomic) IBOutlet FilteredDataSource * filteredDataSource2;

@end
