#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPageNumCell : UITableViewCell
@property (copy, nonatomic) NSString *cellTitle;
@property (strong, nonatomic) NSMutableArray *typeDatas;
@property (assign, nonatomic) BOOL showVip;//是否显示vip
@property (nonatomic,copy) void(^top_didSelectedBlock)(NSInteger item);
@property (nonatomic,copy) void(^top_permissionPDFPageNOBlock)(void);
- (void)top_configCellWithData:(NSArray *)data title:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
