
#import "TOPAppTools.h"
#import "sys/utsname.h"

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


@implementation TOPAppTools

+ (BOOL)top_connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}

#pragma mark -获取系统版本
+ (NSString*)deviceVersion
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceString isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceString isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    if ([deviceString isEqualToString:@"iPhone12,8"])   return @"iPhone SE2";
    if ([deviceString isEqualToString:@"iPhone13,1"])   return @"iPhone 12 mini";
    if ([deviceString isEqualToString:@"iPhone13,2"])   return @"iPhone 12";
    if ([deviceString isEqualToString:@"iPhone13,3"])   return @"iPhone 12  Pro";
    if ([deviceString isEqualToString:@"iPhone13,4"])   return @"iPhone 12  Pro Max";
    return deviceString;
}

+ (NSString *)deviceVersionName{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString; 
}
+ (BOOL)isIPad{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    }else{
        return NO;
    }
}
+ (NSString*)SystemVersion
{
    NSString * str = [NSString stringWithFormat:@"IOS:%.2f",[[[UIDevice currentDevice] systemVersion] floatValue]];
    return str;
}

+ (NSString *)appBundleId {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+ (BOOL)top_isOnlyNumber:(NSString *)number
{
    NSString *numberRegex = @"^[0-9]*$";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
    return [numberTest evaluateWithObject:number];
}

+ (BOOL)top_isFloatNumber:(NSString *)number
{
    NSString *numberRegex = @"^[0-9]+(\\.[0-9]{1,2})?$";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
    return [numberTest evaluateWithObject:number];
}

+ (BOOL)top_isPhoneNumber:(NSString *)phoneNumber{
    
    NSString *regex = @"^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL isMatch = [pred evaluateWithObject:phoneNumber];
    return isMatch;
}
+ (BOOL)top_validatePassword:(NSString *)passWord
{
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,16}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}
+ (UIColor *) colorWithHexString: (NSString *) hexString
{
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#"withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            return [UIColor blackColor];
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length
{
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

#pragma mark - 检查是否是手机号码
+ (BOOL) checkIsMobileNumber:(NSString *)mobileNumber {
    NSString *strMobile = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    NSString *strCM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    NSString *strCU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    NSString *strCT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";\
    
    NSPredicate *regextestMobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strMobile];
    NSPredicate *regextestCM = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strCM];
    NSPredicate *regextestCU = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strCU];
    NSPredicate *regextestCT = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strCT];
    
    if (([regextestMobile evaluateWithObject:mobileNumber]) == YES ||
        ([regextestCM evaluateWithObject:mobileNumber]) == YES ||
        ([regextestCU evaluateWithObject:mobileNumber]) == YES ||
        ([regextestCT evaluateWithObject:mobileNumber]) == YES) {
        return YES;
    }
    
    return NO;
}
+ (BOOL)checkPhoneNumber:(NSString *)phoneNumber {
    NSString *strRegex = @"^1[3-9]\\d{9}$";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strRegex];
    
    return [emailPredicate evaluateWithObject:phoneNumber];
}
#pragma mark - 检查是否是邮箱地址
+ (BOOL) checkEmailAddress:(NSString *)emailAddress {
    NSString *strRegex = @"[A-Z0-9a-z._%+-]+@[A-Z0-9a-z._]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strRegex];
    return [emailPredicate evaluateWithObject:emailAddress];
}
+ (NSInteger) getWeekDayFromDateString:(NSString *)dateString {
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSDate * date = [formatter dateFromString:dateString]; //日期转化NSString to NSDate
    
    NSCalendar *calendaraa = [NSCalendar currentCalendar];
    [calendaraa setFirstWeekday:2]; //设定周一为周首日
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
    NSDateComponents *dateComponent = [calendaraa components:unitFlags fromDate:date];
    NSInteger weekday = [dateComponent weekday];
    return weekday - 1;
}

