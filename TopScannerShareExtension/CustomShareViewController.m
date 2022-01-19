#define ExtensionColor(a,b,c,d) [UIColor colorWithRed:a / 255 green:b / 255 blue:c / 255 alpha:d]

#import "CustomShareViewController.h"
#define ShareAppGroup @"group.tongsoft.simple.scanner"

@interface CustomShareViewController ()
@property (nonatomic ,strong) NSMutableArray * exportDatas;
@property (nonatomic ,assign) BOOL hasExistsUrl;
@property (nonatomic ,strong) NSExtensionItem * extItem;
@property (nonatomic ,strong) NSString * appType;
@property (nonatomic ,strong) NSString * headerString;
@property (nonatomic ,strong) UIImageView * typeImg;
@property (nonatomic ,strong) UILabel * countLab;
@property (nonatomic ,assign) NSInteger count;
@property (nonatomic ,strong) UIButton * saveBtn;
@property (nonatomic ,strong) UIActivityIndicatorView *testActivityIndicator;
@end

@implementation CustomShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self top_setupUI];
    self.view.backgroundColor = [UIColor whiteColor];
}
- (NSMutableArray *)exportDatas{
    if (!_exportDatas) {
        _exportDatas = [NSMutableArray new];
    }
    return _exportDatas;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self top_setupData];
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    });
}

- (void)top_setupUI{
    UIScrollView * scrowView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrowView.scrollEnabled = YES;
    scrowView.contentSize = CGSizeMake(0, self.view.frame.size.height);
    scrowView.showsVerticalScrollIndicator = NO;
    scrowView.showsHorizontalScrollIndicator = NO;
    
    UIImageView * typeImg = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-55)/2, 60, 55, 65)];
    self.typeImg = typeImg;
    
    UIImageView * rowImg = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-30)/2, typeImg.frame.origin.y+typeImg.frame.size.height+30, 30, 55)];
    rowImg.image = [UIImage imageNamed:@"top_arrowDown"];
    
    UIImageView * iconImg = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-75)/2, rowImg.frame.origin.y+rowImg.frame.size.height+20, 75, 75)];
    iconImg.image = [UIImage imageNamed:@"appicon"];
    
    UILabel * countLab = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, iconImg.frame.origin.y+iconImg.frame.size.height+30, 200, 20)];
    countLab.textColor = [UIColor blackColor];
    countLab.alpha = 0.7;
    countLab.font = [UIFont systemFontOfSize:15];
    countLab.textAlignment = NSTextAlignmentCenter;
    self.countLab = countLab;
    
    UIButton * saveBtn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-190)/2, countLab.frame.origin.y+countLab.frame.size.height+30, 190, 50)];
    saveBtn.enabled = NO;
    saveBtn.layer.masksToBounds = YES;
    saveBtn.layer.cornerRadius = 3.0;
    saveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    saveBtn.backgroundColor = [[UIColor alloc]initWithRed:61.0/255 green:131.0/225 blue:215.0/255 alpha:0.6];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn setTitle:NSLocalizedString(@"topscan_batchsave", @"") forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(top_clickSave) forControlEvents:UIControlEventTouchUpInside];
    self.saveBtn = saveBtn;
    
    UIButton * cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-190)/2, saveBtn.frame.origin.y+saveBtn.frame.size.height+5, 190, 50)];
    cancelBtn.layer.masksToBounds = YES;
    cancelBtn.layer.cornerRadius = 3.0;
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(top_clickCancel) forControlEvents:UIControlEventTouchUpInside];
    
    NSString * titleString = [NSLocalizedString(@"topscan_pleasenote", @"") stringByAppendingString:@":"];
    NSString * contentFirstString = NSLocalizedString(@"topscan_importdatatype", @"");
    NSString * contentSedString = NSLocalizedString(@"topscan_fileothersuccessfully", @"");
    
    
    UILabel * tipLabTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, cancelBtn.frame.origin.y+cancelBtn.frame.size.height+30,self.view.frame.size.width-40, 20)];
    tipLabTitle.font = [UIFont systemFontOfSize:16];
    tipLabTitle.textColor = ExtensionColor(51, 51, 51, 1.0);
    tipLabTitle.textAlignment = NSTextAlignmentNatural;
    tipLabTitle.text = titleString;
    
    CGFloat tempW = [self top_getSizeWithStr:contentFirstString Height:18 Font:14].width;
    CGFloat freamH = 0;
    if (tempW>self.view.frame.size.width-40) {
        freamH = 35;
    }else{
        freamH = 18;
    }
    UILabel * tipFirst = [[UILabel alloc]initWithFrame:CGRectMake(20, tipLabTitle.frame.origin.y+tipLabTitle.frame.size.height+5, self.view.frame.size.width-40, freamH)];
    tipFirst.font = [UIFont systemFontOfSize:14];
    tipFirst.numberOfLines = 0;
    tipFirst.textColor = [UIColor grayColor];
    tipFirst.textAlignment = NSTextAlignmentNatural;
    tipFirst.lineBreakMode = NSLineBreakByCharWrapping;
    tipFirst.text = contentFirstString;
    
    CGFloat tempSedW = [self top_getSizeWithStr:contentSedString Height:18 Font:14].width;
    CGFloat freamSedH = 0;
    if (tempSedW>self.view.frame.size.width-40) {
        freamSedH = 35;
    }else{
        freamSedH = 18;
    }
    UILabel * tipSed = [[UILabel alloc]initWithFrame:CGRectMake(20, tipFirst.frame.origin.y+tipFirst.frame.size.height+5, self.view.frame.size.width-40, freamSedH)];
    tipSed.font = [UIFont systemFontOfSize:14];
    tipSed.numberOfLines = 0;
    tipSed.textColor = [UIColor grayColor];
    tipSed.textAlignment = NSTextAlignmentNatural;
    tipSed.lineBreakMode = NSLineBreakByCharWrapping;
    tipSed.text = contentSedString;
    
    [self.view addSubview:scrowView];
    [scrowView addSubview:typeImg];
    [scrowView addSubview:rowImg];
    [scrowView addSubview:iconImg];
    [scrowView addSubview:countLab];
    [scrowView addSubview:saveBtn];
    [scrowView addSubview:cancelBtn];
    [scrowView addSubview:tipLabTitle];
    [scrowView addSubview:tipFirst];
    [scrowView addSubview:tipSed];
}

