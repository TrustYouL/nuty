#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class DocumentModel, TOPFileTargetModel;
@interface TOPFileDataManager : NSObject
@property (nonatomic, strong) TOPTagsListModel * allListModel;//所有文档的标签模型，进入childVC之后在进入pdf预览 然后返回 如果进入app次数不小于10次 文档的个数不小于10个就弹出评论弹窗，allListModel是为了记录doc文档的个数的， 但是这记录不是很准确， 当删除文档之后这个记录所有文档的个数就会有问题 但是可以不考虑， allListModel只用于评分弹窗弹出的逻辑 其他地方不要使用。
@property (nonatomic, strong) DocumentModel *docModel;//当前文件的数据对象
@property (nonatomic, strong) TOPFileTargetModel *fileModel;//移动、复制的指定文件数据对象
@property (nonatomic, strong) NSMutableArray *folderPaths;//恢复备份的文件夹
@property (nonatomic, strong) NSMutableArray *docPaths;//恢复备份的文档
//单例初始化
+ (instancetype)shareInstance;
@end

NS_ASSUME_NONNULL_END
