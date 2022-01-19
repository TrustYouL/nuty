#import "TOPCollageViewCell.h"
#import "TOPCollageModel.h"
#import "StickerView.h"

@interface TOPCollageViewCell ()<StickerViewDelegate>
@property (strong, nonatomic) UIImageView *bgSuperView;
@property (strong, nonatomic) UIImageView *waterMartView;

@end

@implementation TOPCollageViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        self.layer.shadowOpacity = 0.5f;
        self.layer.shadowRadius = 4.0f;
        self.layer.shadowOffset = CGSizeMake(0,0);
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.bgSuperView];
    [self.contentView addSubview:self.waterMartView];
    self.contentView.clipsToBounds = YES;
    [self top_sd_layoutSubViews];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(top_hiddenCtrlTap:)];
    [self.contentView addGestureRecognizer:tapGesture];
}

- (void)top_sd_layoutSubViews {
    UIView *contentView = self.contentView;
    [self.bgSuperView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(contentView);
    }];
    [self.waterMartView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(contentView);
    }];
}

- (void)setCollageModel:(TOPCollageModel *)collageModel {
    _collageModel = collageModel;
    if (_collageModel.isReload) {
        _collageModel.isReload = NO;
        for (UIView *subView in self.bgSuperView.subviews) {
            if ([subView isKindOfClass:[StickerView class]]) {
                [subView removeFromSuperview];
            }
        }
        [self top_configCollageItems:_collageModel.picArr];
    }
}

- (void)top_hiddenCtrlTap:(UITapGestureRecognizer *)gesture {
    [self top_closeAllCtrlItem];
}

#pragma mark -- 拼图控件
- (void)top_configCollageItems:(NSArray *)pics {
    for (int i = 0; i < 2; i++) {
        if (pics.count > i) {
            SSCollagePic *collagePic = pics[i];
            StickerView *sticker1 = [self selectedPicModel:collagePic];
            [self.bgSuperView addSubview:sticker1];
            [self.collageModel.stickerArr addObject:sticker1];
            if (collagePic.isEditing) {
                [sticker1 performTapOperation];
            }
        }
    }
    self.collageModel.bgImgView = self.bgSuperView;
}

- (void)top_showWaterMarkView {
    self.waterMartView.hidden = NO;
    self.waterMartView.image = [UIImage imageWithContentsOfFile:[TOPDocumentHelper top_waterMarkTextImagePath]];
}

- (void)top_hiddenWaterMarkView {
    if (!self.waterMartView.hidden) {
        self.waterMartView.hidden = YES;
    }
}

- (void)top_addStickerView:(StickerView *)sticker {
    sticker.delegate = self;
    if (_waterMartView) {
        [self.bgSuperView insertSubview:sticker belowSubview:_waterMartView];
    } else {
        [self.bgSuperView addSubview:sticker];
    }
    
    [self.collageModel.stickerArr addObject:sticker];
}

#pragma mark -- 关闭编辑状态
- (void)top_closeAllCtrlItem {
    for (UIView *subView in self.bgSuperView.subviews) {
        if ([subView isKindOfClass:[StickerView class]]) {
            [(StickerView *)subView hiddenCtrl];
        }
    }
}

#pragma mark -- 开启图片的编辑状态 ：同时只能编辑一张图片
- (void)top_openCtrlItem:(StickerView *)stickerView {
    [stickerView showCtrl];
    [stickerView removeFromSuperview];
    [self.collageModel.stickerArr removeObject:stickerView];
}

#pragma mark - StickerViewDelegate
#pragma mark -- 编辑按钮
- (UIImage *)stickerView:(StickerView *)stickerView imageForRightTopControl:(CGSize)recommendedSize {
    return self.idCardModel ? [UIImage imageNamed:@"top_signature_crop"] : [UIImage imageNamed:@"top_signature_delete"];
    
}

- (void)top_stickerViewDidTapContentView:(StickerView *)stickerView {
    [self top_closeAllCtrlItem];
    [self top_openCtrlItem:stickerView];
    stickerView.enabledMove = YES;
    if (self.top_beginDragBlock) {
        self.top_beginDragBlock(stickerView);
    }
}


- (StickerView *)selectedPicModel:(SSCollagePic *)model {
    StickerView *sticker1 = [[StickerView alloc] initWithContentFrame:model.imgViewRect contentImage:model.img];
    sticker1.backgroundColor = [UIColor clearColor];
    sticker1.enabledControl = NO;
    sticker1.enabledBorder = NO;
    sticker1.enabledDeleteControl = NO;
    sticker1.enabledMove = NO;
    sticker1.delegate = self;
    sticker1.tag = model.imgIndex;
    return sticker1;
}

- (UIImageView *)bgSuperView {
    if (!_bgSuperView) {
        _bgSuperView = [[UIImageView alloc] initWithFrame:self.bounds];
        _bgSuperView.image = [TOPPictureProcessTool top_imageWithColor:kWhiteColor];
        _bgSuperView.userInteractionEnabled = YES;
    }
    return _bgSuperView;
}

- (UIImageView *)waterMartView {
    if (!_waterMartView) {
        _waterMartView = [[UIImageView alloc] init];
        _waterMartView.hidden = YES;
    }
    return _waterMartView;
}

@end
