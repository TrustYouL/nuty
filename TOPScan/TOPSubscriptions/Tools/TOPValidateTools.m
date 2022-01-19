

#import "TOPValidateTools.h"

@implementation TOPValidateTools
//利用正则表达式验证
+(BOOL)top_validateEmail:(NSString *)email {
    
    NSString *regex =@"^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [emailTest evaluateWithObject:email];
}

+(BOOL)top_validateMobile:(NSString *)mobileNum
{
    //手机号以13、15、18开头，八个\d数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9])|(13[0-9])|(17[0-9])|(16[0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobileNum];
}

// 密码格式
+ (BOOL)top_checkPwd:(NSString *)password{
    NSString *pwdRegex = @"^[A-Za-z0-9@!#%&*-+/:;?,.]{6,16}$";
    NSPredicate *pwdTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pwdRegex];
    return [pwdTest evaluateWithObject:password];
}

/**
 密码判断是否包含特殊字符
 **/
+ (BOOL)top_specialCharacterPassword:(NSString *)password
{
    NSString *pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,16}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
    
}
/**
 *  判断字符串是否为空
 *
 *  @param validateStr 需要验证的字符串
 *
 *  @return YES  为空  NO 不为空
 */
+(BOOL)top_validateIsNull:(NSString*)validateStr{

    return validateStr.length>0?NO:YES;

}

//验证是不是标准的m3u8的视频格式
+ (BOOL)top_validateURLWithAVAddress:(NSString *)validateStr {
    //以.m3u8结尾
    return ([validateStr hasSuffix:@".m3u8"] && [validateStr hasPrefix:@"htt"]);
}

// 验证字符串是否为空
+ (BOOL)top_validateString:(NSString *)string {
    if (string == nil || string == NULL || [string isKindOfClass:[NSNull class]] || [string isEqualToString:@"null"] || string.length == 0) {
        return YES;
    }
    return NO;
}



+(BOOL)top_validateEmailORPhoneNum:(NSString*)validateStr{
    

    
    return ([self top_validateEmail:validateStr]||[self top_validateMobile:validateStr]);
}

+(BOOL)top_validatePassword:(NSString*)passWordStr{

    return passWordStr.length>=6?YES:NO;
}
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
                               view:(UIView*)view
    {
    
        
        if (![TOPValidateTools top_validateIsNull:userName]) {
            if (![TOPValidateTools  top_validateEmailORPhoneNum:userName]) {
                
//                 [MBProgressHUD showError:@"请输入正确的邮箱或手机账号"];
                
                return NO;

            }
        }else{

            return NO;
            
        }
        
      
    
    
         if (![TOPValidateTools top_validateIsNull:password]) {
            
            if (![TOPValidateTools top_validatePassword:password]) {
                
//                 [MBProgressHUD showError:@"密码长度至少6位"];
                
                
                return NO;
            }

         }else{
           
             
//             [MBProgressHUD showError:@"密码不能为空"];
             
             return NO;
         }
        
        
        
        if (![TOPValidateTools top_validateIsNull:repeatPassword]) {
            
            if (![repeatPassword isEqualToString:password]) {
                
                
//                 [MBProgressHUD showError:@"两次输入密码不一致"];
                return NO;
            }
            
        }else{
//               [MBProgressHUD showError:@"重复密码不能为空"];
            
            return NO;
        }
        
    return YES;
}


