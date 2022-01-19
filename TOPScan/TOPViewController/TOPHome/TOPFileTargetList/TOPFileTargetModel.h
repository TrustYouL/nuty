#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPFileTargetModel : NSObject
@property (copy, nonatomic) NSString *docId;
@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *createDate;
@property (copy, nonatomic) NSString *path;
@property (copy, nonatomic) NSString *imagePath;
@property (copy, nonatomic) NSString *number;
@property (assign, nonatomic) BOOL  isFile;
@property (copy, nonatomic) NSString *fatherPath;
@property (nonatomic, copy) NSString * tagsPath;
@property (nonatomic, copy) NSArray * tagsArray;
@property (nonatomic, copy) NSString *coverImagePath;
@property (nonatomic, copy) NSString * gaussianBlurPath;
@property (nonatomic, copy) NSString * docPasswordPath;
@property (assign, nonatomic) BOOL isCurrentFile;
@property (copy, nonatomic) NSString *targetFileName;
@property (assign, nonatomic) BOOL isAllDoc;
@end

NS_ASSUME_NONNULL_END
