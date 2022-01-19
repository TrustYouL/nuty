//
//  UIViewController+ConfigNavBar.m
//  SimpleScan
//
//  Created by GLA on 2021/9/23.
//  Copyright © 2021 admin3. All rights reserved.
//

#import "UIViewController+ConfigNavBar.h"

@implementation UIViewController (ConfigNavBar)

#pragma mark -- 白色背景 黑色字 状态栏高亮
- (void)top_configWhiteBgDarkTitle {
    //状态栏颜色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor];
    [self top_adaptationSystemUpgrade];
}

#pragma mark -- 适配系统更新
- (void)top_adaptationSystemUpgrade {
    NSDictionary *textAtt = @{NSForegroundColorAttributeName:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)],
                              NSFontAttributeName:[UIFont systemFontOfSize:18]};
    if (@available(iOS 15.0, *)){
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor];
        appearance.titleTextAttributes = textAtt;
        appearance.shadowColor = [UIColor clearColor];
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.standardAppearance = appearance;
    } else {
        [self.navigationController.navigationBar setTitleTextAttributes:textAtt];
    }
}

#pragma mark -- 白色背景 黑色字
- (void)top_configLightBgDarkTitle {
    //状态栏颜色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor];
    [self top_adaptationSystemUpgradeLight];
}

- (void)top_adaptationSystemUpgradeLight {
    NSDictionary *textAtt = @{NSForegroundColorAttributeName:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)],
                              NSFontAttributeName:[UIFont systemFontOfSize:18]};
    if (@available(iOS 15.0, *)){
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:kWhiteColor];
        appearance.titleTextAttributes = textAtt;
        appearance.shadowColor = [UIColor clearColor];
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.standardAppearance = appearance;
    } else {
        [self.navigationController.navigationBar setTitleTextAttributes:textAtt];
    }
}

@end
