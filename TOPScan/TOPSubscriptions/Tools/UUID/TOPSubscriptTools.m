

#import "TOPSubscriptTools.h"
#import "TOPSubscriptModel.h"
#import "TOPKeyChainStore.h"
#import <sys/utsname.h>

#define AccountPath [[TOPDocumentHelper top_appBoxDirectory] stringByAppendingPathComponent:@"subscriptInfo.archiver"]

@implementation TOPSubscriptTools
/**
获取本地订阅状态
 */
+ (TOPSubscriptModel *)getSubScriptData
{
    TOPSubscriptModel * subModel =   [NSKeyedUnarchiver unarchiveObjectWithFile:AccountPath];
    if (!subModel)
    {
        subModel = [[TOPSubscriptModel alloc] init];
        subModel.freeOcrNum = 3;
        [NSKeyedArchiver archiveRootObject:subModel toFile:AccountPath];
    }
    return subModel;
}
/**
修改本地订阅状态
 */
+(void)changeSaveSubScripWith:(TOPSubscriptModel *)subModel{
    
    [NSKeyedArchiver archiveRootObject:subModel toFile:AccountPath];
}

// 删除订阅信息
+ (void)removeSubscript {
    
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    BOOL isExist = [fileMgr fileExistsAtPath:AccountPath];
    
    if (isExist) {
        
        NSError *err;
        
        [fileMgr removeItemAtPath:AccountPath error:&err];
    }
}
/**
获取当前的余额
 */
+ (NSInteger )getCurrentUserBalance
{
    TOPSubscriptModel * subModel =   [TOPSubscriptTools getSubScriptData];
    if ([TOPSubscriptTools googleLoginStates]) {
        return subModel.userLoginBalance;
    }
    return subModel.userBalance;
}

+ (BOOL)getSubscriptStates
{
    TOPSubscriptModel * subModel =   [TOPSubscriptTools getSubScriptData];

    return subModel.apple_sub_status;
}

+ (NSInteger)getCurrentAvailableOcrNum
{
    TOPSubscriptModel * subModel =   [TOPSubscriptTools getSubScriptData];
    NSInteger currentbalance = [TOPSubscriptTools getCurrentUserBalance];

    if (subModel.apple_sub_status) {
        return subModel.subOcrNum + currentbalance;
    }else{
        return subModel.freeOcrNum + currentbalance;
    }
}
+ (void )saveWriteCurrentUserBalance:(NSInteger)currentBalance
{
    TOPSubscriptModel * subModel =   [TOPSubscriptTools getSubScriptData];
    if ([TOPSubscriptTools googleLoginStates]) {
        subModel.userLoginBalance =  currentBalance;
    }else{
        subModel.userBalance =  currentBalance;
    }
    [TOPSubscriptTools changeSaveSubScripWith:subModel];
}

+ (NSInteger )getCurrentFreeIdentifyNum
{
    TOPSubscriptModel * subModel =   [TOPSubscriptTools getSubScriptData];
    return subModel.freeOcrNum;
}

+ (void )saveWriteCurrentFreeIdentifyNum:(NSInteger)freeOcrNum
{
    TOPSubscriptModel * subModel =   [TOPSubscriptTools getSubScriptData];
    subModel.freeOcrNum =  freeOcrNum;
    [TOPSubscriptTools changeSaveSubScripWith:subModel];
}

+ (NSInteger )getCurrentSubscriptIdentifyNum
{
    TOPSubscriptModel * subModel =   [TOPSubscriptTools getSubScriptData];
    return subModel.subOcrNum;
}
+ (void )saveWriteSubscriptResetOcrNumTime:(double)uploadTime
{
    TOPSubscriptModel * subModel =   [TOPSubscriptTools getSubScriptData];
    subModel.subscriptUpdateTime =  uploadTime;
    [TOPSubscriptTools changeSaveSubScripWith:subModel];
}
+ (void )saveWriteCurrentSubscripIdentifyNum:(NSInteger)ocrNum{
    TOPSubscriptModel * subModel =   [TOPSubscriptTools getSubScriptData];
    subModel.subOcrNum =  ocrNum;
    [TOPSubscriptTools changeSaveSubScripWith:subModel];
}
+ (BOOL)googleLoginStates {
    if (![FIRAuth auth].currentUser) {
       return NO; // 没有账号，说明是没有登录
    }
    if ([FIRAuth auth].currentUser.anonymous) {
       return NO; // 匿名账户
    }
    if ([TOPValidateTools top_validateString:[FIRAuth auth].currentUser.uid]) {
        return NO; // 没有账号，说明是没有登录
    }
    return YES; // 不符合上述条件，说明是未登录状态
}
+ (void)querySingleUserBalanceRecord
{
    if ([TOPSubscriptTools googleLoginStates]) {return;}
    BOOL statesiCloud =  [TOPScanerShare top_getCurrentiCloudStates];
    if (statesiCloud == YES) {
        //获取容器
        CKContainer *container = [CKContainer defaultContainer];
        //获取公有数据库
        CKDatabase *database = container.privateCloudDatabase;
        CKRecordID *noteID = [[CKRecordID alloc] initWithRecordName:@"ScanNoteID"];
        
        [database fetchRecordWithID:noteID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (record) {
                    
                    if ([record.allKeys containsObject:@"userBalance"]) {
                        if ( [[record objectForKey:@"userBalance"] integerValue] >= 0) {
                            
                            NSInteger currentBalance = [[record objectForKey:@"userBalance"] integerValue];
                            [TOPSubscriptTools saveWriteCurrentUserBalance:currentBalance];
                        }
                        
                    }
                }else{
                    [TOPSubscriptTools createiCloudKit];
                }
                
            });
            
        }];
        
    }
}

#pragma mark- iCloud云端存储

+ (void)updateiCloudKitModel:(NSInteger)userBalance
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus,NSError *_Nullable error) {
            if(accountStatus !=CKAccountStatusNoAccount)
            {
                CKContainer *container = [CKContainer defaultContainer];
                CKDatabase *datebase = container.privateCloudDatabase;
                CKRecordID *noteID = [[CKRecordID alloc] initWithRecordName:@"ScanNoteID"];
                [datebase fetchRecordWithID:noteID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                    if (!error) {
                        NSString *content = [NSString stringWithFormat:@"%ld",userBalance];
                        [record setObject:content forKey:@"userBalance"];
                        [datebase saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                            if (!error) {
                                NSLog(@"iCloud余额修改成功");
                            }
                        }];
                    }
                }];
            }
        }];
    });
}

+  (void)createiCloudKit
{
    //创建保存数据
     CKContainer *container = [CKContainer defaultContainer];
    [container accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError * _Nullable error) {
        if (accountStatus != CKAccountStatusNoAccount) {
            CKDatabase *datebase = container.privateCloudDatabase;
           //创建保存数据
            CKRecordID *noteID = [[CKRecordID alloc] initWithRecordName:@"ScanNoteID"];
       //创建CKRecord 保存数据
            CKRecord *noteRecord = [[CKRecord alloc] initWithRecordType:@"ScanUser" recordID:noteID];
            NSString *content = @"0";
               [noteRecord setValue:content forKey:@"userBalance"];
               [noteRecord setValue:@"appleName" forKey:@"Name"];
               [noteRecord setValue:@"0" forKey:@"user_enable"];
              [datebase saveRecord:noteRecord completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            if(!error)
            {
                NSLog(@"保存成功");
            }
            else
            {
            NSLog(@"保存失败");

            NSLog(@"%@",error.description);

            }
            }];
        }
    }];
}

@end
