//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SSPDFSignaturePic : NSObject

@property (nonatomic, assign) CGRect imgViewRect;
@property (nonatomic, assign) CGRect picRect;
@property (nonatomic, strong) UIImage *img;
@property (nonatomic, assign) NSInteger imgIndex;//图片索引
@property (nonatomic, assign) CGFloat picScale;//图片缩放比例
@property (nonatomic, assign) CGFloat picRotation;//图片旋转角度
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL enabledInteraction;

- (instancetype)initWithImage:(UIImage *)img imgRect:(CGRect)imgRect;
@end

NS_ASSUME_NONNULL_BEGIN

@interface TOPEditPDFModel : NSObject
@property (copy, nonatomic) NSString *pageNum;
@property (copy, nonatomic) NSString *imagePath;
@property (assign, nonatomic) TOPPDFPageNumLayoutType pageNumLayout;
@property (assign, nonatomic) TOPPDFPageDirectionType pageDirection;
@property (assign, nonatomic) CGSize cellSize;
@property (nonatomic, strong) NSMutableArray *picArr;//存放SSPDFSignaturePic

@end

NS_ASSUME_NONNULL_END
