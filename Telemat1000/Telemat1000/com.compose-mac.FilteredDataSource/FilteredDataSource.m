
#import "FilteredDataSource.h"

@interface NSObject (ValueForKeyPathWithIndexes)

- (id)valueForKeyPathWithIndexes:(NSString*)fullPath;

@end

@implementation NSObject (ValueForKeyPathWithIndexes)

- (id)valueForKeyPathWithIndexes:(NSString*)fullPath {
	
    NSArray * parts = [fullPath componentsSeparatedByString:@"."];
    id currentObj = self;
    for (NSString* part in parts)
    {
        if ([part isEqualToString:@"0"] || part.integerValue > 0) {
			if ([currentObj isKindOfClass:[NSArray class]])
				currentObj = [currentObj objectAtIndex:part.integerValue];
			else
				currentObj = nil;
		}
		
		else {
            currentObj = [currentObj valueForKey:part];
		}
    }
    return currentObj;
}
@end



@implementation FilteredDataSource {
	NSArray * _contents;
}

- (void)awakeFromNib {
	[super awakeFromNib];
}

- (void)setOriginalDataSource:(id)originalDataSource {
	if (_originalDataSource) [_originalDataSource removeObserver:self];
	_originalDataSource = originalDataSource;
	[_originalDataSource addObserver:self];
}

- (void)clear {
	_contents = nil;
}

- (void)refresh {
	if (!self.originalDataSource) return;
	[self clear];
	[self.originalDataSource refresh];
}


- (void)dataSourceDidLoad:(DataSourceBase *)dataSource {
	[self filter];
}


- (void)filter {
	_contents = self.originalDataSource.contents;
	if (self.shouldFilterWithKeyPath) [self filterWithKeyPath];
	if (self.shouldFilterWithQuery) [self filterWithQuery];
	[self notifyObservers];
}

- (void)filterWithKeyPath {
	_contents = [_contents valueForKeyPathWithIndexes:self.filterKeyPath];
}

- (void)filterWithQuery {
	if (![_contents isKindOfClass:[NSArray class]]) return;
	
	if (!_filterQuery.length) {
		if (!self.showsAllItemsOnEmptyQuery) {
			_contents = @[];
		}
		return;
	}
	
	NSMutableArray * _results = @[].mutableCopy;
	for (id value in _contents) {
		if ([self value:value containsString:_filterQuery])
			[_results addObject:value];
	}
	
	_contents = _results;
}

- (BOOL)value:(id)value containsString:(NSString *)string {
	
	if (!string) return YES;
	
	NSStringCompareOptions compareOptions = !_searchesCaseSensitive ? NSCaseInsensitiveSearch : 0;

	if ([value isKindOfClass:[NSString class]]) {
		return ([(NSString *)value rangeOfString:string options:compareOptions].location != NSNotFound);
	}
	
	else if ([value isKindOfClass:[NSDictionary class]]) {
		for (NSString * key in value) {
			if ([self value:[value objectForKey:key] containsString:string]) return YES;
		}
	}

	else if ([value isKindOfClass:[NSArray class]]) {
		for (id subvalue in value) {
			if ([self value:subvalue containsString:string]) return YES;
		}
	}

	return NO;

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
	if (!_contents.count) return nil;
	if (indexPath.row < 0 || indexPath.row > _contents.count-1) return nil;
	return _contents[indexPath.row];
}

- (void)setFilterQuery:(NSString *)filterQuery {
	BOOL isUpdating = _filterQuery != nil;
	_filterQuery = filterQuery.copy;
	if (isUpdating) [self filter];
}

- (void)setFilterKeyPath:(NSString *)filterKeyPath {
	BOOL isUpdating = _filterKeyPath != nil;
	_filterKeyPath = filterKeyPath.copy;
	if (isUpdating) [self filter];
}

- (id)contents {
	return _contents;
}

- (void)setURLString:(NSString *)str {
}

- (BOOL)isEditable {
	return self.originalDataSource.isEditable;
}

- (BOOL)deleteItemAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableArray * contents = _contents.mutableCopy;
	[contents removeObjectAtIndex:indexPath.row];
	_contents = [NSArray arrayWithArray:contents];
	BOOL result = [self.originalDataSource deleteItemAtIndexPath:indexPath];
	if (!result) return NO;

	// calling 'numberOfSections' reloads the data of a SimpleDatabase
	return self.originalDataSource.numberOfSections || YES;
}


@end