#import <Foundation/Foundation.h>
#import "TOPTagsListModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPTagsManagerModel : NSObject
@property (nonatomic,strong)TOPTagsListModel * tagsListModel;
@property (nonatomic,assign)BOOL isEdit;
@end

NS_ASSUME_NONNULL_END
