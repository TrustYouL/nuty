#import "TOPSelectColorAlertView.h"
#import "TOPColorCollectionViewCell.h"

static NSString *colorCollectionNib = @"TOPColorCollectionViewCell";
@interface TOPSelectColorAlertView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *purchaseMoneyArrays;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (assign, nonatomic) NSInteger currentColorIndex;
@property (weak, nonatomic) IBOutlet UIView *backgroundTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerConstraint;
@end

@implementation TOPSelectColorAlertView

- (NSMutableArray *)purchaseMoneyArrays
{
    if (_purchaseMoneyArrays == nil) {
        _purchaseMoneyArrays = [NSMutableArray array];
    }
    return _purchaseMoneyArrays;
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [UIColor clearColor];
    self.alertView.alpha = 0.0;
    self.backgroundTableView.layer.cornerRadius = 5;
    self.backgroundTableView.clipsToBounds = YES;
    self.centerConstraint.constant = TOPNavAndTabHeight;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRDefaultSignatureColor] == nil) {
        [[NSUserDefaults standardUserDefaults] setInteger:0  forKey:TOP_TRDefaultSignatureColor];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.currentColorIndex = 0;
    }else{
        self.currentColorIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRDefaultSignatureColor] integerValue];
    }
    
    self.purchaseMoneyArrays = [NSMutableArray arrayWithArray:@[UIColorFromRGB(0x000000),UIColorFromRGB(0xFF7979),UIColorFromRGB(0xD02C25),UIColorFromRGB(0xFFF132),UIColorFromRGB(0xF6B61D),UIColorFromRGB(0xBB1DF6),UIColorFromRGB(0x79F61D),UIColorFromRGB(0x1DF6DF),UIColorFromRGB(0x00964C),UIColorFromRGB(0x1DB6F6),UIColorFromRGB(0x1D41F6),UIColorFromRGB(0x5F1DF6)]];
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection= UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.collectionView registerNib:[UINib nibWithNibName:@"TOPColorCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:colorCollectionNib];
    _collectionView.delegate = self;
    _collectionView.dataSource=self;
    _collectionView.showsHorizontalScrollIndicator=NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.allowsMultipleSelection = NO;
    _collectionView.scrollEnabled = YES;
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundTableView addSubview:_collectionView];
    
    [self.backgroundTableView addConstraints:[NSLayoutConstraint
                                              constraintsWithVisualFormat:@"H:|[_collectionView]|"
                                              options:1.0
                                              metrics:nil
                                              views:NSDictionaryOfVariableBindings(_collectionView)]];
    [self.backgroundTableView addConstraints:[NSLayoutConstraint
                                              constraintsWithVisualFormat:@"V:|[_collectionView]|"
                                              options:1.0
                                              metrics:nil
                                              views:NSDictionaryOfVariableBindings(_collectionView)]];
    [self addTipLabel];
}

- (void)addTipLabel {
    UILabel *noClassLab = [[UILabel alloc] init];
    noClassLab.textColor = kGrayColor;
    noClassLab.textAlignment = NSTextAlignmentCenter;
    noClassLab.font = PingFang_M_FONT_(15);
    noClassLab.text = NSLocalizedString(@"topscan_graffiticolor", @"");
    [self.backgroundTableView addSubview:noClassLab];
    noClassLab.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:noClassLab
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.backgroundTableView
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1.0 constant:0.0];
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:noClassLab
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.backgroundTableView
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.0 constant:0.0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:noClassLab
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.backgroundTableView
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0 constant:-20.0];
    [self.backgroundTableView addConstraints:@[leadingConstraint, trailingConstraint, bottomConstraint]];
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
    [self top_closeXib];
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
    return [[[NSBundle mainBundle]loadNibNamed:@"TOPSelectColorAlertView" owner:nil options:nil]lastObject];
}


- (void)setJumpType:(NSInteger)jumpType
{
    _jumpType = jumpType;
    
}

#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.purchaseMoneyArrays.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    TOPColorCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:colorCollectionNib forIndexPath:indexPath];
    cell.colorView.backgroundColor = self.purchaseMoneyArrays[indexPath.row];
    cell.smaleColorView.backgroundColor = self.purchaseMoneyArrays[indexPath.row];
    cell.smaleColorView.layer.shadowOffset = CGSizeMake(0, 1);
    cell.smaleColorView.layer.shadowColor = [[UIColor colorWithRed:39/255.0 green:43/255.0 blue:48/255.0 alpha:1] colorWithAlphaComponent:0.5].CGColor ;
    cell.smaleColorView.layer.shadowOpacity = 0.8;
    cell.smaleColorView.layer.shadowRadius = 3;
    cell.smaleColorView.layer.cornerRadius = 3;
    cell.smaleColorView.clipsToBounds =NO;
    
    cell.colorView.layer.shadowOffset = CGSizeMake(0, 1);
    cell.colorView.layer.shadowColor = [[UIColor colorWithRed:39/255.0 green:43/255.0 blue:48/255.0 alpha:1] colorWithAlphaComponent:0.5].CGColor ;
    cell.colorView.layer.shadowOpacity = 0.5;
    cell.colorView.layer.shadowRadius = 3;
    cell.colorView.layer.cornerRadius = 3;
    cell.colorView.clipsToBounds =NO;
    cell.colorView.hidden = YES;
    if (self.currentColorIndex == indexPath.row) {
        cell.colorView.hidden = NO;
        cell.smaleColorView.hidden = YES;
        
    }else{
        cell.colorView.hidden = YES;
        cell.smaleColorView.hidden = NO;
        
    }
    return cell;
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    
    return  UIEdgeInsetsMake(20, 15, 5, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(44, 44);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.currentColorIndex !=indexPath.row) {
        TOPColorCollectionViewCell *cell  = (TOPColorCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.colorView.hidden = NO;
        cell.smaleColorView.hidden = YES;
        
        TOPColorCollectionViewCell *lastCell  = (TOPColorCollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentColorIndex inSection:0]];
        lastCell.colorView.hidden = YES;
        lastCell.smaleColorView.hidden = NO;

        self.currentColorIndex = indexPath.row;
        [[NSUserDefaults standardUserDefaults] setInteger:self.currentColorIndex  forKey:TOP_TRDefaultSignatureColor];
        if (self.saveColorSelectBlock) {
            self.saveColorSelectBlock(self.purchaseMoneyArrays[indexPath.row]);
        }
    }else{
        if (self.saveColorSelectBlock) {
            self.saveColorSelectBlock(self.purchaseMoneyArrays[indexPath.row]);
        }
    }
    [self top_closeXib];
}



@end
