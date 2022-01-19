#import "TOPListCollectionViewCell.h"
@interface TOPListCollectionViewCell()
@property (nonatomic, strong)UIImageView  *imgV;
@property (nonatomic, strong)UILabel      *dateLabel;
@property (nonatomic, strong)UILabel      *numLabel;
@property (nonatomic, strong)UILabel      *titleLabel;
@property (nonatomic, strong)UIButton     *selectBtn;
@property (nonatomic, strong)UIView       *lineView;
@end
@implementation TOPListCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =[UIColor whiteColor];
        [self top_createUI];
    }
    return self;
}
- (UIImageView*)imgV{
    if (!_imgV) {
        _imgV = [[UIImageView alloc] initWithFrame:CGRectMake((15), (13), (40),(55))];
        _imgV.backgroundColor = UIColor.greenColor;
    }
    return _imgV;
}

- (UILabel*)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imgV.frame) + (15) ,(15), (285), (16))];
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.font = [self fontsWithSize:15];
    }
    return _titleLabel;
}

- (UILabel*)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imgV.frame) + (15) , CGRectGetMaxY(self.titleLabel.frame)+ (10),  (120), (12))];
        _dateLabel.textColor = UIColor.grayColor;
        _dateLabel.font = [self fontsWithSize:11];
    }
    return _dateLabel;
}


- (UILabel*)numLabel{
    if (!_numLabel) {
        _numLabel = [[UILabel alloc] initWithFrame:CGRectMake( CGRectGetMaxX(self.dateLabel.frame)+ (10) , CGRectGetMaxY(self.titleLabel.frame)+ (5), (14), (14))];
        _numLabel.textColor = UIColor.grayColor;
        _numLabel.layer.cornerRadius = 2;
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.layer.borderColor = [UIColor grayColor].CGColor;
        _numLabel.layer.borderWidth = 0.2;
        _numLabel.layer.masksToBounds = YES;
        _numLabel.font = [self fontsWithSize:13];
    }
    return _numLabel;
}
- (UIView*)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, (79),TOPScreenWidth,0.5)];
        _lineView.backgroundColor = UIColor.grayColor;
    }
    return _lineView;
}
- (void)top_createUI{
    [self.contentView addSubview:self.imgV];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView  addSubview:self.dateLabel];
    [self.contentView addSubview:self.numLabel];
    [self.contentView addSubview:self.lineView];
    
    self.titleLabel.text = @"Document 1";
    self.dateLabel.text = @"2019-06-02";
    self.numLabel.text = @"1";
}

- (void)setModel:(DocumentModel *)model{
    
    self.titleLabel.text = model.name;
    self.numLabel.text = model.number;
    CGSize numSize = [TOPAppTools getLabelFrameWithString:self.numLabel.text font:_numLabel.font sizeMake:CGSizeMake((100), (14))].size;

    if (numSize.width > (14)) {
        self.numLabel.frame = CGRectMake( CGRectGetMaxX(self.dateLabel.frame)+ (10) , CGRectGetMaxY(self.titleLabel.frame)+ (5),numSize.width, (14));
    }
    self.dateLabel.text = model.createDate;
    self.imgV.image = [UIImage imageWithContentsOfFile:model.imagePath];
}

@end
