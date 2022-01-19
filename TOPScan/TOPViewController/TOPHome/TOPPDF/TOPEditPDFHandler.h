#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPEditPDFHandler : NSObject
@property (strong, nonatomic) NSMutableArray *tempData;
@property (assign, nonatomic) CGFloat aspectRatio;
@property (copy, nonatomic) NSString *filePath;
@property (copy, nonatomic) NSArray *imagePathArr;
@property (strong, nonatomic) NSMutableArray *signatureData;

- (NSMutableArray *)setupPdfDatasProgress:(nonnull void (^)(CGFloat myProgress))progress;
- (NSString*)top_creatPDF:(NSArray *)imgArray documentName:(nonnull NSString *)name progress:(nonnull void (^)(CGFloat myProgress))progress;
- (NSString*)top_creatNOPasswordPDF:(NSArray *)imgArray documentName:(nonnull NSString *)name progress:(nonnull void (^)(CGFloat myProgress))progress;
@end

NS_ASSUME_NONNULL_END
