
#import "UIImageView+URL.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "NSStringPunycodeAdditions.h"

@implementation UIImageView (DataLinkExtensions)

- (void)setImageURL:(NSURL *)url {
	
	if (![url isKindOfClass:NSURL.class]) return;
	[self setImageURLString:url.absoluteString];
	
}

- (void)setImageURLString:(NSString *)urlString {
	
	if ([urlString hasPrefix:@"file:"])
		[self setImage:[UIImage imageNamed:[urlString substringFromIndex:5]]];
	else if ([urlString rangeOfString:@":"].location == NSNotFound)
		[self setImage:[UIImage imageNamed:urlString]];
	else {
		if (urlString.length) {
			BOOL alphaBefore = self.alpha;
			self.alpha = 0;
			__block UIImageView * blocksafeSelf = self;
			[self sd_setImageWithURL:[NSURL URLWithUnicodeString:urlString] placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
				if (cacheType == SDImageCacheTypeNone) {
					[UIView animateWithDuration:0.25 animations:^{
						blocksafeSelf.alpha = alphaBefore;
					}];
				}
				else blocksafeSelf.alpha = alphaBefore;
			}];
		}
		else {
			self.image = nil;
		}
	}
	
}

- (void)setHighlightedImageURLString:(NSString *)urlString {

	if ([urlString hasPrefix:@"file:"])
		[self setHighlightedImage:[UIImage imageNamed:[urlString substringFromIndex:5]]];
	else if ([urlString rangeOfString:@":"].location == NSNotFound)
		[self setHighlightedImage:[UIImage imageNamed:urlString]];
	else {
		if (urlString.length) {
			[[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithUnicodeString:urlString]
													   options:0
													  progress:^(NSInteger receivedSize, NSInteger expectedSize) {} 
													 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
				self.highlightedImage = image;
			}];
		}
		else {
			self.highlightedImage = nil;
		}
	}

}

- (void)setImageData:(NSData *)data {
	self.image = [UIImage imageWithData:data];
}

- (NSData *)imageData {
	return UIImagePNGRepresentation(self.image);
}

@end
