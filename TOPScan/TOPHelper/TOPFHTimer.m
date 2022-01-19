#import "TOPFHTimer.h"

@interface TOPFHTimer ()
@property (nonatomic,strong) dispatch_source_t sourceTimer;
@end

@implementation TOPFHTimer

+ (instancetype)shareInstance {
    static TOPFHTimer *singleTon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [[TOPFHTimer alloc] init];
    });
    return singleTon;
}

- (void)top_createTimerSeconds:(void (^)(int))seconds {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _sourceTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    NSTimeInterval delayTime = 0.0f;
    NSTimeInterval timeInterval = 1.0f;
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    dispatch_source_set_timer(_sourceTimer,startDelayTime,timeInterval*NSEC_PER_SEC,0.1*NSEC_PER_SEC);

    __block int i = 0;
    dispatch_source_set_event_handler(_sourceTimer,^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (seconds) {
                seconds(i);
            }
        });
        i ++;
    });
    
    dispatch_resume(_sourceTimer);
}

- (void)top_destroyTimer {
    dispatch_source_cancel(_sourceTimer);
    _sourceTimer = nil;
}


@end
