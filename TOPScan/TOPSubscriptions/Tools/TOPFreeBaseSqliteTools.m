

#import "TOPFreeBaseSqliteTools.h"
@interface TOPFreeBaseSqliteTools()



@property (strong, nonatomic) FIRDatabaseReference *refBase;


@end
static TOPFreeBaseSqliteTools *_sharedSingleton = nil;

@implementation TOPFreeBaseSqliteTools
+ (instancetype)sharedSingleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //不能再使用alloc方法
        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
        _sharedSingleton = [[super allocWithZone:NULL] init];

    });
    return _sharedSingleton;
}

- (FIRDatabaseReference *)refBase
{
    if (_refBase == nil) {
        _refBase = [[FIRDatabase database] reference];

    }
    return _refBase;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [super allocWithZone:zone];
    });
    return _sharedSingleton;
}

-(id)copyWithZone:(NSZone *)zone
{
    return _sharedSingleton;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return _sharedSingleton;
}
#pragma mark-   开启数据库实时的监听

/**
 开启数据库实时的监听
 */
- (void)openObserveGoogleFirebaseValue
{

    if ([TOPSubscriptTools googleLoginStates]) {
        [self removeAllObserveGoogleFirebase];
        NSString *userID = [FIRAuth auth].currentUser.uid;

        [[[self.refBase child:@"ocr_recognize_pages"] child:userID] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSLog(@"userBalance_______%@",snapshot.value);
            if ([snapshot.value isEqual:[NSNull null]]) {
                     return;
                 }
         
            [TOPSubscriptTools saveWriteCurrentUserBalance:[snapshot.value integerValue]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"top_ocr_recognize_pagesChange" object:nil userInfo:nil];
             // 保存账号信息
        }];
    }else{
        [TOPSubscriptTools querySingleUserBalanceRecord];

    }
}


#pragma mark-   移除所有的监听

/**
    移除所有的监听
 */
- (void)removeAllObserveGoogleFirebase
{

    if ([TOPSubscriptTools googleLoginStates]) {
        [self.refBase removeAllObservers];
    }
    
}

#pragma mark-  添加OCR订阅历史
/**
 添加识别历史
 **/
- (void)setOcr_recognize_historyToServiceWith:(NSString *)recognizeHistory
{
    
    if ([TOPSubscriptTools googleLoginStates]) {
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        [[[self.refBase child:@"ocr_recognize_history"] child:userID] setValue:recognizeHistory withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            NSLog(@"%@",error);
            NSLog(@"%@",ref);
        }];
        
    }
    
}

#pragma mark-  添加充值历史
/**
 添加充值历史
 **/
- (void)setOcr_buyhistoryToServiceWith:(NSString *)buyHistory
{
    
    if ([TOPSubscriptTools googleLoginStates]) {
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        [[[self.refBase child:@"ocr_buyhistory"] child:userID] setValue:buyHistory withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            NSLog(@"%@",error);
            NSLog(@"%@",ref);
        }];
        
    }
    
}

#pragma mark- 设置余额到实时数据库
/**
 设置余额到实时数据库
 **/
- (void)setOcr_recognize_pagesToServiceWith:(NSInteger )recognize_pages
{
    
    if ([TOPSubscriptTools googleLoginStates]) {
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        [[[self.refBase child:@"ocr_recognize_pages"] child:userID] setValue:[NSNumber numberWithInteger:recognize_pages] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            NSLog(@"%@",error);
            NSLog(@"%@",ref);
        }];
        
    }
    
}

@end
