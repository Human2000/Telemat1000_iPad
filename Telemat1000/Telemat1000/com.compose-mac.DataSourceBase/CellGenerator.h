
@protocol CellGenerator <NSObject>

- (void)generateTableViewCell:(UITableViewCell **)cell withIdentifier:(NSString *)cellIdentifier indexPath:(NSIndexPath *)indexPath;
- (void)generateCollectionViewCell:(UICollectionViewCell **)cell forCollectionView:(UICollectionView *)collectionView withIdentifier:(NSString *)cellIdentifier indexPath:(NSIndexPath *)indexPath;

@end
