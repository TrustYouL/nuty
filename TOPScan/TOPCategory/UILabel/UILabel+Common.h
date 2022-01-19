#import <UIKit/UIKit.h>

@interface UILabel (Common)
+ (instancetype)label;

+ (instancetype)labelWithTitle:(NSString *)title;
// 已知区域重新调整
- (CGSize)contentSize;
// 不知区域，通过其设置区域
- (CGSize)textSizeIn:(CGSize)size;

//- (void)layoutInContent;

@end
@interface InsetLabel : UILabel
@property (nonatomic, assign) UIEdgeInsets contentInset;
@end
