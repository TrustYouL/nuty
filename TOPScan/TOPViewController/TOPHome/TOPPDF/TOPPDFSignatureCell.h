#import <UIKit/UIKit.h>

@interface SSPDFSignatureModel : NSObject
@property (nonatomic, copy) NSString * _Nonnull imagePath;
@property (nonatomic, assign) BOOL isEditing;
@end

NS_ASSUME_NONNULL_BEGIN

@interface TOPPDFSignatureCell : UICollectionViewCell
- (void)top_congfigCellWithData:(SSPDFSignatureModel *)model;
@end

NS_ASSUME_NONNULL_END
