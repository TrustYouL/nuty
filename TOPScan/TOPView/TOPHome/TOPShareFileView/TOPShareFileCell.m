
#import "TOPShareFileCell.h"
#import "TOPShareFileModel.h"

@interface TOPShareFileCell ()
@property (nonatomic ,strong) UIImageView *icon;
@property (nonatomic ,strong) UIImageView *radioBox;
@property (nonatomic ,strong) UILabel *titleLab;
@property (nonatomic ,strong) UILabel *numberLab;
@property (nonatomic ,strong) UIView *lineView;

@end

@implementation TOPShareFileCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        [self top_configContentView];
    }
    return self;
}

- (void)top_configCellWithData:(TOPShareFileModel *)cellModel {
    self.icon.image = [UIImage imageNamed:cellModel.icon];
    if (cellModel.showSize) {
        NSString *sizeStr = [TOPDocumentHelper top_memorySizeStr:cellModel.fileSize];
        self.titleLab.text = [NSString stringWithFormat:@"%@  (%@)",cellModel.title,sizeStr];
    } else {
        self.titleLab.text = cellModel.title;
    }
    if (cellModel.isSelected) {
        self.radioBox.image = [UIImage imageNamed:@"top_exoprtbtnselect"];
    } else {
        self.radioBox.image = [UIImage imageNamed:@"top_select_n_1"];
    }
}

- (void)setRoundedType:(NSInteger)roundedType {
    _roundedType = roundedType;
    
    CGFloat cornerRadius = 10.f;
    self.backgroundColor = UIColor.clearColor;
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGRect bounds = CGRectInset(self.bounds, 0, 0);
    BOOL addLine = NO;
    if (roundedType == 4) {
        CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
    } else if (roundedType == 1) {
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
        addLine = YES;
    } else if (roundedType == 3) {
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    } else {
        CGPathAddRect(pathRef, nil, bounds);
        addLine = YES;
    }
    layer.path = pathRef;
    CFRelease(pathRef);
    layer.fillColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor colorWithWhite:1.f alpha:0.8f]].CGColor;

    if (addLine == YES) {
        CALayer *lineLayer = [[CALayer alloc] init];
        CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
        lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+50, bounds.size.height-lineHeight, bounds.size.width-50, lineHeight);
        lineLayer.backgroundColor =[UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:RGBA(205, 205, 205, 1.0)].CGColor;
        [layer addSublayer:lineLayer];
    }
    UIView *testView = [[UIView alloc] initWithFrame:bounds];
    [testView.layer insertSublayer:layer atIndex:0];
    testView.backgroundColor = UIColor.clearColor;
    self.backgroundView = testView;;
}

- (void)top_configContentView {
    [self.contentView addSubview:self.icon];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.radioBox];
    [self.contentView addSubview:self.lineView];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(12);
        make.centerY.equalTo(self.contentView);
//        make.width.mas_equalTo(26);
//        make.height.mas_equalTo(23);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.icon.mas_trailing).offset(14);
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-60);
    }];
    
    [self.radioBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-14);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(14);
        make.height.mas_equalTo(14);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(45);
        make.bottom.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark -- lazy
- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
    }
    return _icon;;
}

- (UIImageView *)radioBox {
    if (!_radioBox) {
        _radioBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_select_n_1"]];
    }
    return _radioBox;;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineMostDarkColor defaultColor:RGBA(205, 205, 205, 1.0)];
        _lineView.hidden = YES;
    }
    return _lineView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:kCommonBlackTextColor];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.font = PingFang_R_FONT_(16);
    }
    return _titleLab;
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
