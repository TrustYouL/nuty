#import "TOPDataTool.h"
#import "TOPPictureProcessTool.h"
#import "TOPColorMatrix.h"
@implementation TOPDataTool

+(NSDictionary *)top_pictureProcessDatawithImg:(UIImage *)img currentItem:(NSInteger)item{
    NSDictionary * drawDic = [NSDictionary new];
    switch (item) {
        case TOPProcessTypeOriginal:
            drawDic = @{@"image":img,@"name":NSLocalizedString(@"topscan_original", @"")};
            break;
        case TOPProcessTypeBW:
            drawDic = @{@"image":img,@"name":NSLocalizedString(@"topscan_blackwhite", @"")};
            break;
        case TOPProcessTypeBW2:
            drawDic = @{@"image":img,@"name":NSLocalizedString(@"topscan_blackwhite2", @"")};
            break;
        case TOPProcessTypeBW3:
            drawDic = @{@"image":img,@"name":NSLocalizedString(@"topscan_blackwhite3", @"")};
            break;
        case TOPProcessTypeGrayscale:
            drawDic = @{@"image":img,@"name":NSLocalizedString(@"topscan_grayscale", @"")};
            break;
        case TOPProcessTypeMagicColor:
            drawDic = @{@"image":img,@"name":NSLocalizedString(@"topscan_magiccolor", @"")};
            break;
        case TOPProcessTypeMagicColor2:
            drawDic = @{@"image":img,@"name":NSLocalizedString(@"topscan_magiccolor2", @"")};
            break;
        case TOPProcessTypeNostalgic:
            drawDic = @{@"image":img,@"name":NSLocalizedString(@"topscan_nostalgic", @"")};
            break;
        default:
            break;
    }
    return drawDic;
}
+(NSDictionary *)top_pictureProcessDatawithImgPath:(NSString *)path currentItem:(NSInteger)item{
    NSDictionary * drawDic = [NSDictionary new];
    switch (item) {
        case TOPProcessTypeOriginal:
            drawDic = @{@"image":path,@"name":NSLocalizedString(@"topscan_original", @"")};
            break;
        case TOPProcessTypeBW:
            drawDic = @{@"image":path,@"name":NSLocalizedString(@"topscan_blackwhite", @"")};
            break;
        case TOPProcessTypeBW2:
            drawDic = @{@"image":path,@"name":NSLocalizedString(@"topscan_blackwhite2", @"")};
            break;
        case TOPProcessTypeBW3:
            drawDic = @{@"image":path,@"name":NSLocalizedString(@"topscan_blackwhite3", @"")};
            break;
        case TOPProcessTypeGrayscale:
            drawDic = @{@"image":path,@"name":NSLocalizedString(@"topscan_grayscale", @"")};
            break;
        case TOPProcessTypeMagicColor:
            drawDic = @{@"image":path,@"name":NSLocalizedString(@"topscan_magiccolor", @"")};
            break;
        case TOPProcessTypeMagicColor2:
            drawDic = @{@"image":path,@"name":NSLocalizedString(@"topscan_magiccolor2", @"")};
            break;
        case TOPProcessTypeNostalgic:
            drawDic = @{@"image":path,@"name":NSLocalizedString(@"topscan_nostalgic", @"")};
            break;
        default:
            break;
    }
    return drawDic;
}
+(NSMutableArray *)top_pictureProcessData:(UIImage *)image{
    NSMutableArray *datasourse = [NSMutableArray array];
    NSDictionary *dic = @{@"image":image,@"name":NSLocalizedString(@"topscan_original", @"")};
    [datasourse addObject:dic];
    NSDictionary *diclomo = @{@"image":image,@"name":NSLocalizedString(@"topscan_blackwhite", @"")};
    [datasourse addObject:diclomo];
    NSDictionary *dicheibai = @{@"image":image,@"name":NSLocalizedString(@"topscan_grayscale", @"")};
    [datasourse addObject:dicheibai];
    NSDictionary *dicRetro = @{@"image":image,@"name":NSLocalizedString(@"topscan_magiccolor", @"")};
    [datasourse addObject:dicRetro];
    NSDictionary *dicrui = @{@"image":image,@"name":NSLocalizedString(@"topscan_nostalgic", @"")};
    [datasourse addObject:dicrui];
    
    return datasourse;
}


+(UIImage *)top_pictureProcessData:(GPUImagePicture *)GpuPic withImg:(UIImage *)img withItem:(NSInteger)item{
    return [TOPPictureProcessTool top_imageWithImage:GpuPic withImg:img withItem:item];
}
@end