- (void)top_clickSave{
    if (!self.hasExistsUrl) {
        [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
        return;
    }
    [self top_openAppWithURL];
}

- (void)top_clickCancel{
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    return;
}

#pragma mark - 固定高度和字体大小，获取label的frame
- (CGSize) top_getSizeWithStr:(NSString *) str Height:(float)height Font:(float)fontSize
{
    NSDictionary * attribute = @{NSFontAttributeName :[UIFont systemFontOfSize:fontSize] };
    CGSize tempSize=[str boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                   attributes:attribute
                                      context:nil].size;
    return tempSize;
}

- (void)top_setupData {
    __weak typeof(self)weakSelf = self;
    __block NSInteger num=0;
    
    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem * _Nonnull extItem, NSUInteger idx, BOOL * _Nonnull stop) {
        self.count = extItem.attachments.count;
        [extItem.attachments enumerateObjectsUsingBlock:^(NSItemProvider * _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([itemProvider hasItemConformingToTypeIdentifier:@"public.image"]) {
                [itemProvider loadItemForTypeIdentifier:@"public.image"
                                                options:nil
                                      completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    if ([(NSObject *)item isKindOfClass:[NSURL class]]) {
                        NSData *itemData = [NSData dataWithContentsOfURL:(NSURL *)item options:NSDataReadingMappedIfSafe error:&error];
                        NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:ShareAppGroup];
                        NSURL *fileURL = [groupURL URLByAppendingPathComponent:[(NSURL *)item absoluteString].lastPathComponent];
                        if (itemData) {
                            [itemData writeToURL:fileURL atomically:YES];
                            num++;
                        }
                        weakSelf.headerString = @"public.image";
                        NSURL * tempUrl = (NSURL *)item;
                        NSString * tempString = tempUrl.absoluteString;
                        NSArray * tempArray = [tempString componentsSeparatedByString:@"/"];
                        if ([tempArray containsObject:@"TOPScanBox"]) {
                            weakSelf.appType = @"TOPScanBox";
                        }else{
                            weakSelf.appType = @"OtherApp";
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (num == weakSelf.count) {
                                weakSelf.saveBtn.enabled = YES;
                                weakSelf.saveBtn.backgroundColor = [[UIColor alloc]initWithRed:61.0/255 green:131.0/225 blue:215.0/255 alpha:1];
                            }
                        });
                    }
                }];
                weakSelf.hasExistsUrl = YES;
            }
            
            if ([itemProvider hasItemConformingToTypeIdentifier:@"com.adobe.pdf"]) {
                [itemProvider loadItemForTypeIdentifier:@"com.adobe.pdf"
                                                options:nil
                                      completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    if ([(NSObject *)item isKindOfClass:[NSURL class]]) {
                        weakSelf.extItem = extItem;
                        NSError * error;
                        NSData *itemData = [NSData dataWithContentsOfURL:(NSURL *)item options:NSDataReadingMappedIfSafe error:&error];
                        NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:ShareAppGroup];
                        NSURL *fileURL = [groupURL URLByAppendingPathComponent:[(NSURL *)item absoluteString].lastPathComponent];
                        if (itemData) {
                            [itemData writeToURL:fileURL atomically:YES];
                            num++;
                        }
                        weakSelf.headerString = @"com.adobe.pdf";
                        NSURL * tempUrl = (NSURL *)item;
                        NSString * tempString = tempUrl.absoluteString;
                        NSArray * tempArray = [tempString componentsSeparatedByString:@"/"];
                        if ([tempArray containsObject:@"TOPScanBox"]) {
                            weakSelf.appType = @"TOPScanBox";
                        }else{
                            weakSelf.appType = @"OtherApp";
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (num == weakSelf.count) {
                                weakSelf.saveBtn.enabled = YES;
                                weakSelf.saveBtn.backgroundColor = [[UIColor alloc]initWithRed:61.0/255 green:131.0/225 blue:215.0/255 alpha:1];
                            }
                        });
                    }
                }];
                weakSelf.hasExistsUrl = YES;
            }
            if ([itemProvider hasItemConformingToTypeIdentifier:@"public.zip-archive"]) {
                [itemProvider loadItemForTypeIdentifier:@"public.zip-archive"
                                                options:nil
                                      completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    if ([(NSObject *)item isKindOfClass:[NSURL class]]) {
                        weakSelf.extItem = extItem;
                        NSError * error;
                        NSData *itemData = [NSData dataWithContentsOfURL:(NSURL *)item options:NSDataReadingMappedIfSafe error:&error];
                        NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:ShareAppGroup];
                        NSURL *fileURL = [groupURL URLByAppendingPathComponent:[(NSURL *)item absoluteString].lastPathComponent];
                        if (itemData) {
                            [itemData writeToURL:fileURL atomically:YES];
                            num++;
                        }
                        weakSelf.headerString = @"public.zip-archive";
                        NSURL * tempUrl = (NSURL *)item;
                        NSString * tempString = tempUrl.absoluteString;
                        NSArray * tempArray = [tempString componentsSeparatedByString:@"/"];
                        if ([tempArray containsObject:@"TOPScanBox"]) {
                            weakSelf.appType = @"TOPScanBox";
                        }else{
                            weakSelf.appType = @"OtherApp";
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (num == weakSelf.count) {
                                weakSelf.saveBtn.enabled = YES;
                                weakSelf.saveBtn.backgroundColor = [[UIColor alloc]initWithRed:61.0/255 green:131.0/225 blue:215.0/255 alpha:1];
                                
                            }
                        });
                    }
                }];
                weakSelf.hasExistsUrl = YES;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (extItem.attachments.count>1) {
                    self.countLab.text = [NSString stringWithFormat:@"%ld %@",extItem.attachments.count,NSLocalizedString(@"topscan_fileintotal", @"")];
                }else{
                    self.countLab.text = [NSString stringWithFormat:@"%ld %@",extItem.attachments.count,NSLocalizedString(@"topscan_fileintotal", @"")];
                }
                if ([itemProvider hasItemConformingToTypeIdentifier:@"com.adobe.pdf"]) {
                    weakSelf.typeImg.image = [UIImage imageNamed:@"pdftype"];
                }else if ([itemProvider hasItemConformingToTypeIdentifier:@"public.image"]){
                    weakSelf.typeImg.image = [UIImage imageNamed:@"imagtype"];
                }
            });
        }];
        
    }];
}

- (void)top_openAppWithURL {
    UIResponder* responder =self;
    responder = [responder nextResponder];
    while((responder = [responder nextResponder]) !=nil) {
        if([responder respondsToSelector:@selector(openURL:)] ==YES) {
            NSURL * container = [NSURL URLWithString:[NSString stringWithFormat:@"jumpsimplescanner://%@",[self top_urlStringForShareExtension:@"jumpsimplescanner" text:self.headerString apptype:self.appType]]];
            [responder performSelector:@selector(openURL:) withObject:container];
            [self.extensionContext completeRequestReturningItems:nil completionHandler:NULL];
        }
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
@end
