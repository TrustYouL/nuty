#import "TOPCollageHandler.h"
#import "TOPCollageModel.h"
#import "StickerView.h"
#import "TOPCollageTemplateModel.h"

@interface TOPCollageHandler ()
@property (nonatomic, assign) CGFloat imageRate;

@end

@implementation TOPCollageHandler
- (instancetype)init {
    self = [super init];
    if (self) {
        _templateType = TOPCollageTemplateTypeVerticalHalf;
        _paperType = TOPCollagePageSizeTypeA4;
        _editingImageIndex = 0;
        CGFloat cellH = (TOPScreenWidth - 20) * 106/75.00;
        _cellBounds = CGRectMake(0, 0, (TOPScreenWidth - 20), cellH);
    }
    return self;
}

- (NSMutableArray *)collageViewDatas {
    NSArray *pics = self.imagePathArr.count ? self.imagePathArr :  [TOPDocumentHelper top_sortPicsAtPath:self.filePath];
    NSMutableArray *temp = @[].mutableCopy;
    NSMutableArray *modeArr = @[].mutableCopy;
    NSMutableArray *picModels = @[].mutableCopy;
    int index = 0;
    for (int i = 0; i < pics.count; i++) {
        @autoreleasepool {
            NSString *imgPath = [self.filePath stringByAppendingPathComponent:pics[i]];
            SSCollagePic *picModel = [self top_buildPicModel:imgPath];
            picModel.imgIndex = i;
            if (i == self.editingImageIndex) {
                picModel.isEditing = YES;
            }
            static int j = 0;
            if (j < 2) {
                [modeArr addObject:imgPath];
                [picModels addObject:picModel];
                j ++;
            }
            if (j == 2 || (pics.count == i + 1)) {
                TOPCollageModel *model = [[TOPCollageModel alloc] init];
                model.imageArr = [modeArr mutableCopy];
                model.picIndex = [TOPDocumentHelper top_getFileNameNumber:(index + [TOPDocumentHelper top_maxImageNumIndexAtPath:self.filePath])];
                model.isReload = YES;
                model.modelIndex = index;
                if (j == 2) {
                    picModel.imgViewRect = [self top_adjustFrameWithTemplateType:_templateType imgFrame:picModel.imgViewRect];
                    CGFloat scale = 6;
                    picModel.picRect = CGRectMake(picModel.imgViewRect.origin.x*scale, picModel.imgViewRect.origin.y*scale, CGRectGetWidth(picModel.imgViewRect) *scale, CGRectGetHeight(picModel.imgViewRect) *scale);
                }
                model.picArr = [picModels mutableCopy];
                model.templateType = _templateType;
                [temp addObject:model];
                index ++;
                j = 0;
                [modeArr removeAllObjects];
                [picModels removeAllObjects];
            }
        }
    }
    self.dataArray = [temp mutableCopy];
    return temp;
}

- (TOPCollageModel *)addCollageModel {
    TOPCollageModel *model = [[TOPCollageModel alloc] init];
    model.isReload = YES;
    TOPCollageModel *lastModel = self.dataArray.lastObject;
    model.modelIndex = lastModel.modelIndex + 1;
    model.picIndex = [TOPDocumentHelper top_getFileNameNumber:(model.modelIndex + [TOPDocumentHelper top_maxImageNumIndexAtPath:self.filePath])];
    return model;
}

- (void)setTemplateType:(TOPCollageTemplateType)templateType {
    _templateType = templateType;
}

- (NSMutableArray *)collageTemplateDatas {
    NSMutableArray *arr = @[].mutableCopy;
    for (NSDictionary *dic in [self top_defatulTemplateData]) {
        TOPCollageTemplateModel *template = [self buildTemplateModel:dic];
        [arr addObject:template];
    }
    self.templateArray = [arr mutableCopy];
    return arr;
}

- (TOPCollageTemplateModel *)buildTemplateModel:(NSDictionary *)dic {
    TOPCollageTemplateModel *template = [[TOPCollageTemplateModel alloc] init];
    template.title = dic[@"title"];
    template.isSelected = [dic[@"isSelected"] boolValue];
    template.selectedIconName = dic[@"selectedIconName"];
    template.iconName = dic[@"iconName"];
    template.templateType = [dic[@"templateType"] integerValue];
    if (self.templateType == template.templateType) {
        template.isSelected = YES;
    } else {
        template.isSelected = NO;
    }
    return template;
}

