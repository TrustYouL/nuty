#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPShareDownSizeView : UIView

@property (nonatomic ,assign)NSInteger compressType;//压缩方式
@property (nonatomic ,strong)NSMutableArray * dataArray;//首页分享的数据
@property (nonatomic ,strong)NSMutableArray * childArray;//内部分享数据
@property (nonatomic ,copy)NSString * numberStr;
@property (nonatomic ,assign)CGFloat totalNum;
@property (nonatomic ,strong)UITableView * tableView;
@property (nonatomic ,copy)NSString * pdfPath;
@property (nonatomic ,copy) void(^chooseShareType)(CGFloat rate);
- (instancetype)initWithTitleView:(UIView *)titleView
                       optionsArr:(NSArray *)optionsArr
                      cancelTitle:(NSString *)cancelTitle
                      cancelBlock:(void(^)(void))cancelBlock
                      selectBlock:(void(^)(NSMutableArray * shareArray))selectBlock;

- (instancetype)initWithTitleView:(UIView *)titleView
                       optionsArr:(NSArray *)optionsArr
                      cancelTitle:(NSString *)cancelTitle
                      cancelBlock:(void(^)(void))cancelBlock
                      selectItemBlock:(void(^)(CGFloat rate))selectItemBlock;
@end

NS_ASSUME_NONNULL_END
