//
// UINavigationBar+DefaultTint.h
//

// The 'Global Tint' property from an Xcode Storyboard is not code-accessible in iOS 7.0.
// This is a workaround.

@interface UINavigationBar (DefaultTint)

- (void)setTintColorOrUseDefault:(UIColor *)tintColor;

- (UIColor *)defaultTintColor;

- (void)memorizeDefaultTintColor;

@end
