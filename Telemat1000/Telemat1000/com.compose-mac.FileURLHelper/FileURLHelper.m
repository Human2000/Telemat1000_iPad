//
//  FileURLHelper.m
//

#import "FileURLHelper.h"

NSString * GetResourceIDFromFileURL(NSString * urlString) {
	return nil;
}

NSURL * GetFileURLFromString(NSString * urlString) {

	if ([urlString hasPrefix:@"file:"]) {
		NSString * filename = [urlString substringFromIndex:5];
		return [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
	}
	else {
		return [NSURL URLWithString:urlString];
	}

	return nil;
}

NSURL * GetFileURLForDocumentWithID(NSString * documentIdentifier, NSString * pathExtension, NSString * subdirectory) {
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectoryPath = [paths objectAtIndex:0];
	
	if (subdirectory.length) documentsDirectoryPath = [documentsDirectoryPath stringByAppendingPathComponent:subdirectory];

	BOOL isDirectory = NO;
	if (!([NSFileManager.defaultManager fileExistsAtPath:documentsDirectoryPath isDirectory:&isDirectory] && isDirectory))
		[NSFileManager.defaultManager createDirectoryAtPath:documentsDirectoryPath withIntermediateDirectories:YES attributes:0 error:nil];
	
	if (pathExtension.length) documentIdentifier = [documentIdentifier stringByAppendingPathExtension:pathExtension];
	return [NSURL fileURLWithPath:[documentsDirectoryPath stringByAppendingPathComponent:documentIdentifier]];
}


NSData * GetDataFromLocalFile(NSString * name, NSString * extension) {
	NSString * nameWithExtension = name;
	if (extension.length) nameWithExtension = [name stringByAppendingPathExtension:extension];
	NSData * data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:nameWithExtension ofType:nil]];
	return data;
}

NSData * GetDataFromLocalFileURL(NSString * urlString) {
	NSString * filename = [urlString substringFromIndex:5];
	return GetDataFromLocalFile(filename, nil);
}
