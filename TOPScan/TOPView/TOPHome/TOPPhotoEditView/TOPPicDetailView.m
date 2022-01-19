#define Cell_H 50
#import "TOPPicDetailView.h"
#import "TOPPicDetailCell.h"
@interface TOPPicDetailView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIView * maskView;
@property (nonatomic, strong) UIView * backView;
@property (nonatomic, strong) NSArray * dataArray;
@property (nonatomic, strong) UIImageView * showImgView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, assign) BOOL isFinish;
@end
@implementation TOPPicDetailView
- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray *)dataArray{
    if (self = [super initWithFrame:frame]) {
        self.dataArray = dataArray;
        self.isFinish = NO;
        [self top_setupUI];
        [self.tableView reloadData];
    }
    return self;
}
- (void)top_setupUI{
    UIView * backView = [[UIView alloc]initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
    backView.layer.cornerRadius = 10;
    backView.layer.masksToBounds = YES;
    self.backView = backView;
    
    UIImageView * imgView = [UIImageView new];
    imgView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
    imgView.backgroundColor = [UIColor redColor];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    imgView.layer.cornerRadius = 5;
    self.showImgView = imgView;
    
    self.frame = [UIScreen mainScreen].bounds;
    [self addSubview:self.maskView];
    [self addSubview:self.backView];
    [self addSubview:self.tableView];
    [self addSubview:self.showImgView];
    [self top_masViews];
}
- (void)top_masViews{
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
    [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.top.equalTo(self.mas_bottom);
        make.trailing.equalTo(self);
        make.height.mas_equalTo(Cell_H*self.dataArray.count+190+TOPBottomSafeHeight+30);
    }];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(10);
        make.top.equalTo(self.mas_bottom);
        make.trailing.equalTo(self).offset(-10);
        make.height.mas_equalTo(Cell_H*self.dataArray.count);
    }];
    [self.showImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(125, 130));
    }];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    if (!self.isFinish) {
        [self top_showView];
        UIButton *dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [dismissBtn setImage:[UIImage imageNamed:@"top_menu_close"] forState:UIControlStateNormal];
        [dismissBtn addTarget:self action:@selector(top_dismissView) forControlEvents:UIControlEventTouchUpInside];
        [self.backView addSubview:dismissBtn];
        [dismissBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.backView).offset(-20);
            make.top.equalTo(self.backView).offset(20);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
    }
}
- (void)top_showView{
    [UIView animateWithDuration:0.3 animations:^{
        [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).offset(-(Cell_H*self.dataArray.count+190+TOPBottomSafeHeight+20));
        }];
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).offset(-(Cell_H*self.dataArray.count+TOPBottomSafeHeight+20));
        }];
        [self.showImgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).offset(-(Cell_H*self.dataArray.count+TOPBottomSafeHeight+20+20+130));
        }];
        self.maskView.backgroundColor = RGBA(0, 0, 0, 0.5);
        [self.backView.superview layoutIfNeeded];
    }completion:^(BOOL finished) {
        self.isFinish = YES;
    }];
}
- (void)top_dismissView{
    [UIView animateWithDuration:0.3 animations:^{
        [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom);
        }];
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom);
        }];
        [self.showImgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom);
        }];
        self.maskView.alpha = 0;
        [self.backView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TOPPicDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPPicDetailCell class]) forIndexPath:indexPath];
    cell.picDic = self.dataArray[indexPath.row];
    if (indexPath.row == self.dataArray.count-1) {
        cell.lineView.hidden = YES;
    }else{
        cell.lineView.hidden = NO;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Cell_H;;
}
- (void)setImgPath:(NSString *)imgPath{
    _imgPath = imgPath;
    self.showImgView.image = [UIImage imageWithContentsOfFile:imgPath];
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollEnabled = NO;
        _tableView.layer.cornerRadius = 10;
        [_tableView registerClass:[TOPPicDetailCell class] forCellReuseIdentifier:NSStringFromClass([TOPPicDetailCell class])];
    }
    return _tableView;
}
- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = RGBA(51, 51, 51, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_dismissView)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

@end
