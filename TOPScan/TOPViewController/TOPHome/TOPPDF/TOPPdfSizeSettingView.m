#import "TOPPdfSizeSettingView.h"
#import "TOPPdfSizeCell.h"
@interface TOPPdfSizeSettingView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong)NSMutableArray * dataArray;
@end
@implementation TOPPdfSizeSettingView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUI];
        [self top_loadData];
    }
    return self;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
       
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 65, TOPScreenWidth, self.frame.size.height-65) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[TOPPdfSizeCell class] forCellWithReuseIdentifier:NSStringFromClass([TOPPdfSizeCell class])];
    }
    return _collectionView;
}

- (void)setUI{
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    UIButton * dismissBtn = [[UIButton alloc]initWithFrame:CGRectMake(TOPScreenWidth-64, 15, 44, 44)];
    [dismissBtn setImage:[UIImage imageNamed:@"top_menu_close"] forState:UIControlStateNormal];
    [dismissBtn addTarget:self action:@selector(top_dismissBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:dismissBtn];
    [self addSubview:self.collectionView];

    [dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.trailing.equalTo(self).offset(-20);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(65, 0, 0, 0));
    }];
}

- (void)top_loadData{
    NSDictionary * dic1 = @{@"pdfSizeTitle":@"A3"
                            ,@"pdfSizeW":@"29.7"
                            ,@"pdfSizeH":@"42.0"
                            ,@"pdfType":@(TOPPDFPageSizeA3)
    };
    NSDictionary * dic2 = @{@"pdfSizeTitle":@"A4"
                            ,@"pdfSizeW":@"21.0"
                            ,@"pdfSizeH":@"29.7"
                            ,@"pdfType":@(TOPPDFPageSizeA4)
    };
    NSDictionary * dic3 = @{@"pdfSizeTitle":@"A5"
                            ,@"pdfSizeW":@"14.8"
                            ,@"pdfSizeH":@"21.0"
                            ,@"pdfType":@(TOPPDFPageSizeA5)
    };
    NSDictionary * dic4 = @{@"pdfSizeTitle":@"B4"
                            ,@"pdfSizeW":@"25.0"
                            ,@"pdfSizeH":@"35.3"
                            ,@"pdfType":@(TOPPDFPageSizeB4)
    };
    NSDictionary * dic5 = @{@"pdfSizeTitle":@"B5"
                            ,@"pdfSizeW":@"17.6"
                            ,@"pdfSizeH":@"25.0"
                            ,@"pdfType":@(TOPPDFPageSizeB5)
    };
    NSDictionary * dic6 = @{@"pdfSizeTitle":@"Letter"
                            ,@"pdfSizeW":@"21.6"
                            ,@"pdfSizeH":@"27.9"
                            ,@"pdfType":@(TOPPDFPageSizeLetter)
    };
    NSDictionary * dic7 = @{@"pdfSizeTitle":@"Tabloid"
                            ,@"pdfSizeW":@"27.9"
                            ,@"pdfSizeH":@"43.2"
                            ,@"pdfType":@(TOPPDFPageSizeTabloid)
    };
    NSDictionary * dic8 = @{@"pdfSizeTitle":@"Executive"
                            ,@"pdfSizeW":@"18.4"
                            ,@"pdfSizeH":@"26.7"
                            ,@"pdfType":@(TOPPDFPageSizeExecutive)
    };
    NSDictionary * dic9 = @{@"pdfSizeTitle":@"Postcard"
                            ,@"pdfSizeW":@"10.0"
                            ,@"pdfSizeH":@"14.7"
                            ,@"pdfType":@(TOPPDFPageSizePostcard)
    };
    NSDictionary * dic10 = @{@"pdfSizeTitle":@"Flsa"
                            ,@"pdfSizeW":@"21.6"
                            ,@"pdfSizeH":@"33.0"
                            ,@"pdfType":@(TOPPDFPageSizeFlsa)
    };
    NSDictionary * dic11 = @{@"pdfSizeTitle":@"Flse"
                            ,@"pdfSizeW":@"22.9"
                            ,@"pdfSizeH":@"33.0"
                            ,@"pdfType":@(TOPPDFPageSizeFlse)
    };
    NSDictionary * dic12 = @{@"pdfSizeTitle":@"Arch_A"
                            ,@"pdfSizeW":@"23.0"
                            ,@"pdfSizeH":@"30.5"
                            ,@"pdfType":@(TOPPDFPageSizeArch_A)
    };
    NSDictionary * dic13 = @{@"pdfSizeTitle":@"Legal"
                            ,@"pdfSizeW":@"21.6"
                            ,@"pdfSizeH":@"35.6"
                            ,@"pdfType":@(TOPPDFPageSizeLegal)
    };
    NSDictionary * dic14 = @{@"pdfSizeTitle":@"Arch_B"
                            ,@"pdfSizeW":@"30.5"
                            ,@"pdfSizeH":@"46.0"
                            ,@"pdfType":@(TOPPDFPageSizeArch_B)
    };
    NSDictionary * dic15 = @{@"pdfSizeTitle":@"Business"
                            ,@"pdfSizeW":@"8.5"
                            ,@"pdfSizeH":@"5.5"
                            ,@"pdfType":@(TOPPDFPageSizeBusiness)
    };
    NSArray * tempArray = @[dic1,dic2,dic3,dic4,dic5,dic6,dic7,dic8,dic9,dic10,dic11,dic12,dic13,dic14,dic15];
    for (int i = 0; i<tempArray.count; i++) {
        TOPPdfSizeModel * model = [TOPPdfSizeModel new];
        model.pdfSizeTitle = tempArray[i][@"pdfSizeTitle"];
        model.pdfSizeW = [tempArray[i][@"pdfSizeW"] floatValue];
        model.pdfSizeH = [tempArray[i][@"pdfSizeH"] floatValue];
        model.pdfType = [tempArray[i][@"pdfType"] integerValue];
        if (model.pdfType == [TOPScanerShare top_pageSizeType]) {
            model.cellState = YES;
        }else{
            model.cellState = NO;
        }
        [self.dataArray addObject:model];
    }
    [self.collectionView reloadData];
}
- (void)top_dismissBtnAction{
    if (self.top_dismissAction) {
        self.top_dismissAction();
    }
}

#pragma mark -- UICollectionViewDelegate UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TOPPdfSizeModel * model = self.dataArray[indexPath.item];
    TOPPdfSizeCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TOPPdfSizeCell class]) forIndexPath:indexPath];
    cell.model = model;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((TOPScreenWidth-30-10)/2, 60);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 15, 0, 15);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TOPPdfSizeModel * model = self.dataArray[indexPath.item];
    for (TOPPdfSizeModel * tempMdoel in self.dataArray) {
        if ([tempMdoel isEqual:model]) {
            tempMdoel.cellState = YES;
        }else{
            tempMdoel.cellState = NO;
        }
    }
    [self.collectionView reloadData];
    if (self.top_choosePdfSize) {
        self.top_choosePdfSize(model);
    }
}

@end
