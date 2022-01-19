#define LastBtnW 75

#import "TOPFunctionChildAdjustBottomView.h"
@interface TOPFunctionChildAdjustBottomView ()
@property (nonatomic ,copy)NSArray * picArray;
@property (nonatomic ,copy)NSArray * titleArray;
@property (nonatomic ,strong)NSMutableArray * btnArray;
@end
@implementation TOPFunctionChildAdjustBottomView

- (instancetype)initWithFrame:(CGRect)frame sendPicArray:(NSArray *)array sendTitleArray:(NSArray *)titleArray{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.picArray = array;
        self.titleArray = titleArray;
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    for (int i = 0; i<self.picArray.count; i++) {
        TOPImageTitleButton *btn = [[TOPImageTitleButton alloc] initWithStyle:(EImageTopTitleBottom)];
        if (i == self.picArray.count-1) {
            btn.frame = CGRectMake(TOPScreenWidth-LastBtnW-15, 0, LastBtnW, self.height);
            btn.tag = 1000 + i;
            btn.style = EImageLeftTitleRight;
            UIImage *btnImg = [UIImage imageNamed:self.picArray[i]];
            [btn setImage:btnImg forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(top_downAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [self.btnArray addObject:btn];
        }else{
            CGFloat btnwidth = (TOPScreenWidth-LastBtnW-15) / (self.picArray.count-1);
            CGFloat btnHeight = self.frame.size.height;
            CGFloat btnX = i * btnwidth;
            CGFloat btnY = 0;
            btn.frame = CGRectMake(btnX, btnY, btnwidth, btnHeight);
            btn.margin = UIEdgeInsetsMake(6, 0, 6, 0);
            UIImage *btnImg = [UIImage imageNamed:self.picArray[i]];
            [btn setImage:btnImg forState:UIControlStateNormal];
            [btn setTitle:self.titleArray[i] forState:UIControlStateNormal];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.adjustsFontSizeToFitWidth = YES;
            [btn.titleLabel setFont:[self fontsWithSize:12]];
            [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
            btn.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
            btn.tag = 1000 + i;
            [btn addTarget:self action:@selector(top_downAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [self.btnArray addObject:btn];
        }
        
        if (IS_IPAD) {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self);
                make.width.mas_equalTo(120);
            }];
            btn.margin = UIEdgeInsetsMake((12), 0,0, 0);
        }
    }
    if (IS_IPAD) {
        [self top_distributeSpacingHorizontallyWith:self.btnArray];
    }
}

- (void)top_changePressViewBtnState:(TOPItemsSelectedState)selectedState{
    if (selectedState == TOPItemsSelectedNone) {
        [self top_changeBottonBtnState:self.disableArray withEnable:NO];
    }else{
        [self top_changeBottonBtnState:self.picArray withEnable:YES];
    }
}

- (void)top_changeBottonBtnState:(NSArray *)picArray withEnable:(BOOL)enable{
    for (int i = 0; i<self.btnArray.count; i++) {
        TOPImageTitleButton *btn = self.btnArray[i];
        if (i == 0) {
            btn.enabled = YES;
            [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
        }else{
            btn.enabled = enable;
            if (enable) {
                [btn setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
            }else{
                [btn setTitleColor:RGBA(153, 153, 153, 1.0) forState:UIControlStateNormal];
            }
        }
        [btn setImage:[UIImage imageNamed:picArray[i]] forState:UIControlStateNormal];
    }
}
- (void)top_downAction:(UIButton *)sender{
    if (self.top_clickSendBtnTag) {
        self.top_clickSendBtnTag(sender.tag-1000);
    }
}
- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray new];
    }
    return _btnArray;
}

@end
