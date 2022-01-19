#import "TOPEditPDFViewCell.h"
#import "TOPEditPDFModel.h"
#import "StickerView.h"

@interface TOPEditPDFViewCell ()<StickerViewDelegate>
@property (strong, nonatomic) UIImageView *pdfImageView;
@property (strong, nonatomic) UILabel *pageLabel;
@property (strong, nonatomic) UIImageView *waterMartView;
@property (strong, nonatomic) TOPEditPDFModel *editPDFModel;

@end

@implementation TOPEditPDFViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    [self.contentView addSubview:self.pdfImageView];
    [self.contentView addSubview:self.pageLabel];
    [self.contentView addSubview:self.waterMartView];
    
    self.contentView.clipsToBounds = YES;
    [self top_sd_layoutSubViews];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(top_hiddenCtrlTap:)];
    [self.contentView addGestureRecognizer:tapGesture];
}

- (void)top_updateShadowLayer {
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 0.5;///不透明度
    self.layer.shadowColor = [UIColor colorWithHex:0x000000].CGColor;//阴影颜色
    self.layer.shadowOffset = CGSizeMake(0, 2);//投影偏移
    self.layer.shadowRadius = 4;//半径大小
}

- (void)top_sd_layoutSubViews {
    UIView *contentView = self.contentView;
    [self.pageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.trailing.equalTo(contentView).offset(-15);
        make.top.equalTo(contentView).offset(10);
        make.height.mas_equalTo(15);
    }];
    [self.pdfImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.leading.trailing.equalTo(contentView);
    }];
    [self.waterMartView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.leading.trailing.equalTo(contentView);
    }];
}

- (void)top_configCellWithData:(TOPEditPDFModel *)model {
    self.pdfImageView.image = [UIImage imageWithContentsOfFile:model.imagePath];
    self.pageLabel.text = model.pageNum;
    [self top_pageNumLayout:model.pageNumLayout];
    
    _editPDFModel = model;
    
    for (UIView *subView in self.contentView.subviews) {
        if ([subView isKindOfClass:[StickerView class]]) {
            [subView removeFromSuperview];
        }
    }
    [self top_configCollageItems:model.picArr];
}

- (void)top_pageNumLayout:(TOPPDFPageNumLayoutType)layoutType {
    switch (layoutType) {
        case TOPPDFPageNumLayoutTypeNull:
            self.pageLabel.hidden = YES;
            [self top_mas_resetLayoutTypeFirst];
            break;
        case TOPPDFPageNumLayoutTypeTopLeft:
        case TOPPDFPageNumLayoutTypeTopCenter:
        case TOPPDFPageNumLayoutTypeTopRight:
            self.pageLabel.hidden = NO;
            self.pageLabel.textAlignment = NSTextAlignmentNatural;
            [self top_mas_resetLayoutTypeSecond];
            break;
        case TOPPDFPageNumLayoutTypeBottomLeft:
        case TOPPDFPageNumLayoutTypeBottomCenter:
        case TOPPDFPageNumLayoutTypeBottomRight:
            self.pageLabel.hidden = NO;
            self.pageLabel.textAlignment = NSTextAlignmentNatural;
            [self top_mas_resetLayoutTypeThird];
            break;
            
        default:
            break;
    }
    if (layoutType == TOPPDFPageNumLayoutTypeNull) {
        self.pageLabel.textAlignment = NSTextAlignmentCenter;
    } else if (layoutType == TOPPDFPageNumLayoutTypeBottomLeft || layoutType == TOPPDFPageNumLayoutTypeTopLeft) {
        self.pageLabel.textAlignment = NSTextAlignmentNatural;
    } else if (layoutType == TOPPDFPageNumLayoutTypeBottomCenter || layoutType == TOPPDFPageNumLayoutTypeTopCenter) {
        self.pageLabel.textAlignment = NSTextAlignmentCenter;
    } else if (layoutType == TOPPDFPageNumLayoutTypeBottomRight || layoutType == TOPPDFPageNumLayoutTypeTopRight) {
        self.pageLabel.textAlignment = NSTextAlignmentRight;
    }
}
- (void)top_mas_resetLayoutTypeFirst{
    [self.pdfImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.leading.trailing.equalTo(self.contentView);
    }];
}
- (void)top_mas_resetLayoutTypeSecond{
    [self.pageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(15);
        make.trailing.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.contentView);
        make.height.mas_equalTo(25);
    }];
    [self.pdfImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(25);
        make.bottom.equalTo(self.contentView).offset(-25);
    }];
}
- (void)top_mas_resetLayoutTypeThird{
    [self.pageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(15);
        make.trailing.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(25);
    }];
    [self.pdfImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(25);
        make.bottom.equalTo(self.contentView).offset(-25);
    }];
}
- (void)top_showWaterMarkView {
    self.waterMartView.image = [UIImage imageWithContentsOfFile:[TOPDocumentHelper top_waterMarkTextImagePath]];
    self.waterMartView.hidden = NO;
}

