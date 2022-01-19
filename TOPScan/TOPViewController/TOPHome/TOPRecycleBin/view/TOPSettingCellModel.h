#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSettingCellModel : NSObject
@property (nonatomic ,copy) NSString *title;
@property (nonatomic ,copy) NSString *content;
@property (nonatomic ,assign) NSInteger cellType;
@property (nonatomic ,assign) TOPSettingVCAction action;
@property (nonatomic ,assign) BOOL isOpen;
@property (nonatomic ,assign) BOOL showLine;

@end

NS_ASSUME_NONNULL_END
