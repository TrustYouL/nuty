#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPCodeReaderResultView : UIView
@property (nonatomic ,copy)NSString * resultString;
@property (nonatomic ,copy)void(^top_clickBtnAction)(NSInteger tag,NSString * resultString);
@property (nonatomic ,copy)void(^top_clickShowBtnAction)(BOOL isSelect);
- (void)top_setupUI;
@end

NS_ASSUME_NONNULL_END
