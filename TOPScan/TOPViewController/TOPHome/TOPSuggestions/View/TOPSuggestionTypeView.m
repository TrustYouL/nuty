#import "TOPSuggestionTypeView.h"
#import "TOPTypeCell.h"

@interface TOPSuggestionTypeView()<UITableViewDelegate ,UITableViewDataSource>
@end
@implementation TOPSuggestionTypeView

- (instancetype)init{
    if (self = [super init]) {
        self.layer.cornerRadius = 10;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 0.3;
        self.clipsToBounds = NO;
    }
    return self;
}

- (UITableView *)myTableView{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStylePlain];
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.layer.cornerRadius = 10;
        _myTableView.layer.masksToBounds = YES;
        _myTableView.showsVerticalScrollIndicator = NO;
        _myTableView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        [_myTableView registerClass:[TOPTypeCell class] forCellReuseIdentifier:NSStringFromClass([TOPTypeCell class])];
    }
    return _myTableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.typeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * typeString = self.typeArray[indexPath.row];
    TOPTypeCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPTypeCell class])];
    cell.titleLab.text = typeString;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * typeString = self.typeArray[indexPath.row];
    if (self.top_sendSuggestionType) {
        self.top_sendSuggestionType(typeString);
    }
}

- (void)setTypeArray:(NSMutableArray *)typeArray{
    _typeArray = typeArray;
    [self addSubview:self.myTableView];
    [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.myTableView reloadData];
}

@end
