#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPageDirectionModel : NSObject
@property (copy, nonatomic) NSString *typeTitle;
@property (copy, nonatomic) NSString *typeImage;
@property (copy, nonatomic) NSString *typeHighImage;
@property (assign, nonatomic) TOPPDFPageDirectionType pageDirectionType;
@property (assign, nonatomic) BOOL isHigh;
@end

NS_ASSUME_NONNULL_END
