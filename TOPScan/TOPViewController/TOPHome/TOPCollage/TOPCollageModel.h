#import <Foundation/Foundation.h>

@interface SSCollagePic : NSObject

@property (nonatomic, assign) CGRect imgViewRect;
@property (nonatomic, assign) CGRect picRect;
@property (nonatomic, strong) UIImage *img;
@property (nonatomic, assign) NSInteger imgIndex;
@property (nonatomic, assign) BOOL isEditing;

- (instancetype)initWithImage:(UIImage *)img imgRect:(CGRect)imgRect;
@end

@interface TOPCollageModel : NSObject
@property (nonatomic, strong) NSMutableArray *imageArr;
@property (nonatomic, copy) NSString *picIndex;
@property (nonatomic, assign) BOOL isReload;
@property (nonatomic, assign) NSInteger modelIndex;
@property (nonatomic, strong) NSMutableArray *picArr;
@property (nonatomic, assign) CGRect bgImageRect;
@property (nonatomic, strong) NSMutableArray *stickerArr;
@property (nonatomic, strong) UIImageView *bgImgView;
@property (assign, nonatomic) CGFloat imageScale;
@property (assign, nonatomic) TOPCollageTemplateType templateType;

- (void)top_convertRectBuildPicModel;

@end

