//
//  UIDevice+SSDevice.h
//  SimpleScan
//
//  Created by GLA on 2020/11/16.
//  Copyright © 2020 admin3. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (SSDevice)

/// 旋转屏幕
/// @param interfaceOrientation 要强制转屏的方向
+(void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

NS_ASSUME_NONNULL_END
