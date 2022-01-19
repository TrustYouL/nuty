
#import "TOPUnlockFunctionCollectionViewCell.h"

@implementation TOPUnlockFunctionCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:UIColorFromRGB(0xf2f2f7)];
        _coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box"]];
        [self.contentView addSubview:_coverImageView];
        
        [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.centerX.equalTo(self.contentView);
            make.height.mas_offset(85);
            make.width.mas_offset(85);

        }];
        self.coverImageView.layer.shadowOffset = CGSizeMake(0, 1);
        self.coverImageView.layer.shadowColor = RGBA(9, 103, 103, 0.13).CGColor ;
        self.coverImageView.layer.shadowOpacity = 1;
        self.coverImageView.layer.shadowRadius = 3;
        self.coverImageView.clipsToBounds =NO;
        
        self.driveNameLabel = [[UILabel alloc ]init];
        self.driveNameLabel.font = PingFang_M_FONT_(11);
        self.driveNameLabel.numberOfLines = 0;
        self.driveNameLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
        self.driveNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.driveNameLabel];
        [_driveNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(5);
            make.trailing.equalTo(self.contentView).offset(-5);
            make.top.equalTo(_coverImageView.mas_bottom).offset(5);
            make.bottom.mas_lessThanOrEqualTo(self.contentView).offset(-5);

        }];
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
