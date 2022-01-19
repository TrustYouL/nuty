#import "TOPBaseChildViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TopEditFolderAndDocNameVC : TOPBaseChildViewController
@property (nonatomic ,copy)NSString * defaultString;
@property (nonatomic ,copy)NSString * picName;
@property (nonatomic ,assign)TopFileNameEditType editType;
@property (nonatomic ,copy)void(^top_clickToSendString)(NSString * nameString);
@end

NS_ASSUME_NONNULL_END
