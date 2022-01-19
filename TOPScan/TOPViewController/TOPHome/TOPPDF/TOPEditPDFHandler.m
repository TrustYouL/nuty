#import "TOPEditPDFHandler.h"
#import "TOPEditPDFModel.h"

@interface TOPEditPDFHandler ()

@end

@implementation TOPEditPDFHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        _aspectRatio = 106.0 / 75.0;
    }
    return self;
}


- (NSMutableArray *)setupPdfDatasProgress:(void (^)(CGFloat))progress {
    NSMutableArray *data = @[].mutableCopy;
    NSArray *temp = self.imagePathArr.count ? self.imagePathArr : [TOPDocumentHelper top_sortPicsAtPath:self.filePath];
    int i = 1;
    for (NSString *pic in temp) {
        @autoreleasepool {
            int signatureIndex = i - 1;
            NSString *picPath = [self.filePath stringByAppendingPathComponent:pic];
            TOPEditPDFModel *model = [[TOPEditPDFModel alloc] init];
            model.imagePath = picPath;
            model.pageNum = [NSString stringWithFormat:@"%@",@(i)];
            model.pageNumLayout = [TOPScanerShare top_pdfNumberType];
            model.pageDirection = [TOPScanerShare top_pdfDirection];
            CGFloat cellWidth = TOPScreenWidth - 15 * 2;
            CGSize cellSize = CGSizeMake(cellWidth, cellWidth * self.aspectRatio);
            switch (model.pageDirection) {
                case TOPPDFPageDirectionTypeAutoSize:
                {
                    UIImage *tempImg = [UIImage imageWithContentsOfFile:picPath];
                    if (tempImg) {
                        cellSize = [self top_adjustBGImage:tempImg];
                    }
                }
                    break;
                case TOPPDFPageDirectionTypeLandscape:
                    cellSize = CGSizeMake(cellWidth, cellWidth / self.aspectRatio);
                    break;
                case TOPPDFPageDirectionTypePortrait:
                    cellSize = CGSizeMake(cellWidth, cellWidth * self.aspectRatio);
                    break;
                    
                default:
                    break;
            }
            model.cellSize = cellSize;
            if (signatureIndex < self.signatureData.count) {
                TOPEditPDFModel *signature = self.signatureData[signatureIndex];
                model.picArr = signature.picArr;
            }
            [data addObject:model];
            NSString * stateStr = [NSString stringWithFormat:@"%.3f",((i+1)*10.00)/((temp.count)*10.00)];
            progress([stateStr doubleValue]);
            i ++;
        }
    }
    self.tempData = data;
    return data;
}

- (CGSize)top_adjustBGImage:(UIImage *)image {
    UIImage *imageTy = image;
    float imgWidth = 0;
    float imgHeight = 0;

    CGFloat fatherWidth = TOPScreenWidth - 15 * 2;
    CGFloat fatherHeight = self.aspectRatio > 1.0 ? (fatherWidth / self.aspectRatio) : (fatherWidth * self.aspectRatio);
    imgWidth = fatherWidth;
    imgHeight = imgWidth * imageTy.size.height/imageTy.size.width;
    if (imgHeight > fatherHeight) {
        imgHeight = self.aspectRatio > 1.0 ? (fatherWidth * self.aspectRatio) : (fatherWidth / self.aspectRatio);
    } else {
        imgHeight = fatherHeight;
    }

    return CGSizeMake(imgWidth, imgHeight);
}

