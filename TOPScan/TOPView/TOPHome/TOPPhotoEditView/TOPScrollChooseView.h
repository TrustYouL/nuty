#import <UIKit/UIKit.h>

typedef void(^TOPScrollChooseViewBlock)(NSInteger selectedValue);

@interface TOPScrollChooseView : UIView
@property (strong, nonatomic) UIView * whiteView;
@property (strong, nonatomic) TOPScrollChooseViewBlock confirmBlock;
@property (assign, nonatomic) BOOL unableEdit;//数据源是否不可编辑（默认no：可以编辑）
- (instancetype)initWithQuestionArray:(NSArray *)questionArray withDefaultDesc:(NSInteger )defaultDesc;
- (void)top_showView;

@end
