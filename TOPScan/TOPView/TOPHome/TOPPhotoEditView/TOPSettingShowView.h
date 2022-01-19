#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSettingShowView : UIView
@property (nonatomic ,strong)UITableView * tableView;
@property (nonatomic ,copy)NSString * showType;
@property (nonatomic ,copy)NSArray * dataArray;
@property (nonatomic ,copy)NSArray * pdfSizeArray;
@property (nonatomic ,copy)NSArray * filterArray;
@property (nonatomic ,copy)void (^top_clickDismiss)(NSInteger row,NSString * type);
@end

NS_ASSUME_NONNULL_END
