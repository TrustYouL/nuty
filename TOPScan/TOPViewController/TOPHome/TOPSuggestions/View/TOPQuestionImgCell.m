#import "TOPQuestionImgCell.h"


@implementation TOPQuestionImgCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];

        WS(weakSelf);
        _screenshotView = [TOPSCScreenshotView new];
        _screenshotView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _screenshotView.layer.masksToBounds = YES;
        _screenshotView.layer.cornerRadius = 10;
        _screenshotView.top_addScreenshotImg = ^{
            if (weakSelf.top_addScreenshotImg) {
                weakSelf.top_addScreenshotImg();
            }
        };
        _screenshotView.top_showScreenshotImg = ^(NSInteger currentIndex) {
            if (weakSelf.top_showScreenshotImg) {
                weakSelf.top_showScreenshotImg(currentIndex);
            }
        };
        _screenshotView.top_deleteCurrentPic = ^(NSString * _Nonnull picName) {
            if (weakSelf.top_deleteCurrentPic) {
                weakSelf.top_deleteCurrentPic(picName);
            }
        };
        [self.contentView addSubview:_screenshotView];
        [self top_setViewFream];
    }
    return self;
}

- (void)top_setViewFream{
    [_screenshotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(15);
        make.trailing.equalTo(self.contentView).offset(-15);
        make.top.bottom.equalTo(self.contentView);
    }];
}

- (void)setReloadType:(BOOL)reloadType{
    _reloadType = reloadType;
    _screenshotView.reloadType = reloadType;
}
- (void)setImagesArray:(NSMutableArray *)imagesArray{
    _imagesArray = imagesArray;
    _screenshotView.imagesArray = [imagesArray mutableCopy];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
