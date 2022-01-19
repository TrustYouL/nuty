#import <Foundation/Foundation.h>

@protocol TOPMenuAbleItem;

typedef void (^MenuAction)(id<TOPMenuAbleItem> menu);

@protocol TOPMenuAbleItem <NSObject>


- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon action:(MenuAction)action;

@optional
- (NSString *)title;
- (UIImage *)icon;
- (void)menuAction;
- (NSInteger)tag;
- (void)setTag:(NSInteger)tag;

@optional
- (UIColor *)foreColor;

@end
