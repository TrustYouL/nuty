#import "TOPMergeTableView.h"
#import "TOPListFolderTableViewCell.h"
#import "TOPMergeTagCell.h"
#import "TOPMergeCell.h"
@interface TOPMergeTableView()<UITableViewDelegate,UITableViewDataSource>
@end
@implementation TOPMergeTableView
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.showsVerticalScrollIndicator = NO;
        [self registerClass:[TOPMergeTagCell class] forCellReuseIdentifier:NSStringFromClass([TOPMergeTagCell class])];
        [self registerClass:[TOPMergeCell class] forCellReuseIdentifier:NSStringFromClass([TOPMergeCell class])];
        [self registerClass:[TOPListFolderTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPListFolderTableViewCell class])];

    }
    return self;;
}
- (NSMutableArray *)listArray{
    if (!_listArray) {
        _listArray = [NSMutableArray new];
    }
    return _listArray;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DocumentModel *model = self.listArray[indexPath.row];
    if ([model.type isEqualToString:@"0"]) {
        TOPListFolderTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPListFolderTableViewCell class]) forIndexPath:indexPath];
        cell.isMerge = _isMerge;
        cell.model = model;
        weakify(self);
        cell.top_ChoseBtnBlock = ^(BOOL selected){
            DocumentModel * currentModel = [weakSelf.listArray objectAtIndex:indexPath.row];
            currentModel.selectStatus = selected;
            if (weakSelf.top_longPressCheckItemHandler) {
                weakSelf.top_longPressCheckItemHandler(indexPath.row, selected);
            }
            if (weakSelf.top_longPressCalculateSelectedHander) {
                weakSelf.top_longPressCalculateSelectedHander();
            }
        };
        return cell;
    }else{
        if (model.tagsArray.count>0) {
            TOPMergeTagCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPMergeTagCell class]) forIndexPath:indexPath];
            cell.model = model;
            weakify(self);
            cell.top_ChoseBtnBlock = ^(BOOL selected){
                DocumentModel * currentModel = [weakSelf.listArray objectAtIndex:indexPath.row];
                currentModel.selectStatus = selected;
                if (weakSelf.top_longPressCheckItemHandler) {
                    weakSelf.top_longPressCheckItemHandler(indexPath.row, selected);
                }
                if (weakSelf.top_longPressCalculateSelectedHander) {
                    weakSelf.top_longPressCalculateSelectedHander();
                }
            };
            return cell;
        }else{
            TOPMergeCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPMergeCell class]) forIndexPath:indexPath];
            cell.model = model;
            weakify(self);
            cell.top_ChoseBtnBlock = ^(BOOL selected){
                DocumentModel * currentModel = [weakSelf.listArray objectAtIndex:indexPath.row];
                currentModel.selectStatus = selected;
                if (weakSelf.top_longPressCheckItemHandler) {
                    weakSelf.top_longPressCheckItemHandler(indexPath.row, selected);
                }
                if (weakSelf.top_longPressCalculateSelectedHander) {
                    weakSelf.top_longPressCalculateSelectedHander();
                }
            };
            return cell;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 0)];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, 0)];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DocumentModel *model = self.listArray[indexPath.row];
    if ([model.type isEqualToString:@"0"]) {
        return 50;
    }else{
        return 110;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DocumentModel *model = self.listArray[indexPath.row];
    if ([[TOPScanerShare shared] isEditing]) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[TOPListFolderTableViewCell class]]) {
            TOPListFolderTableViewCell * cell11 = (TOPListFolderTableViewCell *)cell;
            cell11.choseBtn.selected = ! cell11.choseBtn.selected;
            model.selectStatus = !model.selectStatus;
        }else if([cell isKindOfClass:[TOPMergeTagCell class]]){
            TOPMergeTagCell * cell22 = (TOPMergeTagCell *)cell;
            cell22.choseBtn.selected = ! cell22.choseBtn.selected;
            model.selectStatus = !model.selectStatus;
        }else{
            TOPMergeCell * cell33 = (TOPMergeCell *)cell;
            cell33.choseBtn.selected = ! cell33.choseBtn.selected;
            model.selectStatus = !model.selectStatus;
        }
    
        if (_isMerge) {
            if ([model.type isEqualToString:@"0"]) {
                if (self.top_pushNextControllerHandler) {
                    self.top_pushNextControllerHandler(model);
                }
                return;
            }
        }
        
        if (self.top_longPressCheckItemHandler) {
            self.top_longPressCheckItemHandler(indexPath.row, model.selectStatus);
        }
        if (self.top_longPressCalculateSelectedHander) {
            self.top_longPressCalculateSelectedHander();
        }
    }else{
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([TOPScanerShare shared].isEditing) {
        return NO;
    }else{
        return YES;
    }
}

- (void)setIsMerge:(BOOL)isMerge{
    _isMerge = isMerge;
    [self reloadData];
}

@end
