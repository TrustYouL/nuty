#import "TOPCameraTorchView.h"
#import "UIView+EqualMargin.h"
@interface TOPCameraTorchView()
@property (nonatomic ,strong)UIButton * tagBtn;
@end
@implementation TOPCameraTorchView
- (instancetype)init{
    if (self = [super init]) {
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.backgroundColor = RGBA(0, 0, 0, 0.5);
        
        [self top_setupUI];
    }
    return self;
}

- (NSArray *)flashTypeArray{
    NSArray * tempArray = @[@(TOPCameraFlashTypeAuto),@(TOPCameraFlashTypeOn),@(TOPCameraFlashTypeOff),@(TOPCameraFlashTypeTroch)];
    return tempArray;
}

- (void)top_setupUI{
    NSArray * defaultIconArray = @[@"top_flashAutoDefault",@"top_flashOnDefault",@"top_flashOffDefault",@"top_torchOnDefault"];
    NSArray * selectIconArray = @[@"top_flashAutoSelect",@"top_flashOnSelect",@"top_flashOffSelect",@"top_torchOnSelect"];

    NSArray * titleArray = @[NSLocalizedString(@"topscan_cameralightauto", @""),NSLocalizedString(@"topscan_cameralighton", @""),NSLocalizedString(@"topscan_cameralightoff", @""),NSLocalizedString(@"topscan_cameralighttorch", @"")];
    NSMutableArray * tempArray = [NSMutableArray new];
    NSInteger saveType = [TOPScanerShare top_cameraFlashType];
    for (int i = 0; i<[self flashTypeArray].count; i++) {
        UIButton * tagBtn = [[UIButton alloc]init];
        NSInteger type = [[self flashTypeArray][i] integerValue];
        if (type == saveType) {
            tagBtn.selected = YES;
            self.tagBtn = tagBtn;
        }else{
            tagBtn.selected = NO;
        }
        tagBtn.tag = 1000+i;
        [tagBtn setImage:[UIImage imageNamed:defaultIconArray[i]] forState:UIControlStateNormal];
        [tagBtn setImage:[UIImage imageNamed:selectIconArray[i]] forState:UIControlStateSelected];
        tagBtn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [tagBtn setTitle:titleArray[i] forState:UIControlStateNormal];
        [tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [tagBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateSelected];
        [tagBtn addTarget:self action:@selector(top_clickBtnSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tagBtn];
        [tempArray addObject:tagBtn];
        
        [tagBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.size.mas_equalTo(CGSizeMake(40, 65));
        }];
        if (isRTL()) {
            [tagBtn setTitleEdgeInsets:UIEdgeInsetsMake(tagBtn.imageView.bounds.size.height+14,  0, 0,-tagBtn.imageView.bounds.size.width)];
            [tagBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-tagBtn.titleLabel.bounds.size.width/2, tagBtn.titleLabel.bounds.size.height, tagBtn.titleLabel.bounds.size.width/2)];
        }else{
            [tagBtn setTitleEdgeInsets:UIEdgeInsetsMake(tagBtn.imageView.bounds.size.height+14, -tagBtn.imageView.bounds.size.width, 0, 0)];
            [tagBtn setImageEdgeInsets:UIEdgeInsetsMake(0,tagBtn.titleLabel.bounds.size.width/2, tagBtn.titleLabel.bounds.size.height, -tagBtn.titleLabel.bounds.size.width/2)];
        }
    }
    [self top_distributeSpacingHorizontallyWith:tempArray];
}

- (void)top_clickBtnSelect:(UIButton *)sender{
    TOPCameraFlashType type = [[self flashTypeArray][sender.tag-1000] integerValue];
    if (self.tagBtn != sender){
        self.tagBtn.selected = NO;
        sender.selected = YES;
        UIButton * btn = (UIButton * )[self viewWithTag:sender.tag];
        self.tagBtn = btn;
        
    }else{
        sender.selected = YES;
    }
    
    if (self.top_clickFlashBtnChangeType) {
        self.top_clickFlashBtnChangeType(type);
    }
}

@end
