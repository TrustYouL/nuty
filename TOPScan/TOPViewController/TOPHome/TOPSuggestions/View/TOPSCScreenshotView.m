#import "TOPSCScreenshotView.h"
#import "TOPScreenshotCell.h"
@interface TOPSCScreenshotView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic ,strong)UICollectionView * myCollectionView;
@property (nonatomic ,strong)UILabel * numLab;
@end
@implementation TOPSCScreenshotView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        [self top_setupUI];
    }
    return self;
}

- (void)top_setupUI{
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 250, 30)];
    titleLab.textColor = RGB(153, 153, 153);
    titleLab.font = [UIFont systemFontOfSize:12];
    titleLab.textAlignment = NSTextAlignmentNatural;
    titleLab.text = NSLocalizedString(@"topscan_questiontoasttitle", @"");
    [self addSubview:titleLab];
    
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(10, 50, self.width-20, 1.0)];
    lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:TOPAppBackgroundColor];
    [self addSubview:lineView];
    
    UILabel * numLab = [[UILabel alloc]initWithFrame:CGRectMake(self.width-10-35, 50+5, 35, 15)];
    numLab.textColor = RGB(102, 102, 102);
    numLab.font = [UIFont systemFontOfSize:12];
    numLab.textAlignment = NSTextAlignmentCenter;
    self.numLab = numLab;
    [self addSubview:numLab];
    [self addSubview:self.myCollectionView];
    
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.top.equalTo(self).offset(5);
        make.trailing.equalTo(self).offset(-15);
        make.height.mas_equalTo(20);
    }];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.top.equalTo(titleLab.mas_bottom).offset(5);
        make.trailing.equalTo(self).offset(-15);
        make.height.mas_equalTo(1.0);
    }];
    [numLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom).offset(4);
        make.trailing.equalTo(self).offset(-10);
        make.size.mas_equalTo(CGSizeMake(35, 14));
    }];
    [self.myCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(15);
        make.top.equalTo(numLab.mas_bottom).offset(5);
        make.trailing.equalTo(self).offset(-15);
        make.bottom.equalTo(self).offset(-10);
    }];
}
- (UICollectionView *)myCollectionView{
    if (!_myCollectionView) {
        TOPLocalFlowLayout * layout = [[TOPLocalFlowLayout alloc]init];
        //滚动方向
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 0;

        _myCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,70, self.width, self.height-70) collectionViewLayout:layout];
        _myCollectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        _myCollectionView.dataSource = self;
        _myCollectionView.delegate = self;
        _myCollectionView.showsHorizontalScrollIndicator = NO;
        [_myCollectionView registerClass:[TOPScreenshotCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPScreenshotCell class])];
    }
    return _myCollectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.imagesArray.count == 9) {
        return self.imagesArray.count;
    }
    return self.imagesArray.count+1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    TOPScreenshotCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPScreenshotCell class]) forIndexPath:indexPath];
    cell.top_deleteCurrentPic = ^(NSString * _Nonnull picName) {
        if (weakSelf.top_deleteCurrentPic) {
            weakSelf.top_deleteCurrentPic(picName);
        }
    };
    if (indexPath.row<self.imagesArray.count) {
        cell.picName = self.imagesArray[indexPath.row];
    }
    
    if (self.imagesArray.count != 9&&indexPath.row == self.imagesArray.count) {
        cell.deleteImg.hidden = YES;
        cell.deleteBtn.hidden = YES;
        cell.backView.hidden = NO;
        cell.addImg.hidden = NO;
    }else{
        cell.deleteImg.hidden = NO;
        cell.deleteBtn.hidden = NO;
        cell.backView.hidden = YES;
        cell.addImg.hidden = YES;
    }
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPAD) {
        return CGSizeMake(90, 100);
    }else{
        return CGSizeMake((self.width-30)/4,(self.width-30)/4+15);
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.imagesArray.count != 9&&indexPath.row == self.imagesArray.count) {//添加图片
        if (self.top_addScreenshotImg) {
            self.top_addScreenshotImg();
        }
    }else{//展示图片
        if (self.top_showScreenshotImg) {
            self.top_showScreenshotImg(indexPath.row);
        }
    }
}

- (void)setImagesArray:(NSMutableArray *)imagesArray{
    _imagesArray = imagesArray;
    [self.myCollectionView reloadData];
    if (imagesArray.count>0) {
        NSString * numString = [NSString stringWithFormat:@"%ld/9",imagesArray.count];
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[numString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType } documentAttributes:nil error:nil];
        NSRange range = NSMakeRange(0, attrStr.length-1);
        [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:range];
        [attrStr addAttribute:NSForegroundColorAttributeName value:RGB(51, 51, 51) range:range];
        self.numLab.attributedText = attrStr;
    }
}

@end
