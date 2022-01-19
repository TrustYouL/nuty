

#import "TOPUnlockFuntionTableViewCell.h"

@implementation TOPUnlockFuntionTableViewCell

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
        bgView.layer.cornerRadius = 10;
        bgView.clipsToBounds = YES;
        
        _coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_unlock_unlimitedFolder"]];
        [self.contentView addSubview:_coverImageView];
        
        [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.leading.equalTo(self.contentView).offset(30);
            make.height.mas_offset(65);
            make.width.mas_offset(65);
        }];

        _topTitleLabel = [[UILabel alloc] init];
        _topTitleLabel.font = PingFang_R_FONT_(15);
        _topTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];

        [self.contentView addSubview:_topTitleLabel];
        [_topTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_lessThanOrEqualTo(self.contentView).offset(-30);
            make.leading.equalTo(self.coverImageView.mas_trailing).offset(5);

        }];
  
        _itemTitleLabel = [[UILabel alloc] init];
        _itemTitleLabel.numberOfLines = 0;
        [self.contentView addSubview:_itemTitleLabel];
        [_itemTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topTitleLabel.mas_bottom).offset(5);
            make.leading.equalTo(self.coverImageView.mas_trailing).offset(5);
            make.trailing.mas_lessThanOrEqualTo(self.contentView).offset(-20);

        }];
        _itemTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x333333)];
        _itemTitleLabel.font = PingFang_R_FONT_(11);
        _itemTitleLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
- (void)setDictData:(NSDictionary *)dictData
{
    _dictData = dictData;
    self.coverImageView.image = [UIImage imageNamed:dictData[@"rowIcon"]];
    NSString *rowNameStr = dictData[@"rowName"];
    float titleHeight = [dictData[@"titleHeight"] floatValue];
    
    float titleDetailHeight = [dictData[@"titleDetailHeight"] floatValue];
    float CellHeight = [dictData[@"CellHeight"] floatValue];
    float topmas_float = (CellHeight -titleDetailHeight-titleHeight-5)/2;
    
    [_topTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(topmas_float);
    }];
    [_itemTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topTitleLabel.mas_bottom).offset(5);

    }];
    self.topTitleLabel.text = rowNameStr;
    self.itemTitleLabel.text = dictData[@"rowDetail"];

}

@end
