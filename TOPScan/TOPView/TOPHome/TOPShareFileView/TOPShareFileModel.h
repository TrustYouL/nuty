#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPShareFileModel : NSObject

@property (nonatomic, assign) BOOL isSelected;//是否选中
@property (nonatomic, assign) BOOL showSize;//是否显示文件大小
@property (nonatomic, assign) BOOL isZip;//是否压缩文件
@property (nonatomic, assign) BOOL zipItem;//压缩选项
@property (nonatomic, assign) TOPShareFileType fileType;//分享文件的类型
@property (nonatomic, assign) CGFloat fileSize;//文件大小
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *icon;
/// 当前选项的次级数据
@property (nonatomic, strong) NSMutableArray *sectionData;

@end

NS_ASSUME_NONNULL_END
