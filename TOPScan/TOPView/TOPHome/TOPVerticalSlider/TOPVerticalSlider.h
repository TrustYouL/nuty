//
//  TOPVerticalSlider.h
//  Seeker
//
//  Created by GLA on 2021/9/15.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPVerticalSlider : UIView
@property (strong, nonatomic) UILabel *valueLabel;
@property (assign, nonatomic) float value;
@property (strong, nonatomic) UIImage *thumImage;
@property (assign, nonatomic) float minimumValue;
@property (assign, nonatomic) float maximumValue;
@property (assign, nonatomic) NSInteger itemCount;

@property (copy, nonatomic) void (^passValue) (float value);
@property (copy, nonatomic) void (^passEndValue) (float value);
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title progressColor:(UIColor *)progressColor thumImage:(NSString *)thumImage;

@end

 
NS_ASSUME_NONNULL_END
