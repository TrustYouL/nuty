#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPTranslationView : UIView
@property (nonatomic ,copy)NSString * translationString;
@property (nonatomic,copy) void(^top_beginTranslateBlock)(void);
@property (nonatomic,copy) void(^top_showSourceLanguageBlock)(void);
@property (nonatomic,copy) void(^top_showTargetLanguageBlock)(void);
@property (nonatomic ,copy)NSString *targetTitle;
@property (nonatomic ,copy)NSString *sourceTitle;

@end

NS_ASSUME_NONNULL_END
