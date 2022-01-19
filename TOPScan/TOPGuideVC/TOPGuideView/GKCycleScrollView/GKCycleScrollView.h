#import <UIKit/UIKit.h>
#import "GKCycleScrollViewCell.h"

typedef NS_ENUM(NSUInteger, GKCycleScrollViewScrollDirection) {
    GKCycleScrollViewScrollDirectionHorizontal = 0, // 横向
    GKCycleScrollViewScrollDirectionVertical   = 1  // 纵向
};

@class GKCycleScrollView;
@protocol GKCycleScrollViewDataSource <NSObject>
- (NSInteger)numberOfCellsInCycleScrollView:(GKCycleScrollView *)cycleScrollView;
- (GKCycleScrollViewCell *)cycleScrollView:(GKCycleScrollView *)cycleScrollView cellForViewAtIndex:(NSInteger)index;
@end
@protocol GKCycleScrollViewDelegate <NSObject>
@optional
- (CGSize)sizeForCellInCycleScrollView:(GKCycleScrollView *)cycleScrollView;
- (void)cycleScrollView:(GKCycleScrollView *)cycleScrollView didScrollCellToIndex:(NSInteger)index;
- (void)cycleScrollView:(GKCycleScrollView *)cycleScrollView didSelectCellAtIndex:(NSInteger)index;
- (void)cycleScrollView:(GKCycleScrollView *)cycleScrollView scrollingFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex ratio:(CGFloat)ratio;
#pragma mark - UIScrollViewDelegate 相关
- (void)cycleScrollView:(GKCycleScrollView *)cycleScrollView willBeginDragging:(UIScrollView *)scrollView;
- (void)cycleScrollView:(GKCycleScrollView *)cycleScrollView didScroll:(UIScrollView *)scrollView;
- (void)cycleScrollView:(GKCycleScrollView *)cycleScrollView didEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)cycleScrollView:(GKCycleScrollView *)cycleScrollView didEndDecelerating:(UIScrollView *)scrollView;
- (void)cycleScrollView:(GKCycleScrollView *)cycleScrollView didEndScrollingAnimation:(UIScrollView *)scrollView;
@end

@interface GKCycleScrollView : UIView
@property (nonatomic, weak) id<GKCycleScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<GKCycleScrollViewDelegate> delegate;
@property (nonatomic, assign) GKCycleScrollViewScrollDirection  direction;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, strong, readonly) GKCycleScrollViewCell *currentCell;
@property (nonatomic, assign, readonly) NSInteger currentSelectIndex;
@property (nonatomic, assign) NSInteger defaultSelectIndex;
@property (nonatomic, assign) BOOL isAutoScroll;
@property (nonatomic, assign) BOOL isInfiniteLoop;
@property (nonatomic, assign) BOOL isChangeAlpha;
@property (nonatomic, assign) CGFloat minimumCellAlpha;
@property (nonatomic, assign) CGFloat leftRightMargin;
@property (nonatomic, assign) CGFloat topBottomMargin;
@property (nonatomic, assign) CGFloat autoScrollTime;
- (void)reloadData;
- (GKCycleScrollViewCell *)dequeueReusableCell;
- (void)scrollToCellAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)adjustCurrentCell;
- (void)startTimer;
- (void)stopTimer;

@end
