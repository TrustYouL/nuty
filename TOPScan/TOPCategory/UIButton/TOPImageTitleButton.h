#import <UIKit/UIKit.h>

#import "TOPMenuButton.h"

typedef enum
{
    EImageTopTitleBottom,
    ETitleTopImageBottom,
    EImageLeftTitleRight,
    ETitleLeftImageRight,
    
    EImageLeftTitleRightLeft,
    EImageLeftTitleRightCenter,
    
    ETitleLeftImageRightCenter,
    ETitleLeftImageRightLeft,
    
    EFitTitleLeftImageRight, // 根据内容调整
    
}TOPImageTitleButtonStyle;

@interface TOPImageTitleButton : TOPMenuButton
{
@protected
    UIEdgeInsets _margin;
    CGSize _padding;
    CGSize _imageSize;
    TOPImageTitleButtonStyle _style;
}

@property (nonatomic, assign) UIEdgeInsets margin;
@property (nonatomic, assign) CGSize padding;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) TOPImageTitleButtonStyle style;
@property (nonatomic, assign) NSInteger wrbCount;

- (instancetype)initWithStyle:(TOPImageTitleButtonStyle)style;

- (instancetype)initWithStyle:(TOPImageTitleButtonStyle)style maggin:(UIEdgeInsets)margin;

- (instancetype)initWithStyle:(TOPImageTitleButtonStyle)style maggin:(UIEdgeInsets)margin padding:(CGSize)padding;


@end
