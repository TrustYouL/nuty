#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPQuestionDescribeCell : UITableViewCell<UITextViewDelegate>
@property (nonatomic ,strong)UITextView * textView;
@property (nonatomic ,copy)NSString * placerString;
@property (nonatomic ,copy)NSString * textContent;
@property (nonatomic ,assign)NSInteger row;
@property (nonatomic ,copy)void(^top_startEdit)(UITextView * myTV);
@property (nonatomic ,copy)void(^top_sendEditcontent)(NSString * contentString,NSInteger row);
@end

NS_ASSUME_NONNULL_END
