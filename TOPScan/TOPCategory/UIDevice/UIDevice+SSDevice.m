//
//  UIDevice+SSDevice.m
//  SimpleScan
//
//  Created by GLA on 2020/11/16.
//  Copyright © 2020 admin3. All rights reserved.
//

#import "UIDevice+SSDevice.h"

@implementation UIDevice (SSDevice)

+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSNumber *resetOrientationTarget = [NSNumber numberWithInteger:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:TOP_TROrientationKey];
    NSNumber *orientationTarget = [NSNumber numberWithInteger:interfaceOrientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:TOP_TROrientationKey];
}

@end