- (SSCollagePic *)top_buildPicModel:(NSString *)picPath {
    CGFloat rate = [UIScreen mainScreen].scale > 2 ? 0.25 : 0.3;
    UIImage *subImage = [UIImage imageWithContentsOfFile:picPath];
    UIImage *scaleImage = [TOPPictureProcessTool top_scaleImageWithData:[NSData dataWithContentsOfFile:picPath] withSize:CGSizeMake(subImage.size.width * rate, subImage.size.height * rate)];
    CGRect imgViewRect = [self layoutImageViewWithModel:self.templateType image:subImage];
    CGFloat scale = 6;
    CGRect subViewRect = CGRectMake(imgViewRect.origin.x*scale, imgViewRect.origin.y*scale, CGRectGetWidth(imgViewRect) *scale, CGRectGetHeight(imgViewRect) *scale);
    SSCollagePic *picModel = [[SSCollagePic alloc] initWithImage:scaleImage imgRect:subViewRect];
    picModel.imgViewRect = imgViewRect;
    return picModel;
}

- (CGSize)top_imageSizeWithHeight:(CGFloat)height width:(CGFloat)width {
    CGFloat paperW = 210.00;
    switch (self.paperType) {
        case TOPCollagePageSizeTypeA3:
            paperW = 297.00;
            break;
        case TOPCollagePageSizeTypeA4:
            paperW = 210.00;
            break;
        case TOPCollagePageSizeTypeA5:
            paperW = 149.00;
            break;
        case TOPCollagePageSizeTypeB4:
            paperW = 250.00;
            break;
        case TOPCollagePageSizeTypeB5:
            paperW = 176.00;
            break;
            
        default:
            break;
    }
    CGFloat imgW = 0;
    CGFloat imgH = 0;
    CGFloat fatherWidth = CGRectGetWidth(self.cellBounds);
    CGFloat fatherHeight = CGRectGetHeight(self.cellBounds)/2;
    if (self.imageRate >= fatherWidth/fatherHeight) {//宽图
        imgW = fatherWidth/paperW * width;
        imgH = imgW / self.imageRate;
    } else {//竖向长图
        imgH = fatherWidth/paperW * width;;
        imgW = imgH * self.imageRate;
    }
    if (imgH > (fatherHeight - 20)) {
        imgH = fatherHeight - 20;
        imgW = imgH * self.imageRate;
    }
    if (imgW > 0) {
        imgW = imgW;
    } else {
        imgW = 100;
        imgH = imgW / self.imageRate;
    }
    CGSize size = CGSizeMake(imgW, imgH);
    return size;
}

- (CGRect)layoutImageViewWithModel:(NSInteger)type image:(UIImage *)image {
    self.imageRate = (image.size.width * 100.0)/ (image.size.height * 100.0);
    CGRect imgFrame = CGRectZero;
    switch (type) {
        case TOPCollageTemplateTypeDriverLicense:
            imgFrame = [self top_adaptiveImageWithSize:[self top_imageSizeWithHeight:54.0 width:85.6]];
            break;
        case TOPCollageTemplateTypeIDCard:
            imgFrame = [self top_adaptiveImageWithSize:[self top_imageSizeWithHeight:54.0 width:85.6]];
            break;
        case TOPCollageTemplateTypePassport:
            imgFrame = [self top_adaptiveImageWithSize:[self top_imageSizeWithHeight:88.0 width:125.00]];
            break;
        case TOPCollageTemplateTypeAccountBook:
            imgFrame = [self top_adaptiveImageWithSize:[self top_imageSizeWithHeight:105.0 width:143.00]];
            break;
        case TOPCollageTemplateTypeProofOfProperty:
            imgFrame = [self top_adaptiveImageWithSize:[self top_imageSizeWithHeight:105.0 width:143.00]];
            break;
        case TOPCollageTemplateTypeHorizontalHalf:
            imgFrame = [self top_adaptiveHorizontalImage:image];
            break;
        case TOPCollageTemplateTypeVerticalHalf:
            imgFrame = [self top_adaptiveTargetImage:image];
            break;
            
        default:
            break;
    }
    return imgFrame;
}

- (CGRect)top_adaptiveImageWithSize:(CGSize)imageSize {
    float imgWidth = imageSize.width;
    float imgHeight = imageSize.height;
    CGFloat fatherWidth = CGRectGetWidth(self.cellBounds);
    CGFloat fatherHeight = CGRectGetHeight(self.cellBounds)/2;
    return CGRectMake((fatherWidth-imgWidth)/2, (fatherHeight-imgHeight)/2, imgWidth, imgHeight);
}

