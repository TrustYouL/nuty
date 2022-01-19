#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, TRSignatureEditStyle) {
    TRSignatureEditStyleDefault = 0,//默认新增
    TRSignatureEditStyleReset = 1 //重置编辑
    
};
NS_ASSUME_NONNULL_BEGIN

@interface TOPSignatureViewController : UIViewController
@property (nonatomic,copy) void(^top_saveSignatureBlock)(UIImage *signatureImg);
@property (nonatomic,copy) NSString *imagePath;
@property (nonatomic,assign) TRSignatureEditStyle openSignatureStyle;
@property (nonatomic,copy) void(^top_backToResetContentoffset)(void);

@end

NS_ASSUME_NONNULL_END
