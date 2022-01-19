#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,PDFSettingType)
{
    PDFSettingTypeFileName = 1,         //PDF文件名字
    PDFSettingTypePageNumber,           //页码
    PDFSettingTypePageDirection,        //纸张朝向
};

NS_ASSUME_NONNULL_BEGIN

@interface TOPPDFSettingViewController : UIViewController
@property (copy, nonatomic) NSArray *signatureArr;
@property (copy, nonatomic) NSString *pdfName;
@property (nonatomic, copy) void(^top_editPDFNameBlock)(NSString *name);
@property (nonatomic, copy) void(^top_editPDFNumLayoutBlock)(void);
@property (nonatomic, copy) void(^top_editPDFDirectionBlock)(void);

@end

NS_ASSUME_NONNULL_END
