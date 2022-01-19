#import "TOPActionSheetView.h"
#import "TOPActionCell.h"
#import "TOPShareCancelCell.h"
#define Space 10

@interface TOPActionSheetView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *headView;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, copy) NSString *cancelTitle;

@property (nonatomic, copy) void(^cancelBlock)(void);

@property (nonatomic, copy) void(^selectBlock)(NSInteger);

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isFinish;

@end

@implementation TOPActionSheetView

- (instancetype)initWithTitleView:(UIView *)titleView
                       optionsArr:(NSArray *)optionsArr
                      cancelTitle:(NSString *)cancelTitle
                      cancelBlock:(void (^)(void))cancelBlock
                      selectBlock:(void (^)(NSInteger))selectBlock
{
    if (self = [super init]) {
        self.dataSource = [NSArray array];
        self.headView = titleView;
        self.dataSource = optionsArr;
        self.cancelTitle = cancelTitle;
        self.cancelBlock = cancelBlock;
        self.selectBlock = selectBlock;
        self.isFinish = NO;

        [self top_createUI];
    }
    return self;
}

- (void)top_createUI
{
    self.frame = [UIScreen mainScreen].bounds;
    [self addSubview:self.maskView];
    [self addSubview:self.tableView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
    if (IS_IPAD) {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mas_bottom);
            make.height.mas_equalTo(self.tableView.rowHeight*(self.dataSource.count+1)+2*Space);
            make.width.mas_equalTo(IPAD_CELLW);
        }];
    }else{
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(Space);
            make.top.equalTo(self.mas_bottom);
            make.trailing.equalTo(self).offset(-Space);
            make.height.mas_equalTo(self.tableView.rowHeight*(self.dataSource.count+1)+2*Space);
        }];
    }

}

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = [UIColor clearColor];
    }
    return _maskView;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 50;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.separatorInset = UIEdgeInsetsMake(0, -50, 0, 0);
        _tableView.layer.cornerRadius = 10;
        
        [_tableView registerClass:[TOPActionCell class] forCellReuseIdentifier:NSStringFromClass([TOPActionCell class])];
        [_tableView registerClass:[TOPShareCancelCell class] forCellReuseIdentifier:NSStringFromClass([TOPShareCancelCell class])];

    }
    return _tableView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TOPActionCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPActionCell class]) forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.titleArray = [self.dataSource mutableCopy];
        cell.titleLab.text = self.dataSource[indexPath.row];
        cell.row = indexPath.row;
        cell.drawIndex = self.drawIndex;
    }
    else
    {
        TOPShareCancelCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPShareCancelCell class]) forIndexPath:indexPath];
        return cell;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? self.dataSource.count : 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(Space, 10, IPAD_CELLW-2*Space, Space)];
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return Space;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        if (self.selectBlock) {
            self.selectBlock(indexPath.row);
        }
        [self top_dismissView];
    }
    else
    {
        self.cancelBlock();
        [self top_dismissView];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.isFinish) {
        [self top_showView];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self top_dismissView];
}

- (void)top_showView
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).offset(-(self.tableView.rowHeight*(self.dataSource.count+1)+2*Space+TOPBottomSafeHeight));
        }];
        self.maskView.backgroundColor = RGBA(0, 0, 0, 0.5);
        [self.tableView.superview layoutIfNeeded];
    }completion:^(BOOL finished) {
        self.isFinish = YES;
    }];
}

- (void)top_dismissView
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom);
        }];
        self.maskView.alpha = 0;
        [self.tableView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setDrawIndex:(NSInteger)drawIndex{
    _drawIndex = drawIndex;
    [self.tableView reloadData];
}
@end
