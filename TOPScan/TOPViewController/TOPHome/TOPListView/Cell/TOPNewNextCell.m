#define Cell_W (TOPScreenWidth - (15+15+10*3))/4

#import "TOPNewNextCell.h"
#import "UIImageView+AsyncCover.h"
#import "UIColor+DarkMode.h"
#import "TOPShowImg.h"
@interface TOPNewNextCell()
@property (nonatomic ,strong) UILabel * titleLabel;
@property (nonatomic ,strong) UILabel * dateLabel;
@property (nonatomic ,strong) UILabel * numLabel;
@property (nonatomic ,strong) UILabel * tagLab;
@property (nonatomic ,strong) UIImageView * tagImg;
@property (nonatomic ,strong) UIView * lineView;
@property (nonatomic ,strong) UIButton * moveBtn;
@property (nonatomic ,assign) BOOL moveFlag;
@property (nonatomic, strong)UIImageView  *collectionImg;
@property (nonatomic, assign)CGFloat leftW;
@property (nonatomic ,strong) TOPShowImg * showImg1;
@property (nonatomic ,strong) TOPShowImg * showImg2;
@property (nonatomic ,strong) TOPShowImg * showImg3;
@property (nonatomic ,strong) TOPShowImg * showImg4;
@end
@implementation TOPNewNextCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
        _titleLabel.font = [self fontsWithSize:15];
        _titleLabel.textAlignment = NSTextAlignmentNatural;
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = RGBA(153, 153, 153, 1.0);
        _dateLabel.font = [self fontsWithSize:12];
        
        _numLabel = [[UILabel alloc] init];
        _numLabel.textColor = UIColor.grayColor;
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.font = [self fontsWithSize:13];
        _numLabel.layer.masksToBounds = YES;
        _numLabel.layer.cornerRadius = 2;
        _numLabel.layer.borderColor = RGBA(153, 153, 153, 1.0).CGColor;
        _numLabel.layer.borderWidth = 0.5;
        
        _tagImg = [UIImageView new];
        _tagImg.image = [UIImage imageNamed:@"top_biaoqian"];
        
        _collectionImg = [UIImageView new];
        _collectionImg.image = [UIImage imageNamed:@"top_collectionicon"];
        _collectionImg.hidden = YES;
        
        _tagLab = [[UILabel alloc] init];
        _tagLab.textColor = UIColor.grayColor;
        _tagLab.hidden = NO;
        _tagLab.textAlignment = NSTextAlignmentNatural;
        _tagLab.font = [self fontsWithSize:13];
        
        _choseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _choseBtn.hidden = YES;
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllNormal"] forState:UIControlStateNormal];
        [_choseBtn setImage:[UIImage imageNamed:@"top_scamerbatch_AllSelect"] forState:UIControlStateSelected];
        [_choseBtn addTarget:self action:@selector(top_selectAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _showImg1 = [TOPShowImg new];
        _showImg2 = [TOPShowImg new];
        _showImg3 = [TOPShowImg new];
        _showImg4 = [TOPShowImg new];

        NSString * imgName = [NSString new];
        if (isRTL()) {
            imgName = @"top_rtlnectmove";
        }else{
            imgName = @"top_nectmove";
        }
        _moveBtn = [UIButton new];
        _moveBtn.hidden = YES;
        [_moveBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        [_moveBtn addTarget:self action:@selector(moveAction) forControlEvents:UIControlEventTouchUpInside];
                
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_dateLabel];
        [self.contentView addSubview:_numLabel];
        [self.contentView addSubview:_tagImg];
        [self.contentView addSubview:_tagLab];
        [self.contentView addSubview:_choseBtn];
        [self.contentView addSubview:_showImg1];
        [self.contentView addSubview:_showImg2];
        [self.contentView addSubview:_showImg3];
        [self.contentView addSubview:_showImg4];
        [self.contentView addSubview:_moveBtn];
        [self.contentView addSubview:_collectionImg];

        [self top_setupFream];
    }
    return self;
}
- (void)top_setupFream{
    UIView * contentView = self.contentView;
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.trailing.equalTo(contentView).offset(-60);
        make.top.equalTo(contentView).offset(5);
        make.height.mas_equalTo(17);
    }];
    [_dateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.top.equalTo(_titleLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(14);
    }];
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_dateLabel.mas_trailing).offset(10);
        make.centerY.equalTo(_dateLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(45, 15));
    }];
    [_collectionImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_numLabel.mas_trailing).offset(10);
        make.centerY.equalTo(_dateLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(23/2, 23/2));
    }];
    [_tagImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_numLabel.mas_trailing).offset(_leftW);
        make.centerY.equalTo(_dateLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(23/2, 23/2));
    }];
    [_tagLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_tagImg.mas_trailing).offset(5);
        make.trailing.equalTo(contentView).offset(-60);
        make.centerY.equalTo(_dateLabel.mas_centerY);
        make.height.mas_equalTo(23/2+4);
    }];
    NSInteger cellW = Cell_W;
    [_showImg1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(15);
        make.top.equalTo(_numLabel.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(cellW, cellW));
    }];
    [_showImg2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_showImg1.mas_trailing).offset(10);
        make.top.equalTo(_numLabel.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(cellW, cellW));
    }];
    [_showImg3 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_showImg2.mas_trailing).offset(10);
        make.top.equalTo(_numLabel.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(cellW, cellW));
    }];
    [_showImg4 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_showImg3.mas_trailing).offset(10);
        make.top.equalTo(_numLabel.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(cellW, cellW));
    }];
    [_choseBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(10);
        make.trailing.equalTo(contentView).offset(-15);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [_moveBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_showImg4.mas_trailing);
        make.trailing.equalTo(contentView).offset(-5);
        make.centerY.equalTo(_showImg4.mas_centerY);
        make.height.mas_equalTo(50);
    }];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _titleLabel.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
}
- (void)top_showSelectBtn{
    _choseBtn.hidden = NO;
}
- (void)top_selectAction:(UIButton*)btn{
    btn.selected = !btn.selected;
    if (self.top_ChoseBtnBlock) {
        self.top_ChoseBtnBlock(btn.selected);
    }
}
- (void)moveAction{
    
}
- (void)setItem:(NSInteger)item{
    _item = item;
}
- (void)setModel:(DocumentModel *)model{
    _model = model;
    _titleLabel.text = model.name;
    _choseBtn.hidden = ![TOPScanerShare shared].isEditing;
    _choseBtn.selected = model.selectStatus;
    _numLabel.text = model.number;
    _dateLabel.text = model.createDate;
    
    NSArray * tagsArray = model.tagsArray;
    if (tagsArray.count>0) {
        _tagImg.hidden = NO;
        _tagLab.hidden = NO;
        NSString * allString = [NSString new];
        for (TOPTagsModel * tagModel in tagsArray) {
            allString = [NSString stringWithFormat:@"%@ | %@",allString,tagModel.name];
        }
        if (allString.length>2) {
            _tagLab.text = [allString substringFromIndex:2];
        }
    }else{
        _tagImg.hidden = YES;
        _tagLab.hidden = YES;
    }
    if (model.collectionstate) {
        _collectionImg.hidden = NO;
        _leftW = 10+12+3;
    }else{
        _collectionImg.hidden = YES;
        _leftW = 10;
    }
    [_numLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_dateLabel.mas_trailing).offset(15);
        make.centerY.equalTo(_dateLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([TOPDocumentHelper top_getSizeWithStr:model.number Height:15 Font:13].width+8, 15));
    }];
    [_tagImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_numLabel.mas_trailing).offset(_leftW);
        make.centerY.equalTo(_dateLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(23/2, 23/2));
    }];
    if ([TOPWHCFileManager top_isExistsAtPath:model.docPasswordPath]) {
        _showImg1.gaussianImg.hidden = NO;
        _showImg2.gaussianImg.hidden = NO;
        _showImg3.gaussianImg.hidden = NO;
        _showImg4.gaussianImg.hidden = NO;
    }else{
        _showImg1.gaussianImg.hidden = YES;
        _showImg2.gaussianImg.hidden = YES;
        _showImg3.gaussianImg.hidden = YES;
        _showImg4.gaussianImg.hidden = YES;
    }
    [self top_loadCollcttionData:model];
}

