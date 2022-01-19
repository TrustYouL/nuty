#import "TOPOptionButton.h"

#define KMainW [UIScreen mainScreen].bounds.size.width
#define KMainH [UIScreen mainScreen].bounds.size.height
#define KMarginYWhenMoving 20.0f
#define KRowHeight 44.0f
#define KMaxShowLine 7
#define KFont [UIFont systemFontOfSize:13.0f]
#define KBackColor [UIColor whiteColor]

@interface TOPOptionButton ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *searchArray;
@property (nonatomic, strong) UIWindow *cover;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, weak) UIView *view;
@property (nonatomic, weak) UIButton *button;

@end

@implementation TOPOptionButton

static NSString *KOptionButtonCell = @"KOptionButtonCell";

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self top_setup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self top_setup];
    }
    
    return self;
}

- (void)top_setup {
    TOPImageTitleButton *button = [[TOPImageTitleButton alloc] initWithStyle:(ETitleLeftImageRightCenter)];
    button.frame = self.bounds;
    [button setTitleColor:[UIColor top_viewControllerBackGroundColor:RGBA(180, 180, 180, 1.0) defaultColor:[UIColor blackColor]] forState:UIControlStateNormal];
    button.titleLabel.font = KFont;
    [button setImage:[UIImage imageNamed:@"top_bottom"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"top_bottom"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(top_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    self.button = button;
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.barTintColor = KBackColor;
    _searchBar.layer.borderWidth = 1.0f;
    _searchBar.layer.borderColor = RGBA(105, 105, 105, 1.0).CGColor;
    _searchBar.delegate = self;
    _searchBar.keyboardType = UIKeyboardTypeASCIICapable;
    
    //选项视图
    _tableView = [[UITableView alloc] init];
    _tableView.rowHeight = KRowHeight;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.layer.borderWidth = 1.0f;
    _tableView.layer.borderColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:RGBA(230, 230, 230, 1.0)].CGColor;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    
    _row = 0;
    self.showSearchBar = NO;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    _tableView.layer.borderColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:RGBA(230, 230, 230, 1.0)].CGColor;
}
- (void)top_buttonAction:(UIButton *)button
{
    button.hidden = YES;
    
    [self top_creatControl];
    
    [self endEditing];
}

- (void)top_creatControl
{
    _cover = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _cover.windowLevel = UIWindowLevelAlert;
    _cover.hidden = NO;
    
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_cover addSubview:view];
    self.view = view;
    
    UIView *backview = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backview.backgroundColor = [UIColor colorWithRed:(0)/255.0 green:(0)/255.0 blue:(0)/255.0 alpha:0.0f];
    [backview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tap:)]];
    [self.view addSubview:backview];
    
    CGRect frame = [self.superview convertRect:self.frame toView:self.view];
    
    TOPImageTitleButton *button = [[TOPImageTitleButton alloc] initWithStyle:(ETitleLeftImageRightCenter)];
    button.frame = CGRectMake(frame.origin.x, frame.origin.y, self.frame.size.width, self.frame.size.height);
    button.titleLabel.font = KFont;
    [button setTitle:_button.titleLabel.text forState:UIControlStateNormal];
    [button setTitleColor:[UIColor top_viewControllerBackGroundColor:RGBA(180, 180, 180, 1.0) defaultColor:[UIColor blackColor]] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(top_btnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"top_bottom"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"top_bottom"] forState:UIControlStateHighlighted];
   
    [self.view addSubview:button];
    
    if (_showSearchBar) {
        _searchBar.frame = CGRectMake(frame.origin.x, CGRectGetMaxY(frame), frame.size.width, KRowHeight);
        [self.view addSubview:_searchBar];
    }
    
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    //设置frame
    NSInteger rowCount = _showSearchBar ? KMaxShowLine - 1 : KMaxShowLine;
    CGFloat tabelViewY = _showSearchBar ? CGRectGetMaxY(_searchBar.frame) : CGRectGetMaxY(frame);
    if (_array.count <= rowCount) {
        _tableView.frame = CGRectMake(frame.origin.x, tabelViewY, frame.size.width, _array.count * KRowHeight);
    }else {
        _tableView.frame = CGRectMake(frame.origin.x, tabelViewY, frame.size.width, rowCount * KRowHeight);
    }
    
    [self.view addSubview:_tableView];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [_button setTitle:_title forState:UIControlStateNormal];
}

- (void)setArray:(NSArray *)array
{
    _array = array;
    
    self.searchArray = [_array copy];
    
    [_tableView reloadData];
}

- (void)top_btnOnClick
{
    [self top_dismissOptionAlert];
}

- (void)Tap:(UITapGestureRecognizer *)recognizer
{
    [self top_dismissOptionAlert];
}

- (void)top_dismissOptionAlert
{
    [_searchBar resignFirstResponder];
    
    if (self.view.frame.origin.y == 0) {
        [self top_removeCover];
    }else {
        [self searchBarTextDidEndEditing:_searchBar];
    }
}

- (void)top_removeCover
{
    [_searchBar resignFirstResponder];
    _cover.hidden = YES;
    _cover = nil;
    _button.hidden = NO;
}

- (void)endEditing
{
    [[[self findViewController] view] endEditing:YES];
}

- (UIViewController *)findViewController
{
    id target = self;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchText];
        _searchArray = [[_array filteredArrayUsingPredicate:predicate] copy];
    }else {
        _searchArray = [_array copy];
    }
    
    [_tableView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    UIView *view = self.superview;
    while (view.superview) {
        view = view.superview;
    }
    
    CGFloat Y = KMarginYWhenMoving - [self.superview convertRect:self.frame toView:self.view].origin.y;
    [UIView animateWithDuration:0.22f animations:^{
        view.frame = CGRectMake(0, Y, KMainW, KMainH);
        self.view.frame = CGRectMake(0, Y, KMainW, KMainH);
    }];
    
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    UIView *view = self.superview;
    while (view.superview) {
        view = view.superview;
    }
    
    [UIView animateWithDuration:0.22f animations:^{
        view.frame = CGRectMake(0, 0, KMainW, KMainH);
        self.view.frame = CGRectMake(0, 0, KMainW, KMainH);
    }completion:^(BOOL finished) {
        [self top_removeCover];
    }];
}

#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _searchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KOptionButtonCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:KOptionButtonCell];
    }
    cell.textLabel.text = _searchArray[indexPath.row];
    cell.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    cell.textLabel.font = KFont;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _row = indexPath.row;
    self.title = _searchArray[_row];
    [self top_dismissOptionAlert];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectOptionInHWOptionButton:withBtnType:)]) {
        [_delegate didSelectOptionInHWOptionButton:self withBtnType:self.btnType];
    }
}

@end
