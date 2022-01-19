#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPShowPicTextCollectionViewCell : UICollectionViewCell<UIScrollViewDelegate,UITextViewDelegate>
@property (nonatomic ,strong)DocumentModel * model;
@property (nonatomic ,strong)UIView * whiteCoverView;
@property (nonatomic ,strong)UIImageView * iconImg;
@property (nonatomic ,strong)UILabel * titleLab;
@property (nonatomic ,strong)UIButton * recognizeBtn;
@property (nonatomic ,strong)UITextView * textView;
@property (nonatomic ,copy)void(^top_clickToOcr)(void);
@property (nonatomic ,copy)void(^top_scrollBeginHide)(void);
@property (nonatomic ,copy)void(^top_scrollEndShow)(void);

@end

NS_ASSUME_NONNULL_END
