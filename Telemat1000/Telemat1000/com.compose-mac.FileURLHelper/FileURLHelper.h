//
//  FileURLHelper.h
//

#import <Foundation/Foundation.h>

NSURL * GetFileURLFromString(NSString * urlString);
NSURL * GetFileURLForDocumentWithID(NSString * identifier, NSString * pathExtension, NSString * subdirectory);
NSData * GetDataFromLocalFileURL(NSString * urlString);
NSData * GetDataFromLocalFile(NSString * name, NSString * extension);
NSString * GetResourceIDFromFileURL(NSString * urlString);
