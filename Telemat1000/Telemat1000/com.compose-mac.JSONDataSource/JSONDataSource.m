
#import "JSONDataSource.h"
#import "NSStringPunycodeAdditions.h"

@implementation JSONDataSource

- (void)setURLString:(NSString *)URLString {
	_URLString = [URLString copy];
	_dataString = nil;
	[self load];
}

- (void)setDataString:(NSString *)dataString {
	_dataString = [dataString copy];
	_URLString = nil;
	[self load];
}

- (void)load {
	
	if (self.URLString) {
		
		[self sendRequestForURLFromString:self.URLString completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

			if (connectionError || !data) return;
			
			[self parseJSON:data];

		}];
		
	}
	else if (self.dataString) {
		[self parseJSON:[self.dataString dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
}

- (BOOL)didLoad {
	return _contents != nil;
}

- (id)contents {
	return _contents;
}

- (void)parseJSON:(NSData *)jsonData {
	
	NSError * error = nil;
	
	NSJSONReadingOptions options = 0;
	if (_isEditable) options |= NSJSONReadingMutableContainers;
	_contents = [NSJSONSerialization JSONObjectWithData:jsonData options:options error:&error];
	
	if (error) {
		NSLog(@"Error parsing JSON: %@", error);
		return;
	}
	[self notifyObservers];
	
}


- (void)clear {
	_contents = nil;
}


- (void)reset {
	[self clear];
	[self notifyObservers];
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

- (NSString *)description {
	if (_contents) return [NSString stringWithFormat:@"%@ { contents: %@ }", super.description, [_contents description]];
	return [NSString stringWithFormat:@"%@ { URL: %@, didLoad: %@ }", super.description, self.URLString, self.didLoad ? @"YES" : @"NO"];
	
}

@end
