#import "TOPSwithBackTableViewCell.h"

@implementation TOPSwithBackTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.switchView.onTintColor= TOPAPPGreenColor;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction)switchChangeClick:(UISwitch *)sender {
    if ([self.swithName isEqualToString:NSLocalizedString(@"topscan_restorebackwifi", @"")])
    {
        if (sender.on) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Backup-Wi-Fionly"];
        }else{
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Backup-Wi-Fionly"];
        }
    }
    
    if ([self.swithName isEqualToString:NSLocalizedString(@"topscan_addorginalfile", @"")])
    {
        if (sender.on) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSaveOriginalImage"];
        }else{
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isSaveOriginalImage"];
        }
    }
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
        BOOL isSaveOriginalImage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isOpenLock"] boolValue];
        if (isSaveOriginalImage) {
            self.switchView.on = true;
        }else{
            self.switchView.on = false;
        }
    }
}
@end
