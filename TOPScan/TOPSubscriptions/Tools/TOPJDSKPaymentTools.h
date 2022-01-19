

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h> // 苹果内购
//#import "NSDate+Category.h"
@class PurchaseNumModel;

@class TOPPurchasepayModel;
typedef NS_ENUM(NSInteger, IAPFiledCode) {
    /**
     *  苹果返回错误信息
     */
    IAP_FILEDCOED_APPLECODE = 0,
    
    /**
     *  用户禁止应用内付费购买
     */
    IAP_FILEDCOED_NORIGHT = 1,
    
    /**
     *  商品为空
     */
    IAP_FILEDCOED_EMPTYGOODS = 2,
    /**
     *  无法获取产品信息，请重试
     */
    IAP_FILEDCOED_CANNOTGETINFORMATION = 3,
    /**
     *  购买失败，请重试
     */
    IAP_FILEDCOED_BUYFILED = 4,
    /**
     *  用户取消交易
     */
    IAP_FILEDCOED_USERCANCEL = 5,
    /**
     *  服务器验证失败
     */

    IAP_FILEDCOED_SERVERERROR = 6,
    /**
     *  服务器验证失败 参数为空
     */
    
    IAP_FILEDCOED_parameterempty = 7,
    /**
     *  绑定号码失败
     */
    
    IAP_FILEDCOED_BindNumFiled = 8,
    /**
     * 恢复订阅失败
     */
    
    IAP_FILEDCOED_RestoreFiled = 9,
    /**
     * 没有可恢复订阅
     */
    
    IAP_FILEDCOED_NORestoreData = 10
};


typedef NS_ENUM(NSInteger, IAPSucceedCode) {
    /**
     *  返回交易成功信息
     */
    IAPSucceedCode_Succeed = 0,
    
    /**
     *  用户正在购买
     */
   IAPSucceedCode_Purchasing = 1,
    
    /**
     *  与服务器验证成功
     */
    IAPSucceedCode_ServersSucceed = 2,
    
    /**
     *  恢复订阅与服务器验证成功
     */
    IAPSucceedCode_ServersRestoreSucceed = 3
    
};


@protocol TOPJDSKPaymentToolsDelegate <NSObject>

- (void)top_filedWithErrorCode:(NSInteger)errorCode andError:(NSString *)error; //失败

- (void)top_succeedWithsucceedCode:(NSInteger)succeedCode; //失败

@end
@interface TOPJDSKPaymentTools : NSObject

@property (nonatomic, weak)id<TOPJDSKPaymentToolsDelegate>delegate;

/**
 启动工具
 */
- (void)top_startManager;

/**
 结束工具
 */
- (void)top_stopManager;

#pragma mark 恢复订阅

- (void)top_restoreSubscriptTransaction;
+ (instancetype)shareInstance;
/**
 开始订阅
@param payModel  订阅信息 (号码 国家 订阅类型)
*/
-(void)top_startBuyNumberWithServer:( TOPPurchasepayModel*)payModel ;

@end
