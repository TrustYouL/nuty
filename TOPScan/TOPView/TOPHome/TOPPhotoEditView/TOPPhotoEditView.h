#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPhotoEditView : UIView

- (instancetype)initWithFrame:(CGRect)frame withType:(int)type;
@property (nonatomic, copy) void(^photoEditUpClickHandler)(NSInteger index);
@property (nonatomic, copy) void(^photoEditDownClickHandler)(NSInteger index);
@property (nonatomic ,strong) UIButton * cutBtn;
@property (nonatomic ,strong) UIButton * nextBtn;
@property (nonatomic ,strong) UIButton * creditsButton;

@property (nonatomic ,strong) UILabel * titleLab;
@property (nonatomic ,strong) NSMutableArray * btnArray;
@property (nonatomic ,strong) NSMutableArray * downBtnArray;
@property (nonatomic, copy) void(^photoEditOneHandler)(NSInteger index);
@property (nonatomic, copy) NSArray * upArray;
@property (nonatomic, copy) NSArray * downImgArray;
@property (nonatomic, copy) NSArray * downTitleArray;
@property (nonatomic, assign) TOPPhotoShowViewShowType enterType;
- (void)top_creatView;
- (void)top_changeCutBtnState:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
