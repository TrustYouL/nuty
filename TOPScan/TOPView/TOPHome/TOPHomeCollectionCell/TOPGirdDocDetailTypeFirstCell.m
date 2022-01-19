#import "TOPGirdDocDetailTypeFirstCell.h"
#import "TOPDataModelHandler.h"
#import "UIImageView+AsyncCover.h"
@implementation TOPGirdDocDetailTypeFirstCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =[UIColor whiteColor];
        
        _selectStateImg = [UIImageView new];
        _selectStateImg.image = [UIImage imageNamed:@"top_selectState"];
        
        _choseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _choseBtn.hidden = YES;
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllNormal"] forState:UIControlStateNormal];
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllSelect"] forState:UIControlStateSelected];
        [_choseBtn addTarget:self action:@selector(top_selectAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [self boldFontsWithSize:14];
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.font = [self fontsWithSize:10];
        
        _numLabel = [[UILabel alloc] init];
        _numLabel.textColor = [UIColor whiteColor];
        _numLabel.layer.cornerRadius = 2;
        _numLabel.font = [self fontsWithSize:10];
        if (isRTL()) {
            _numLabel.textAlignment = NSTextAlignmentNatural;

        }else{
            _numLabel.textAlignment = NSTextAlignmentRight;
        }
        _coverView = [UIView new];
        _coverView.backgroundColor = RGBA(0, 0, 0, 0.4);
        
        _showBackBtn = [UIButton new];
        _showBackBtn.backgroundColor = [UIColor clearColor];
        [_showBackBtn addTarget:self action:@selector(top_clickShowBackBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        _textView = [UITextView new];
        _textView.textColor = [UIColor whiteColor];
        _textView.font = [UIFont systemFontOfSize:13];
        _textView.textAlignment = NSTextAlignmentNatural;
        _textView.editable = NO;
        _textView.selectable = NO;
        _textView.scrollEnabled = NO;
        _textView.backgroundColor = RGBA(104, 153, 228, 1.0);

        _noteBtn = [UIButton new];
        [_noteBtn setImage:[UIImage imageNamed:@"top_nextnote"] forState:UIControlStateNormal];
        [_noteBtn setImage:[UIImage imageNamed:@"top_nextnote"] forState:UIControlStateSelected];
        [_noteBtn addTarget:self action:@selector(top_clickNoteBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        _ocrBtn = [UIButton new];
        [_ocrBtn setImage:[UIImage imageNamed:@"top_nextocr"] forState:UIControlStateNormal];
        [_ocrBtn addTarget:self action:@selector(top_clickOCRBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.imgV];
        [self.contentView addSubview:_coverView];
        [self.contentView addSubview:_choseBtn];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_selectStateImg];
        [self.contentView addSubview:_dateLabel];
        [self.contentView addSubview:_numLabel];
        [self.contentView addSubview:_showBackBtn];
        [self.contentView addSubview:_noteBtn];
        [self.contentView addSubview:_ocrBtn];
        [self.contentView addSubview:_textView];
        [self top_createUI];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clickTap:)];
        [_textView addGestureRecognizer:tap];
    }
    return self;
}
- (void)top_clickShowBackBtn:(UIButton *)sender{
    if (self.top_clickToJump) {
        self.top_clickToJump();
    }
}

- (void)top_clickTap:(UIGestureRecognizer *)ges{
    if (self.top_clickToJump) {
        self.top_clickToJump();
    }
}

- (void)top_clickNoteBtn:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        _textView.hidden = NO;
        _showBackBtn.hidden = NO;
    }else{
        _textView.hidden = YES;
        _showBackBtn.hidden = YES;
    }
}

- (void)top_clickOCRBtn:(UIButton *)sender{
    if (self.top_clickOCRToJump) {
        self.top_clickOCRToJump();
    }
}

