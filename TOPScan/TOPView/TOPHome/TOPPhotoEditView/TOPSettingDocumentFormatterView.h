#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSettingDocumentFormatterView : UIView
@property (nonatomic ,copy)void(^top_clickToDismiss)(void);
@property (nonatomic ,copy)void(^top_clickCell)(NSString * formatString);
@property (nonatomic ,copy)void(^top_clickCellSendLanguageDic)(NSString * keyString,NSInteger row);
@property (nonatomic ,copy)void(^top_clickCellSendExportType)(BOOL allBtnSelect,NSInteger row);
@property (nonatomic ,copy)void(^top_selectedJPGQualityBlock)(NSString * keyString,NSInteger row);
@property (nonatomic ,assign) TOPFormatterViewEnterType enterType;
@property (nonatomic ,strong) NSMutableArray * languageArray;
@property (nonatomic ,strong) NSArray * dataArray;
@end  

NS_ASSUME_NONNULL_END
