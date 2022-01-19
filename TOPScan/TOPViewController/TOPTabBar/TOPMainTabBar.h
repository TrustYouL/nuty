#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol TOPMainTabBarDelegate <NSObject>
-(void)changeIndex:(NSInteger)index;
@end

@interface TOPMainTabBar : UITabBar

@property(nonatomic,assign)NSInteger tabIndex;
@property(nonatomic,weak)id delegate;
@property(nonatomic,copy)void (^changeIndex)(NSInteger index);

- (instancetype)initWithTitArr:(NSArray *)titArr imgArr:(NSArray *)imgArr sImgArr:(NSArray *)sImgArr;

- (void)top_currentSelect:(NSInteger)selectIndex;
@end

NS_ASSUME_NONNULL_END
