#import "TOPTagsListCell.h"

@implementation TOPTagsListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];

        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(120, 120, 120, 1.0)];
        _titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
        
        _numLab = [UILabel new];
        _numLab.font = [UIFont systemFontOfSize:14];
        _numLab.textAlignment = NSTextAlignmentCenter;
        _numLab.textColor = RGBA(153, 153, 153, 1.0);
        _numLab.layer.masksToBounds = YES;
        _numLab.layer.cornerRadius = 1;
        _numLab.layer.borderColor = RGBA(153, 153, 153, 1.0).CGColor;
        _numLab.layer.borderWidth = 1;
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:TOPAppBackgroundColor];
       
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_numLab];
        [self.contentView addSubview:_lineView];

    }
    return self;
}

- (void)setModel:(TOPTagsListModel *)model{
    _model = model;
    CGFloat numW = [TOPDocumentHelper top_getSizeWithStr:model.tagNum Height:18 Font:14].width+10;
    if (numW>40) {
        numW = 40;
    }
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(10);
        make.trailing.equalTo(self.contentView).offset(-55);
        make.bottom.top.equalTo(self.contentView);
    }];
    [_numLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-10);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(numW, 15));
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(1.0);
    }];
    
    NSString * tagsName = model.tagName;
    if ([tagsName isEqualToString:TOP_TRTagsAllDocesKey]) {
        tagsName = TOP_TRTagsAllDocesName;
    }else if([tagsName isEqualToString:TOP_TRTagsUngroupedKey]){
        tagsName = TOP_TRTagsUngroupedName;
    }
    
    NSString * saveTag = [TOPScanerShare top_saveTagsName];
    _titleLab.text = tagsName;
    _numLab.text = model.tagNum;
    
    if ([model.tagName isEqualToString:saveTag]) {
        _titleLab.textColor = TOPAPPGreenColor;
    }else{
        _titleLab.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(120, 120, 120, 1.0)];
    }
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
