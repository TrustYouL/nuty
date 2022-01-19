#import "TOPSelectEraserAlertView.h"
#import "TOPSignatureLineWithCell.h"
#import "TOPEraserHeaderCollectionReusableView.h"

static NSString *LineWidthCollectionNib = @"TOPSignatureLineWithCell1";
static NSString *footerCollectionNib = @"footerCollectionNib";

@interface TOPSelectEraserAlertView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *purchaseMoneyArrays;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (assign, nonatomic) NSInteger currentColorIndex;
@property (weak, nonatomic) IBOutlet UIView *backgroundTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerConstraint;
@end

@implementation TOPSelectEraserAlertView

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
    self.centerConstraint.constant = kIs_iPhoneX ? 60+TOPNavAndTabHeight : 90+TOPNavAndTabHeight;
    self.purchaseMoneyArrays = [NSMutableArray arrayWithArray:@[@8,@12,@16,@20,@24]];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TOP_RTDefaultSignatureEraserWitdth] == nil) {
        [[NSUserDefaults standardUserDefaults] setInteger:8  forKey:TOP_RTDefaultSignatureEraserWitdth];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.currentColorIndex = 0;
    }else{
        NSInteger currentLineWidth = [[[NSUserDefaults standardUserDefaults] objectForKey:TOP_RTDefaultSignatureEraserWitdth] integerValue];
        for (int i = 0;i< self.purchaseMoneyArrays.count;i++) {
            NSInteger contentIndex = [self.purchaseMoneyArrays[i] integerValue];
            if (contentIndex == currentLineWidth) {
                self.currentColorIndex = i;
                break;
            }
        }
    }
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection= UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TOPSignatureLineWithCell" bundle:nil] forCellWithReuseIdentifier:LineWidthCollectionNib];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"TOPEraserHeaderCollectionReusableView"
                                                bundle:nil]
      forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
             withReuseIdentifier:footerCollectionNib];
    
    [_collectionView
     registerClass:[UICollectionReusableView class]
     forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
     withReuseIdentifier:@"noneSectionFooter"];
    
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
    return [[[NSBundle mainBundle]loadNibNamed:@"TOPSelectEraserAlertView" owner:nil options:nil]lastObject];
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
    
    TOPSignatureLineWithCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LineWidthCollectionNib forIndexPath:indexPath];
    cell.lineWidth = [self.purchaseMoneyArrays[indexPath.row] integerValue];
    if (self.currentColorIndex == indexPath.row) {
        cell.lineWithView.backgroundColor = kTopicBlueColor;
        
    }else{
        cell.lineWithView.backgroundColor = UIColorFromRGB(0xCECECE);
    }
    return cell;
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    
    return  UIEdgeInsetsMake(40, 20, 20, 20);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((NSInteger)(246-80)/5, 35);
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionFooter){
        
        TOPEraserHeaderCollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerCollectionNib forIndexPath:indexPath];
        reusableview = footerView;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    
    return  CGSizeMake(CGRectGetWidth(self.alertView.frame), 40);
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.currentColorIndex !=indexPath.row) {
        TOPSignatureLineWithCell *cell  = (TOPSignatureLineWithCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.lineWithView.backgroundColor = kTopicBlueColor;
        TOPSignatureLineWithCell *lastCell  = (TOPSignatureLineWithCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentColorIndex inSection:0]];
        lastCell.lineWithView.backgroundColor = UIColorFromRGB(0xCECECE);
        
        self.currentColorIndex = indexPath.row;
        [[NSUserDefaults standardUserDefaults] setInteger:[self.purchaseMoneyArrays[indexPath.row] integerValue]  forKey:TOP_RTDefaultSignatureEraserWitdth];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (self.saveLineWidthSelectBlock) {
            NSInteger indexLineWidth = [self.purchaseMoneyArrays[indexPath.row] integerValue];
            self.saveLineWidthSelectBlock(indexLineWidth);
        }
    }else{
        [[NSUserDefaults standardUserDefaults] setInteger:[self.purchaseMoneyArrays[indexPath.row] integerValue]  forKey:TOP_RTDefaultSignatureEraserWitdth];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (self.saveLineWidthSelectBlock) {
            NSInteger indexLineWidth = [self.purchaseMoneyArrays[indexPath.row] integerValue];
            self.saveLineWidthSelectBlock(indexLineWidth);
        }
        
    }
    [self top_closeXib];
    
}



@end
