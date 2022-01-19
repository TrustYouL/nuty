#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPdfSizeModel : NSObject
@property (nonatomic,copy)NSString * pdfSizeTitle;
@property (nonatomic,assign)NSInteger pdfType;
@property (nonatomic,assign)CGFloat pdfSizeW;
@property (nonatomic,assign)CGFloat pdfSizeH;
@property (nonatomic,assign)BOOL cellState;

@end

NS_ASSUME_NONNULL_END
