

#import <Foundation/Foundation.h>
@interface TOPValidateTools : NSObject

/**
 正则表达式
 */
/**
 *  验证是否为邮箱
 *
 *  @param email 邮箱地址
 *
 *  @return YES  是  NO 不是
 */
+(BOOL)top_validateEmail:(NSString *)email;

/**
 *  验证是否为手机号码
 *
 *  @param mobileNum 手机号码
 *
 *  @return YES  是 NO 不是
 */
+(BOOL)top_validateMobile:(NSString *)mobileNum;

//// 手机号码检查  aaronhua
//+ (BOOL)checkPhone:(NSString *)mobileNumbel;

// 密码格式
+ (BOOL)top_checkPwd:(NSString *)password;

/**
 密码判断是否包含特殊字符
 **/
+ (BOOL)top_specialCharacterPassword:(NSString *)password;
//#pragma 正则匹配用户密码6-16位数字和字母组合
//+ (BOOL)checkPassword:(NSString *)password;
/**
 *  验证是否手机号码或者邮箱
 *
 *  @param validateStr 验证的内容
 *
 *  @return YES 是 NO不是
 */
+(BOOL)top_validateEmailORPhoneNum:(NSString*)validateStr;

//验证是不是标准的m3u8的视频格式
+ (BOOL)top_validateURLWithAVAddress:(NSString *)validateStr;

// 验证字符串是否为空
+ (BOOL)top_validateString:(NSString *)string;
/**
 *  验证密码是否符合标准
 *
 *  @param passWordStr 密码
 *
 *  @return YES  是  NO 非法
 */
+(BOOL)top_validatePassword:(NSString*)passWordStr;


/**
 *  判断字符串是否为空
 *
 *  @param validateStr 需要验证的字符串
 *
 *  @return YES  为空  NO 不为空
 */
+(BOOL)top_validateIsNull:(NSString*)validateStr;


/**
 *  验证用户注册是否通过
 *
 *  @param userName       用户名
 *  @param password       密码
 *  @param repeatPassword 重复密码
 *  @param view           提示View 的位置
 *
 *  @return YES 验证通过  NO 验证不通过
 */
+(BOOL)top_validateRegisterWithUserName:(NSString*)userName
                           password:(NSString*)password
                     repeatPassword:(NSString*)repeatPassword
                               view:(UIView*)view;

/**
 *  验证邮箱格式是否正确
 *
 *  @param email      邮箱
 *
 *  @return YES 验证通过  NO 验证不通过
 */
+ (BOOL)istop_validateEmail:(NSString *)email;

/**
 *  验证手机号格式是否正确
 *
 *  @param emailCode      手机号
 *
 *  @return YES 验证通过  NO 验证不通过
 */
//+ (BOOL)isValidatMobilePhoneCode:(NSString *)emailCode;

/**
 *  验证证件号码格式是否正确
 *
 *  @param emailCode      证件号
 *
 *  @return YES 验证通过  NO 验证不通过
 */
+ (BOOL)top_isValidatMobileCertificates:(NSString *)emailCode;
/**
 *  切换TextField 验证输入的信息
 *
 *  @param textField   当前输入框
 *  @param passwordStr 密码
 *  @param view        显示提醒的View
 */
+(void)top_validateOnChangeTextField:(UITextField*)textField password:(NSString*)passwordStr showInView:(UIView*)view;

/// -- 设备是否越狱
+ (BOOL)top_isJailBreak;

/// -- 下个月的月初
+ (NSTimeInterval)top_beginningOfNextMonth:(NSTimeInterval)time;

@end
