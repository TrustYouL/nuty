#import "TOPPhotoReEditView.h"
@interface TOPPhotoReEditView()
@property (nonatomic ,copy)NSArray * iconArray;
@property (nonatomic ,copy)NSArray * titleArray;
@property (nonatomic ,strong)NSMutableArray * btnArray;
@property (nonatomic ,strong)UIImageView * backImg;
@property (nonatomic ,strong)UIImageView * picImg;
@property (nonatomic ,strong)TOPImageTitleButton * picBtn;
@property (nonatomic ,strong)UILabel * pageLab;
@end
@implementation TOPPhotoReEditView
- (instancetype)initWithFrame:(CGRect)frame iconArray:(nonnull NSArray *)iconArray titleArray:(nonnull NSArray *)titleArray{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.iconArray = iconArray;
        self.titleArray = titleArray;
        [self top_setupUI];
    }
    return self;
}
- (void)top_setupUI{
    _backImg = [UIImageView new];
    _backImg.image = [UIImage imageNamed:@"top_photo_reEdit_back"];
    
    _picImg = [UIImageView new];
    _picImg.layer.borderWidth = 0.5;
    _picImg.layer.borderColor = RGBA(180, 180, 180, 1.0).CGColor;
    _picImg.layer.masksToBounds = YES;
    
    _picBtn = [[TOPImageTitleButton alloc]initWithStyle:EImageTopTitleBottom];
    _picBtn.tag = 1001+self.titleArray.count;
    _picBtn.backgroundColor = [UIColor clearColor];
    [_picBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _pageLab = [UILabel new];
    _pageLab.adjustsFontSizeToFitWidth = YES;
    _pageLab.textColor = TOPAPPGreenColor;
    _pageLab.font = [UIFont boldSystemFontOfSize:13];
    _pageLab.backgroundColor = RGBA(61, 135, 215, 0.4);
    _pageLab.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_backImg];
    [self addSubview:_picImg];
    [self addSubview:_picBtn];
    [_picImg addSubview:_pageLab];
    
    NSMutableArray * tempArray = [NSMutableArray new];
    for (int i = 0; i<self.titleArray.count; i++) {
        TOPImageTitleButton * btn = [[TOPImageTitleButton alloc]initWithStyle:EImageTopTitleBottom];
        btn.tag = 1001+i;
        btn.titleLabel.font = [UIFont systemFontOfSize:11];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.adjustsImageWhenHighlighted = NO;
        [btn setTitle:self.titleArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:RGBA(153, 153, 153, 1.0) forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:self.iconArray[i]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [tempArray addObject:btn];
    }
    self.btnArray = tempArray;
    [self top_maskAllView];
}
- (void)top_maskAllView{
    TOPImageTitleButton * btn1 = self.btnArray[0];
    TOPImageTitleButton * btn2 = self.btnArray[1];
    TOPImageTitleButton * btn3 = self.btnArray[2];
    TOPImageTitleButton * btn4 = self.btnArray[3];
    TOPImageTitleButton * btn5 = self.btnArray[4];
    TOPImageTitleButton * btn6 = self.btnArray[5];

    CGFloat topH ;
    CGFloat imgH ;
    CGFloat leftW ;
    CGFloat btnTopH ;

    if (IS_IPAD) {
        topH = 60;
        imgH = 40;
        leftW = 60;
        btnTopH = 30;
    }else{
        if (TOPBottomSafeHeight>0) {
            topH = 45;
            imgH = 30;
        }else{
            topH = 20;
            imgH = 20;
        }
        leftW = 40;
        btnTopH = 15;
    }
   
    [_backImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(topH);
        make.size.mas_equalTo(CGSizeMake(113, 118));
    }];
    [_picImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(topH);
        make.size.mas_equalTo(CGSizeMake(113, 110));
    }];
    [_picBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(topH);
        make.size.mas_equalTo(CGSizeMake(113, 110));
    }];
    [_pageLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.equalTo(_picImg);
        make.size.mas_equalTo(CGSizeMake(50, 16));
    }];
    [btn2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(_backImg.mas_bottom).offset(imgH);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
    [btn1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(btn2.mas_leading).offset(-leftW);
        make.top.equalTo(_backImg.mas_bottom).offset(imgH);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
    [btn3 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(btn2.mas_trailing).offset(leftW);
        make.top.equalTo(_backImg.mas_bottom).offset(imgH);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
    [btn5 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(btn2.mas_bottom).offset(btnTopH);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
    [btn4 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(btn5.mas_leading).offset(-leftW);
        make.top.equalTo(btn2.mas_bottom).offset(btnTopH);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
    [btn6 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(btn5.mas_trailing).offset(leftW);
        make.top.equalTo(btn2.mas_bottom).offset(btnTopH);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
}
- (void)top_clickBtn:(TOPImageTitleButton *)sender{
    if (self.top_clickBtnBlock) {
        self.top_clickBtnBlock(sender.tag-1001);
    }
}
- (void)setDataArray:(NSMutableArray *)dataArray{
    _dataArray = dataArray;
    if (dataArray.count) {
        DocumentModel * model = dataArray[0];
        _picImg.image = [UIImage imageWithContentsOfFile:model.path];
        _pageLab.text = [NSString stringWithFormat:@"%ldP",dataArray.count];
    }
}
- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray new];
    }
    return _btnArray;
}

@end
