#import <Foundation/Foundation.h>

@class TOPQRCodeReaderViewController;
@protocol TOPQRCodeReaderDelegate <NSObject>

@optional

#pragma mark - Listening for Reader Status
- (void)reader:(TOPQRCodeReaderViewController *)reader didScanResult:(NSString *)result;
- (void)readerDidCancel:(TOPQRCodeReaderViewController *)reader;

@end
