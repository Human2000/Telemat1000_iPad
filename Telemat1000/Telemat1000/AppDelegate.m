//
//  AppDelegate.m
//  Telemat1000
//

#import "AppDelegate.h"

@implementation AppDelegate {
	NSUInteger _defaultSupportedInterfaceOrientations;
}

@synthesize window = _window;

- (

#ifdef __IPHONE_9_0
UIInterfaceOrientationMask
#else
NSUInteger
#endif

)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
	if (_currentSupportedInterfaceOrientations) return _currentSupportedInterfaceOrientations;
	return _defaultSupportedInterfaceOrientations;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {


	NSArray * supportedOrientations = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"];
	for (NSString * interfaceOrientation in supportedOrientations) {
		if ([interfaceOrientation isEqualToString:@"UIInterfaceOrientationLandscapeLeft"])
			_defaultSupportedInterfaceOrientations |= UIInterfaceOrientationMaskLandscapeLeft;
		else if ([interfaceOrientation isEqualToString:@"UIInterfaceOrientationLandscapeRight"])
			_defaultSupportedInterfaceOrientations |= UIInterfaceOrientationMaskLandscapeRight;
		else if ([interfaceOrientation isEqualToString:@"UIInterfaceOrientationPortrait"])
			_defaultSupportedInterfaceOrientations |= UIInterfaceOrientationMaskPortrait;
		else if ([interfaceOrientation isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"])
			_defaultSupportedInterfaceOrientations |= UIInterfaceOrientationMaskPortraitUpsideDown;
	}

	[application setStatusBarHidden:NO];

	return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlEventReceived" object:event];
}

@end