#pragma mark -- 视图展示隐藏的处理
- (void)top_loadCollcttionData:(DocumentModel *)model{
    [self top_moveBtnState];
    [self top_judgeChildViewState:[model.picArray mutableCopy]];
    if ([model.number integerValue]>4) {
        self.showImg4.showNum = [model.number integerValue]-4;
        self.showImg4.gaussianImg.hidden = YES;
    }else{
        self.showImg4.showNum = 0;
    }
}
- (void)top_judgeChildViewState:(NSMutableArray *)tempArray{
    if (tempArray.count == 1) {
        DocumentModel * nextModel1 = tempArray[0];
        [self top_showImage:self.showImg1 currentModel:nextModel1];
        self.showImg1.hidden = NO;
        self.showImg1.nextModel = nextModel1;
        self.showImg2.hidden = YES;
        self.showImg3.hidden = YES;
        self.showImg4.hidden = YES;
    }
    if (tempArray.count == 2) {
        DocumentModel * nextModel1 = tempArray[0];
        [self top_showImage:self.showImg1 currentModel:nextModel1];
        DocumentModel * nextModel2 = tempArray[1];
        [self top_showImage:self.showImg2 currentModel:nextModel2];
        self.showImg1.hidden = NO;
        self.showImg2.hidden = NO;
        self.showImg1.nextModel = nextModel1;
        self.showImg2.nextModel = nextModel2;
        self.showImg3.hidden = YES;
        self.showImg4.hidden = YES;
    }
    if (tempArray.count == 3) {
        DocumentModel * nextModel1 = tempArray[0];
        [self top_showImage:self.showImg1 currentModel:nextModel1];
        DocumentModel * nextModel2 = tempArray[1];
        [self top_showImage:self.showImg2 currentModel:nextModel2];
        DocumentModel * nextModel3 = tempArray[2];
        [self top_showImage:self.showImg3 currentModel:nextModel3];
        self.showImg1.hidden = NO;
        self.showImg2.hidden = NO;
        self.showImg3.hidden = NO;
        self.showImg1.nextModel = nextModel1;
        self.showImg2.nextModel = nextModel2;
        self.showImg3.nextModel = nextModel3;
        self.showImg4.hidden = YES;
    }
    if (tempArray.count>=4) {
        DocumentModel * nextModel1 = tempArray[0];
        [self top_showImage:self.showImg1 currentModel:nextModel1];
        DocumentModel * nextModel2 = tempArray[1];
        [self top_showImage:self.showImg2 currentModel:nextModel2];
        DocumentModel * nextModel3 = tempArray[2];
        [self top_showImage:self.showImg3 currentModel:nextModel3];
        DocumentModel * nextModel4 = tempArray[3];
        [self top_showImage:self.showImg4 currentModel:nextModel4];
        self.showImg1.hidden = NO;
        self.showImg2.hidden = NO;
        self.showImg3.hidden = NO;
        self.showImg4.hidden = NO;
        self.showImg1.nextModel = nextModel1;
        self.showImg2.nextModel = nextModel2;
        self.showImg3.nextModel = nextModel3;
        self.showImg4.nextModel = nextModel4;
    }
}
- (void)top_showImage:(UIImageView *)showImg currentModel:(DocumentModel *)model{
    [showImg top_createCoverImage:model.path atPath:model.coverImagePath complete:^(UIImage * _Nonnull img) {
        if (img) {
            UIImage * bluImg = [UIImage new];
            if ([TOPWHCFileManager top_isExistsAtPath:self.model.docPasswordPath]) {
                if ([TOPWHCFileManager top_isExistsAtPath:model.gaussianBlurPath]) {
                    bluImg = [UIImage imageWithContentsOfFile:model.gaussianBlurPath];//显示高斯模糊图片
                } else {
                    bluImg = [TOPDocumentHelper top_blurryImage:img withBlurLevel:60];
                    if (bluImg) {
                        [TOPDocumentHelper top_saveImage:bluImg atPath:model.gaussianBlurPath];//保存高斯模糊图片到本地
                    }
                }
            } else {
                bluImg = img;
            }
            showImg.image = bluImg;
        }
    }];
}
#pragma mark -- 点击滑动的按钮的显示与隐藏
- (void)top_moveBtnState{
    if (self.collectionData.count>4) {
        _moveBtn.hidden = NO;
    }else{
        _moveBtn.hidden = YES;
    }
}
- (void)top_clickTap:(UITapGestureRecognizer *)ges{
    if (self.top_gesBlock) {
        self.top_gesBlock();
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
