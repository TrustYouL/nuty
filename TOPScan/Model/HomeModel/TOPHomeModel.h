
#import <Foundation/Foundation.h>
#import "TOPAppDocument.h"
#import "TOPAPPFolder.h"
NS_ASSUME_NONNULL_BEGIN
@class GADNativeAd;
@interface TOPHomeModel : NSObject
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *createDate;
@property (nonatomic, strong) NSArray *folderList;
@end
@interface DocumentModel : NSObject

@property (nonatomic, copy) NSString *fileName;//上一个文件夹的名字
@property (nonatomic, copy) NSString *type; //区分文件是否属于Documnets 还是 Folders 0是Folders  1是Documnets
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *createDate;//修改时间（最开始创建的字段后面延用的就没做更改）
@property (nonatomic, copy) NSString *picCreateDate;//创建时间（获取图片详细信息时用到）
@property (nonatomic, copy) NSString *path;//文件路径
@property (nonatomic, copy) NSString *movePath; // 移动的path 即文件夹的路径
@property (nonatomic, copy) NSString *imagePath;//图片路径
@property (nonatomic, copy) NSString *number; //foler：文档数量  document：图片数量 image：图片大小
@property (nonatomic, copy) NSString *photoIndex; //照片名字  去掉后缀的
@property (nonatomic, copy) NSString *photoName;  //照片名字  带后缀后缀的
@property (nonatomic, copy) NSString *numberIndex; //照片后缀, 取到的后四位
@property (nonatomic, copy) NSString *notePath;//txt文档的路径 
@property (nonatomic, copy) NSString *note;//txt文档的内容
@property (nonatomic, copy) NSString *ocrPath;//OCR路径
@property (nonatomic, copy) NSString *ocr;//ocr内容
@property (nonatomic, assign) NSInteger collectionstate;//doc文档的收藏状态
@property (nonatomic, assign) BOOL  isFile;  //(YES是文件, NO是文件夹)
@property (nonatomic, assign) BOOL  isHaveSourceFile;  //是否有源文件
@property (nonatomic, assign) BOOL  selectStatus; //按钮状态
@property (nonatomic, assign) BOOL  docNoticeLock; //文档提醒开关状态
@property (nonatomic, assign) BOOL  chooseStatus;  //点击状态 判定是否点击过(YES是点击过, NO没有点击过)(在图片展示界面用到)
@property (nonatomic, copy) NSDate *remindTime; //文档提醒时间
@property (nonatomic, copy) NSString *remindTitle; //源文件图片路径
@property (nonatomic, copy) NSString *remindNote; //源文件图片路径

@property (nonatomic, copy) NSString *originalImagePath; //源文件图片路径
@property (nonatomic, copy) NSString *coverImagePath;//缩略图 封面展示用
@property (nonatomic, copy) NSString *midCoverImgPath;//中等大小的缩略图 最近浏览封面展示用
@property (nonatomic, copy) NSString *gaussianBlurPath;//高斯模糊图片
@property (nonatomic, copy) NSString *tagsPath;//Tags文件夹的路径
@property (nonatomic, copy) NSArray *tagsArray;//Tags文件夹下的文件夹
@property (nonatomic, copy) NSString *docPasswordPath;//doc文档密码文件夹路径
@property (nonatomic, copy) NSArray *docArray;//存放folder文件夹下docemnt文件夹 这里只有folder类文件夹用到
@property (nonatomic, copy) NSArray *picArray;//doc文档下的图片数组最多保存4个图片 视图展示类型为ShowListNextGoods时用到
@property (nonatomic, copy) NSString *docId;//目录id 数据库记录

@property (nonatomic, assign)BOOL isAd;//广告判定 yes是 no不是
@property (nonatomic, strong)GADNativeAd * adModel;//广告model
@end

NS_ASSUME_NONNULL_END
