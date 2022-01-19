//
//  TOPHomeChildViewController.h
#import <UIKit/UIKit.h>
#import "TOPBaseChildViewController.h"
#import "TOPFunctionColletionModel.h"
NS_ASSUME_NONNULL_BEGIN

@class DocumentModel;
@interface TOPHomeChildViewController : TOPBaseChildViewController
@property (nonatomic, strong) DocumentModel *docModel;
@property (nonatomic, copy) NSString *upperPathString;
@property (nonatomic, copy) NSString *pathString;
@property (nonatomic, assign) NSInteger fileType;
@property (nonatomic, copy) NSString *addType;
@property (nonatomic, copy) NSString *fileNameString;
@property (nonatomic, copy) NSString *startPath;
@property (nonatomic, assign) TOPHomeChildViewControllerBackType backType;
@property (nonatomic, strong)NSArray * assetsArray;
@property (nonatomic, strong)NSArray * upArray;
@property (nonatomic, strong)TOPFunctionColletionModel * selectBoxModel;
@property (nonatomic, assign)BOOL backRefresh;
@property (nonatomic, assign)BOOL showMoreView;
@property (copy, nonatomic) void(^top_backBtnAction)(void);
@property (copy, nonatomic) void(^top_backScreenshotAction)(void);
@property (copy, nonatomic) void(^top_pdfExtractAction)(NSString * endPath, NSString * upperPathString);
@property (nonatomic ,assign)BOOL isAppDelegate;
- (void)top_CancleSelectAction;
- (void)top_LoadSanBoxData;
@end

NS_ASSUME_NONNULL_END