- (CGRect)top_adaptiveHorizontalImage:(UIImage *)image {
    CGFloat lineSpace = 10;
    UIImage *imageTy = image;
    float imgWidth = 0;
    float imgHeight = 0;

    CGFloat fatherWidth = CGRectGetWidth(self.cellBounds) - lineSpace *4;
    CGFloat fatherHeight = CGRectGetHeight(self.cellBounds);
    if  (imageTy.size.width/imageTy.size.height >= fatherWidth/fatherHeight) {
        imgWidth = fatherWidth/2;
        imgHeight = imgWidth / imageTy.size.width * imageTy.size.height;
    } else {
        imgHeight = fatherHeight/2;
        imgWidth = imgHeight / imageTy.size.height * imageTy.size.width;
    }
    return CGRectMake(lineSpace + (fatherWidth/2-imgWidth)/2, (fatherHeight-imgHeight)/2, imgWidth, imgHeight);
}

- (CGRect)top_adaptiveTargetImage:(UIImage *)image {
    CGFloat lineSpace = 10;
    UIImage *imageTy = image;
    float imgWidth = 0;
    float imgHeight = 0;

    CGFloat fatherWidth = CGRectGetWidth(self.cellBounds);
    CGFloat fatherHeight = CGRectGetHeight(self.cellBounds) - lineSpace *4;
    if  (imageTy.size.width/imageTy.size.height >= fatherWidth/fatherHeight) {
        imgWidth = fatherWidth/2;
        imgHeight = imgWidth / imageTy.size.width * imageTy.size.height;
    } else {
        imgHeight = fatherHeight/2;
        imgWidth = imgHeight / imageTy.size.height * imageTy.size.width;
    }
    return CGRectMake((fatherWidth-imgWidth)/2, lineSpace + (fatherHeight/2 - imgHeight)/2, imgWidth, imgHeight);
}

- (CGRect)top_adjustFrameWithTemplateType:(TOPCollageTemplateType)type imgFrame:(CGRect)frame {
    CGRect imgFrame = frame;
    switch (type) {
        case TOPCollageTemplateTypeDriverLicense:
            imgFrame.origin.y = CGRectGetHeight(self.cellBounds)/2 + imgFrame.origin.y;
            break;
        case TOPCollageTemplateTypeIDCard:
            imgFrame.origin.y = CGRectGetHeight(self.cellBounds)/2 + imgFrame.origin.y;
            break;
        case TOPCollageTemplateTypePassport:
            imgFrame.origin.y = CGRectGetHeight(self.cellBounds)/2 + imgFrame.origin.y;
            break;
        case TOPCollageTemplateTypeAccountBook:
            imgFrame.origin.y = CGRectGetHeight(self.cellBounds)/2 + imgFrame.origin.y;
            break;
        case TOPCollageTemplateTypeProofOfProperty:
            imgFrame.origin.y = CGRectGetHeight(self.cellBounds)/2 + imgFrame.origin.y;
            break;
        case TOPCollageTemplateTypeHorizontalHalf:
            imgFrame.origin.x = CGRectGetWidth(self.cellBounds)/2 + imgFrame.origin.x;
            break;
        case TOPCollageTemplateTypeVerticalHalf:
            imgFrame.origin.y = CGRectGetHeight(self.cellBounds)/2 + imgFrame.origin.y;
            break;
            
        default:
            break;
    }
    return imgFrame;
}

#pragma mark -- 编辑图片要更新数据
- (void)top_reloadPicData {
    CGRect bgRect = CGRectZero;
    for (TOPCollageModel *model in self.dataArray) {
        if (model.bgImageRect.size.height > 0) {//未加载的cell没有赋值bgImageRect，将已加载的值赋给。。
            bgRect = model.bgImageRect;
        } else {
            model.bgImageRect = bgRect;
        }
        [model top_convertRectBuildPicModel];
    }
}

