#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPhotoShowNoteView : UIView
@property (nonatomic ,strong)UITextView * textView;
@property (nonatomic ,copy)NSString * noteString;
@property (nonatomic ,copy)void (^top_sendTextViewContent)(NSString * contentString);
@end

NS_ASSUME_NONNULL_END
