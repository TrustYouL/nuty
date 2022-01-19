#import "TOPTranslateModelCell.h"
#import "TOPTranslateModel.h"

@interface TOPTranslateModelCell ()
@property (nonatomic, strong) UILabel *cellTitleLab;
@property (nonatomic, strong) UIImageView *checkIcon;
@property (nonatomic, strong) UIButton *downLoadBtn;
@property (nonatomic, strong) TOPLoadingCircleView *loadingCicle;
@property (nonatomic, strong) TOPTranslateModel *translateModel;

@end

@implementation TOPTranslateModelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    [self.contentView addSubview:self.checkIcon];
    [self.contentView addSubview:self.downLoadBtn];
    [self.contentView addSubview:self.cellTitleLab];
    [self top_sd_layoutSubViews];
}

- (void)top_sd_layoutSubViews {
    UIView *contentView = self.contentView;
    [self.checkIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(10);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [self.downLoadBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-15);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.cellTitleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.checkIcon.mas_trailing).offset(15);
        make.trailing.equalTo(self.downLoadBtn.mas_leading).offset(-25);
        make.centerY.equalTo(contentView);
        make.height.mas_equalTo(20);
    }];
}

- (void)top_configCellWithData:(TOPTranslateModel *)model {
    _translateModel = model;
    self.checkIcon.hidden = !model.isSelected;
    self.cellTitleLab.text = model.language;
    if (model.isLoading) {
        [self top_startLoading];
    } else {
        [self top_stopLoading];
        UIImage *downloadImg;
        if (model.isDownloaded) {
            downloadImg = [UIImage imageNamed:@"top_delete_language"];
        } else {
            downloadImg = [UIImage imageNamed:@"top_download_language"];
        }
        [self.downLoadBtn setImage:downloadImg forState:UIControlStateNormal];
    }
}

- (void)top_startLoading {
    self.translateModel.isLoading = YES;
    self.downLoadBtn.hidden = YES;
    self.loadingCicle.hidden = NO;
    [self.loadingCicle top_startLoading];
}

- (void)top_stopLoading {
    if (_loadingCicle) {
        self.downLoadBtn.hidden = NO;
        self.loadingCicle.hidden = YES;
        [self.loadingCicle dismiss];
        [self.loadingCicle removeFromSuperview];
        self.loadingCicle = nil;
    }
}

- (void)top_clickDownloadBtn {
    if (self.translateModel.isDownloaded) {
        if (self.top_deleteLanguageModelBlock) {
            self.top_deleteLanguageModelBlock();
        }
    } else {
        if (self.top_clickDownloadBlock) {
            self.top_clickDownloadBlock();
        }
        [self top_startLoading];
    }
}

#pragma mark -- lazy
- (UILabel *)cellTitleLab {
    if (!_cellTitleLab) {
        UILabel *noClassLab = [[UILabel alloc] init];
        noClassLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        noClassLab.textAlignment = NSTextAlignmentNatural;
        noClassLab.font = PingFang_R_FONT_(17);
        noClassLab.text = @"";
        [self.contentView addSubview:noClassLab];
        _cellTitleLab = noClassLab;
    }
    return _cellTitleLab;
}

- (UIImageView *)checkIcon {
    if (!_checkIcon) {
        UIImage *noClassImg = [UIImage imageNamed:@"top_settingSelect"];
        UIImageView *noClass = [[UIImageView alloc] initWithImage:noClassImg];
        noClass.hidden = YES;
        [self.contentView addSubview:noClass];
        _checkIcon = noClass;
    }
    return _checkIcon;
}

- (UIButton *)downLoadBtn {
    if (!_downLoadBtn) {
        UIButton *ovalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [ovalBtn setTitle:@"" forState:UIControlStateNormal];
        [ovalBtn setImage:[UIImage imageNamed:@"top_download_language"] forState:UIControlStateNormal];
        [ovalBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
        ovalBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:ovalBtn];
        [ovalBtn addTarget:self action:@selector(top_clickDownloadBtn) forControlEvents:UIControlEventTouchUpInside];
        _downLoadBtn = ovalBtn;
    }
    return _downLoadBtn;
}

- (TOPLoadingCircleView *)loadingCicle {
    if (!_loadingCicle) {
        TOPLoadingCircleView *cicle = [[TOPLoadingCircleView alloc] initWithFrame:CGRectMake(TOPScreenWidth - 50, 12, 30, 30)];
        [self addSubview:cicle];
        _loadingCicle = cicle;
    }
    return _loadingCicle;
}

@end
