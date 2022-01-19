#import "TOPSwithBackTapTableViewCell.h"

@implementation TOPSwithBackTapTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.swithTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    self.lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:RGBA(240, 240, 240, 1.0)];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)changeAppSafeClick:(UIButton *)sender {
    if ([self.swithName isEqualToString:NSLocalizedString(@"topscan_turnoffpassword",@"")]) {
        if (self.top_swichOpenOrCloseAppSafeBlock) {
            self.top_swichOpenOrCloseAppSafeBlock(self.switchView.on, self.swithName);
        }
    }else{
        BOOL isSaveOriginalImage = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeStates] boolValue];
        BOOL currentStates = NO;
        if (isSaveOriginalImage) {
            currentStates = NO;
        }else{
            currentStates = YES;
            
        }
        if (self.top_swichOpenOrCloseAppSafeBlock) {
            self.top_swichOpenOrCloseAppSafeBlock(currentStates,self.swithName);
        }
    }
}

- (void)setCellType:(NSString *)cellType{
    _cellType = cellType;
}

- (void)setSwithName:(NSString *)swithName
{
    _swithName = swithName;
    self.swithTitleLabel.text = swithName;
    if ([swithName isEqualToString:NSLocalizedString(@"topscan_restorebackwifi", @"")]) {
        BOOL isWiFiOnly = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Backup-Wi-Fionly"] boolValue];
        if (isWiFiOnly) {
            self.switchView.on = true;
        }else{
            self.switchView.on = false;
        }
    }
    
    if ([swithName isEqualToString:NSLocalizedString(@"topscan_addorginalfile", @"")]) {
        BOOL isSaveOriginalImage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isSaveOriginalImage"] boolValue];
        if (isSaveOriginalImage) {
            self.switchView.on = true;
        }else{
            self.switchView.on = false;
        }
    }
    
    if ([swithName isEqualToString:NSLocalizedString(@"topscan_apppwd",@"")]) {
        BOOL isSaveOriginalImage = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeStates] boolValue];
        NSInteger currentUnlockNum =   [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeUnLockType] integerValue];
        if (isSaveOriginalImage && currentUnlockNum==TOPAppSetSafeUnlockTypePwd) {
            self.switchView.on = true;
        }else{
            self.switchView.on = false;
        }
    }
    if ([swithName isEqualToString:@"Touch ID"]) {
        BOOL isSaveOriginalImage = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeStates] boolValue];
        NSInteger currentUnlockNum =   [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeUnLockType] integerValue];
        if (isSaveOriginalImage && currentUnlockNum==TOPAppSetSafeUnlockTypeTouchID) {
            self.switchView.on = true;
        }else{
            self.switchView.on = false;
        }
    }
    if ([swithName isEqualToString:@"Face ID"]) {
        BOOL isSaveOriginalImage = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeStates] boolValue];
        NSInteger currentUnlockNum =   [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRAppSafeUnLockType] integerValue];
        if (isSaveOriginalImage && currentUnlockNum==TOPAppSetSafeUnlockTypeFaceID) {
            self.switchView.on = true;
        }else{
            self.switchView.on = false;
        }
    }

    if ([swithName isEqualToString:NSLocalizedString(@"topscan_turnoffpassword",@"")]) {
        NSString * password = [NSString new];
        if ([_cellType isEqualToString:@"doc"]) {
            password = [TOPScanerShare top_docPassword];
        }else{
            password = [TOPScanerShare top_pdfPassword];
        }
        if (password.length>0) {
            self.switchView.on = true;
            self.swithTitleLabel.text = NSLocalizedString(@"topscan_turnoffpassword",@"");
        }else{
            self.switchView.on = false;
            self.swithTitleLabel.text = NSLocalizedString(@"topscan_turnonpassword", @"");
        }
    }
}
@end
