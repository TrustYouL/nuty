#import "TOPPdfSizeCell.h"
@interface TOPPdfSizeCell()
@property (nonatomic,strong)UIView * backView;
@property (nonatomic,strong)UILabel * titleLab;
@property (nonatomic,strong)UILabel * sizeLab;
@end
@implementation TOPPdfSizeCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        
        _backView = [UIView new];
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:17];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = TOPAPPGreenColor;
        
        _sizeLab = [UILabel new];
        _sizeLab.font = [UIFont systemFontOfSize:13];
        _sizeLab.textAlignment = NSTextAlignmentCenter;
        _sizeLab.textColor = TOPAPPGreenColor;
       
        [self.contentView addSubview:_backView];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_sizeLab];
        [self top_setUI];
    }
    return self;
}

- (void)top_setUI{
    UIView * contentView = self.contentView;
    [_backView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView).insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(5);
        make.trailing.equalTo(contentView).offset(-5);
        make.top.equalTo(contentView).offset(10);
        make.height.mas_equalTo(20);
    }];
    [_sizeLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(5);
        make.trailing.equalTo(contentView).offset(-5);
        make.top.equalTo(_titleLab.mas_bottom).offset(5);
        make.height.mas_equalTo(10);
    }];
}

- (void)setModel:(TOPPdfSizeModel *)model{
    _model = model;
    if (!_model.cellState) {
        _backView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        _backView.layer.cornerRadius = 5;
        _backView.layer.borderColor = TOPAPPGreenColor.CGColor;
        _backView.layer.borderWidth = 0.5;
    }else{
        _backView.backgroundColor = RGBA(36, 196, 164, 0.2);
        _backView.layer.cornerRadius = 5;
        _backView.layer.borderColor = [UIColor clearColor].CGColor;
        _backView.layer.borderWidth = 0;
    }
    
    _titleLab.text = _model.pdfSizeTitle;
    _sizeLab.text = [NSString stringWithFormat:@"%.1fx%.1fcm",_model.pdfSizeW,_model.pdfSizeH];
}
@end
