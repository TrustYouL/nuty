#import "TOPColorMenuView.h"

@interface TOPColorMenuView()<UIGestureRecognizerDelegate>
@property (strong, nonatomic) UIView *selectedColorItem;


@end

@implementation TOPColorMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setColorsArray:(NSArray *)colorsArray {
    _colorsArray = colorsArray;
    [self top_colorMenu];
}

- (void)setCurrentColor:(UIColor *)currentColor {
    if (currentColor) {
        _currentColor = currentColor;
        [self top_setSelectedItemWithColor:_currentColor];
    }
}

- (void)top_setSelectedItemWithColor:(UIColor *)color {
    [self.selectedColorItem removeFromSuperview];
    self.selectedColorItem = nil;
    NSArray *colors = self.colorsArray;
    CGFloat menuWidth = CGRectGetWidth(self.bounds) - 40;
    CGFloat menuHeight = 40;
    CGFloat itemWidth = menuWidth / colors.count;
    CGFloat itemY = 15;
    for (int i = 0; i < colors.count; i ++) {
        UIColor *itemColor = colors[i];
        if ([self top_isEqualColor:itemColor toColor:color]) {
            self.selectedColorItem = [[UIView alloc] initWithFrame:CGRectMake(20 + i*itemWidth, itemY, itemWidth, menuHeight)];
            self.selectedColorItem.backgroundColor = itemColor;
            break;
        }
    }
    if (self.selectedColorItem) {
        [self addSubview:self.selectedColorItem];
        [self top_highlightSelectColor:self.selectedColorItem];
    }
}

- (void)top_colorMenu {
    NSArray *colors = self.colorsArray;
    CGFloat menuWidth = CGRectGetWidth(self.bounds) - 40;
    CGFloat menuHeight = 40;
    CGFloat itemWidth = menuWidth / colors.count;
    CGFloat itemY = 15;
    for (int i = 0; i < colors.count; i ++) {
        UIColor *itemColor = colors[i];
        UIView *item = [self colorView];
        item.backgroundColor = itemColor;
        item.frame = CGRectMake(20 + i*itemWidth, itemY, itemWidth, menuHeight);
        [self addSubview:item];
    }
}

- (void)top_highlightSelectColor:(UIView *)view {
    UIColor *selectColor = view.backgroundColor;
    if (self.didSelectedItemBlock) {
        self.didSelectedItemBlock(selectColor);
    }
    if (self.selectedColorItem) {
        self.selectedColorItem.transform = CGAffineTransformIdentity;
    }
    CGFloat scale = 1.3;
    self.selectedColorItem.center = view.center;
    self.selectedColorItem.backgroundColor = selectColor;
    [UIView animateWithDuration:0.3
                     animations:^{
        self.selectedColorItem.transform = CGAffineTransformScale(self.selectedColorItem.transform, scale, scale);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark -- 判断两个颜色是否相同
- (BOOL)top_isEqualColor:(UIColor *)color1 toColor:(UIColor *)color2 {
    NSArray *rgbs1 = [self top_getRGBWithColor:color1];
    NSArray *rgbs2 = [self top_getRGBWithColor:color2];
    BOOL isEq = YES;
    for (int i = 0; i < rgbs1.count; i ++) {
        CGFloat rgbItem = [rgbs1[i] floatValue];
        if (i < rgbs2.count) {
            CGFloat rgbItem2 = [rgbs2[i] floatValue];
            if (rgbItem != rgbItem2) {
                isEq = NO;
                break;
            }
        }
    }
    return isEq;
}

#pragma mark -- 获取颜色的r、g、b
- (NSArray *)top_getRGBWithColor:(UIColor *)color {
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return @[@(red), @(green), @(blue), @(alpha)];
}

#pragma mark -- 单个颜色块
- (UIView *)colorView {
    UIView *item = [[UIView alloc] init];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.delegate = self;
    [item addGestureRecognizer:tapGesture];
    return item;
}

#pragma mark -- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *colorView = touch.view;
    [self top_highlightSelectColor:colorView];
    return YES;
}

@end