#pragma mark -- 合并图片
- (UIImage *)top_collagedImagesWithModel:(TOPCollageModel *)collageModel {
    if (!collageModel.picArr.count) {
        return nil;
    }
    UIImage *backgroundImage = [UIImage imageNamed:@"top_collage_bg"];
    UIGraphicsBeginImageContextWithOptions(collageModel.bgImageRect.size, NO, 1.0);
    [backgroundImage drawInRect:collageModel.bgImageRect];
    for (SSCollagePic *picModel in collageModel.picArr) {
        UIImage *temp = picModel.img;
        [temp drawInRect:picModel.picRect];
    }
    if ([TOPWHCFileManager top_isExistsAtPath:[TOPDocumentHelper top_waterMarkTextImagePath]]) {
        UIImage *markImg = [UIImage imageWithContentsOfFile:[TOPDocumentHelper top_waterMarkTextImagePath]];
        [markImg drawInRect:collageModel.bgImageRect];
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark -- 输出全部拼接后的图片
- (void)top_outputCollageImages {
    for (TOPCollageModel *model in self.dataArray) {
        [self top_createCollage:model];
    }
}

- (void)top_createCollage:(TOPCollageModel *)model {
    UIImage *cellImg = [self top_collagedImagesWithModel:model];
    if (cellImg) {
        UIImage *newImg = [TOPPictureProcessTool top_fetchOriginalImageWithData:[TOPDocumentHelper top_saveImageForData:cellImg]];
        NSString *imgName = [NSString stringWithFormat:@"%@%@%@",[TOPDocumentHelper top_getFormatCurrentTime],model.picIndex,TOP_TRJPGPathSuffixString];
        [TOPDocumentHelper top_saveImage:newImg atPath:[TOPDocumentHelper top_collageImagePath:imgName]];
    }
}

#pragma mark -- 保存全部拼接图
- (void)top_saveCollageImages {
    [TOPDocumentHelper top_copyFileItemsAtPath:[TOPDocumentHelper top_collageImageFileString] toNewFileAtPath:self.filePath];
}

#pragma mark -- 拷贝源图
- (void)top_saveOriginalImageWithNewImage:(NSString *)newPath {
    NSString *originalImgPath = newPath;
    if ([TOPWHCFileManager top_isExistsAtPath:originalImgPath] && [TOPScanerShare top_saveOriginalImage]) {
        NSString *newOriginalPath = [TOPDocumentHelper top_originalImage:newPath];
        [TOPWHCFileManager top_copyItemAtPath:originalImgPath toPath:newOriginalPath];
    }
}

#pragma mark -- lazy
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[].mutableCopy;
    }
    return _dataArray;
}

- (NSMutableArray *)templateArray {
    if (!_templateArray) {
        _templateArray = @[].mutableCopy;
    }
    return _templateArray;
}

- (NSArray *)top_defatulTemplateData {
    NSDictionary *temp1 = @{@"isSelected":@(0),
                            @"selectedIconName":@"top_DriverLicense_selected",
                            @"iconName":@"top_DriverLicense",
                            @"title":NSLocalizedString(@"topscan_collagedriverlicense", @""),
                            @"templateType":@(TOPCollageTemplateTypeDriverLicense)};
    NSDictionary *temp2 = @{@"isSelected":@(0),
                            @"selectedIconName":@"top_IDCard_selected",
                            @"iconName":@"top_IDCard",
                            @"title":NSLocalizedString(@"topscan_collageidcard", @""),
                            @"templateType":@(TOPCollageTemplateTypeIDCard)};
    NSDictionary *temp3 = @{@"isSelected":@(0),
                            @"selectedIconName":@"top_Passport_selected",
                            @"iconName":@"top_Passport",
                            @"title":NSLocalizedString(@"topscan_collagepassport", @""),
                            @"templateType":@(TOPCollageTemplateTypePassport)};
    NSDictionary *temp4 = @{@"isSelected":@(0),
                            @"selectedIconName":@"top_AccountBook_selected",
                            @"iconName":@"top_AccountBook",
                            @"title":NSLocalizedString(@"topscan_collageaccountbook", @""),
                            @"templateType":@(TOPCollageTemplateTypeAccountBook)};
    NSDictionary *temp5 = @{@"isSelected":@(0),
                            @"selectedIconName":@"top_Property_selected",
                            @"iconName":@"top_Property",
                            @"title":NSLocalizedString(@"topscan_collageproof", @""),
                            @"templateType":@(TOPCollageTemplateTypeProofOfProperty)};
    NSDictionary *temp6 = @{@"isSelected":@(1),
                            @"selectedIconName":@"top_VerticalHalf_selected",
                            @"iconName":@"top_VerticalHalf",
                            @"title":@"2x1",
                            @"templateType":@(TOPCollageTemplateTypeVerticalHalf)};
    NSDictionary *temp7 = @{@"isSelected":@(0),
                            @"selectedIconName":@"top_HorizontalHalf_selected",
                            @"iconName":@"top_HorizontalHalf",
                            @"title":@"1x2",
                            @"templateType":@(TOPCollageTemplateTypeHorizontalHalf)};
    NSArray *temps = @[temp1, temp2, temp3, temp4, temp5, temp6, temp7];
    return temps;
}

@end
