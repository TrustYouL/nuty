#import "TOPPermissionManager.h"
#import "TOPUserInfoManager.h"
#import "TOPSubscriptTools.h"

@implementation TOPPermissionManager

#pragma mark -- 某个权限的数据
+ (NSDictionary *)top_permissionDataByType:(TOPPermissionType)type  {
    NSDictionary *dic = [TOPDataModelHandler top_readPermissionJsonFile];
    NSString *itemKey = [TOPDataModelHandler top_permissionKey:type];
    NSDictionary *advDic = dic[itemKey];
    return advDic;
}

#pragma mark -- 某个权限的 vip裁定
+ (BOOL)vipEnableByPermissionType:(TOPPermissionType)type {
    NSDictionary *dic = [self top_permissionDataByType:type];
    BOOL vipEnable = [dic[@"vip"] boolValue];
    return vipEnable;
}

#pragma mark -- 某个权限的 老用户裁定
+ (BOOL)oldEnableByPermissionType:(TOPPermissionType)type {
    NSDictionary *dic = [self top_permissionDataByType:type];
    BOOL oldEnable = [dic[@"old"] boolValue];
    return oldEnable;
}

#pragma mark -- 裁定权限 **所有的权限都是相同的逻辑**
+ (BOOL)top_verdictPermissionByVip:(BOOL)vipEnable byOld:(BOOL)oldEnable {
    BOOL isVip = [TOPUserInfoManager shareInstance].isVip, isOld =  [TOPUserInfoManager shareInstance].isOld;
    if ((vipEnable && isVip) || (oldEnable && isOld)) {
        return YES;
    }
    return NO;
}

+ (BOOL)enablePermissionByType:(TOPPermissionType)type  {
    NSDictionary *dic = [self top_permissionDataByType:type];
    BOOL vipEnable = [dic[@"vip"] boolValue];
    BOOL oldEnable = [dic[@"old"] boolValue];
    BOOL enable = [self top_verdictPermissionByVip:vipEnable byOld:oldEnable];
    return enable;
}

#pragma mark -- 过滤广告
+ (BOOL)top_enableByAdvertising {
    BOOL enable = [self enablePermissionByType:TOPPermissionTypeAdvertising];
    return enable;
}

#pragma mark -- 云识别OCR
+ (BOOL)top_enableByOCROnline {
    BOOL enable = [self enablePermissionByType:TOPPermissionTypeOCROnline];
    NSInteger balancePoints = [TOPSubscriptTools getCurrentUserBalance];//额外购买的点数
    if (enable) {
        NSInteger subscriptionPoints = [TOPSubscriptTools getCurrentSubscriptIdentifyNum];//订阅每月1000点
        if ((subscriptionPoints + balancePoints) > 0) {
            return YES;
        }
    } else {
        NSInteger freePoints = [TOPSubscriptTools getCurrentFreeIdentifyNum];//免费点数
        if ((freePoints + balancePoints) > 0) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -- 拼图保存
+ (BOOL)top_enableByCollageSave {
    BOOL enable = [self enablePermissionByType:TOPPermissionTypeCollageSave];
    return enable;
}

#pragma mark -- PDF水印
+ (BOOL)top_enableByPDFWaterMark {
    BOOL enable = [self enablePermissionByType:TOPPermissionTypePDFWaterMark];
    return enable;
}

#pragma mark -- PDF签名
+ (BOOL)top_enableByPDFSignature {
    BOOL enable = [self enablePermissionByType:TOPPermissionTypePDFSignature];
    return enable;
}

#pragma mark -- PDF页码
+ (BOOL)top_enableByPDFPageNO {
    BOOL enable = [self enablePermissionByType:TOPPermissionTypePDFPageNO];
    return enable;
}

#pragma mark -- PDF密码
+ (BOOL)top_enableByPDFPassword {
    BOOL enable = [self enablePermissionByType:TOPPermissionTypePDFPassword];
    return enable;
}

#pragma mark -- EmailMySelf
+ (BOOL)top_enableByEmailMySelf {
    BOOL enable = [self enablePermissionByType:TOPPermissionTypeEmailMySelf];
    return enable;
}

#pragma mark -- 图片签名
+ (BOOL)top_enableByImageSign {
    BOOL enable = [self enablePermissionByType:TOPPermissionTypeImageSign];
    return enable;
}

#pragma mark -- 图片涂鸦 -- 暂时开放
+ (BOOL)top_enableByImageGraffiti {
    return YES;
//    BOOL enable = [self enablePermissionByType:TOPPermissionTypeImageGraffiti];
//    return enable;
}

#pragma mark -- 高质量图片
+ (BOOL)top_enableByImageHigh {
    BOOL enable = [self enablePermissionByType:TOPPermissionTypeImageHigh];
    return enable;
}

#pragma mark -- 超高质量图片
+ (BOOL)top_enableByImageSuperHigh {
    BOOL enable = [self enablePermissionByType:TOPPermissionTypeImageSuperHigh];
    return enable;
}

#pragma mark -- 创建文件夹
+ (BOOL)top_enableByCreateFolder {
    BOOL enable = [self enablePermissionByType:TOPPermissionTypeCreateFolder];
    return enable;
}

#pragma mark -- 上传文件
+ (BOOL)top_enableByUploadFile {
    BOOL enable = [self enablePermissionByType:TOPPermissionTypeUploadFile];
    return enable;
}

@end
