#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define ShareAppGroup @"group.tongsoft.simple.scanner"
@interface ActionViewController ()

@property(strong,nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic ,copy) NSString *hostAppType;
@property (nonatomic ,assign) NSInteger count;

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hostAppType = @"hostApp";
    [self top_parsingData];
}

#pragma mark -- 解析数据
- (void)top_parsingData {
    __weak typeof(self)weakSelf = self;
    __block NSInteger num=0;
    
    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem * _Nonnull extItem, NSUInteger idx, BOOL * _Nonnull stop) {
        self.count = extItem.attachments.count;
        
        [extItem.attachments enumerateObjectsUsingBlock:^(NSItemProvider * _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage
                                                options:nil
                                      completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    if ([(NSObject *)item isKindOfClass:[NSURL class]]) {
                        NSString * tempString = [(NSURL *)item absoluteString];
                        if([tempString rangeOfString:@"TOPScanBox"].location != NSNotFound) {
                            self.hostAppType = @"TOPScanBox";
                        }
                        NSData *itemData = [NSData dataWithContentsOfURL:(NSURL *)item options:NSDataReadingMappedIfSafe error:&error];
                        NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:ShareAppGroup];
                        NSURL *fileURL = [groupURL URLByAppendingPathComponent:[(NSURL *)item absoluteString].lastPathComponent];
                        if (itemData) {
                            [itemData writeToURL:fileURL atomically:YES];
                            num++;
                        }
                        if (num == weakSelf.count) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self top_openAppWithURL];
                            });
                        }
                    }
                }];
            }
        }];
    }];
    [self.extensionContext completeRequestReturningItems:nil completionHandler:NULL];
    
}

- (void)top_openAppWithURL {
    [self.extensionContext completeRequestReturningItems:nil completionHandler:NULL];
    NSURL *destinationURL = [NSURL URLWithString:[NSString stringWithFormat:@"jumpsimplescanner://ImportPic_%@",[self top_urlStringForShareExtension:@"jumpsimplescanner" text:@"public.image" apptype:self.hostAppType]]];
    NSString *className = [[NSString alloc] initWithData:[NSData dataWithBytes:(unsigned char []){0x55, 0x49, 0x41, 0x70, 0x70, 0x6C, 0x69, 0x63, 0x61, 0x74, 0x69, 0x6F, 0x6E} length:13] encoding:NSASCIIStringEncoding];
    if (NSClassFromString(className)) {
        id object = [NSClassFromString(className) performSelector:@selector(sharedApplication)];
        [object performSelector:@selector(openURL:) withObject:destinationURL];
    }
}

- (NSString*)top_urlStringForShareExtension:(NSString*)urlString text:(NSString*)text apptype:(NSString *)appType{
    NSString* finalUrl=[NSString stringWithFormat:@"%@-%@-%@", urlString, appType,text];
    finalUrl =  (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                      NULL,
                                                                                      (CFStringRef)finalUrl,
                                                                                      NULL,
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                      kCFStringEncodingUTF8 ));
    return finalUrl;
}

- (IBAction)done {
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
