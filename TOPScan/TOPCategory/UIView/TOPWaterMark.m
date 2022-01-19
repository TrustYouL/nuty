#import "TOPWaterMark.h"
//这三个属性 主要是让水印文字和水印文字之间间隔的效果，以及水印的文字的倾斜角度 ，不设置默认为平行角度
#define HORIZONTAL_SPACEING 60//水平间距
#define VERTICAL_SPACEING 50//竖直间距
#define CG_TRANSFORM_ROTATING -(M_PI_2 / 3)//旋转角度(正旋45度 || 反旋45度)

@implementation TOPWaterMark

+ (UIImage*)view:(UIImageView *)view WaterImageWithImage:(UIImage *)image text:(NSString *)text {
    view.backgroundColor = [UIColor clearColor];
    //设置水印大小，可以根据图片大小或者view大小
    CGFloat  img_w = view.bounds.size.width;
    CGFloat  img_h = view.bounds.size.height;
    //1.开启上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(img_w, img_h), NO, 0.0);
    //2.绘制图片 水印图片
    [image drawInRect:CGRectMake(0, 0, img_w, img_h)];
    
    /* --添加水印文字样式--*/
    UIFont * font = [UIFont systemFontOfSize:[[NSUserDefaults standardUserDefaults] floatForKey:TOP_TRWatermarkTextFontValueKey]]; //水印文字大小
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:TOP_TRWatermarkTextColorKey];
    UIColor *textColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    CGFloat opacity = [[NSUserDefaults standardUserDefaults] floatForKey:TOP_TRWatermarkTextOpacityKey];
    UIColor *color = [textColor colorWithAlphaComponent:opacity];
    NSDictionary * attr = @{NSFontAttributeName:font,NSForegroundColorAttributeName:color};
    NSMutableAttributedString * attr_str =[[NSMutableAttributedString alloc]initWithString:text attributes:attr];
    
    //文字：字符串的宽、高
    CGFloat str_w = attr_str.size.width;
    CGFloat str_h = attr_str.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(img_w/2, img_h/2));
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(CG_TRANSFORM_ROTATING));
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-img_w/2, -img_h/2));
    CGFloat sqrtLength = sqrt(img_w*img_w + img_h*img_h);
    
    int count_Hor = sqrtLength / (str_w + HORIZONTAL_SPACEING) + 1;
    int count_Ver = sqrtLength / (str_h + VERTICAL_SPACEING) + 1;
    
    //此处计算出需要绘制水印文字的起始点，由于水印区域要大于图片区域所以起点在原有基础上移
    CGFloat orignX = -(sqrtLength-img_w)/2;
    CGFloat orignY = -(sqrtLength-img_h)/2;
    
    //在每列绘制时X坐标叠加
    CGFloat overlayOrignX = orignX;
    //在每行绘制时Y坐标叠加
    CGFloat overlayOrignY = orignY;
    for (int i = 0; i < count_Hor * count_Ver; i++) {
        //绘制图片
        [text drawInRect:CGRectMake(overlayOrignX, overlayOrignY, str_w, str_h) withAttributes:attr];
        if (i % count_Hor == 0 && i != 0) {
            overlayOrignX = orignX;
            overlayOrignY += (str_h + VERTICAL_SPACEING);
        }else{
            overlayOrignX += (str_w + HORIZONTAL_SPACEING);
        }
    }
    
    //3.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //4.关闭图形上下文
    UIGraphicsEndImageContext();
    CGContextRestoreGState(context);
    //用png格式保存，因为jpg不支持透明效果
    NSData *imgData = UIImagePNGRepresentation(newImage);
    [imgData writeToFile:[TOPDocumentHelper top_waterMarkTextImagePath] atomically:YES];
    return newImage;
}

@end

