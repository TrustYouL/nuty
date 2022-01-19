
#import "TOPScreenshotCell.h"

@implementation TOPScreenshotCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        
        _backView = [UIView new];
        _backView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:TOPAppBackgroundColor];
        
        _addImg = [UIImageView new];
        _addImg.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:TOPAppBackgroundColor];
        _addImg.image = [UIImage imageNamed:@"top_screenshotAdd"];
        
        _deleteImg = [UIImageView new];
        _deleteImg.image = [UIImage imageNamed:@"top_screenshotDelete"];
        
        _deleteBtn = [UIButton new];
        _deleteBtn.backgroundColor = [UIColor clearColor];
        [_deleteBtn addTarget:self action:@selector(top_clickDeleteBtn) forControlEvents:UIControlEventTouchUpInside];
        
        WS(weakSelf);
        _zoomView = [[TOPPhotoEditScrollView alloc]init];
        _zoomView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMostDarkColor defaultColor:TOPAppBackgroundColor];;
        _zoomView.userInteractionEnabled = NO;
        _zoomView.photoZoomScale = ^(CGFloat zoomScale) {
            [weakSelf top_judgeZoomScale:zoomScale];
        };
        [self.contentView addSubview:_zoomView];
        [self.contentView addSubview:_deleteImg];
        [self.contentView addSubview:_deleteBtn];
        [self.contentView addSubview:_backView];
        [self.contentView addSubview:_addImg];
        [self top_setViewFream];
    }
    return self;
}
- (void)top_clickDeleteBtn{
    if (self.top_deleteCurrentPic) {
        self.top_deleteCurrentPic(self.picName);
    }
}
- (void)setPicName:(NSString *)picName{
    _picName = picName;
    _zoomView.mainImage = [UIImage imageWithContentsOfFile:[TOPCamerPic_Path stringByAppendingPathComponent:picName]];
}

- (void)top_setViewFream{
    [_zoomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(9);
        make.leading.bottom.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-9);
    }];
    [_deleteImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-2);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(9);
        make.leading.bottom.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView).offset(-9);
    }];
    [_addImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_backView.mas_centerX);
        make.centerY.equalTo(_backView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

- (void)top_judgeZoomScale:(CGFloat)zoomScale{
    if (self.top_sendZoomScale) {
        self.top_sendZoomScale(zoomScale); 
    }
}
@end
