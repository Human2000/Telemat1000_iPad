	//
//  Cell9849.m
//  Telemat1000
//

#import "Cell9849.h"
#import "AppDelegate.h"
#import "UIViewControllerSharedMethods.h"
#import "BindingsHandler.h"
#import "UINavigationBar+DefaultTint.h"
#import "UIImageView+URL.h"
#import "NSStringPunycodeAdditions.h"

@implementation Cell9849 {
	NSDictionary * _inputData;
	BOOL _inputDataIsDictionary;
}

- (void)setInputData:(NSDictionary *)dataDictionary
{
	_inputData = dataDictionary;
	_inputDataIsDictionary = [_inputData isKindOfClass:[NSDictionary class]];

	// Configure the view for the dataset
	self.imageView2.imageURLString = [BindingsHandler transformValue:(_inputDataIsDictionary ? [_inputData valueForKeyPath:@"Bild"] : nil) withTransformer:@"TO_STRING"];


}

- (NSDictionary *)inputData
{
	return _inputData;
}

- (UIView *)view {
	return self.contentView;
}


@end
