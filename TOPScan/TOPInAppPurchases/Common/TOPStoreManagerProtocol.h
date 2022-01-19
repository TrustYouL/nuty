

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TOPStoreManagerProtocol <NSObject>

@required

- (void)topStoreManagerDidReceiveResponse:(id)response;
- (void)topStoreManagerDidReceiveMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
