#import "TOPTagsManagerCell.h"

@implementation TOPTagsManagerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _titleLab = [UILabel new];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        _titleLab.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTap)];
        [_titleLab addGestureRecognizer:tap];
        
        _numLab = [UILabel new];
        _numLab.font = [UIFont systemFontOfSize:14];
        _numLab.textAlignment = NSTextAlignmentCenter;
        _numLab.textColor = RGBA(153, 153, 153, 1.0);
        _numLab.layer.masksToBounds = YES;
        _numLab.layer.cornerRadius = 1;
        _numLab.layer.borderColor = RGBA(153, 153, 153, 1.0).CGColor;
        _numLab.layer.borderWidth = 1;
        _numLab.alpha = 1;
        
        _editBtn = [UIButton new];
        [_editBtn setImage:[UIImage imageNamed:@"top_tagsRename"] forState:UIControlStateNormal];
        [_editBtn addTarget:self action:@selector(top_clickEditBtn) forControlEvents:UIControlEventTouchUpInside];
        _editBtn.hidden = YES;
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:TOPAppBackgroundColor];

        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_numLab];
        [self.contentView addSubview:_editBtn];
        [self.contentView addSubview:_lineView];
    }
    return self;
}

- (void)setModel:(TOPTagsManagerModel *)model{
    _model = model;
    NSString * tagsName = _model.tagsListModel.tagName;
    if ([tagsName isEqualToString:TOP_TRTagsAllDocesKey]) {
        tagsName = TOP_TRTagsAllDocesName;
    }else if([tagsName isEqualToString:TOP_TRTagsUngroupedKey]){
        tagsName = TOP_TRTagsUngroupedName;
    }
    _titleLab.text = tagsName;
    _numLab.text = _model.tagsListModel.tagNum;
    [self top_isNotEditFream];
}
#pragma mark --正常状态的fream
- (void)top_isNotEditFream{
    CGFloat numW = [TOPDocumentHelper top_getSizeWithStr:_model.tagsListModel.tagNum Height:18 Font:14].width+10;
    if (numW>60) {
        numW = 60;
    }
    
    UIView * contentView = self.contentView;
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.leading.equalTo(contentView).offset(15);
        make.trailing.equalTo(contentView).offset(-60);
        make.height.mas_equalTo(50);
    }];
    [_numLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-15);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(numW, 15));
    }];
    [_editBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-10);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
    if (_model.isEdit) {
        _numLab.hidden = YES;
        _editBtn.hidden = NO;
    }else{
        _numLab.hidden = NO;
        _editBtn.hidden = YES;
    }
}

- (void)top_clickEditBtn{
    if (self.top_clickToEdit) {
        self.top_clickToEdit(_model);
    }
}

- (void)top_clickTap{
    if (_model.isEdit) {
        if (self.top_clickToEdit) {
            self.top_clickToEdit(_model);
        }
    }else{
        if (self.top_clickToBack) {
            self.top_clickToBack(_model);
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
