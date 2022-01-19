#import "TOPFileTargetTableView.h"
#import "TOPListFolderTableViewCell.h"
#import "TOPListTableViewCell.h"
#import "TOPListTableViewTagsCell.h"
#import "TOPFileTargetModel.h"

static const CGFloat FolderCellHeight = 50;
static const CGFloat DocumentCellHeight = 110;

@interface TOPFileTargetTableView ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation TOPFileTargetTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.showsVerticalScrollIndicator = NO;
        [self registerClass:[TOPListTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPListTableViewCell class])];
        [self registerClass:[TOPListTableViewTagsCell class] forCellReuseIdentifier:NSStringFromClass([TOPListTableViewTagsCell class])];
        [self registerClass:[TOPListFolderTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TOPListFolderTableViewCell class])];
    }
    return self;
}

#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TOPFileTargetModel *model = self.dataArray[indexPath.row];
    if (self.fileTargetType == TOPFileTargetTypeFolder) {
        TOPListFolderTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPListFolderTableViewCell class]) forIndexPath:indexPath];
        [cell top_configCellWithData:model];
        if (indexPath.row == self.dataArray.count-1) {
            cell.lineView.hidden = YES;
        }else{
            cell.lineView.hidden = NO;
        }
        return cell;
    }else{
        if (model.tagsArray.count>0) {
            TOPListTableViewTagsCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPListTableViewTagsCell class]) forIndexPath:indexPath];
            [cell top_configCellWithData:model];
            if (indexPath.row == self.dataArray.count-1) {
                cell.lineView.hidden = YES;
            }else{
                cell.lineView.hidden = NO;
            }
            return cell;
        }else{
            TOPListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPListTableViewCell class]) forIndexPath:indexPath];
            [cell top_configCellWithData:model];
            if (indexPath.row == self.dataArray.count-1) {
                cell.lineView.hidden = YES;
            }else{
                cell.lineView.hidden = NO;
            }
            return cell;
        }
    }
}

#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.fileTargetType == TOPFileTargetTypeFolder) {
        return FolderCellHeight;
    }
    return DocumentCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TOPFileTargetModel *model = self.dataArray[indexPath.row];
    [TOPFileDataManager shareInstance].fileModel = model;
    if (self.top_didSelectFileBlock) {
        self.top_didSelectFileBlock(model); 
    }
}


@end
