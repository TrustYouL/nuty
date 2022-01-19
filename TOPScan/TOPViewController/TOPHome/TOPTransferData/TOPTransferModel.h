#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPTransferModel : NSObject

@property (copy, nonatomic) NSString *title; //标题
@property (assign, nonatomic) BOOL  isSearching;  //正在搜索中
@property (nonatomic) id  peerId;  //节点数据

@end

NS_ASSUME_NONNULL_END
