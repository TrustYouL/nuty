#import "TOPSubscribeCell.h"

@implementation TOPSubscribeCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        if (IS_IPAD) {
            self.layer.cornerRadius = 5;
            self.layer.shadowColor = [UIColor blackColor].CGColor;
            self.layer.shadowOffset = CGSizeMake(0, 0);
            self.layer.shadowOpacity = 0.3;
            self.clipsToBounds = NO;
        }else{
            self.layer.cornerRadius = 5;
            self.layer.masksToBounds = YES;
            self.layer.borderWidth = 1.5;
            self.layer.borderColor = RGBA(51, 51, 51, 1.0).CGColor;
        }
        
        _imgV = [UIImageView new];
        
        _iconImgV = [UIImageView new];
        _iconImgV.backgroundColor = [UIColor clearColor];
        _iconImgV.image = [UIImage imageNamed:@"top_subscribTitleBack"];
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont boldSystemFontOfSize:10];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_imgV];
        [self addSubview:_iconImgV];
        [self addSubview:_titleLab];
    }
    return self;
}

- (void)setModel:(TOPSubscribeModel *)model{
    _model = model;
    _imgV.image = [UIImage imageNamed:model.imgString];
    _titleLab.text = model.titleString;
    
    [_imgV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    if (model.isLeft) {
        [_iconImgV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(10);
            make.bottom.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(75, 16));
        }];
        [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(10);
            make.bottom.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(75, 16));
        }];
    }else{
        [_iconImgV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self).offset(-10);
            make.bottom.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(75, 16));
        }];
        [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self).offset(-10);
            make.bottom.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(75, 16));
        }];
    }
}

@end