- (void)top_createUI{
    UIView * contentView = self.contentView;

    [_imgV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView);
    }];
    [_choseBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    CGFloat coverH = 0;
    CGFloat titleBottomH = 0;
    if ([TOPScanerShare top_childHideDetailType] == 1) {
        coverH = 45;
        titleBottomH = 24;
        _dateLabel.hidden = NO;
        _numLabel.hidden = NO;
    }else{
        coverH = 25;
        titleBottomH = 5;
        _dateLabel.hidden = YES;
        _numLabel.hidden = YES;
    }
    [_coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(contentView);
        make.height.mas_equalTo(coverH);
    }];
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-5);
        make.top.equalTo(_titleLabel.mas_bottom).offset(0);
        make.bottom.equalTo(_dateLabel.mas_bottom).offset(0);
        make.width.greaterThanOrEqualTo(@30).priority(500);
    }];
    [_dateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(5);
        make.trailing.equalTo(_numLabel.mas_leading).offset(-5).priority(1000);
        make.bottom.equalTo(contentView).offset(0);
        make.top.equalTo(_titleLabel.mas_bottom).offset(0);
    }];
    [_selectStateImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-5);
        make.centerY.equalTo(_titleLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
    [_showBackBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView);
    }];
    CGFloat titleRight = 0;
    if (_selectStateImg.hidden) {
        titleRight = 5;
    }else{
        titleRight = 25;
    }
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(5);
        make.trailing.equalTo(contentView).offset(-titleRight);
        make.bottom.equalTo(contentView).offset(-titleBottomH);
    }];
    CGFloat ocrRight = 0;
    if (_model.note.length>0) {
        ocrRight = 30;
    }else{
        ocrRight = 5;
    }
    
    [_noteBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView);
        make.top.equalTo(contentView).offset(3);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [_ocrBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(contentView).offset(-ocrRight);
        make.top.equalTo(contentView).offset(3);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [_textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView).insets(UIEdgeInsetsMake(45, 0, 0, 0));
    }];
}

- (void)top_showSelectBtn{
    _choseBtn.hidden = NO;
    _noteBtn.hidden = YES;
    _ocrBtn.hidden = YES;
    _textView.hidden = YES;
    _showBackBtn.hidden = YES;
}
- (void)setMarkCellId:(NSString *)markCellId{
    _markCellId = markCellId;
    if ([markCellId isEqualToString:_model.docId]) {
        _selectStateImg.hidden = NO;
    }else{
        _selectStateImg.hidden = YES;
    }
}
- (void)setModel:(DocumentModel *)model{
    _model = model;
    _textView.hidden = YES;
    _textView.text = _model.note;
    _ocrTV.hidden = YES;
    _showBackBtn.hidden = YES;
    _noteBtn.selected = NO;
    _choseBtn.hidden = ![TOPScanerShare shared].isEditing;
    _titleLabel.text = model.name;
    _numLabel.text = model.number;
    _choseBtn.selected = model.selectStatus;
    _dateLabel.text = model.createDate;
    
    [self.imgV setCoverImageWithPath:model.imagePath coverPath:model.coverImagePath];
    
    if ([TOPScanerShare shared].isEditing) {
        [self top_isEditingToHide];
    }else{
        if ([TOPWHCFileManager top_isExistsAtPath:_model.notePath]) {
            _noteBtn.hidden = NO;
        }else{
            _noteBtn.hidden = YES;
        }
        
        if ([TOPWHCFileManager top_isExistsAtPath:_model.ocrPath]) {
            _ocrBtn.hidden = NO;
        }else{
            _ocrBtn.hidden = YES;
        }
        [self top_createUI];
    }
}

- (void)top_isEditingToHide{
    _noteBtn.hidden = YES;
    _ocrBtn.hidden = YES;
    _textView.hidden = YES;
    _noteBtn.selected = NO;
}

- (void)setModel:(DocumentModel * _Nonnull)model  index:(NSString*)index{

}
- (UIImageView *)currentImageView{
    return self.imgV;
}

- (void)top_selectAction:(UIButton*)btn{
    btn.selected = !btn.selected;
    if (self.top_ChoseBtnBlock) {
          self.top_ChoseBtnBlock(btn.selected);
      }
    
}
- (UIImageView *)imgV {
    if (!_imgV) {
        _imgV = [[UIImageView alloc] init];
        _imgV.contentMode = UIViewContentModeScaleAspectFill;
        _imgV.clipsToBounds = YES;
    }
    return _imgV;
}

@end
