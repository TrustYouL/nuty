#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSuggestionTypeView : UIView
@property (nonatomic ,strong)NSMutableArray * typeArray;
@property (nonatomic ,strong)UITableView * myTableView;
@property (nonatomic ,copy)void(^top_sendSuggestionType)(NSString * suggestionType);
@end

NS_ASSUME_NONNULL_END
