

@interface UIImageView (DataLinkExtensions)

- (void)setImageURL:(NSURL *)url;
- (void)setImageURLString:(NSString *)urlString;

- (void)setImageData:(NSData *)data;
- (NSData *)imageData;

@end