#pragma mark -- 生成带密码的PDF
- (NSString*)top_creatPDF:(NSArray *)imgArray documentName:(nonnull NSString *)name progress:(nonnull void (^)(CGFloat))progress {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * doocumentPath = TOPPDF_Path;

    if (![fileManager fileExistsAtPath:doocumentPath]) {
        [fileManager createDirectoryAtPath:doocumentPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [NSString new];
    filePath = [doocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",name]];

    UIImage *watermark = [UIImage imageWithContentsOfFile:[TOPDocumentHelper top_waterMarkTextImagePath]];
    CGRect current = [TOPDocumentHelper top_getPdfsizeWithType:[TOPScanerShare top_pageSizeType]];

    NSString *pdfPassword = [TOPScanerShare top_pdfPassword];
    NSDictionary *tempDict = [pdfPassword length] ? @{
        (NSString *)kCGPDFContextOwnerPassword : pdfPassword,
        (NSString *)kCGPDFContextUserPassword : pdfPassword} : NULL;
    UIGraphicsBeginPDFContextToFile(filePath, current, tempDict);
    
    CGRect  pdfBounds = UIGraphicsGetPDFContextBounds();
    for (int i = 0; i<imgArray.count; i++) {
        @autoreleasepool {
            TOPEditPDFModel *model = self.tempData[i];
            CGFloat pdfWidth = 0, pdfHeight = 0;
            CGFloat pdfRate = model.cellSize.height / model.cellSize.width;
            NSDecimalNumber *newRate = [TOPAppTools Rounding:pdfRate afterPoint:3];
            NSDecimalNumber *oldRate = [TOPAppTools Rounding:self.aspectRatio afterPoint:3];
            if ([newRate compare:oldRate] == NSOrderedSame) {
                pdfWidth = pdfBounds.size.width;
                pdfHeight = pdfBounds.size.height;
            } else {
                pdfWidth = pdfBounds.size.height;
                pdfHeight = pdfBounds.size.width;
            }
            UIImage *watermarkImage = pdfRate > 1.0 ? watermark : [TOPDocumentHelper top_image:watermark rotation:UIImageOrientationLeft];
            UIImage * image = imgArray[i];
            CGFloat scale = pdfWidth / model.cellSize.width;
            
            CGFloat marginH = 25 *scale;
            CGFloat imageW = image.size.width;
            CGFloat imageH = image.size.height;
            CGFloat fatherW = pdfWidth;
            CGFloat fatherH = pdfHeight - marginH * 2;
            CGRect getRect;
            if (imageW <= fatherW && imageH <= fatherH)
            {
                CGFloat originX = (fatherW - imageW) / 2;
                CGFloat originY = (fatherH - imageH) / 2;
                getRect = CGRectMake(originX, originY, imageW, imageH);
            }else{
                CGFloat width,height;
                if ((imageW / imageH) > (fatherW / fatherH))
                {
                    width  = fatherW;
                    height = width * imageH / imageW;
                }
                else
                {
                    height = fatherH;
                    width = height * imageW / imageH;
                }
                getRect = CGRectMake((fatherW - width) / 2, (pdfHeight - height) / 2, width, height);
            }
            
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pdfWidth, pdfHeight), NULL);
            [self top_drawPageNum:model pdfSize:CGSizeMake(pdfWidth, pdfHeight) scale:scale];
            [image drawInRect:getRect];
            for (SSPDFSignaturePic *picModel in model.picArr) {
                UIImage *temp = picModel.img;
                CGRect subViewRect = CGRectMake(picModel.imgViewRect.origin.x*scale, picModel.imgViewRect.origin.y*scale, CGRectGetWidth(picModel.imgViewRect) *scale, CGRectGetHeight(picModel.imgViewRect) *scale);
                [temp drawInRect:subViewRect];
            }
            if (watermarkImage) {
                [watermarkImage drawInRect:CGRectMake(0, 0, pdfWidth, pdfHeight)];
            }
            NSString * stateStr = [NSString stringWithFormat:@"%.3f",((i+1)*10.00)/((imgArray.count)*10.00)];
            progress([stateStr doubleValue]);
        }
    }
    UIGraphicsEndPDFContext();
    
    return filePath;
}

#pragma mark -- 生成不带密码的PDF
- (NSString *)top_creatNOPasswordPDF:(NSArray *)imgArray documentName:(NSString *)name progress:(void (^)(CGFloat))progress {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * doocumentPath = TOPPDF_Path;

    if (![fileManager fileExistsAtPath:doocumentPath]) {
        [fileManager createDirectoryAtPath:doocumentPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [NSString new];
    filePath = [doocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",name]];
    UIImage *watermark = [UIImage imageWithContentsOfFile:[TOPDocumentHelper top_waterMarkTextImagePath]];
    CGRect current = [TOPDocumentHelper top_getPdfsizeWithType:[TOPScanerShare top_pageSizeType]];
    UIGraphicsBeginPDFContextToFile(filePath, current, NULL);
    
    CGRect  pdfBounds = UIGraphicsGetPDFContextBounds();
    for (int i = 0; i<imgArray.count; i++) {
        @autoreleasepool {
            TOPEditPDFModel *model = self.tempData[i];
            CGFloat pdfWidth = 0, pdfHeight = 0;
            CGFloat pdfRate = model.cellSize.height / model.cellSize.width;
            NSDecimalNumber *newRate = [TOPAppTools Rounding:pdfRate afterPoint:3];
            NSDecimalNumber *oldRate = [TOPAppTools Rounding:self.aspectRatio afterPoint:3];
            if ([newRate compare:oldRate] == NSOrderedSame) {
                pdfWidth = pdfBounds.size.width;
                pdfHeight = pdfBounds.size.height;
            } else {
                pdfWidth = pdfBounds.size.height;
                pdfHeight = pdfBounds.size.width;
            }
            UIImage *watermarkImage = pdfRate > 1.0 ? watermark : [TOPDocumentHelper top_image:watermark rotation:UIImageOrientationLeft];
            UIImage * image = imgArray[i];
            CGFloat scale = pdfWidth / model.cellSize.width;
            
            CGFloat marginH = 25 *scale;
            CGFloat imageW = image.size.width;
            CGFloat imageH = image.size.height;
            CGFloat fatherW = pdfWidth;
            CGFloat fatherH = pdfHeight - marginH * 2;
            CGRect getRect;
            if (imageW <= fatherW && imageH <= fatherH)
            {
                CGFloat originX = (fatherW - imageW) / 2;
                CGFloat originY = (fatherH - imageH) / 2;
                getRect = CGRectMake(originX, originY, imageW, imageH);
            }
            else
            {
                CGFloat width,height;//缩放图片
                if ((imageW / imageH) > (fatherW / fatherH))
                {
                    width  = fatherW;
                    height = width * imageH / imageW;
                }
                else
                {
                    height = fatherH;
                    width = height * imageW / imageH;
                }
                getRect = CGRectMake((fatherW - width) / 2, (pdfHeight - height) / 2, width, height);
            }
            
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pdfWidth, pdfHeight), NULL);
            [self top_drawPageNum:model pdfSize:CGSizeMake(pdfWidth, pdfHeight) scale:scale];
            [image drawInRect:getRect];
            for (SSPDFSignaturePic *picModel in model.picArr) {
                UIImage *temp = picModel.img;
                CGRect subViewRect = CGRectMake(picModel.imgViewRect.origin.x*scale, picModel.imgViewRect.origin.y*scale, CGRectGetWidth(picModel.imgViewRect) *scale, CGRectGetHeight(picModel.imgViewRect) *scale);
                [temp drawInRect:subViewRect];
            }
            if (watermarkImage) {
                [watermarkImage drawInRect:CGRectMake(0, 0, pdfWidth, pdfHeight)];
            }
            NSString * stateStr = [NSString stringWithFormat:@"%.3f",((i+1)*10.00)/((imgArray.count)*10.00)];
            progress([stateStr doubleValue]);
        }
    }
    UIGraphicsEndPDFContext();
    
    return filePath;
}

#pragma mark -- 绘制页码
- (void)top_drawPageNum:(TOPEditPDFModel *)model pdfSize:(CGSize)pdfSize scale:(CGFloat)scale {
    if (model.pageNumLayout != TOPPDFPageNumLayoutTypeNull) {
        NSString *title = model.pageNum;
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        NSTextAlignment aligment = NSTextAlignmentNatural;
        switch (model.pageNumLayout) {
            case TOPPDFPageNumLayoutTypeNull:
                aligment = NSTextAlignmentNatural;
                break;
            case TOPPDFPageNumLayoutTypeTopLeft:
            case TOPPDFPageNumLayoutTypeBottomLeft:
                aligment = NSTextAlignmentNatural;
                break;
            case TOPPDFPageNumLayoutTypeTopCenter:
            case TOPPDFPageNumLayoutTypeBottomCenter:
                aligment = NSTextAlignmentCenter;
                break;
            case TOPPDFPageNumLayoutTypeTopRight:
            case TOPPDFPageNumLayoutTypeBottomRight:
                aligment = NSTextAlignmentRight;
                break;
                
            default:
                break;
        }
        NSInteger fontSize = 10 * scale;
        style.alignment = aligment;
        NSDictionary *attribute = @{NSFontAttributeName:PingFang_R_FONT_(fontSize),NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:RGB(53, 53, 53)};
        CGRect pageNumRect = [self top_pageLabelFrame:model.pageNumLayout scale:scale pdfSize:CGSizeMake(pdfSize.width, pdfSize.height)];
        [title drawInRect:pageNumRect withAttributes:attribute];
    }
}

- (CGRect)top_pageLabelFrame:(TOPPDFPageNumLayoutType)layoutType scale:(CGFloat)scale pdfSize:(CGSize)pdfSize {
    CGRect frame = CGRectZero;
    switch (layoutType) {
        case TOPPDFPageNumLayoutTypeNull:
            frame = CGRectZero;
            break;
        case TOPPDFPageNumLayoutTypeTopLeft:
        case TOPPDFPageNumLayoutTypeTopCenter:
        case TOPPDFPageNumLayoutTypeTopRight:
            frame = CGRectMake(15 * scale, 15 * scale / 2, pdfSize.width - 15 * scale * 2, 25 * scale);
            break;
        case TOPPDFPageNumLayoutTypeBottomLeft:
        case TOPPDFPageNumLayoutTypeBottomCenter:
        case TOPPDFPageNumLayoutTypeBottomRight:
            frame = CGRectMake(15 * scale, pdfSize.height - 25 * scale + 15 * scale / 2, pdfSize.width - 15 * scale * 2, 25 * scale);
            break;
            
        default:
            break;
    }
    return frame;
}

- (NSMutableArray *)tempData {
    if (!_tempData) {
        _tempData = @[].mutableCopy;
    }
    return _tempData;
}

- (NSMutableArray *)signatureData {
    if (!_signatureData) {
        _signatureData = @[].mutableCopy;
    }
    return _signatureData;
}

@end
