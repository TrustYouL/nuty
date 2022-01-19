#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TOPOpenCVWrapper : NSObject
+(NSMutableArray *)top_getLargestSquarePoints: (UIImage *) image : (CGSize) size :(BOOL)isAutomatic;
+(UIImage *)top_getTransformedImage: (CGFloat) newWidth : (CGFloat) newHeight : (UIImage *) origImage : (CGPoint [4]) corners : (CGSize) size;
+(UIImage *)top_getTransformedObjectImage: (CGFloat) newWidth : (CGFloat) newHeight : (UIImage *) origImage : (NSArray *) corners : (CGSize) size;
+(UIImage *)top_getNoShardingImage:(UIImage *) origImage;

@end
