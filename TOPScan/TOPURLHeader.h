//
//  TOPURLHeader.h
//  SimpleScan
//
//  Created by admin3 on 2021/7/30.
//  Copyright © 2021 admin3. All rights reserved.
//

#ifndef TOPURLHeader_h
#define TOPURLHeader_h
#define TOP_TRFAQURL                @"https://www.tongsoftinfo.com/simple-scanner/FAQ.html"//FAQ
#define TOP_TRPrivacyPolicyURL      @"https://www.tongsoftinfo.com/simple-scanner/Privacy-Policy.html"//Privacy Policy
#define TOP_TRUserAgreementURL      @"https://tongsoftinfo.com/Termsofuse.html"//UserAgreement
#define TOP_TRAppStroeLink            @"https://itunes.apple.com/app/apple-store/id1531265666"//在appStore的链接

//// 域名
//#define HOST @"https://fax.tongsoft.top"
#define HOST @"https://simplescanner.tongsoft.top"
// 域名
#define HHOST @"https://www.tongsoft.top"
/**
 用户意见反馈
 */
#define TOP_TRUserFeedBack [NSString stringWithFormat:@"%@/feedBack/addFeedBack",HOST]
/**
 ocr识别的完成之后 识别的页数
 */
#define TOP_TROCRUsedPages [NSString stringWithFormat:@"%@/ocr/addOcrUsedPages",HOST]

/**
新增订阅
 */
#define TOP_TRAddAppleIAPServer [NSString stringWithFormat:@"%@/simpleScannerSubscription/addSubscription",HOST]

/**
充值校验
 */
#define TOP_TRBuyCreditsCheck [NSString stringWithFormat:@"%@/scanIAP/addOCR",HOST]

/**
获取app版本信息 控件禁用
 */
#define TOP_TRGETSubscriptInfo [NSString stringWithFormat:@"%@/simpleScannerSubscription/getSubscription",HOST]
/**
获取app版本信息 控件禁用
 */
#define TOP_TRVersionFunctionInfo [NSString stringWithFormat:@"%@/VersionFunction",HHOST]

/**
验证获取验证码
 */
#define TOP_TRVerificationCodeVerification [NSString stringWithFormat:@"%@/emailVerification/verificationCodeVerification",HHOST]

/**
获取验证码
 */
#endif /* TOPURLHeader_h */
