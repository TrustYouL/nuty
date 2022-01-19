#import <UIKit/UIKit.h>

@interface UIView (JXExtension)
/** x值 */
@property (nonatomic,assign) CGFloat x;
/** y值 */
@property (nonatomic,assign) CGFloat y;
/** 宽度 */
@property (nonatomic,assign) CGFloat width;
/** 高度 */
@property (nonatomic,assign) CGFloat height;
/** 大小size */
@property (nonatomic,assign) CGSize size;
/** 中心点Y值 */
@property (nonatomic,assign) CGFloat centerY;
/** 中心点X值 */
@property (nonatomic,assign) CGFloat centerX;

@property (nonatomic, assign) CGPoint origin;
//计算文本高度
+ (CGRect)boundStr:(NSString *)str size:(CGSize)size font:(UIFont*)font;
@end
