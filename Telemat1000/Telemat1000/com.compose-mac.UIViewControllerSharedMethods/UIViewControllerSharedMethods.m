//
//  UIViewControllerSharedMethods.m
//

#import "UIViewControllerSharedMethods.h"

@protocol ObjectWithInputDataSource <NSObject>
- (id)sceneInputDataSource;
@end

@protocol SomeDataSource <NSObject>
- (NSDictionary *)datasetForItemAtIndexPath:(NSIndexPath *)indexPath;
@end


@implementation UIViewControllerSharedMethods

+ (void)unselectAllCellsInView:(UIView *)view animated:(BOOL)animated {
	
	if ([view isKindOfClass:[UITableView class]]) {
		[(UITableView *)view deselectRowAtIndexPath:[(UITableView *)view indexPathForSelectedRow] animated:animated];
		return;
	}
	if ([view isKindOfClass:[UICollectionView class]]) {
		[(UICollectionView *)view deselectItemAtIndexPath:[[(UICollectionView *)view indexPathsForSelectedItems] firstObject] animated:animated];
		return;
	}
	
	for (UIView * subview in view.subviews) {
		[self unselectAllCellsInView:subview animated:animated];
	}
	
}

+ (void)prepareViewController:(UIViewController *)viewController forSegue:(UIStoryboardSegue *)segue sender:(id)sender {

	id destination = [segue destinationViewController];
	
	
	if ([destination respondsToSelector:@selector(sceneInputDataSource)]) {
		id inputDataSource = [destination performSelector:@selector(sceneInputDataSource)];
		SEL selector = NSSelectorFromString(@"setContents:indexPath:originalDataSource:");

		if ([inputDataSource respondsToSelector:selector]) {
			
			id originalDataSource = nil;
			NSIndexPath * indexPath = nil;
			id contents = nil;

			UIView * viewWithDataSource = (UIView *)sender;
			while ([viewWithDataSource respondsToSelector:@selector(dataSource)] == NO) {
				viewWithDataSource = viewWithDataSource.superview;
				if (viewWithDataSource == viewController.view || !viewWithDataSource) return;
			}
			originalDataSource = [viewWithDataSource performSelector:@selector(dataSource)];
			
			if ([viewWithDataSource respondsToSelector:@selector(indexPathForCell:)]) {
				indexPath = [viewWithDataSource performSelector:@selector(indexPathForCell:) withObject:sender];
			}
			else return;

			if ([originalDataSource respondsToSelector:@selector(datasetForItemAtIndexPath:)]) {
				contents = [originalDataSource performSelector:@selector(datasetForItemAtIndexPath:) withObject:indexPath];
			}
			else return;

			
			NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[inputDataSource methodSignatureForSelector:selector]];
			invocation.selector = selector;
			invocation.target = inputDataSource;
			[invocation setArgument:&contents atIndex:2];
			[invocation setArgument:&indexPath atIndex:3];
			[invocation setArgument:&originalDataSource atIndex:4];
			[invocation invoke];
			
		}
	}
	
}

@end
