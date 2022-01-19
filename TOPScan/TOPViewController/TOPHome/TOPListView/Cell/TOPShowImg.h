#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class DocumentModel;
@interface TOPShowImg : UIImageView
@property (nonatomic ,strong)UILabel * coverLab;
@property (nonatomic ,strong)UIImageView * noteImg;
@property (nonatomic ,strong)UIImageView * ocrImg;
@property (nonatomic ,strong)UIImageView * gaussianImg;
@property (nonatomic ,strong)DocumentModel * nextModel;
@property (nonatomic ,assign)NSInteger showNum;
@end

NS_ASSUME_NONNULL_END
