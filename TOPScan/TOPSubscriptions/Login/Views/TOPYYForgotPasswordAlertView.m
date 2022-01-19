

#import "TOPYYForgotPasswordAlertView.h"


@interface TOPYYForgotPasswordAlertView ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
//高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *backgroundTableView;
@property (weak, nonatomic) IBOutlet UITextField *textFolderField;
/*
 确定按钮
 */
@property (weak, nonatomic) IBOutlet UILabel *titleAlertLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@end

@implementation TOPYYForgotPasswordAlertView

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.cancelButton.backgroundColor = [UIColor clearColor];
    [self.cancelButton setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(153, 153, 153, 1.0)] forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [UIColor clearColor];
    [self.confirmButton setTitleColor:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(153, 153, 153, 1.0)] forState:UIControlStateNormal];
    self.textFolderField.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    self.titleAlertLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    self.lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:TOPAppBackgroundColor];
    
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [UIColor clearColor];
    self.alertView.alpha = 0.0;
    self.alertView.layer.cornerRadius = 15;
    self.alertView.clipsToBounds = YES;
    self.textFolderField.clearsOnBeginEditing = NO;
    self.textFolderField.delegate = self;
    self.textFolderField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.titleAlertLabel.text = NSLocalizedString(@"topscan_resetpsd", @"");
    self.textFolderField.placeholder = NSLocalizedString(@"topscan_email", @"");
    [self.cancelButton setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
    [self.confirmButton setTitle:NSLocalizedString(@"topscan_send", @"") forState:UIControlStateNormal];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //判断字符串是否全是空格
    if ( [[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_emailemptytips", @"")];
        return YES;
    }
    //去除textfieled的前后空格
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (self.sendTextForgotPasswordBlock) {
        self.sendTextForgotPasswordBlock(textField.text);
    }
    [textField resignFirstResponder];
    return YES;
}
-(void)top_showXibSupview:(UIView *)supView
{
    [supView addSubview:self];
    self.alertView.transform = CGAffineTransformScale(self.alertView.transform,1.1,1.1);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundColor =  [UIColorFromRGB(0x333333) colorWithAlphaComponent:0.5];
        self.alertView.transform = CGAffineTransformIdentity;
        self.alertView.alpha = 1.0;
    } completion:nil];
}

-(void)top_showXib
{
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self];
    self.alertView.transform = CGAffineTransformScale(self.alertView.transform,1.1,1.1);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundColor =  [UIColorFromRGB(0x333333) colorWithAlphaComponent:0.5];
        self.alertView.transform = CGAffineTransformIdentity;
        self.alertView.alpha = 1.0;
    } completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
}
-(void)top_closeXib
{
    [self endEditing:YES];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 0.0;
        self.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.0];
        self.alertView.transform = CGAffineTransformScale(self.alertView.transform,0.9,0.9);
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

+(instancetype)top_creatXIB
{
    return [[[NSBundle mainBundle]loadNibNamed:@"TOPYYForgotPasswordAlertView" owner:nil options:nil]lastObject];
}

- (IBAction)buttonClick:(UIButton *)sender {
    [self.textFolderField resignFirstResponder];
    switch (sender.tag) {
        case 2:
        {
            if ([TOPValidateTools top_validateString:self.textFolderField.text]) {
                [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_emailemptytips", @"")];
                return;
            }
            //判断字符串是否全是空格
            if ( [[self.textFolderField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
                [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_emailemptytips", @"")];
                return;
            }
            if ([TOPValidateTools top_validateEmail:self.textFolderField.text]==NO) {
                [[TOPCornerToast shareInstance] makeToast:NSLocalizedString(@"topscan_emailinvalidtips", @"")];
                return;
            }
            //去除textfieled的前后空格
            self.textFolderField.text = [self.textFolderField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (self.sendTextForgotPasswordBlock) {
                self.sendTextForgotPasswordBlock(self.textFolderField.text);
            }
            [self top_closeXib];
        }
            break;
        case 1:
        {
            [self top_closeXib];
        }
            break;
        default:
            break;
    }
}

- (void) setCustomTitleStr:(NSString *)customTitleStr
{
    _customTitleStr = customTitleStr;
    self.titleAlertLabel.text = customTitleStr;
}
@end
