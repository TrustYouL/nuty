#import "TOPOneDriveFolderCollectionViewCell.h"
#import "UIImage+category.h"

@interface TOPOneDriveFolderCollectionViewCell ()

@property (nonatomic, readonly, strong) NSCache *memoryCache;
@property (nonatomic) BOXFileThumbnailRequest *thumbnailRequest;

@end
@implementation TOPOneDriveFolderCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    _memoryCache = [[NSCache alloc] init];
}

- (void)setBoxItem:(BOXItem *)boxItem
{
    _boxItem = boxItem;
    self.contentTitleLabel.text = boxItem.name;
    if ( boxItem.isFile) {
        __weak TOPOneDriveFolderCollectionViewCell *me = self;
        void (^imageSetBlock)(UIImage *image, UIViewContentMode contentMode) = ^void(UIImage *image, UIViewContentMode contentMode) {
            me.coverImageView.image = image;
            me.coverImageView.contentMode = contentMode;
        };
        __block BOXFile *file = (BOXFile *)boxItem;
        BOXThumbnailSize thumbnailSize = BOXThumbnailSize128;
        if ([self hasThumbnailInCacheForFile:file size:thumbnailSize]) {
            self.thumbnailRequest = [self fetchThumbnailForFile:file size:BOXThumbnailSize128 completion:^(UIImage *image, NSError *error) {
                if ([me.boxItem.modelID isEqualToString:file.modelID]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageSetBlock(image, UIViewContentModeScaleAspectFit);
                    });
                }
            }];
        } else {
            
            self.thumbnailRequest = [self fetchThumbnailForFile:file size:BOXThumbnailSize128 completion:^(UIImage *image, NSError *error) {
                if (error == nil) {
                    if ([me.boxItem.modelID isEqualToString:file.modelID]) {
                        imageSetBlock(image, UIViewContentModeScaleAspectFit);
                        CATransition *transition = [CATransition animation];
                        transition.duration = 0.3f;
                        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                        transition.type = kCATransitionFade;
                        [me.coverImageView.layer addAnimation:transition forKey:nil];
                    }
                }
            }];
        }
        self.contentTitleLabel.textColor = UIColorFromRGB(0xB7B7B7);
        self.topTitleConstraint.constant = 15;
        self.creatTimeLabel.hidden = NO;
    }else{
        self.coverImageView.image = [UIImage imageNamed:@"top_drive_newfolder_b"];
        self.contentTitleLabel.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:UIColorFromRGB(0x222222)];
        self.creatTimeLabel.hidden = YES;
        self.topTitleConstraint.constant = 27;
    }
}

- (BOXFileThumbnailRequest *)fetchThumbnailForFile:(BOXFile *)file size:(BOXThumbnailSize)size completion:(BOXImageBlock)completion
{
    NSString *key = [self cacheKeyForFile:file thumbnailSize:size];
    __block UIImage *thumbnail = [self.memoryCache objectForKey:key];
    if (thumbnail) {
        completion(thumbnail, nil);
    } else {
        BOXContentClient  *contentClient = [BOXContentClient defaultClient];

        BOXFileThumbnailRequest *request = [contentClient fileThumbnailRequestWithID:file.modelID size:size];
        [request performRequestWithProgress:nil completion:^(UIImage *image, NSError *error) {
            if (image) {
                thumbnail = [image box_imageAtAppropriateScaleFactor];
                [self.memoryCache setObject:thumbnail forKey:key];
            }
            completion(image, error);
        }];
        return request;
    }
    return nil;
}


- (BOOL)hasThumbnailInCacheForFile:(BOXFile *)file size:(BOXThumbnailSize)size
{
    NSString *key = [self cacheKeyForFile:file thumbnailSize:size];
    return [self.memoryCache objectForKey:key] != nil;
}

- (NSString *)cacheKeyForFile:(BOXFile *)file thumbnailSize:(BOXThumbnailSize)thumbnailSize
{
    NSString *key = [NSString stringWithFormat:@"%@_%lu", file.SHA1, (unsigned long) thumbnailSize];
    return key;
}
@end
