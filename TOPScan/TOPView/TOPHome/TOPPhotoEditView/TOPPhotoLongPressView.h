#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPPhotoLongPressView : UIView
@property (copy, nonatomic) NSArray *selectedImgs;
@property (copy, nonatomic) NSArray *disableImgs;
@property (copy, nonatomic) NSArray *highlightImgs;
@property (copy, nonatomic) NSArray *highlightItems;
@property (copy, nonatomic) NSArray *funcArray;
@property (copy, nonatomic) NSArray *funcTitles;
@property (assign, nonatomic) BOOL isSingle;

- (instancetype)initWithPressUpFrame:(CGRect)frame;
- (instancetype)initWithPressBottomFrame:(CGRect)frame sendPicArray:(NSArray *)picArray sendNameArray:(NSArray *)nameArray;
- (instancetype)initWithFrame:(CGRect)frame withBarItems:(NSArray *)itemArray;
@property (nonatomic, copy) void(^top_cancleEditHandler)(void);
@property (nonatomic, copy) void(^top_selectAllHandler)(BOOL selected);
@property (nonatomic, copy) void(^top_longPressBootomItemHandler)(NSInteger index);
@property(nonatomic,strong)UIButton *allSelectBtn;
@property(nonatomic,strong)UIButton * tagBtn;
- (void)top_configureSelectedCount:(NSInteger)count;
- (void)top_changePressViewBtnStatue:(NSArray *)picArray enabled:(BOOL)enable;
- (void)top_changeShareBtnStatue:(BOOL)enable;
- (void)top_changeDeleteBtnStatue:(BOOL)enable;
- (void)top_changePressViewBtnState:(TOPItemsSelectedState)selectedState;
- (void)top_didSelectedFunction:(NSNumber *)item;
- (void)top_didSelectedFunctionChangeState:(NSNumber *)item;
- (void)top_setHighlightItem:(NSNumber *)item;
- (void)top_changeUPViewState;
- (void)top_refreshLogoShow:(BOOL)show;
@end

NS_ASSUME_NONNULL_END
