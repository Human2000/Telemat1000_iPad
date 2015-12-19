//
//  BindingsHandler.m
//
//

#import "BindingsHandler.h"

@implementation BindingsContext {
	NSMutableArray * _callingObjectStack;
	NSTimer * _timer;
}

- (id)init {
	self = [super init];
	if (self) {
		_callingObjectStack = @[].mutableCopy;
	}
	return self;
}

// To prevent cycles
- (BOOL)shouldApplyBindingsForObject:(id)object {
	if (_callingObjectStack.count < 10) return NO;
	return [_callingObjectStack containsObject:object];
}

- (void)addCallingObject:(id)object {
	[_callingObjectStack addObject:object];

	if (!_timer) {
		_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(cleanCallingObjectStack) userInfo:nil repeats:NO];
	}
}

- (void)cleanCallingObjectStack {
	_timer = nil;
	if (_callingObjectStack.count) [_callingObjectStack removeAllObjects];
}

@end

@implementation BindingsHandler

+ (void)applyBindings:(NSDictionary *)_bindings forKeyPath:(NSString *)keyPath ofObject:(id<BindingsKeyValueCoding>)object {
	
	if ([self.sharedContext shouldApplyBindingsForObject:object]) return;
	[self.sharedContext addCallingObject:object];
	
	BOOL keyPathIsEmpty = keyPath.length == 0;
	
	NSDictionary * bindingsForObject = [_bindings objectForKey:[NSNumber numberWithUnsignedInteger:object.hash]];
	
	for (NSString * bindingsKeyPath in bindingsForObject) {
		
		if ([bindingsKeyPath hasPrefix:keyPath] || keyPathIsEmpty) {
			
			for (NSDictionary * bindingInfo in bindingsForObject[bindingsKeyPath]) {
				
				id<BindingsKeyValueCoding> destinationObject = bindingInfo[@"object"];
				NSString * keyPath = bindingsKeyPath;
				if ([keyPath hasSuffix:@"."]) keyPath = [keyPath substringToIndex:bindingsKeyPath.length-1];
				
				id value;
				if (!keyPath.length) {
					value = object;
				}
				else {
					value = [object valueForKeyPath:keyPath];
				}
				
				NSString * transformer = bindingInfo[@"transformer"];
				if (transformer) {
					value = [self transformValue:value withTransformer:transformer];
				}
				
				[destinationObject setValue:value forKeyPath:bindingInfo[@"keyPath"]];
			}
		}
	}
	
}

+ (id)transformValue:(id)value withTransformer:(NSString *)transformer {
	if ([transformer isEqualToString:@"TO_STRING"]) {
		if ([value isKindOfClass:[NSString class]]) return value;
		if ([value isKindOfClass:[NSNumber class]]) return [value stringValue];
		return @"";
	}
	if ([transformer isEqualToString:@"TO_NUMBER"]) {
		if ([value isKindOfClass:[NSNumber class]]) return value;
		if ([value isKindOfClass:[NSString class]]) return @([value doubleValue]);
		return @"";
	}
	if ([transformer isEqualToString:@"TO_BOOLEAN"]) {
		if ([value isKindOfClass:[NSNumber class]]) return value;
		if ([value isKindOfClass:[NSString class]]) return [NSNumber numberWithBool:(BOOL)[(NSString *)value length]];
		return @0;
	}
	if ([transformer isEqualToString:@"TO_INVERTED_BOOLEAN"]) {
		if ([value isKindOfClass:[NSNumber class]]) return [NSNumber numberWithBool:![value boolValue]];
		if ([value isKindOfClass:[NSString class]]) return [NSNumber numberWithBool:![(NSString *)value length]];
		return @1;
	}
	if ([transformer isEqualToString:@"TO_DATA"]) {
		if ([value isKindOfClass:[NSData class]]) return value;
		if ([value isKindOfClass:[NSString class]]) return [((NSString *)value) dataUsingEncoding:NSUTF8StringEncoding];
		return [NSData data];
	}
	if ([transformer hasPrefix:@"TYPE_CONSTRAINT__"]) {
		NSString * className = [transformer substringFromIndex:17];
		Class c = NSClassFromString(className);
		if ([value isKindOfClass:c]) return value;
		return nil;
	}
	return nil;
}

+ (BindingsContext *)sharedContext {
	static BindingsContext * sharedContext;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedContext = [[BindingsContext alloc] init];
	});
	return sharedContext;
}

@end
