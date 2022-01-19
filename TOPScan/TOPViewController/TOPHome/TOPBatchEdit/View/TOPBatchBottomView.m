#import "TOPBatchBottomView.h"
#import "TOPCropEditModel.h"

@interface TOPBatchBottomView()  {
    NSInteger clickCount;
}
@end
@implementation TOPBatchBottomView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        clickCount = 0;
        [self top_setChildView];
    }
    return self;
}

- (void)top_setChildView{
    _allBtn = [[TOPImageTitleButton alloc] initWithStyle:(EImageTopTitleBottom)];
    _allBtn.tapAnimationDuration = 0.0;
    _allBtn.tag = 1000+0;
    _allBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _allBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _allBtn.margin = UIEdgeInsetsMake(7, 0, 5, 0);
    _allBtn.padding = CGSizeMake(3, 3);
    [_allBtn setTitle:NSLocalizedString(@"topscan_batchall", @"") forState:UIControlStateNormal];
    [_allBtn setImage:[UIImage imageNamed:@"top_cropFull"] forState:UIControlStateNormal];
    
    [_allBtn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
    [_allBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _finishBtn = [UIButton new];
    _finishBtn.tag = 1000+1;
    _finishBtn.backgroundColor = [UIColor clearColor];
    [_finishBtn setImage:[UIImage imageNamed:@"top_scamerbatch_reEditAffirm"] forState:UIControlStateNormal];//(60.40)
    [_finishBtn addTarget:self action:@selector(top_clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_allBtn];
    [self addSubview:_finishBtn];
    [self top_setFream];
}

- (void)top_setFream{
    [_allBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(35);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(40);
    }];
    [_finishBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-20);
        make.centerY.equalTo(_allBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(60, 40));
    }];
}

- (void)top_clickBtn:(UIButton *)sender{
    if (sender.tag == 1000) {
        NSInteger index = clickCount % self.cropModel.leftCropBtnStates.count;
        if (index < self.cropModel.leftCropBtnStates.count) {
            NSInteger state = [self.cropModel.leftCropBtnStates[index] integerValue];
            if (self.top_cropBtnClick) {
                self.top_cropBtnClick(state);//传递数据
            }
        }
        [self top_clickCropBtn];//修改按钮状态
    } else {
        sender.selected = !sender.selected;
        if (self.top_sendBtnTag) {
            self.top_sendBtnTag(sender.tag-1000,sender.selected);
        }
    }
}

- (void)top_clickCropBtn{
    clickCount ++;
    NSInteger index = clickCount % self.cropModel.leftCropBtnStates.count;
    if (index < self.cropModel.leftCropBtnStates.count) {
        NSInteger state = [self.cropModel.leftCropBtnStates[index] integerValue];
        self.cropModel.cropState = state;
        [self top_resetAllBtnState:state];
    } else {
        NSLog(@"btn error");
    }
}

- (void)top_updateAllBtn:(TOPCropEditModel *)model {
    _cropModel = model;
    NSInteger index = [self.cropModel.leftCropBtnStates indexOfObject:@(model.cropState)];
    clickCount = index;
    [self top_resetAllBtnState:model.cropState];
}

- (void)top_resetAllBtnState:(NSInteger)state {
    NSString *btnImage = @"";
    NSString *btnTitle = @"";
    switch (state) {
        case TOPCropBtnStateAuto:
            btnImage = @"top_cropAuto";
            btnTitle = NSLocalizedString(@"topscan_batchauto", @"");
            break;
        case TOPCropBtnStateFull:
            btnImage = @"top_cropFull";
            btnTitle = NSLocalizedString(@"topscan_batchall", @"");
            break;
        case TOPCropBtnStateFit:
            btnImage = @"top_cropFit";
            btnTitle = NSLocalizedString(@"topscan_batchfit", @"");
            break;
            
        default:
            break;
    }
    [self.allBtn setImage:[UIImage imageNamed:btnImage] forState:UIControlStateNormal];
    [self.allBtn setTitle:btnTitle forState:UIControlStateNormal];
}

#pragma mark -- 更改按钮的状态
- (void)top_restoreAllBtnState:(BOOL)isAutomatic{
    self.allBtn.selected = !isAutomatic;
}
@end
