#import "TOPShareCancelCell.h"

@implementation TOPShareCancelCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:18];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:TOPAPPGreenColor];
      
        [self.contentView addSubview:_titleLab];
        [self top_createUI];
    }
    return self;
}

- (void)top_createUI{
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(120, 20));
    }];
    
    _titleLab.text = NSLocalizedString(@"topscan_cancel", @"");
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
