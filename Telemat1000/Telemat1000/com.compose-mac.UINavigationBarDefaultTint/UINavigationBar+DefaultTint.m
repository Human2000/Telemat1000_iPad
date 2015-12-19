//
// UINavigationBar+DefaultTint.m
//

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


static UIColor * _defaultNavigationBarColor;

@implementation UINavigationBar (DefaultTint)

- (void)setTintColorOrUseDefault:(UIColor *)tintColor {
	if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
		if (tintColor) self.tintColor = tintColor;
		else self.tintColor = nil;
		return;
	}

	[self memorizeDefaultTintColor];
	if (tintColor) self.tintColor = tintColor;
	else self.tintColor = self.defaultTintColor;
}

- (UIColor *)defaultTintColor {
	return _defaultNavigationBarColor;
}

- (void)memorizeDefaultTintColor {
	if (!_defaultNavigationBarColor) {
		_defaultNavigationBarColor = self.tintColor;
	}
}

@end
