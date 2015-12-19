//
//  JavaScriptContainer.m
//
//

// This can only be enabled if the app targets iOS 7 or newer.
// Otherwise it would fail Apple's public code usage validation.

#define USE_IOS7_APPROACH 0

#import "JavaScriptContainer.h"
#if USE_IOS7_APPROACH
#import <JavaScriptCore/JavaScriptCore.h>
#endif

static id safeJSONObject(id unsafeObject) {
	if ([unsafeObject isKindOfClass:[NSDictionary class]]) {
		NSMutableDictionary * result = @{}.mutableCopy;
		for (NSString * key in unsafeObject) {
			result[key] = safeJSONObject([unsafeObject valueForKey:key]);
		}
		return result;
	}
	if ([unsafeObject isKindOfClass:[NSArray class]]) {
		NSMutableArray * result = @[].mutableCopy;
		for (id unsaveValue in unsafeObject) {
			[result addObject:safeJSONObject(unsaveValue)];
		}
		return result;
	}
	if ([unsafeObject isKindOfClass:[NSString class]] || [unsafeObject isKindOfClass:[NSNumber class]]) {
		return unsafeObject;
	}
	return NSNull.null; // NSNull for NSArray/NSDictionary storage
}

static NSString * saveJSONStringFromObject(id obj) {
	if (!obj) return @"undefined";
	
	if ([NSJSONSerialization isValidJSONObject:obj]) {
		return [NSString.alloc initWithData:[NSJSONSerialization dataWithJSONObject:obj options:0 error:nil] encoding:NSUTF8StringEncoding];
	}

	id safe = safeJSONObject(obj);
	if ([safe isKindOfClass:[NSString class]] || [safe isKindOfClass:[NSNumber class]]) {
		return [[NSString.alloc initWithData:[NSJSONSerialization dataWithJSONObject:@{@"value":safe} options:0 error:nil] encoding:NSUTF8StringEncoding] stringByAppendingString:@".value"];
	}
	if ([safe isKindOfClass:[NSArray class]] || [safe isKindOfClass:[NSDictionary class]]) {
		return [NSString.alloc initWithData:[NSJSONSerialization dataWithJSONObject:safe options:0 error:nil] encoding:NSUTF8StringEncoding];
	}
	return nil;
}

@implementation JavaScriptContainer {
	id _contents;
	UIWebView * _webView;
#if USE_IOS7_APPROACH
	JSContext * _context;
#endif
	id _inputData;
	id _inputData2;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		if (self.evaluatesImmediately) [self evaluateScriptAndNotify:YES];
	});
}

- (void)loadInputData {
	_inputData = self.inputDataSource.contents;
	_inputData2 = self.inputDataSource2.contents;
}

- (id)contents {
	return _contents;
}

- (void)evaluate {
	[self evaluateScriptAndNotify:YES];
}

- (void)evaluateWithData:(id)data {
	_inputData = data;
	[self evaluate];
	[self loadInputData]; // restore input data
}

- (void)evaluateScriptAndNotify:(BOOL)notify {
	if (!_script.length) return;
	[self loadInputData];
	// iOS 7
	if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
		
		[self evaluateScriptPostSystem7];
	}
	// iOS 6 and earlier
	else {
		[self evaluateScriptPreSystem7];
	}
	if (notify) [self notifyObservers];
}

- (void)evaluateScriptPreSystem7 {
	if (!_webView) _webView = [UIWebView.alloc initWithFrame:(CGRectMake(0, 0, 1, 1))];
	NSString * input1String = saveJSONStringFromObject(_inputData);
	NSString * input2String = saveJSONStringFromObject(_inputData2);
	NSString * wrappedScript = [NSString stringWithFormat:@"JSON.stringify((function () { var input = %@, input2 = %@; %@ })())", input1String, input2String, _script];
	NSString * returnValue = [_webView stringByEvaluatingJavaScriptFromString:wrappedScript];
	_contents = [NSJSONSerialization JSONObjectWithData:[returnValue dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

- (void)evaluateScriptPostSystem7 {
#if USE_IOS7_APPROACH
	static JSValue * arrayPrototype;
	if (!_context) {
		_context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
		[_context setExceptionHandler:^(JSContext * ctx, JSValue * value) {
			NSLog(@"JavaScript Exception: %@", value);
		}];
		arrayPrototype = [_context evaluateScript:@"Array"];
	}
	
	[_context globalObject][@"input"] = _inputData;
	[_context globalObject][@"input2"] = _inputData2;

	NSString * wrappedScript = [NSString stringWithFormat:@"(function () { %@ })()", _script];
	JSValue * returnValue = [_context evaluateScript:wrappedScript];

	if (returnValue.isUndefined || returnValue.isNull) {
		_contents = nil;
	}
	else if (returnValue.isBoolean || returnValue.isNumber) {
		_contents = returnValue.toNumber;
	}
	else if (returnValue.isString) {
		_contents = returnValue.toString;
	}
	else if (returnValue.isObject) {
		
		if ([returnValue isInstanceOf:arrayPrototype]) {
			_contents = returnValue.toArray;
		}
		else {
			@try {
				_contents = returnValue.toDictionary;
			}
			@catch (NSException *exception) {
				NSLog(@"Exception in 'returnValue.toDictionary': %@", exception);
				_contents = nil;
			}
		}
		
	}
#else
	[self evaluateScriptPreSystem7];
#endif
}

- (id)valueForKeyPath:(NSString *)keyPath {
	if ([keyPath hasPrefix:@"contents."]) {
		keyPath = [keyPath substringFromIndex:9];
		if (!keyPath.length) return _contents;
		if ([_contents isKindOfClass:[NSDictionary class]]) {
			return [_contents valueForKeyPath:keyPath];
		}
		return nil;
	}
	return [super valueForKeyPath:keyPath];
}


- (NSInteger)numberOfSections {
	if (!_contents) return 0;
	if (![_contents isKindOfClass:[NSArray class]]) return 0;
	return 1;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
	if ([_contents isKindOfClass:[NSArray class]]) {
		return ((NSArray *)_contents).count;
	}
	return 0;
}

- (NSDictionary *)datasetForItemAtIndexPath:(NSIndexPath *)indexPath {
	return _contents[indexPath.row];
}


@end
