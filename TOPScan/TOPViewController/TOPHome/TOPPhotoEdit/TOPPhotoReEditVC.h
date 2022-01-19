#import <UIKit/UIKit.h>
#import "TOPBaseChildViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPPhotoReEditVC : TOPBaseChildViewController
@property (nonatomic ,strong) UIImage * originImage;//没裁剪的图片
@property (nonatomic ,strong) NSMutableArray * dataArray;
@property (nonatomic ,strong) NSMutableArray * showArray;
@property (nonatomic ,strong) DocumentModel * model;
@property (nonatomic ,strong) UIImage *cropImage;
@property (nonatomic ,copy) NSString *pathString;
@property (nonatomic ,copy) NSArray *cropPoints;
@property (nonatomic ,copy) NSArray *autoCropPoints;
@property (nonatomic ,assign) NSInteger fileType;  //文件类型
@property (nonatomic ,assign) TOPHomeChildViewControllerBackType backType;

@end

NS_ASSUME_NONNULL_END
