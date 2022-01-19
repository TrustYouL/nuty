#import <UIKit/UIKit.h>

#import "TOPMenuAbleItem.h"
#import "TOPMenuItem.h"
#import "TOPRoundedButton.h"

@interface TOPMenuButton : TOPRoundedButton<TOPMenuAbleItem>

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) NSString *title;

- (instancetype)initWithTitle:(NSString *)title action:(MenuAction)action;

- (instancetype)initWithBackground:(UIImage *)icon action:(MenuAction)action;

- (instancetype)initWithMenu:(TOPMenuItem *)item;

- (void)setClickAction:(MenuAction)action;

// protected
- (void)onClick:(id)sender;

@end