+ (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect= CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (CGRect)getLabelFrameWithString:(NSString *)context
                             font:(UIFont *)textFont
                         sizeMake:(CGSize)labelSize{
    CGRect tmpRect;
    tmpRect = [context boundingRectWithSize:labelSize
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:[NSDictionary dictionaryWithObjectsAndKeys:textFont,NSFontAttributeName, nil]
                                    context:nil];
    
    return tmpRect;
}
+ (NSString *) getVersionNumber {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *versionStr = [infoDic objectForKey:@"CFBundleShortVersionString"];
    return versionStr;
}

#pragma mark -- 比较版本号大小-如果有新版本返回Yes
+ (BOOL)compareVersion:(NSString *)localVerson WithVersionApp:(NSString *)versonAPP {
    //将版本号按照"."切割后存入数组中
    NSArray *localArray = [localVerson componentsSeparatedByString:@"."];
    NSArray *appArray = [versonAPP componentsSeparatedByString:@"."];
    NSInteger minArrayLength = MIN(localArray.count, appArray.count);
    BOOL needUpdate = NO;
    
    for(int i=0;i<minArrayLength;i++){//以最短的数组长度为遍历次数,防止数组越界
        //取出每个部分的字符串值,比较数值大小
        NSString *localElement = localArray[i];
        NSString *appElement = appArray[i];
        NSInteger  localValue =  localElement.integerValue;
        NSInteger  appValue = appElement.integerValue;
        if (localValue == appValue) {
            needUpdate = NO;
        } else {//从前往后比较数字大小,一旦分出大小,跳出循环
            needUpdate = localValue < appValue ? YES : NO;
            break;
        }
    }
    return needUpdate;
}

+ (BOOL) fileIsExists:(NSString *)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (UIStoryboard *) getStoryboardInstance
{
    NSString *storyboardName = [self getStoryboardName];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    return storyboard;
}

+ (NSString *) getStoryboardName
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return @"Main";
    }
    else
    {
        return @"Main";
    }
}
+ (NSString *) getCurrentDateString {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strTime = [formatter stringFromDate:date];
    return strTime;
}
+ (NSString *)top_getCurrentTimeSeconds {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    [formatter setTimeZone:timeZone];
    //设置时间格式
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateStr = [formatter  stringFromDate:[NSDate date]];
    return dateStr;
}
// 获取当前系统的语言
+ (NSString *) getCurrentSysLanguage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    return currentLanguage;
}

// 拼接URL
+ (NSString *) spliceUrl:(NSString *)interfaceName {
    NSString *language = [self getCurrentSysLanguage];
    NSString *stringLanguage = @"";
    if ([language isEqualToString:@"en-CN"]) {
        stringLanguage = @"en";
    }
    else {
        stringLanguage = @"zh";
    }
    NSString *requestUrl = [NSString stringWithFormat:@"%@?locale=%@", interfaceName, stringLanguage];
    return requestUrl;
}

