#import "TOPDownProgressAlertView.h"

@interface TOPDownProgressAlertView ()
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *backgroundTableView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *downTitleLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *downProgressView;

@end
static void *ProgressObserverContext = &ProgressObserverContext;
@implementation TOPDownProgressAlertView
-(void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [UIColor clearColor];
    self.alertView.alpha = 0.0;
    self.alertView.layer.cornerRadius = 5;
    self.alertView.clipsToBounds = YES;
    self.downTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
}

-(void)top_showXib
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
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
            [self top_hideProgress];
            [self removeFromSuperview];
        }
    }];
}

+(instancetype)top_creatXIB
{
    return [[[NSBundle mainBundle]loadNibNamed:@"TOPDownProgressAlertView" owner:nil options:nil]lastObject];
}

- (IBAction)buttonClick:(UIButton *)sender {
    TOPSCAlertController *alertCtr = [TOPSCAlertController alertControllerWithTitle:NSLocalizedString(@"topscan_tips", @"") message:NSLocalizedString(@"topscan_backupinbackgroundaleat", @"") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_cancel", @"") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"topscan_ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.closeViewBlock) {
            self.closeViewBlock();
        }
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDownOrUpdateInback"];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"topscan_startbackupinbackground", @"") ];
        [self top_closeXib];
        
    }];
    
    [alertCtr addAction:sureAction];
    [alertCtr addAction:setAction];
    [[TOPDocumentHelper top_topViewController] presentViewController:alertCtr animated:YES completion:nil];
}

- (void)setProgress:(NSProgress *)progress
{
    _progress = progress;
    [progress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:0 context:ProgressObserverContext];
}

- (void)setTitleName:(NSString *)titleName
{
    _titleName = titleName;
    self.downTitleLabel.text = titleName;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == ProgressObserverContext){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSProgress *progress = object;
            [self.downProgressView setProgress:progress.fractionCompleted animated:YES];
            if (progress.fractionCompleted  >= 1.0f) {
                if (self.currentIndexCount == self.downTotalCount-1) {
                    
                    [self top_closeXib];
                }
            }
        });
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)top_hideProgress
{
    [self top_closeXib];
}
- (void)setProgressFloat:(float)progressFloat
{
    _progressFloat = progressFloat;
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.downProgressView setProgress:progressFloat animated:YES];
    });
    if (progressFloat  >= 1.0f) {
        if (self.currentIndexCount == self.downTotalCount-1) {
            [self top_closeXib];
        }
    }
}

@end
