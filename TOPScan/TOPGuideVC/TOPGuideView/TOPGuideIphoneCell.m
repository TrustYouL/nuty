#import "TOPGuideIphoneCell.h"

@implementation TOPGuideIphoneCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        WS(weakSelf);
        _guideView = [[TOPGuideView alloc]init];
        _guideView.top_lastPageEnterAction = ^{
            if (weakSelf.top_lastPageEnterAction) {
                weakSelf.top_lastPageEnterAction();
            }
        };
        [self.contentView addSubview:_guideView];
        [self top_setViewFream];
    }
    return self;
}

- (void)top_setViewFream{
    [_guideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)setModel:(TOPGuideModel *)model{
    _model = model;
    _guideView.model = model;
}

@end
