#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TOPCollageModel;
@interface TOPCollageHandler : NSObject
@property (copy, nonatomic) NSString *filePath;
@property (copy, nonatomic) NSArray *imagePathArr;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *templateArray;
@property (assign, nonatomic) TOPCollageTemplateType templateType;
@property (assign, nonatomic) TOPCollagePageSizeType paperType;
@property (assign, nonatomic) CGRect cellBounds;
@property (nonatomic, assign) NSInteger editingImageIndex;
- (NSMutableArray *)collageViewDatas;
- (NSMutableArray *)collageTemplateDatas;
- (TOPCollageModel *)addCollageModel;
- (void)top_reloadPicData;
- (void)top_outputCollageImages;
- (void)top_saveCollageImages;
- (void)top_createCollage:(TOPCollageModel *)model;
@end

NS_ASSUME_NONNULL_END