//用户名
+ (BOOL)isValidateAccount:(NSString *)email {
    NSString *AccountRegex = @"^(?!_)(?!.*?_$)[a-zA-Z0-9_\u4e00-\u9fa5]{2,16}$";
    //    NSString *AccountRegex = @"[a-zA-Z0-9_\u4e00-\u9fa5]+$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", AccountRegex];
    return [emailTest evaluateWithObject:email];
}
//邮箱
+ (BOOL)istop_validateEmail:(NSString *)email {
    NSString *emailRegex = @"\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
//固话
+ (BOOL)isValidatPhoneCode:(NSString *)emailCode {
    NSString *emailRegex = @"^0(10|2[0-5789]|\\d{3,4})-\\d{7,8}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailCode];
}
//手机
+ (BOOL)isValidatMobilePhoneCode:(NSString *)emailCode {
    NSString *emailRegex = @"^(?:(?:1\\d{10})|(?:0(?:10|2[0-57-9]|[3-9]\\d{2})-)?\\d{7,8})$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailCode];
}
//证件
+ (BOOL)top_isValidatMobileCertificates:(NSString *)emailCode {
    NSString *emailRegex = @"^.[A-Za-z0-9]+$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailCode];
}
//名称
+ (BOOL)isValidatMobileChinaName:(NSString *)emailCode {
    NSString *emailRegex = @"[\u4e00-\u9fa5]{2,32}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailCode];
}
//密码
+ (BOOL)isValidatMobilePassWord:(NSString *)emailCode {
    NSString *emailRegex = @"^[a-zA-Z0-9\\.]{5,10}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailCode];
}


/**
 *  切换TextField 验证输入的信息
 *
 *  @param textField   当前输入框
 *  @param passwordStr 密码
 *  @param view        显示提醒的View
 */
+(void)top_validateOnChangeTextField:(UITextField*)textField password:(NSString*)passwordStr showInView:(UIView*)view{

    
    switch (textField.tag) {
        case 11:
            
            
            if (![TOPValidateTools top_validateEmailORPhoneNum:textField.text]) {
           
                
//                [MBProgressHUD showError:@"请输入正确的邮箱或手机账号"];
            }
            
            
            break;
            

        case 22:
            
            if (![TOPValidateTools top_validatePassword:textField.text]) {
                
//                 [MBProgressHUD showError:@"密码长度至少6位"];
            }
            
            break;
        case 33:
            
            if ([TOPValidateTools top_validateIsNull:textField.text]) {
         
                
//                [MBProgressHUD showError:@"重复密码不能为空"];
            }else{
                
                if (![textField.text isEqualToString:passwordStr]) {
            
//                     [MBProgressHUD showError:@"两次输入密码不一致" ];
                }
            }
            
            
            break;
            
            
        default:
            break;
    }
}

#pragma mark -- 设备是否越狱
+ (BOOL)top_isJailBreak {
    BOOL isJail = NO;
    /// 根据是否能打开cydia判断
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        isJail = YES;
    }
    /// 根据是否能获取所有应用的名称判断 没有越狱的设备是没有读取所有应用名称的权限的。
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"User/Applications/"]) {
        isJail = YES;
    }
    
    NSArray *jailbreak_tool_paths = @[
        @"/Applications/Cydia.app",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/bin/bash",
        @"/usr/sbin/sshd",
        @"/etc/apt"
    ];
    
    /// 判断这些文件是否存在，只要有存在的，就可以认为手机已经越狱了。
    for (int i=0; i<jailbreak_tool_paths.count; i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:jailbreak_tool_paths[i]]) {
            isJail = YES;
            break;
        }
    }
    
    return isJail;
}

+ (NSTimeInterval)top_beginningOfNextMonth:(NSTimeInterval)time {
    NSDate *now = [NSDate dateWithTimeIntervalSince1970:time];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay ;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger days = [dateComponent day] - 1;
    
    NSTimeInterval oneDay = 24 * 60 * 60;  // 一天一共有多少秒
    NSDate *appointDate = [now initWithTimeIntervalSinceNow: -(oneDay * days)];//当月月初时间
    
    NSDateComponents *lastMonthComps = [[NSDateComponents alloc] init];
    [lastMonthComps setMonth:1];
    NSDate *newdate = [calendar dateByAddingComponents:lastMonthComps toDate:appointDate options:0];//往后推一个月
    
    NSTimeInterval nextTime = [newdate timeIntervalSince1970] * 1000;
    return nextTime;
}


@end