//对图片尺寸进行压缩--
+ (UIImage*)top_imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSString *)getAppVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getAppName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}
+ (NSData *)dataWithBase64EncodedString:(NSString *)string
{
    if (string == nil)
        [NSException raise:NSInvalidArgumentException format:nil];
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

#pragma mark - 加密
+ (NSString *)base64EncodedStringFrom:(NSData *)data
{
    if ([data length] == 0)
        return @"";
    
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
            buffer[bufferLength++] = ((char *)[data bytes])[i++];
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

/// MD5加密
+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

#pragma mark -
// 有效返回yes  无效返回no
+ (BOOL)top_validateString:(NSString *)string {
    if (!string) {
        return NO;
    }
    
    if (string.length == 0) {
        return NO;
    }
    
    //去除两边空格后长度如果为0，则为无效
    NSString *str = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (str.length == 0) {
        return NO;
    }
    
    return YES;
}

//获取IP地址
+ (NSString *)deviceWANIPAdress {
    NSError *error;
    NSURL *ipURL = [NSURL URLWithString:@"http://pv.sohu.com/cityjson?ie=utf-8"];
    NSMutableString *ip = [NSMutableString stringWithContentsOfURL:ipURL encoding:NSUTF8StringEncoding error:&error];
    
    //判断返回字符串是否为所需数据
    if ([ip hasPrefix:@"var returnCitySN = "]) {
        //对字符串进行处理，然后进行json解析
        //删除字符串多余字符串
        NSRange range = NSMakeRange(0, 19);
        [ip deleteCharactersInRange:range];
        NSString * nowIp =[ip substringToIndex:ip.length-1];
        
        //将字符串转换成二进制进行Json解析
        NSData * data = [nowIp dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        return dict[@"cip"];
    }
    return @"";
}
+ (void)top_drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    if (lineView.frame.size.width > lineView.frame.size.height) {
        [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
        [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    }else{
        [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame), CGRectGetHeight(lineView.frame) / 2)];
        [shapeLayer setLineWidth:CGRectGetWidth(lineView.frame)];
    }
    
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    if (lineView.frame.size.width > lineView.frame.size.height) {
        CGPathAddLineToPoint(path, NULL,CGRectGetWidth(lineView.frame), 0);
    }else{
        CGPathAddLineToPoint(path, NULL,0, CGRectGetHeight(lineView.frame));
    }
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}

+ (NSNumber *)getFormatterMoney:(NSString *)moneyString {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *number = [formatter numberFromString:moneyString];
    return number;
}

#pragma mark - 根据StoryBoardID获取ViewController
+ (UIViewController *)getViewControllerWithIdentifier:(NSString *)identifier {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController * viewCtl = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    return viewCtl;
}
#pragma mark - 钥匙串加密
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

//写入
+ (void)save:(NSString *)service data:(id)data {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

// 读取
+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData*)keyData];
        } @catch (NSException *e) {
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}
// 删除
+ (void)deleteData:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}
+ (NSMutableArray *)getThreeDeeTouchArray {
    NSMutableArray *itemArray = [NSMutableArray array];
    
    UIApplicationShortcutIcon *payIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeAdd];
    UIApplicationShortcutItem *payItem = [[UIApplicationShortcutItem alloc] initWithType:@"com.platform.pay" localizedTitle:@"充值" localizedSubtitle:nil icon:payIcon userInfo:nil];
    UIApplicationShortcutIcon *withdrawIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeShare];
    UIApplicationShortcutItem *withdrawItem = [[UIApplicationShortcutItem alloc] initWithType:@"com.platform.withdraw" localizedTitle:@"提款" localizedSubtitle:nil icon:withdrawIcon userInfo:nil];
    
    UIApplicationShortcutIcon *transferIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeShare];
    UIApplicationShortcutItem *transferItem = [[UIApplicationShortcutItem alloc] initWithType:@"com.platform.transfer" localizedTitle:@"转账" localizedSubtitle:nil icon:transferIcon userInfo:nil];
    
    [itemArray addObject:payItem];
    [itemArray addObject:transferItem];
    [itemArray addObject:withdrawItem];
    
    // 如果有最后转账的游戏，就显示打开这个游戏，如果没有，就显示活动
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *lastDic = [userDefaults objectForKey:[NSString stringWithFormat:@"%@_LastGame",[userDefaults objectForKey:@"ZXUSERNAME"]]];
    if (lastDic) {
        UIApplicationShortcutIcon *gameIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypePlay];
        UIApplicationShortcutItem *gameItem = [[UIApplicationShortcutItem alloc] initWithType:@"com.platform.game" localizedTitle:[NSString stringWithFormat:@"打开%@",[lastDic objectForKey:@"name"]] localizedSubtitle:nil icon:gameIcon userInfo:nil];
        [itemArray insertObject:gameItem atIndex:0];
    }
    
    return itemArray;
}

+ (void)shakeToShow:(UIView*)aView {
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;// 动画时间
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1.0)]];
    // 这三个数字，我只研究了前两个，所以最后一个数字我还是按照它原来写1.0；前两个是控制view的大小的；
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)]];
    animation.values = values;
    [aView.layer addAnimation:animation forKey:nil];
}
+ (BOOL)hasLastNumber:(NSString*)regular number:(NSString*)num{
    NSString *regex = regular;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:num];
}

+ (void)skipCustomerSafari{
    NSString *netStr;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:netStr]];
}

