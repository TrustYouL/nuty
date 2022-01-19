

#import "TOPPurchaseCreditsTableViewCell.h"
#import "TOPPurchasepayModel.h"
@implementation TOPPurchaseCreditsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
        UIView *bgView = [UIView new];
        
        [self.contentView addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.leading.equalTo(self.contentView).offset(15);
            make.trailing.equalTo(self.contentView).offset(-15);
            make.bottom.equalTo(self.contentView);
        }];
        bgView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        bgView.layer.cornerRadius = 50/2;
        bgView.clipsToBounds = YES;
        
        UILabel *typeLabel  = [[UILabel alloc] init];
        [bgView addSubview:typeLabel];
        typeLabel.font = PingFang_M_FONT_(18);
        typeLabel.text = @"OCR";
        typeLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];;
        [typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bgView);
            make.leading.equalTo(bgView).offset(20);
            make.width.mas_offset(50);
        }];
   
  
        _priceTitleLabel = [[UILabel alloc] init];
        [bgView addSubview:_priceTitleLabel];
        [_priceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bgView);
            make.trailing.equalTo(bgView.mas_trailing).offset(-40);

        }];
        _priceTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x333333)];
        _priceTitleLabel.font = PingFang_R_FONT_(16);
        _priceTitleLabel.backgroundColor = [UIColor clearColor];
        if (isRTL()) {
            _priceTitleLabel.textAlignment = NSTextAlignmentLeft;
        }else{
            _priceTitleLabel.textAlignment = NSTextAlignmentRight;
        }
        _creditsPageTitleLabel = [[UILabel alloc] init];
        _creditsPageTitleLabel.textAlignment = NSTextAlignmentNatural;
        _creditsPageTitleLabel.font = PingFang_R_FONT_(16);
        _creditsPageTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];;

        [bgView addSubview:_creditsPageTitleLabel];
        [_creditsPageTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(typeLabel.mas_trailing).offset(15);
            make.centerY.equalTo(bgView);
            make.trailing.mas_lessThanOrEqualTo(self.priceTitleLabel.mas_leading).offset(-15);

        }];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDictDataModel:(TOPPurchasepayModel *)dictDataModel
{
    _dictDataModel = dictDataModel;
    self.creditsPageTitleLabel.text = dictDataModel.productSubTitle;
    self.priceTitleLabel.text =  dictDataModel.productTitle;
}

@end
