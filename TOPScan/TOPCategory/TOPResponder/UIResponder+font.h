//
//  UIResponder+font.h
//  SimpleScan
//
//  Created by admin3 on 2022/1/10.
//  Copyright © 2022 admin3. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (font)

- (UIFont *)fontsWithSize:(CGFloat)width;
- (UIFont *)boldFontsWithSize:(CGFloat)width;
- (CGSize)sizeWithWidth:(CGFloat)width withHeight:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
