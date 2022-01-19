#ifndef CommonLibrary_ColorMarcro_h
#define CommonLibrary_ColorMarcro_h

#import "UIColor+MLPFlatColors.h"


// 取色值相关的方法
#define RGB(r,g,b)          [UIColor colorWithRed:(r)/255.f \
                                            green:(g)/255.f \
                                             blue:(b)/255.f \
                                            alpha:1.f]

#define RGBA(r,g,b,a)       [UIColor colorWithRed:(r)/255.f \
                                            green:(g)/255.f \
                                             blue:(b)/255.f \
                                            alpha:(a)]

#define RGBOF(rgbValue)     [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                            green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
                                             blue:((float)(rgbValue & 0xFF))/255.0 \
                                            alpha:1.0]

#define RGBA_OF(rgbValue)   [UIColor colorWithRed:((float)(((rgbValue) & 0xFF000000) >> 24))/255.0 \
                                             green:((float)(((rgbValue) & 0x00FF0000) >> 16))/255.0 \
                                              blue:((float)(rgbValue & 0x0000FF00) >> 8)/255.0 \
                                             alpha:((float)(rgbValue & 0x000000FF))/255.0]

#define RGBAOF(v, a)        [UIColor colorWithRed:((float)(((v) & 0xFF0000) >> 16))/255.0 \
                                            green:((float)(((v) & 0x00FF00) >> 8))/255.0 \
                                             blue:((float)(v & 0x0000FF))/255.0 \
                                            alpha:a]


// 定义通用颜色
#define kBlackColor         [UIColor blackColor]
#define kDarkGrayColor      [UIColor darkGrayColor]
#define kLightGrayColor     [UIColor lightGrayColor]
#define kWhiteColor         [UIColor whiteColor]
#define kGrayColor          [UIColor grayColor]
#define kRedColor           [UIColor redColor]
#define kGreenColor         [UIColor greenColor]
#define kBlueColor          [UIColor blueColor]
#define kCyanColor          [UIColor cyanColor]
#define kYellowColor        [UIColor yellowColor]
#define kMagentaColor       [UIColor magentaColor]
#define kOrangeColor        [UIColor orangeColor]
#define kPurpleColor        [UIColor purpleColor]
#define kClearColor         [UIColor clearColor]

#define kRandomFlatColor    [UIColor randomFlatColor]

#define kUnderLineColor     UIColorFromRGB(0xe8e9ed)

#define kMainColor          [UIColor colorWithRed:0.28 green:0.57 blue:0.94 alpha:1.00]

#define kTabbarNormal       RGB(153, 153, 153)


#define kMainBlueTextColor      [UIColor colorWithHexString:@"007EFF"]
#define kMainGrayTextColor      [UIColor colorWithHexString:@"6B6B6B"]
#define kTextColor              [UIColor colorWithHexString:@"4B4B4B"]
#define kMainBlackTextColor     [UIColor colorWithHexString:@"2B2B2B"]
#define KPlaceHolderColor       [UIColor colorWithHexString:@"BBBBBB"]
#define kMainOrangeColor        [UIColor colorWithHexString:@"FF7200"]
//分割线背景色
#define kMainLineColor          [UIColor colorWithHexString:@"E5E5E5"]

#define kCommonRedTextColor     [UIColor colorWithHexString:@"E44E47"]
#define kCommonBlueTextColor      [UIColor colorWithHexString:@"3D84D8"]
#define kCommonBlackTextColor     RGBA(34, 34, 34, 1.0)
#define kCommonGrayWhiteBgColor    RGBA(241, 241, 241, 1.0)
#define kTopicBlueColor            TOPAPPGreenColor

//颜色的标记

//登录页
#define SettingColor  [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1]

#define ViewBgColor  [UIColor colorWithRed:238/255.0 green:238/255.0 blue:240/255.0 alpha:1]

//#c0c0c0  浅灰色
#define LittleGrayColor  [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1]

//#0088fe 导航栏背景色
#define NaviBgColor  [UIColor colorWithHexString:@"007EFF"]
// tabbar默认颜色
#define TabbarNormalColor  [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.00]
//#888888 浅灰色稍微深一点儿
#define SomeGrayColor  [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1]

//#5bb39d  浅绿色
#define LightGreenColor  [UIColor colorWithRed:88/255.0 green:213/255.0 blue:109/255.0 alpha:1]

//我的界面绿色
#define MyGreenColor  [UIColor colorWithRed:91/255.0 green:179/255.0 blue:157/255.0 alpha:1]


//#dddddd   禁止按钮的背景色
#define ForbidBg  [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1]

//登录页面 title颜色
#define loginTitleColor [UIColor colorWithHexString:@"B7B6B6"]

//#c3c3c3  禁止按钮的文字
#define ForbidTitleColor  [UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1]


//#7c7c7c  转账页里面的
#define TransferColor  [UIColor colorWithRed:124/255.0 green:124/255.0 blue:124/255.0 alpha:1]


//#717171 优惠的时间字体颜色

#define DiscountColor [UIColor colorWithRed:113/255.0 green:113/255.0 blue:113/255.0 alpha:1]


//#a5a5a5
#define MyLabelColor [UIColor colorWithRed:165/255.0 green:165/255.0 blue:165/255.0 alpha:1]


//#aeaeae  修改密码里面的颜色
#define PwdLabelColor [UIColor colorWithRed:165/255.0 green:165/255.0 blue:165/255.0 alpha:1]



//#a2a2a2  交易记录里面的颜色
#define RecordColor [UIColor colorWithRed:162/255.0 green:162/255.0 blue:162/255.0 alpha:1]

#endif
