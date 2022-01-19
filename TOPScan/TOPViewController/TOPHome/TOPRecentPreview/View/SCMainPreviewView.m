//
//  SCMainPreviewView.m
//  SimpleScan
//
//  Created by admin3 on 2021/9/1.
//  Copyright © 2021 admin3. All rights reserved.
//

#import "SCMainPreviewView.h"
@interface SCMainPreviewView()
@property (nonatomic, strong)UIButton * shareBtn;
@property (nonatomic, strong)UIButton * emailBtn;
@property (nonatomic, strong)UIButton * printBtn;
@property (nonatomic, strong)UIButton * moreBtn;
@property (nonatomic, strong)UILabel * titleLabel;
@property (nonatomic, strong)UILabel * dateLabel;
@property (nonatomic, strong)UILabel * numLabel;
@property (nonatomic, strong)UILabel * tagLab;
@property (nonatomic, strong)UIImageView * gaussianImg;
@property (nonatomic, strong)UIImageView * imgV;
@property (nonatomic, strong)UIImageView * tagImg;
@property (nonatomic, strong)UIView * middleLine;
@property (nonatomic, strong)UIView * coverView;
@property (nonatomic, strong)UIView * centerView;
@property (nonatomic, strong)UIImageView  *collectionImg;
@property (nonatomic, assign)CGFloat leftW;
@property (nonatomic, assign)CGFloat lineSpace;
@property (nonatomic, assign)CGFloat tagTop;

