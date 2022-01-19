

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonHMAC.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import <arpa/inet.h>

#import <CommonCrypto/CommonCrypto.h>
#import <Security/Security.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPAppTools : NSObject

//判断当前是否可以连接到网络
+ (BOOL)top_connectedToNetwork;
+ (BOOL)top_isOnlyNumber:(NSString *)number;
+ (BOOL)top_isFloatNumber:(NSString *)number;
+ (BOOL)top_isPhoneNumber:(NSString *)phoneNumber;
+ (BOOL)top_validatePassword:(NSString *)passWord;
+ (void)callPhoneNumber:(NSString *)phoneNum inView:(UIView *)view;
+ (UIColor *) colorWithHexString: (NSString *) hexString;
+ (BOOL) checkIsMobileNumber:(NSString *)mobileNumber;
+ (BOOL) checkEmailAddress:(NSString *)emailAddress;
+ (NSInteger) getWeekDayFromDateString:(NSString *)dateString;
+ (UIImage*) createImageWithColor: (UIColor*) color;
+ (CGRect)getLabelFrameWithString:(NSString *)context
                             font:(UIFont *)textFont
                         sizeMake:(CGSize)labelSize;
+ (NSString *)getVersionNumber;
+ (BOOL)compareVersion:(NSString *)localVerson WithVersionApp:(NSString *)versonAPP;
+ (BOOL)checkPhoneNumber:(NSString *)phoneNumber;
+ (BOOL) fileIsExists:(NSString *)filePath;
+ (UIStoryboard *) getStoryboardInstance;
+ (NSString *) getCurrentDateString;
+ (NSString *)top_getCurrentTimeSeconds;
+ (NSString *) getCurrentSysLanguage;
+ (NSString *) spliceUrl:(NSString *)interfaceName;
+ (UIImage*)top_imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (NSString *)getAppVersion;
+ (NSString *)getAppName;
+ (NSString *)SystemVersion;
+ (NSString *)deviceVersion;
+ (NSString *)deviceVersionName;
+ (NSString *)appBundleId;
+ (BOOL)isIPad;
+ (NSData *)dataWithBase64EncodedString:(NSString *)string;
+ (NSString *)base64EncodedStringFrom:(NSData *)data;
+ (NSString *)md5:(NSString *)str;
+ (BOOL)top_validateString:(NSString *)string;
+ (UIViewController *)getViewControllerWithIdentifier:(NSString *)identifier;
+ (NSString *)deviceWANIPAdress;
+ (void)top_drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor;
+ (NSNumber *)getFormatterMoney:(NSString *)moneyString;
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteData:(NSString *)service;
+ (NSMutableArray *)getThreeDeeTouchArray;
+ (void)shakeToShow:(UIView*)aView;
+ (BOOL)checkCameraCanUse;
+ (BOOL)hasLastNumber:(NSString*)regular number:(NSString*)num;
+ (UIImage *)top_imageWithColor:(UIColor *)color;
+ (void)skipCustomerSafari;
+ (CIImage *)QRFromUrl:(NSString *)urlStr;
+ (UIImage *)top_createUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size;
+ (NSDictionary*)dictionaryFromQuery:(NSString*)query;
+ (NSString *)getDecimalMoneyString:(NSString *)string;
+ (NSString *)getIntDecimalMoneyString:(NSString *)string;
+ (NSString *)getNormalMoneyString:(NSString *)moneyString;
+ (double)getDoubleNormalMoneyString:(NSString *)moneyString;
+ (NSString *)getChineseNumberStr:(NSInteger)albNum;
+ (NSMutableAttributedString *)setBalance:(NSString *)balance;
+ (NSString *)filterHTML:(NSString *)html;
+ (CGFloat)labMaxWidth:(NSString *)labStr withFontSize:(CGFloat)fontSize;
+ (CGSize)sizeWithFont:(CGFloat)fontSize textSizeWidht:(CGFloat)widht textSizeHeight:(CGFloat)height text:(NSString *)text;
+ (CGFloat)sizeLineFeedWithFont:(CGFloat)fontSize textSizeWidht:(CGFloat)widht text:(NSString *)text;
+ (NSDecimalNumber *)Rounding:(float)number afterPoint:(NSInteger)position;
+ (NSString *)timeStringFromDate:(NSDate *)date;
+ (double)timeStamp;
+ (NSString *)hashedValueForAccountName:(NSString *)userAccountName;
+ (BOOL)needShowDiscountThemeView;
@end

NS_ASSUME_NONNULL_END
