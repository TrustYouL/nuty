#import "TOPTransferDataTableView.h"
#import "TOPTransferModel.h"
#import "TOPTransferCell.h"

@interface TOPTransferDataTableView ()<UITableViewDelegate, UITableViewDataSource>
@property (assign, nonatomic) BOOL isSelect;
@end

@implementation TOPTransferDataTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:TOPAppBackgroundColor];
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.showsVerticalScrollIndicator = NO;
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        [self registerClass:[TOPTransferCell class] forCellReuseIdentifier:NSStringFromClass([TOPTransferCell class])];
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
    TOPTransferCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TOPTransferCell class]) forIndexPath:indexPath];
    TOPTransferModel *model = self.dataArray[indexPath.row];
    [cell top_configCellWithData:model];
    return cell;
}

#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSelect == false) {
         self.isSelect = true;
        [self performSelector:@selector(top_repeatDelay) withObject:nil afterDelay:1.0f];
        if (self.top_didSelectItemBlock) {
            self.top_didSelectItemBlock(indexPath.row);
        }
    }
}

- (void)top_repeatDelay{
      self.isSelect = false;
}

@end
