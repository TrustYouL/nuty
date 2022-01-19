#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPFunctionColletionListCell : UITableViewCell
@property (nonatomic ,strong)UILabel * deviceNameLab;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIImageView * iconImg;
@property (nonatomic ,strong)UIImageView * rowImg;
@property (nonatomic ,strong)UIView * lineView;
@property (nonatomic ,copy)NSString * folderPath;
@end

NS_ASSUME_NONNULL_END