- (void)top_hiddenWaterMarkView {
    if (!self.waterMartView.hidden) {
        self.waterMartView.hidden = YES;
    }
}

- (void)top_hiddenCtrlTap:(UITapGestureRecognizer *)gesture {
    [self top_closeAllCtrlItem];
}

#pragma mark -- 拼图控件
- (void)top_configCollageItems:(NSArray *)pics {
    for (SSPDFSignaturePic *collagePic in pics) {
        StickerView *sticker1 = [self selectedPicModel:collagePic];
        [self.contentView addSubview:sticker1];
        if (collagePic.isEditing) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [sticker1 performTapOperation];
            });
        }
    }
}

- (void)top_addStickerView:(StickerView *)sticker {
    sticker.delegate = self;
    [self.contentView addSubview:sticker];
}

#pragma mark -- 关闭编辑状态
- (void)top_closeAllCtrlItem {
    for (UIView *subView in self.contentView.subviews) {
        if ([subView isKindOfClass:[StickerView class]]) {
            [(StickerView *)subView hiddenCtrl];
        }
    }
}

#pragma mark -- 开启图片的编辑状态 ：同时只能编辑一张图片
- (void)top_openCtrlItem:(StickerView *)stickerView {
    [stickerView showCtrl];
    [stickerView removeFromSuperview];
}

#pragma mark - StickerViewDelegate
#pragma mark -- 编辑按钮
- (UIImage *)stickerView:(StickerView *)stickerView imageForRightTopControl:(CGSize)recommendedSize {
    return [UIImage imageNamed:@"top_signature_delete"];
    
}

- (void)top_stickerViewDidTapContentView:(StickerView *)stickerView {
    [self top_closeAllCtrlItem];
    [self top_openCtrlItem:stickerView];
    stickerView.enabledMove = YES;
    if (self.top_beginReformBlock) {
        self.top_beginReformBlock(stickerView);
    }
}

- (void)top_stickerViewDidTapRightTopControl:(StickerView *)stickerView {
    [self top_removeStickerView:stickerView];
}

- (void)top_removeStickerView:(StickerView *)stickerView {
    [stickerView removeFromSuperview];
    for (int i = 0; i<self.editPDFModel.picArr.count; i++) {
        SSPDFSignaturePic *pic = self.editPDFModel.picArr[i];
        if (pic.imgIndex == stickerView.tag) {
            [self.editPDFModel.picArr removeObject:pic];
            break;
        }
    }
}

- (StickerView *)selectedPicModel:(SSPDFSignaturePic *)model {
    StickerView *sticker1 = [[StickerView alloc] initWithContentFrame:model.imgViewRect contentImage:model.img];
    sticker1.backgroundColor = [UIColor clearColor];
    sticker1.enabledControl = NO;
    sticker1.enabledBorder = NO;
    sticker1.enabledDeleteControl = NO;
    sticker1.enabledMove = NO;
    sticker1.delegate = self;
    sticker1.enabledInteraction = model.enabledInteraction;
    sticker1.tag = model.imgIndex;
    return sticker1;
}

#pragma mark -- lazy
- (UIImageView *)pdfImageView {
    if (!_pdfImageView) {
        UIImageView *noClass = [[UIImageView alloc] init];
        noClass.contentMode = UIViewContentModeScaleAspectFit;
        _pdfImageView = noClass;
    }
    return _pdfImageView;
}

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        UILabel *backLabel = [[UILabel alloc] init];
        backLabel.text = @"";
        backLabel.textColor = RGB(53, 53, 53);
        backLabel.font = PingFang_R_FONT_(10);
        backLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel = backLabel;
    }
    return _pageLabel;
}

- (UIImageView *)waterMartView {
    if (!_waterMartView) {
        _waterMartView = [[UIImageView alloc] init];
        _waterMartView.contentMode = UIViewContentModeScaleAspectFill;
        _waterMartView.clipsToBounds = YES;
        _waterMartView.hidden = YES;
    }
    return _waterMartView;
}

@end
