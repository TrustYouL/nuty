#define CornerRadius 10

#import "TOPShareTypeCell.h"
@implementation TOPShareTypeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        
        _backViewF = [UIView new];
        _backViewF.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _backViewF.layer.cornerRadius = CornerRadius;
        _backViewF.layer.masksToBounds = YES;
        
        _backViewS = [UIView new];
        _backViewS.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _backViewT = [UIView new];
        _backViewT.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _img = [UIImageView new];
        _iconImg = [UIImageView new];

        _titleLab = [UILabel new];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titleLab.font = [UIFont boldSystemFontOfSize:15];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        
        _numberLab = [UILabel new];
        _numberLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(120, 120, 120, 1.0)];
        _numberLab.font = [UIFont systemFontOfSize:13];
        if (isRTL()) {
            _numberLab.textAlignment = NSTextAlignmentLeft;
        }else{
            _numberLab.textAlignment = NSTextAlignmentRight;
        }
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(235, 235, 235, 1.0)];
        _lineView.hidden = YES;

        [self.contentView addSubview:_backViewF];
        [self.contentView addSubview:_backViewS];
        [self.contentView addSubview:_backViewT];
        [self.contentView addSubview:_img];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_numberLab];
        [self.contentView addSubview:_lineView];
        [self.contentView addSubview:_iconImg];

        [self top_creatDefaultUI];
    }
    return self;
}

- (void)top_creatDefaultUI{
    UIView * contentView = self.contentView;
    [_backViewF mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(contentView);
    }];
    [_backViewS mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(contentView);
        make.top.equalTo(contentView).offset(CornerRadius/2+5);
    }];
    [_backViewT mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(contentView);
        make.bottom.equalTo(contentView).offset(-(CornerRadius/2+5));
    }];
}

- (void)top_createShareUI{
    UIView * contentView = self.contentView;
    [_img mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(20);
        make.centerY.equalTo(contentView);
//        make.size.mas_equalTo(CGSizeMake(24, 21));
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_img.mas_trailing).offset(10);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(250, 20));
    }];
    [_numberLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-40);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_img.mas_trailing).offset(10);
        make.trailing.equalTo(contentView).offset(-10);
        make.bottom.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
    
    _numberLab.hidden = YES;
    _img.image = [UIImage imageNamed:_picArray[_row]];
    _titleLab.text = _titleArray[_row];
    
    if (_row == 0|| _row == 1) {
        _numberLab.hidden = NO;
    }else{
        _numberLab.hidden = YES;
    }
}

- (void)top_createSortUI{
    UIView * contentView = self.contentView;
    [_img mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView);
        make.trailing.equalTo(contentView);
        make.bottom.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
    [_iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-15);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_img.mas_trailing).offset(10);
        make.trailing.equalTo(_iconImg.mas_leading).offset(-10);
        make.centerY.equalTo(contentView);
        make.height.mas_equalTo(20);
    }];
    _titleLab.font = [UIFont systemFontOfSize:16];
    _titleLab.text = _titleArray[_row];
    _iconImg.image = [UIImage imageNamed:@"top_settingSelect"];
    
    NSArray * sortArray = [self top_fileOrderTypeArray];
    NSInteger sortType = [sortArray[_row] integerValue];
    if (_popType == TOPPopUpBounceViewTypeSort) {
        if (sortType == [TOPScanerShare top_sortType]) {
            _titleLab.textColor = TOPAPPGreenColor;
            _img.image = [UIImage imageNamed:_selectArray[_row]];
            _iconImg.hidden = NO;
        }else{
            _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
            _img.image = [UIImage imageNamed:_picArray[_row]];
            _iconImg.hidden = YES;
        }
    }
    if (_popType == TOPPopUpBounceViewTypeTagSort) {
        if (sortType == [TOPScanerShare top_sortTagsType]) {
            _titleLab.textColor = TOPAPPGreenColor;
            _img.image = [UIImage imageNamed:_selectArray[_row]];
            _iconImg.hidden = NO;
        }else{
            _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
            _img.image = [UIImage imageNamed:_picArray[_row]];
            _iconImg.hidden = YES;
        }
    }
}

- (void)setShowSectionHeader:(BOOL)showSectionHeader{
    _showSectionHeader = showSectionHeader;
}
- (void)setRow:(NSInteger)row{
    _row = row;
    if (_row == 0) {
        _backViewS.hidden = NO;
        if (_showSectionHeader) {
            _backViewT.hidden = NO;
        }else{
            _backViewT.hidden = YES;
        }
    }else if(_row == _titleArray.count-1){
        _backViewS.hidden = YES;
        _backViewT.hidden = NO;
    }else{
        _backViewS.hidden = NO;
        _backViewT.hidden = NO;
    }
}
- (void)setTitleArray:(NSMutableArray *)titleArray{
    _titleArray = titleArray;
}

- (void)setPicArray:(NSMutableArray *)picArray{
    _picArray = picArray;
}
- (void)setSelectArray:(NSMutableArray *)selectArray{
    _selectArray = selectArray;
}
- (void)setPopType:(TOPPopUpBounceViewType)popType{
    _popType = popType;
    if (_popType == TOPPopUpBounceViewTypeShare) {
        [self top_createShareUI];
    }
    
    if (_popType == TOPPopUpBounceViewTypeSort||_popType == TOPPopUpBounceViewTypeTagSort ) {
        [self top_createSortUI];
    }
}

- (NSArray *)top_fileOrderTypeArray{
    NSArray * tempArray = @[@(FolderDocumentCreateDescending),@(FolderDocumentCreateAscending),@(FolderDocumentUpdateDescending),@(FolderDocumentUpdateAscending),@(FolderDocumentFileNameAToZ),@(FolderDocumentFileNameZToA)];
    return tempArray;
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
