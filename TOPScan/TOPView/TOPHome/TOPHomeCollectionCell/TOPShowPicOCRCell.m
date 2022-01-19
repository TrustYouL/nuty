#import "TOPShowPicOCRCell.h"

#define TopView_H 44
#define Bottom_H 60

@implementation TOPShowPicOCRCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _tkImageView = [TOPImageView new];
        _tkImageView.needScaleCrop = YES;
        _tkImageView.showCrossLines = YES;
        _tkImageView.showMidLines = YES;
        _tkImageView.isChange = NO;
        [self.contentView addSubview:_tkImageView];
    }
    return self;
}

- (void)setModel:(DocumentModel *)model{
    _model = model;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self top_setChildViewFream];
    });
}
- (void)top_setChildViewFream{
    UIImage * img = [UIImage imageWithContentsOfFile:_model.imagePath];
    CGFloat tempW = TOPScreenWidth-20;
    CGFloat tempH = TOPScreenHeight-TOPStatusBarHeight-TOPBottomSafeHeight-Bottom_H-TopView_H;
    CGFloat imgW = 0.0;
    CGFloat imgH = 0.0;
    if (img) {
        if ((img.size.height/img.size.width)*TOPScreenWidth<=tempH) {
            imgW = tempW;
            imgH = (img.size.height/img.size.width)*tempW;
        }else{
            imgW = (img.size.width/img.size.height)*tempH;
            imgH = tempH;
        }
    }
    [_tkImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(imgW, imgH));
    }];
    if (img) {
        _tkImageView.toCropImage = img;
        _tkImageView.cropAreaCornerWidth = 30;
        _tkImageView.cropAreaCornerHeight = 25;
        _tkImageView.minSpace = 0;
        _tkImageView.cropAreaCornerLineWidth = 4;
        _tkImageView.cropAreaBorderLineWidth = 2;
        _tkImageView.cropAreaMidLineWidth = 220;
        _tkImageView.cropAreaMidLineHeight = 25;
        _tkImageView.cropAreaMidLineColor = [UIColor clearColor];
        _tkImageView.cropAreaCrossLineColor = [UIColor clearColor];
        _tkImageView.cropAreaCrossLineWidth = 20;
        _tkImageView.cropAreaCornerLineColor = TOPAPPGreenColor;
        _tkImageView.cropAreaBorderLineColor = TOPAPPGreenColor;
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


@end
