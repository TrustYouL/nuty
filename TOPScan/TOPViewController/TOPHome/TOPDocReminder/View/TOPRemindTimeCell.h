
#import <UIKit/UIKit.h>
#import "TOPTextView.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPRemindTimeCell : UITableViewCell<UITextViewDelegate>
@property (nonatomic ,strong)UIView * coverView;
@property (nonatomic ,strong)TOPTextView * timeTV;
@property (nonatomic ,copy)NSString * timeString;
@property (nonatomic ,copy)void(^top_clickAndSetTime)(void);
@end

NS_ASSUME_NONNULL_END
