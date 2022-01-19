#import "TopDirveSelectItemTabCell.h"

@implementation TopDirveSelectItemTabCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _selectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_scamerbatch_AllNormal"]];

        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1)];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.numberOfLines = 2;
   
        UILabel *lineLabel = [UILabel new];
        lineLabel.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:UIColorFromRGB(0xF0F0F0)];

        [self.contentView addSubview:_selectImageView];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:lineLabel];
        
        [_selectImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset((15));
            make.top.equalTo(self.contentView).offset(15);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_selectImageView.mas_trailing).offset((15));
            make.trailing.equalTo(self.contentView).offset(-15);
            make.top.equalTo(self.contentView).offset(5);
            make.bottom.equalTo(self.contentView).offset(-5);
        }];
        [lineLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}

@end
