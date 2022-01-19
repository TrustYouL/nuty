#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPTagsListModel : NSObject
@property (nonatomic,assign)NSInteger tagID;
@property (nonatomic,copy)NSString * tagName;
@property (nonatomic,copy)NSString * tagNum;
@property (nonatomic,copy)NSString * tagPath;
@property (nonatomic,copy)NSArray * docArray;
@end

NS_ASSUME_NONNULL_END
