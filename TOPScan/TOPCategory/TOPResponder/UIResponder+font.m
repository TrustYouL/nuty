//
//  UIResponder+font.m
//  SimpleScan
//
//  Created by admin3 on 2022/1/10.
//  Copyright © 2022 admin3. All rights reserved.
//

#import "UIResponder+font.h"

@implementation UIResponder (font)
#pragma mark font
-(UIFont*)fontsWithSize:(CGFloat)width{

    return [UIFont systemFontOfSize:width];
}

- (UIFont *)boldFontsWithSize:(CGFloat)width {
    return [UIFont boldSystemFontOfSize:(width)];
}


- (CGSize)sizeWithWidth:(CGFloat)width withHeight:(CGFloat)height {
    CGSize size = CGSizeMake((width), (height));
    return size;
}

@end
