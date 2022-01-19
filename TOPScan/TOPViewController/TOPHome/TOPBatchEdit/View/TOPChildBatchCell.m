#import "TOPChildBatchCell.h"

@implementation TOPChildBatchCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _backLab = [UILabel new];
        _backLab.backgroundColor = RGBA(51, 51, 51, 0.5);
        _backLab.textAlignment = NSTextAlignmentCenter;
        _backLab.textColor = [UIColor whiteColor];
        _backLab.hidden = YES;
        
        _flImg = [FLAnimatedImageView new];
        _flImg.backgroundColor = [UIColor clearColor];

        _picImg = [[UIImageView alloc] init];
        _picImg.backgroundColor = [UIColor clearColor];
        _picImg.contentMode = UIViewContentModeScaleAspectFill;
        _picImg.clipsToBounds = YES;
        
        _iconImg = [UIImageView new];
        
        _titleLab = [UILabel new];
        _titleLab.backgroundColor = TOPAPPGreenColor;
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.font = [UIFont systemFontOfSize:18];
        _titleLab.textAlignment = NSTextAlignmentCenter;
      
        [self.contentView addSubview:_picImg];
        [self.contentView addSubview:_iconImg];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_backLab];
        [self.contentView addSubview:_flImg];
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    UIView * contentView = self.contentView;
    [_picImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(contentView);
        make.bottom.equalTo(contentView).offset(-30);
    }];
    [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-5);
        make.top.equalTo(contentView).offset(5);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(contentView);
        make.height.mas_equalTo(30);
    }];
    [_backLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(contentView);
        make.bottom.equalTo(contentView).offset(-30);
    }];
    [_flImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_backLab.mas_centerX);
        make.centerY.equalTo(_backLab.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
  
    NSString *path = [[NSBundle mainBundle] pathForResource:@"batchAnimation" ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    FLAnimatedImage * image = [FLAnimatedImage animatedImageWithGIFData:data];
    _flImg.animatedImage = image;
}

- (void)setModel:(TOPBatchEditModel *)model{
    _model = model;
    _titleLab.text = model.indexString;
    if (model.selectStatus) {
        _iconImg.image = [UIImage imageNamed:@"top_scamerbatch_AllSelect"];
    }else{
        _iconImg.image = [UIImage imageNamed:@"top_scamerbatch_AllNormal"];
    }
    
    if (_model.isShow) {
        _backLab.hidden = NO;
        _flImg.hidden = NO;
    }else{
        _backLab.hidden = YES;
        _flImg.hidden = YES;
    }
    
    if ([TOPWHCFileManager top_isExistsAtPath:model.coverImgPath]) {
        _picImg.image = [UIImage imageWithContentsOfFile:model.coverImgPath];
    }else{
        [self top_getAfterRotationCoverImg]; 
    }
}

#pragma mark --获取缩略图
- (void)top_getAfterRotationCoverImg{
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TOPDataModelHandler top_createCoverImage:weakSelf.model.imgPath atPath:weakSelf.model.coverImgPath];//保存缩略图到本地
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *coverImage = [UIImage imageWithContentsOfFile:weakSelf.model.coverImgPath];
            if (!coverImage) {
                coverImage = [UIImage imageWithContentsOfFile:weakSelf.model.imgPath];
            }
            weakSelf.picImg.image = coverImage;
        });
    });
}
@end
