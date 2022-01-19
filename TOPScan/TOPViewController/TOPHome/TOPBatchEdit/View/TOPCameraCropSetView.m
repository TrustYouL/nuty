#import "TOPCameraCropSetView.h"

@implementation TOPCameraCropSetView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = RGBA(0, 0, 0, 0.4);
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        
        _titleLab = [UILabel new];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.font = [UIFont systemFontOfSize:14];
        
        _switchBtn = [UISwitch new];
        _switchBtn.transform = CGAffineTransformMakeScale(0.65, 0.65);
        _switchBtn.onTintColor = TOPAPPGreenColor;
        _switchBtn.thumbTintColor = [UIColor whiteColor];
        [_switchBtn addTarget:self action:@selector(top_subscribeTopic:) forControlEvents:UIControlEventValueChanged];
         
        [self addSubview:_titleLab];
        [self addSubview:_switchBtn];
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    [_switchBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(5);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(60, 30));
    }];
    [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.trailing.equalTo(_switchBtn.mas_leading).offset(-25);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(80, 25));
    }];
    
    _titleLab.text = NSLocalizedString(@"topscan_cropautomaticcameraaip", @"");
    if ([TOPScanerShare top_saveBatchImage] == TOPSettingSaveYES) {
        _switchBtn.on = YES;
    }else{
        _switchBtn.on = NO;
    }
}

- (void)top_subscribeTopic:(UISwitch *)sender{
    if (sender.on) {
        [TOPScanerShare top_writeSaveBatchImage:TOPSettingSaveYES];
    }else{
        [TOPScanerShare top_writeSaveBatchImage:TOPSettingSaveNO];
    }
}

@end
