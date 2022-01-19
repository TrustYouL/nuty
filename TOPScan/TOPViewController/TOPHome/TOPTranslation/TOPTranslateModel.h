#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPTranslateModel : NSObject
@property (copy, nonatomic) NSString *language;
@property (copy, nonatomic) NSString *languageCode;
@property (assign, nonatomic) BOOL isSelected;
@property (assign, nonatomic) BOOL isDownloaded;
@property (assign, nonatomic) BOOL isLoading;
@end

NS_ASSUME_NONNULL_END
