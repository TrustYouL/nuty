#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPOneDriveFolderCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectCoverImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topTitleConstraint;
@property (nonatomic,strong) BOXItem *boxItem;
@property (weak, nonatomic) IBOutlet UILabel *creatTimeLabel;
@end

NS_ASSUME_NONNULL_END
