#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPEditSelectedHeaderView : UIView
@property(nonatomic,strong) UIButton *allSelectBtn;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) void(^top_cancleEditHandler)(void);
@property (nonatomic, copy) void(^top_selectAllHandler)(BOOL selected);

@end

NS_ASSUME_NONNULL_END
