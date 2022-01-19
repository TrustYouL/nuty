#import "TOPTagsManagerTableView.h"
#import "TOPTagsManagerCell.h"
#import "TOPTagsManagerModel.h"
@interface TOPTagsManagerTableView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)NSMutableArray * defaultTagsArray;
@property (nonatomic,strong)NSMutableArray * tagsArray;
@end
@implementation TOPTagsManagerTableView
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style]) {
        self.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
        self.backgroundColor = TOPAppBackgroundColor;
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.showsVerticalScrollIndicator = NO;
        [self registerClass:[TOPTagsManagerCell class] forCellReuseIdentifier:NSStringFromClass([TOPTagsManagerCell class])];
    }
    return self;;
}

- (NSMutableArray *)defaultTagsArray{
    if (!_defaultTagsArray) {
        _defaultTagsArray = [NSMutableArray new];
    }
    return _defaultTagsArray;
}

- (NSMutableArray *)tagsArray{
    if (!_tagsArray) {
        _tagsArray = [NSMutableArray new];
    }
    return _tagsArray;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.defaultTagsArray.count;
    }else{
        return self.tagsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TOPTagsManagerCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPTagsManagerCell class]) forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.model = self.defaultTagsArray[indexPath.item];
    }else{
        cell.model = self.tagsArray[indexPath.item];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 10)];
    header.backgroundColor = TOPAppBackgroundColor;
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 10)];
    footerView.backgroundColor = TOPAppBackgroundColor;
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 6;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}



- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)){
    //删除
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:NSLocalizedString(@"topscan_delete", @"") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        completionHandler(YES);
    }];
    deleteRowAction.image = [UIImage imageNamed:@"top_sideDelete"];
    deleteRowAction.backgroundColor = [UIColor redColor];
    
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    return config;
}

- (void)setDataArray:(NSArray *)dataArray{
    [self.defaultTagsArray removeAllObjects];
    [self.tagsArray removeAllObjects];
    for (TOPTagsListModel * model in dataArray) {
        TOPTagsManagerModel * managerModel = [TOPTagsManagerModel new];
        managerModel.tagsListModel = model;
        managerModel.isEdit = NO;
        if ([model.tagName isEqualToString:TOP_TRTagsAllDocesKey]||[model.tagName isEqualToString:TOP_TRTagsUngroupedKey]) {
            [self.defaultTagsArray addObject:managerModel];
        }else{
            [self.tagsArray addObject:managerModel];
        }
    }
    [self reloadData];
}

- (void)setIsEdit:(BOOL)isEdit{
    _isEdit = isEdit;
    for (TOPTagsManagerModel * model in self.tagsArray) {
        model.isEdit = _isEdit;
    }
    NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndex:1];
    [self reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}
@end
