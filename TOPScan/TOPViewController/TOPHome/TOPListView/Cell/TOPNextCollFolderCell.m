#import "TOPNextCollFolderCell.h"
@interface TOPNextCollFolderCell()
@property (nonatomic ,strong)UILabel * titleLabel;
@property (nonatomic ,strong)UIImageView * iconImg;
@property (nonatomic ,strong)UILabel * numLabel;
@property (nonatomic ,strong) UIView * lineView;

@end
@implementation TOPNextCollFolderCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.layer.borderColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(210, 210, 210, 1.0)].CGColor;
        self.layer.borderWidth = 0.7;
        
        _circleView = [UIView new];
        _circleView.layer.cornerRadius = 10/2;
        _circleView.layer.borderColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewSecondDarkColor defaultColor:RGBA(210, 210, 210, 1.0)].CGColor;
        _circleView.layer.borderWidth = 0.7;
        
        _circleBtn = [UIButton new];
        _circleBtn.backgroundColor = [UIColor clearColor];
        [_circleBtn addTarget:self action:@selector(top_clickCircleBtn) forControlEvents:UIControlEventTouchUpInside];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
        _titleLabel.font = [self fontsWithSize:11];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
     
        _numLabel = [[UILabel alloc] init];
        _numLabel.textColor = UIColor.grayColor;
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.font = [self fontsWithSize:10];
        _numLabel.layer.masksToBounds = YES;
        _numLabel.layer.cornerRadius = 2;
        _numLabel.layer.borderColor = RGBA(153, 153, 153, 1.0).CGColor;
        _numLabel.layer.borderWidth = 0.5;
        
        _iconImg = [UIImageView new];
        _iconImg.image = [UIImage imageNamed:@"top_wenjianjia_icon"];
        
        _choseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _choseBtn.hidden = YES;
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllNormal"] forState:UIControlStateNormal];
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllSelect"] forState:UIControlStateSelected];
        [_choseBtn addTarget:self action:@selector(top_selectAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        
        [self.contentView addSubview:_circleView];
        [self.contentView addSubview:_circleBtn];
        [self.contentView addSubview:_choseBtn];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_numLabel];
        [self.contentView addSubview:_iconImg];

        [self top_setupFream];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.layer.borderColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(210, 210, 210, 1.0)].CGColor;
    self.layer.borderWidth = 0.7;
    
    _circleView.layer.cornerRadius = 10/2;
    _circleView.layer.borderColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewSecondDarkColor defaultColor:RGBA(210, 210, 210, 1.0)].CGColor;
    _circleView.layer.borderWidth = 0.7;
    
    _titleLabel.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
    _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
}
- (void)top_setupFream{
    UIView * contentView = self.contentView;
    [_circleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(5);
        make.trailing.equalTo(contentView).offset(-5);
        make.size.mas_equalTo(CGSizeMake(10, 10));
    }];
    [_circleBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(0);
        make.trailing.equalTo(contentView).offset(0);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.top.equalTo(contentView).offset(10);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(5);
        make.trailing.equalTo(contentView).offset(-5);
        make.top.equalTo(_iconImg.mas_bottom).offset(5);
        make.bottom.equalTo(contentView).offset(-20);
    }];
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-10);
        make.bottom.equalTo(contentView).offset(-5);
        make.size.mas_equalTo(CGSizeMake(30, 13));
    }];
    [_choseBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(5);
        make.trailing.equalTo(contentView).offset(-5);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
}
- (void)setModel:(DocumentModel *)model{
    _model = model;
    _titleLabel.text = model.name;
    _numLabel.text = model.number;
    if (_isMerge) {
        _choseBtn.hidden = YES;
        [self top_hideCircleView];
    }else{
        _choseBtn.hidden = ![TOPScanerShare shared].isEditing;
        _circleView.hidden = [TOPScanerShare shared].isEditing;
        _circleBtn.hidden = [TOPScanerShare shared].isEditing;
    }
    _choseBtn.selected = model.selectStatus;
    CGSize numSize = [TOPAppTools getLabelFrameWithString:_numLabel.text font:_numLabel.font sizeMake:CGSizeMake((100), (14))].size;
    if (numSize.width > (14)) {
        _numLabel.frame = CGRectMake(self.frame.size.width - (10) - numSize.width, CGRectGetMaxY(_titleLabel.frame)+ (5), numSize.width, (14));
    }
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-10);
        make.bottom.equalTo(self.contentView).offset(-5);
        make.size.mas_equalTo(CGSizeMake([TOPDocumentHelper top_getSizeWithStr:model.number Height:15 Font:13].width+10, 13));
    }];
}
- (void)top_showSelectBtn{
    _choseBtn.hidden = NO;
}
- (void)top_hideCircleView{
    _circleView.hidden = YES;
    _circleBtn.hidden = YES;
}
- (void)top_showCircleView{
    _circleView.hidden = NO;
    _circleBtn.hidden = NO;
}
- (void)top_selectAction:(UIButton*)btn{
    btn.selected = !btn.selected;
    if (self.top_ChoseBtnBlock) {
        self.top_ChoseBtnBlock(btn.selected);
    }
}
- (void)top_clickCircleBtn{
    if (self.top_circleBtnBlock) {
        self.top_circleBtnBlock();
    }
}
@end
