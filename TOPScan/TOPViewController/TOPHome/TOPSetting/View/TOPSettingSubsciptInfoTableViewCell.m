#import "TOPSettingSubsciptInfoTableViewCell.h"
#import "TOPSubscriptModel.h"

@implementation TOPSettingSubsciptInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        self.bgView = [[UIView alloc] init];
        self.bgView.backgroundColor = [UIColor whiteColor];
        self.bgView.layer.cornerRadius = 20;
        [self.contentView addSubview:self.bgView];
        self.bgView.layer.shadowOffset = CGSizeMake(0, 1);
        self.bgView.layer.shadowColor = RGBA(38, 38, 38, 0.16).CGColor ;
        self.bgView.layer.shadowOpacity = 1;
        self.bgView.layer.shadowRadius = 3;
        self.bgView.clipsToBounds =NO;
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.leading.equalTo(self.contentView).offset(34);
            make.trailing.equalTo(self.contentView).offset(-34);
            make.bottom.equalTo(self.contentView);
        }];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_member_bg_image"]];
        [self.bgView addSubview:bgImageView];
        bgImageView.clipsToBounds = YES;
        bgImageView.layer.cornerRadius = 20;
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgView);
            make.leading.equalTo(self.bgView);
            make.trailing.equalTo(self.bgView);
            make.bottom.equalTo(self.bgView);
        }];
        
        self.rowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_member_icon_cover"]];
        [self.bgView addSubview:self.rowImg];
        [self.rowImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bgView);
            make.leading.equalTo(self.bgView).offset(26);
            make.height.mas_offset(73);
            make.width.mas_offset(78);
        }];
        UILabel *subscriptTitleLabel = [UILabel new];
        subscriptTitleLabel.font = PingFang_R_FONT_(12);
        subscriptTitleLabel.textColor = UIColorFromRGB(0x444444);
        subscriptTitleLabel.textAlignment = NSTextAlignmentNatural;
        subscriptTitleLabel.text = [NSLocalizedString(@"topscan_subsctiptplan", @"") stringByAppendingString:@":"];
        [self.bgView addSubview:subscriptTitleLabel];
        [subscriptTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgView).offset(15);
            make.leading.equalTo(self.rowImg.mas_trailing).offset(26);
            make.trailing.equalTo(self.bgView).offset(-15);
        }];
        
        TOPSubscriptModel *subModel = [TOPSubscriptTools getSubScriptData];
        self.subscriptionPlanContentLab = [[UILabel alloc] init];
        self.subscriptionPlanContentLab.font = PingFang_M_FONT_(12);
        self.subscriptionPlanContentLab.textColor = TOPAPPGreenColor;

        [self.bgView addSubview:self.subscriptionPlanContentLab];
        if (subModel.priceTitle.length<=0) {
            if ([subModel.purchaseKey isEqualToString:InAppProductIdSubscriptionMonth]) {
                self.subscriptionPlanContentLab.text =@"1 Month Premium";
            }else  if ([subModel.purchaseKey isEqualToString:InAppProductIdSubscriptionYear]) {
                self.subscriptionPlanContentLab.text =@"1 Year Premium";
            }
        }else{
            self.subscriptionPlanContentLab.text = subModel.priceTitle;
        }
        [self.subscriptionPlanContentLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(subscriptTitleLabel.mas_bottom).offset(3);
            make.leading.equalTo(subscriptTitleLabel);
            make.trailing.mas_lessThanOrEqualTo(self.bgView).offset(-15);
        }];
        
        UILabel *renewedTitleLabel = [UILabel new];
        renewedTitleLabel.font = PingFang_R_FONT_(12);
        renewedTitleLabel.textColor = UIColorFromRGB(0x444444);
        renewedTitleLabel.textAlignment = NSTextAlignmentNatural;
        renewedTitleLabel.text = [NSLocalizedString(@"topscan_renewedday", @"") stringByAppendingString:@":"];
        [self.bgView addSubview:renewedTitleLabel];
        [renewedTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.subscriptionPlanContentLab.mas_bottom).offset(14);
            make.leading.equalTo(subscriptTitleLabel);
            make.trailing.equalTo(self.bgView).offset(-15);
        }];
        
        self.renewedDayContentLab = [[UILabel alloc] init];
        self.renewedDayContentLab.font = PingFang_M_FONT_(12);
        self.renewedDayContentLab.textColor = TOPAPPGreenColor;
        self.renewedDayContentLab.textAlignment = NSTextAlignmentNatural;
        self.renewedDayContentLab.text = [self top_getRenewedDateWithInterval:subModel.subscriptEndTime];
        [self.bgView addSubview:self.renewedDayContentLab];
        [self.renewedDayContentLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(renewedTitleLabel.mas_bottom).offset(3);
            make.leading.equalTo(renewedTitleLabel);
            make.trailing.mas_lessThanOrEqualTo(self.bgView).offset(-15);
        }];
        
        UILabel *automaticRenewalTitleLabel = [UILabel new];
        automaticRenewalTitleLabel.font = PingFang_R_FONT_(12);
        automaticRenewalTitleLabel.textColor = UIColorFromRGB(0x444444);
        automaticRenewalTitleLabel.textAlignment = NSTextAlignmentNatural;
        automaticRenewalTitleLabel.text = [NSLocalizedString(@"topscan_automaticrenewal", @"") stringByAppendingString:@":"];
        [self.bgView addSubview:automaticRenewalTitleLabel];
        [automaticRenewalTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.renewedDayContentLab.mas_bottom).offset(14);
            make.leading.equalTo(subscriptTitleLabel);
            make.trailing.equalTo(self.bgView).offset(-15);
        }];
        
        self.automaticRenewalConetentLab = [[UILabel alloc] init];
        self.automaticRenewalConetentLab.font = PingFang_M_FONT_(12);
        self.automaticRenewalConetentLab.textAlignment = NSTextAlignmentNatural;
        self.automaticRenewalConetentLab.textColor = TOPAPPGreenColor;
        if (subModel.auto_renew_status == 1) {
            self.automaticRenewalConetentLab.text = [NSLocalizedString(@"topscan_cameralighton", @"") uppercaseString];
        }else{
            self.automaticRenewalConetentLab.text = [NSLocalizedString(@"topscan_cameralightoff", @"") uppercaseString];;
        }
        [self.bgView addSubview:self.automaticRenewalConetentLab];
        [self.automaticRenewalConetentLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(automaticRenewalTitleLabel.mas_bottom).offset(3);
            make.leading.equalTo(automaticRenewalTitleLabel);
            make.trailing.mas_lessThanOrEqualTo(self.bgView).offset(-15);
        }];
        
        
        TOPImageTitleButton *btn = [[TOPImageTitleButton alloc] init];
        UIImage *btnImg = [UIImage new];
        if (isRTL()) {
            btn.style =EImageLeftTitleRight;
            btnImg = [UIImage imageNamed:@"top_rever_detail_arowwpr"];
        }else{
            btn.style = ETitleLeftImageRight;
            btnImg = [UIImage imageNamed:@"top_member_detail_arowwpr"];
        }
        [self.bgView addSubview:btn];

        [btn setImage:btnImg forState:UIControlStateNormal];
        [btn setTitle:NSLocalizedString(@"topscan_moredetails", @"") forState:UIControlStateNormal];
        btn.titleLabel.font = PingFang_R_FONT_(10);
        [btn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(purSubscriptMoreDetails:) forControlEvents:UIControlEventTouchUpInside];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_bgView).offset(0);
            make.height.mas_offset(30);
            make.width.mas_offset(75);
            make.trailing.equalTo(self.bgView).offset(-20);
        }];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
}
- (void)setSubscriptInfoModel:(TOPSubscriptModel *)subscriptInfoModel
{
    _subscriptInfoModel = subscriptInfoModel;
    
    if (subscriptInfoModel.auto_renew_status) {
        self.automaticRenewalConetentLab.text = [NSLocalizedString(@"topscan_cameralighton", @"") uppercaseString];
    }else{
        self.automaticRenewalConetentLab.text =  [NSLocalizedString(@"topscan_cameralightoff", @"") uppercaseString];
    }
    self.renewedDayContentLab.text = [self top_getRenewedDateWithInterval:subscriptInfoModel.subscriptEndTime];
    
}

- (NSString *)top_getRenewedDateWithInterval:(double)interval
{
 
    NSDate *creatDate = [NSDate dateWithTimeIntervalSince1970:interval/1000];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:[TOPScanerShare top_documentDateType]];
    
    NSString *strDate = [dateFormatter stringFromDate:creatDate];
    
    return strDate;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)purSubscriptMoreDetails:(UIButton *)sender
{
    if (self.top_clickMoreDetailBlock) {
        self.top_clickMoreDetailBlock();
    }
}

@end