//  颜色转换为背景图片
+ (UIImage *)top_imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
+(CIImage *)QRFromUrl:(NSString *)urlStr{
    // 1、创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 恢复滤镜的默认属性
    [filter setDefaults];
    // 2、设置数据
    NSString *info = urlStr;
    // 将字符串转换成
    NSData *infoData = [info dataUsingEncoding:NSUTF8StringEncoding];
    // 通过KVC设置滤镜inputMessage数据
    [filter setValue:infoData forKeyPath:@"inputMessage"];
    // 3、获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    return outputImage;
}

+(UIImage *)top_createUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(cs);
    UIImage *scaleImg = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return scaleImg;
}

+ (NSDictionary*)dictionaryFromQuery:(NSString*)query
{
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [[kvPair objectAtIndex:0] stringByRemovingPercentEncoding];
            NSString* value = [[kvPair objectAtIndex:1] stringByRemovingPercentEncoding];
            [pairs setObject:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}



// 获取美元格式的金额字符串
+ (NSString *)getDecimalMoneyString:(NSString *)string {
    
    // 判断是否null 若是赋值为0 防止崩溃
    if (([string isEqual:[NSNull null]] || string == nil)) {
        string = 0;
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.numberStyle = kCFNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = 2;
    formatter.minimumFractionDigits = 2;
    // 注意传入参数的数据长度，可用double
    NSNumber *number = [formatter numberFromString:string];
    NSString *decimalStr = [formatter stringFromNumber:number];
    return decimalStr;
}

// 获取美元整数格式的金额字符串
+ (NSString *)getIntDecimalMoneyString:(NSString *)string {
    
    // 判断是否null 若是赋值为0 防止崩溃
    if (([string isEqual:[NSNull null]] || string == nil)) {
        string = 0;
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.numberStyle = kCFNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = 0;
    formatter.minimumFractionDigits = 0;
    // 注意传入参数的数据长度，可用double
    NSNumber *number = [formatter numberFromString:string];
    NSString *decimalStr = [formatter stringFromNumber:number];
    return decimalStr;
}

// 获取普通的金额字符串
+ (NSString *)getNormalMoneyString:(NSString *)moneyString{
    NSString *normalString = [moneyString stringByReplacingOccurrencesOfString:@"," withString:@""];
    return normalString;
}

// 获取数字类型的金额字符串
+ (double)getDoubleNormalMoneyString:(NSString *)moneyString {
    NSString *normalString = [moneyString stringByReplacingOccurrencesOfString:@"￥" withString:@""];
    normalString = [normalString stringByReplacingOccurrencesOfString:@"," withString:@""];
    normalString = [NSString stringWithFormat:@"%.2f",[normalString doubleValue]];
    NSDecimalNumber *decimalNum = [NSDecimalNumber decimalNumberWithString:normalString];
    return [decimalNum doubleValue];
}

// 获取中文格式的数字字符串
+ (NSString *)getChineseNumberStr:(NSInteger)albNum{
    NSArray *chineseNumeralsArray = @[@"零",@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十"];
    return chineseNumeralsArray[albNum];
}

/// textField 输入的金额格式三位添加逗号分隔
+ (NSMutableAttributedString *)setBalance:(NSString *)balance {
    if (balance == nil) {
        balance = @"";
    }
    NSString *newBalance = [balance stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formattedBalance = [formatter stringFromNumber:[NSNumber numberWithInteger:[newBalance integerValue]]];
    NSMutableAttributedString *vAttrString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@", formattedBalance] attributes:nil];
    //    SLog(@"===---- %@",vAttrString);
    return vAttrString;
}

+ (NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return html;
}

#pragma mark -- 计算多行文字最大宽度
+ (CGFloat)labMaxWidth:(NSString *)labStr withFontSize:(CGFloat)fontSize {
    NSArray *strArr = [labStr componentsSeparatedByString:@"\n"];
    NSMutableArray *widthArr = [@[] mutableCopy];
    for (NSString *str in strArr) {
        CGFloat textWidth = [TOPAppTools sizeWithFont:fontSize textSizeWidht:0 textSizeHeight:36 text:str].width;
        [widthArr addObject:[NSString stringWithFormat:@"%.0f",textWidth]];
    }
    //取文字最长那条作为文本宽度
    CGFloat maxValue = [[widthArr valueForKeyPath:@"@max.floatValue"] floatValue];
    return maxValue;
}

#pragma mark -- 计算文字大小(size)
+ (CGSize)sizeWithFont:(CGFloat)fontSize textSizeWidht:(CGFloat)widht textSizeHeight:(CGFloat)height text:(NSString *)text {
    CGFloat margin = 6;
    if (widht == MAXFLOAT || widht == CGFLOAT_MAX || widht == 0) {
        CGRect rect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingTruncatesLastVisibleLine|   NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil];
        return CGSizeMake(rect.size.width + margin, height);
    } else if (height == MAXFLOAT || height == CGFLOAT_MAX || height == 0) {
        CGRect rect = [text boundingRectWithSize:CGSizeMake(widht, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|   NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil];
        
        return CGSizeMake(widht, rect.size.height + margin);
    }
    return CGSizeMake(0, 0);
}

#pragma mark -- 计算文字高度，允许换行计算
+ (CGFloat)sizeLineFeedWithFont:(CGFloat)fontSize textSizeWidht:(CGFloat)widht text:(NSString *)text {
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, widht, 0)];
    textView.text = text;
    textView.font = [UIFont systemFontOfSize:fontSize];
    CGSize size = CGSizeMake(widht, MAXFLOAT);
    CGSize constraint = [textView sizeThatFits:size];
    return constraint.height;
}

+ (NSDecimalNumber *)Rounding:(float)number afterPoint:(NSInteger)position {
     NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode: NSRoundPlain scale: position raiseOnExactness: NO raiseOnOverflow: NO raiseOnUnderflow:YES raiseOnDivideByZero: NO];
     NSDecimalNumber *floatDecimal = [[NSDecimalNumber alloc] initWithFloat: number];
     NSDecimalNumber *resultNumber = [floatDecimal decimalNumberByRoundingAccordingToBehavior:handler];
     return resultNumber;
}

+ (NSString *)timeStringFromDate:(NSDate *)date {
    NSString *strDate = [[TOPDateFormatter shareInstance] stringFromDate:date];
    return strDate;
}

// 精度毫秒
+ (double)timeStamp {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

#pragma mark -- one-way hash 单向散列
+ (NSString *)hashedValueForAccountName:(NSString *)userAccountName {
    const int HASH_SIZE = 32;
    unsigned char hashedChars[HASH_SIZE];
    const char *accountName = [userAccountName UTF8String];
    size_t accountNameLen = strlen(accountName);
    if (accountNameLen > UINT32_MAX) {
        NSLog(@"Account name too long to hash: %@", userAccountName);
        return nil;
    }
    CC_SHA256(accountName, (CC_LONG)accountNameLen, hashedChars);
    NSMutableString *userAccountHash = [[NSMutableString alloc] init];
    for (int i = 0; i < HASH_SIZE; i++) {
        if (i != 0 && i%4 == 0) {
            [userAccountHash appendString:@"-"];
        }
        [userAccountHash appendFormat:@"%02x", hashedChars[i]];
    }
    return userAccountHash;
}

#pragma mark -- 是否需要弹出折扣活动窗口
+ (BOOL)needShowDiscountThemeView {//暂时关闭入口
    if ([TOPScanerShare top_purchaseSubscriptionsCount]) {//有购买过订阅的就不能享受优惠
        return NO;
    }
    BOOL checkCount = [TOPScanerShare top_theCountSubscribtionVC] >= 2 ? YES : NO;//进入购买界面两次
    BOOL purchaseCount = [TOPScanerShare top_theCountClickPurchased] >= 1 ? YES : NO;//点击购买按钮一次
    if (checkCount && purchaseCount) {
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"lifeTimeKey"] < 0) {//优惠过期
            return  NO;
        }
        return  YES;
    }
    return NO;
}

@end
