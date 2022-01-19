#import <UIKit/UIKit.h>
#import "TOPSettingEmailModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPSettingEmailCell : UITableViewCell<UITextFieldDelegate,UITextViewDelegate>
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UITextField * titleField;
@property (nonatomic ,strong)UITextView * textView;
@property (nonatomic ,strong)UIView * lineView;
@property (nonatomic ,assign)NSInteger row;
@property (nonatomic ,assign)BOOL isKeyBoardShow;
@property (nonatomic ,assign)BOOL isKeyBoardHide;
@property (nonatomic ,strong)TOPSettingEmailModel * model;
@property (nonatomic ,copy)void(^top_beginEdit)(NSInteger row);
@property (nonatomic ,copy)void(^top_returnEdit)(void);
@property (nonatomic ,copy)void(^top_sendTextFieldText)(NSString * text,NSInteger row);
@end

NS_ASSUME_NONNULL_END
