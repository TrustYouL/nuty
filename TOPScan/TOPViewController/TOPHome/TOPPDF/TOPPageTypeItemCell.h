#import <UIKit/UIKit.h>

@class TOPPageNumModel, TOPPageDirectionModel;
NS_ASSUME_NONNULL_BEGIN

@interface TOPPageTypeItemCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *typeLab;
@property (nonatomic, strong) UILabel *numLab;
@property (nonatomic, strong) UIImageView *showView;

- (void)top_configCellWithData:(TOPPageNumModel *)model;
- (void)top_configDirectionCellWithData:(TOPPageDirectionModel *)model;

@end

NS_ASSUME_NONNULL_END
