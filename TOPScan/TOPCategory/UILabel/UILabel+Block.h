#import <UIKit/UIKit.h>

#pragma mark- STRUCT_LINEMTHOD

typedef struct{
    __unsafe_unretained NSString * attributeName;
    __unsafe_unretained id value;
    NSRange range;
}PZAttributedMode;
CG_INLINE PZAttributedMode PZAttributedMake(NSString * s, id i, NSRange r)
{
    PZAttributedMode mode;
    mode.attributeName = s;
    mode.value = i;
    mode.range = r;
    return mode;
}
CG_INLINE NSValue* PZAttributedModeToValue(PZAttributedMode aMode)
{
    NSValue * value = [NSValue valueWithBytes:&aMode objCType:@encode(PZAttributedMode)];
    return value;
}
CG_INLINE PZAttributedMode ValueToPZAttributedMode(NSValue * value)
{
    PZAttributedMode aMode;
    [value getValue:&aMode];
    return aMode;
}

#pragma mark- TYPEDEF_BLOCK
typedef void (^ZYLabelBasicSetBlock)(UILabel * lab);
typedef void (^ZYLabelAfterHandleBlock)(UILabel * lab,NSTimeInterval time);
@interface UILabel (Block)

#pragma mark- NEW_METHOD
+(UILabel *)label_Alloc:(ZYLabelBasicSetBlock)basicSet;
+(UILabel *)label_Alloc:(ZYLabelBasicSetBlock)basicSet addView:(UIView *)superView;
-(void)label_basicSet:(ZYLabelBasicSetBlock)basicSet;
+(UILabel *)label_AllocAutoMask:(ZYLabelBasicSetBlock)basicSet withText:(NSString *)text lineBreakMode:(NSLineBreakMode)lineBreakMode font:(UIFont *)font withLabelFrame:(CGRect)frame heightMask:(BOOL)heightMask;
+(UILabel *)label_AllocAutoMask:(ZYLabelBasicSetBlock)basicSet withText:(NSString *)text lineBreakMode:(NSLineBreakMode)lineBreakMode font:(UIFont *)font withLabelFrame:(CGRect)frame heightMask:(BOOL)heightMask addView:(UIView *)superView;
-(void)label_AutoMaskWithHeightMask:(BOOL)heightMask;
+(UILabel *)label_AllocColorAdverb:(ZYLabelBasicSetBlock)basicSet withColor:(UIImage *)image;
+(UILabel *)label_AllocColorAdverb:(ZYLabelBasicSetBlock)basicSet withColor:(UIImage *)image addView:(UIView *)superView;
-(void)label_ColorAdverb:(UIImage *)image;
+(UILabel *)label_AllocAttributedString:(ZYLabelBasicSetBlock)basicSet withText:(NSString *)text attributedMode:(NSArray<NSValue *> *)attributedArray;
+(UILabel *)label_AllocAttributedString:(ZYLabelBasicSetBlock)basicSet withText:(NSString *)text attributedMode:(NSArray<NSValue *> *)attributedArray addView:(UIView *)superView;
-(void)label_AttributedString:(NSString *)text attributedMode:(NSArray<NSValue *> *)attributedArray;
-(void)showUnderLine;
-(void)showDeleteLine:(UIColor *)color;
-(void)lab_AutoRowMove:(ZYLabelAfterHandleBlock)handleBlock withReqeat:(BOOL)bol_NeedRepead;
@end
