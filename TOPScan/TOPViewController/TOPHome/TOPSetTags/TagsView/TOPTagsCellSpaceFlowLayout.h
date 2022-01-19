#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,AlignType){
    AlignWithLeft,
    AlignWithCenter,
    AlignWithRight
};
@interface TOPTagsCellSpaceFlowLayout : UICollectionViewFlowLayout
@property (nonatomic,assign)CGFloat betweenOfCell;
@property (nonatomic,assign)AlignType cellType;
-(instancetype)initWthType : (AlignType)cellType;
-(instancetype)initWithType:(AlignType) cellType betweenOfCell:(CGFloat)betweenOfCell;
@end

NS_ASSUME_NONNULL_END
