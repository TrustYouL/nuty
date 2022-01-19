#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPScameraBatchBottomView : UIView
@property (nonatomic, copy) void(^top_longPressBootomItemHandler)(NSInteger index);
@property (nonatomic, copy) NSArray * normalArray;
@property (nonatomic, copy) NSArray * reEditArray;
@property (nonatomic, copy) NSString *selectFilterItem;
@property (nonatomic, strong) UIColor *normalStateColor;


- (instancetype)initWithFrame:(CGRect)frame sendPic:(NSArray *)picArray;
- (instancetype)initWithFrame:(CGRect)frame sendPic:(NSArray *)picArray itemNames:(NSArray *)names;
- (void)top_changeBtnState:(BOOL)enable;
- (void)top_changeFilterBtnSelectState:(BOOL)select atIndex:(NSInteger)index ;
- (void)top_changeFinishBtnState:(BOOL)enable;
@end

NS_ASSUME_NONNULL_END