@end
@implementation SCMainPreviewView
- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        UIView * centerView = [UIView new];
        centerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        centerView.layer.cornerRadius = 15;
        centerView.layer.shadowColor = [UIColor blackColor].CGColor;
        centerView.layer.shadowOffset = CGSizeMake(0, 0);
        centerView.layer.shadowOpacity = 0.3;
        centerView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_tapAction:)];
        [centerView addGestureRecognizer:tap];
        self.centerView = centerView;
        
        UIButton * shareBtn = [UIButton new];
        shareBtn.tag = 1001+0;
        [shareBtn setImage:[UIImage imageNamed:@"top_menu_share_colorful"] forState:UIControlStateNormal];
        [shareBtn setImage:[UIImage imageNamed:@"top_menu_share_colorful"] forState:UIControlStateHighlighted];
        [shareBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.shareBtn = shareBtn;
        
        UIButton * emailBtn = [UIButton new];
        emailBtn.tag = 1001+1;
        [emailBtn setImage:[UIImage imageNamed:@"top_menu_email_colorful"] forState:UIControlStateNormal];
        [emailBtn setImage:[UIImage imageNamed:@"top_menu_email_colorful"] forState:UIControlStateHighlighted];
        [emailBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.emailBtn = emailBtn;
        
        UIButton * printBtn = [UIButton new];
        printBtn.tag = 1001+2;
        [printBtn setImage:[UIImage imageNamed:@"top_menu_fax_colorful"] forState:UIControlStateNormal];
        [printBtn setImage:[UIImage imageNamed:@"top_menu_fax_colorful"] forState:UIControlStateHighlighted];
        [printBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.printBtn = printBtn;
        
        UIButton * moreBtn = [UIButton new];
        moreBtn.tag = 1001+3;
        [moreBtn setImage:[UIImage imageNamed:@"top_menu_more_colorful"] forState:UIControlStateNormal];
        [moreBtn setImage:[UIImage imageNamed:@"top_menu_more_colorful"] forState:UIControlStateHighlighted];
        [moreBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.moreBtn = moreBtn;
        
        UIView * middleLine = [UIView new];//基准线
        middleLine.backgroundColor = [UIColor clearColor];
        self.middleLine = middleLine;
        
        [self addSubview:centerView];
        [self addSubview:shareBtn];
        [self addSubview:emailBtn];
        [self addSubview:printBtn];
        [self addSubview:moreBtn];
        [self addSubview:middleLine];
        
        _imgV = [[UIImageView alloc] init];
        _imgV.backgroundColor = [UIColor whiteColor];
        _imgV.contentMode = UIViewContentModeScaleAspectFill;
        _imgV.clipsToBounds = YES;
        _imgV.layer.cornerRadius = 15;
        
        _gaussianImg = [UIImageView new];
        _gaussianImg.image = [UIImage imageNamed:@"top_gaussianblur"];

        _coverView = [UIView new];
        _coverView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _titleLabel = [UILabel new];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;//防止遇见空格换行
        _titleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
        _titleLabel.textAlignment = NSTextAlignmentNatural;
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [self fontsWithSize:17];//20
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = RGBA(153, 153, 153, 1.0);
        _dateLabel.font = [self fontsWithSize:14];//16
        
        _numLabel = [[UILabel alloc] init];
        _numLabel.textColor = UIColor.grayColor;
        _numLabel.layer.cornerRadius = 2;
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.layer.borderColor = RGBA(153, 153, 153, 1.0).CGColor;
        _numLabel.layer.borderWidth = 1;
        _numLabel.layer.masksToBounds = YES;
        _numLabel.font = [self fontsWithSize:14];//16
        
        _tagImg = [UIImageView new];
        _tagImg.image = [UIImage imageNamed:@"top_biaoqian"];
        
        _collectionImg = [UIImageView new];
        _collectionImg.image = [UIImage imageNamed:@"top_collectionicon"];
        _collectionImg.hidden = YES;
        
        _tagLab = [[UILabel alloc] init];
        _tagLab.textColor = UIColor.grayColor;
        _tagLab.hidden = NO;
        _tagLab.textAlignment = NSTextAlignmentNatural;
        _tagLab.font = [self fontsWithSize:12];
        
        [self.centerView addSubview:_imgV];
        [self.centerView addSubview:_gaussianImg];
        [self.centerView addSubview:_coverView];
        [self.centerView addSubview:_titleLabel];
        [self.centerView addSubview:_dateLabel];
        [self.centerView addSubview:_numLabel];
        [self.centerView addSubview:_tagImg];
        [self.centerView addSubview:_tagLab];
        [self.centerView addSubview:_collectionImg];
        
        CGSize topSize ;
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;//ipad切换横竖屏时 字体大小 lab的间距也随着改变
        if (IS_IPAD) {
            if (orientation == UIInterfaceOrientationPortrait||orientation == UIInterfaceOrientationPortraitUpsideDown) {//竖屏
                if (![TOPPermissionManager top_enableByAdvertising]) {//不是会员展示广告
                    topSize = CGSizeMake(50+50, 20);
                }else{
                    topSize = CGSizeMake(75+50, 50);
                }
            }else{
                if (![TOPPermissionManager top_enableByAdvertising]) {//不是会员展示广告
                    topSize = CGSizeMake(50+30, 20);
                }else{
                    topSize = CGSizeMake(75+30, 50);
                }
            }
            
        }else{
            if (![TOPPermissionManager top_enableByAdvertising]) {//不是会员展示广告
                topSize = CGSizeMake(50, 20);
            }else{
                topSize = CGSizeMake(75, 50);
            }
        }
        
        [self top_setupUI:topSize];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
    self.centerView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _coverView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _titleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
}
- (void)top_setupUI:(CGSize)size{
    if (IS_IPAD) {
        [self.centerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(size.width);
            make.bottom.equalTo(self).offset(-(150+TOPBottomSafeHeight+50));
            make.width.mas_equalTo(self.centerView.mas_height).multipliedBy(270.0/351);
        }];
    }else{
        [self.centerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(size.width);
            make.left.equalTo(self).offset(35);
            make.right.equalTo(self).offset(-35);
            make.bottom.equalTo(self).offset(-(165+TOPBottomSafeHeight));
        }];
    }
   
    [self.middleLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(1, 1));
    }];
    [self.emailBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.middleLine.mas_leading).offset(-15);
        make.top.equalTo(self.centerView.mas_bottom).offset(size.height);
        make.size.mas_equalTo(CGSizeMake(59, 59));
    }];
    [self.shareBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.emailBtn.mas_leading).offset(-30);
        make.centerY.equalTo(self.emailBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(59, 59));
    }];
    [self.printBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.middleLine.mas_trailing).offset(15);
        make.centerY.equalTo(self.emailBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(59, 59));
    }];
    [self.moreBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.printBtn.mas_trailing).offset(30);
        make.centerY.equalTo(self.emailBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(59, 59));
    }];
    [self setCenterViewSubViews];
}
- (void)setCenterViewSubViews{
    CGFloat titleH = 0;
    CGFloat dateTop = 0;
    CGFloat tagTop = 0;
    CGFloat numW = 20.0;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;//ipad切换横竖屏时 字体大小 lab的间距也随着改变
    if (IS_IPAD) {
        if (orientation == UIInterfaceOrientationPortrait||orientation == UIInterfaceOrientationPortraitUpsideDown) {//竖屏
            _titleLabel.font = [self fontsWithSize:20];
            _dateLabel.font = [self fontsWithSize:16];
            _numLabel.font = [self fontsWithSize:16];
            _tagLab.font = [self fontsWithSize:14];
            _lineSpace = 20;
            titleH = 65;
            dateTop = 20;
            tagTop = 20;
            if (_lastModel.number.length) {
                numW = [TOPDocumentHelper top_getSizeWithStr:_lastModel.number Height:17 Font:16].width+10;
            }
        }else{//横屏
            _titleLabel.font = [self fontsWithSize:17];
            _dateLabel.font = [self fontsWithSize:14];
            _numLabel.font = [self fontsWithSize:14];
            _tagLab.font = [self fontsWithSize:12];
            _lineSpace = 10;
            titleH = 55;
            dateTop = 5;
            tagTop = 15;
            numW = [TOPDocumentHelper top_getSizeWithStr:_lastModel.number Height:17 Font:16].width+10;
        }
    }else{
        _titleLabel.font = [self fontsWithSize:17];
        _dateLabel.font = [self fontsWithSize:14];
        _numLabel.font = [self fontsWithSize:14];
        _tagLab.font = [self fontsWithSize:12];
        _lineSpace = 10;
        titleH = 50;
        dateTop = 5;
        tagTop = 8;
        numW = [TOPDocumentHelper top_getSizeWithStr:_lastModel.number Height:17 Font:14].width+10;
    }
    _leftW = _lineSpace;
    _tagTop = tagTop;
    [_imgV mas_remakeConstraints:^(MASConstraintMaker *make) {//20
        make.leading.trailing.top.equalTo(self.centerView);
        make.height.mas_equalTo(self.centerView.mas_height).multipliedBy(248.0/351);
    }];
    [_gaussianImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_imgV);
        make.size.mas_equalTo(CGSizeMake(15, 20));
    }];
    [_coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgV.mas_bottom).offset(-15);
        make.leading.trailing.equalTo(self.centerView);
        make.bottom.equalTo(self.centerView).offset(-15);
    }];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.centerView).offset(_lineSpace);
        make.trailing.equalTo(self.centerView).offset(-_lineSpace);
        make.top.equalTo(_imgV.mas_bottom);
        make.height.mas_offset(titleH);
    }];
    [_dateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.centerView).offset(_lineSpace);
        make.top.equalTo(_titleLabel.mas_bottom).offset(dateTop);
        make.height.mas_offset(16);
    }];
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_dateLabel.mas_trailing).offset(20);
        make.centerY.equalTo(_dateLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(numW, 17));
    }];
    [_collectionImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.centerView).offset(_lineSpace);
        make.top.equalTo(_dateLabel.mas_bottom).offset(tagTop);
        make.size.mas_equalTo(CGSizeMake(24/2, 24/2));
    }];
    [_tagImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.centerView).offset(_leftW);
        make.top.equalTo(_dateLabel.mas_bottom).offset(tagTop);
        make.size.mas_equalTo(CGSizeMake(23/2, 23/2));
    }];
    [_tagLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_tagImg.mas_trailing).offset(2);
        make.trailing.equalTo(self.centerView).offset(-_lineSpace);
        make.centerY.equalTo(_tagImg.mas_centerY);
        make.height.mas_equalTo(16);
    }];
}
- (void)setLastModel:(DocumentModel *)lastModel{
    _lastModel = lastModel;
    _titleLabel.text = lastModel.name;
    _dateLabel.text = lastModel.createDate;
    _gaussianImg.image = [UIImage imageNamed:@"top_gaussianblur"];
    _numLabel.text = lastModel.number;
    
    if ([TOPWHCFileManager top_isExistsAtPath:lastModel.docPasswordPath]) {
        _imgV.image = [UIImage imageWithContentsOfFile:lastModel.gaussianBlurPath];//显示高斯模糊图片
        _gaussianImg.hidden = NO;
    }else{
        _imgV.image = [UIImage imageWithContentsOfFile:lastModel.imagePath];
        _gaussianImg.hidden = YES;
    }
    if (!_imgV.image) {//异步加载缩略图
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            /*
            if (![TOPWHCFileManager top_isExistsAtPath:lastModel.midCoverImgPath]) {
                [TOPDataModelHandler top_createMidCoverImage:lastModel.imagePath atPath:lastModel.midCoverImgPath];//保存缩略图到本地
            }*/
            UIImage *coverImage = [UIImage imageWithContentsOfFile:lastModel.imagePath];
            UIImage * bluImg = [UIImage new];
            /*
            if (!coverImage) {
                coverImage = [UIImage imageWithContentsOfFile:lastModel.imagePath];
            }*/
            if ([TOPWHCFileManager top_isExistsAtPath:lastModel.docPasswordPath]) {
                bluImg = [TOPDocumentHelper top_blurryImage:coverImage withBlurLevel:60];
                if (bluImg) {
                    [TOPDocumentHelper top_saveImage:bluImg atPath:lastModel.gaussianBlurPath];//保存高斯模糊图片到本地
                } else {
                    bluImg = coverImage;
                }
            } else {
                bluImg = coverImage;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imgV.image = bluImg;
            });
        });
    }

    //标签处理
    NSArray * tagsArray = lastModel.tagsArray;
    if (tagsArray.count>0) {
        _tagImg.hidden = NO;
        _tagLab.hidden = NO;
        NSString * allString = [NSString new];
        for (TOPTagsModel * tagModel in tagsArray) {
            allString = [NSString stringWithFormat:@"%@ | %@",allString,tagModel.name];
        }
        if (allString.length>2) {
            _tagLab.text = [allString substringFromIndex:2];
        }
    }else{
        _tagImg.hidden = YES;
        _tagLab.hidden = YES;
    }
    
    CGFloat lineSpace = 0;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (IS_IPAD) {
        if (orientation == UIInterfaceOrientationPortrait||orientation == UIInterfaceOrientationPortraitUpsideDown) {//竖屏
            lineSpace = 20;
        }else{//横屏
            lineSpace = 10;
        }
    }else{
        lineSpace = 10;
    }
    if (lastModel.collectionstate) {
        _collectionImg.hidden = NO;
        _leftW = self.lineSpace+12+3;
    }else{
        _collectionImg.hidden = YES;
        _leftW = self.lineSpace;
    }
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_dateLabel.mas_trailing).offset(20);
        make.centerY.equalTo(_dateLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([TOPDocumentHelper top_getSizeWithStr:lastModel.number Height:15 Font:14].width+10, 17));
    }];
    [_tagImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.centerView).offset(_leftW);
        make.top.equalTo(_dateLabel.mas_bottom).offset(_tagTop);
        make.size.mas_equalTo(CGSizeMake(23/2, 23/2));
    }];
}
- (void)top_tapAction:(UITapGestureRecognizer *)tap{
    if (self.previewFunctionType) {
        self.previewFunctionType(4);
    }
}
- (void)top_clickBtn:(UIButton *)sender{
    NSInteger tag = sender.tag-1001;
    if (self.previewFunctionType) {
        self.previewFunctionType(tag);
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
