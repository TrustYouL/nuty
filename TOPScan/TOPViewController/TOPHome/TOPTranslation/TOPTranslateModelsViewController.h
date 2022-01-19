#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPTranslateModelsViewController : UIViewController
@property (nonatomic ,copy) NSString *sourceLanguage;//源语言
@property (nonatomic ,copy) NSString *targetLanguage;//目标语言

@property (nonatomic,copy) void(^top_selectedLanguageBlock)(NSString *languageCode);

@end

NS_ASSUME_NONNULL_END
