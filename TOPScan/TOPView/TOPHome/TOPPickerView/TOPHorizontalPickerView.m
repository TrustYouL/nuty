#import "TOPHorizontalPickerView.h"
#import "TOPPickerItem.h"

#define kAnimationTime .2

@interface TOPHorizontalPickerView ()<UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) NSMutableArray *items;

@end

@implementation TOPHorizontalPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

#pragma mark - UI
- (void)setUp {
    self.items = [NSMutableArray array];
    self.scrollView = [[UIScrollView alloc] initWithFrame:
                       CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.decelerationRate = 0.5;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.firstItemX = 0;
    [self addSubview:self.scrollView];
}

#pragma mark - layout Items
- (void)layoutSubviews {
    NSLog(@"  ---  layoutSubviews  --- ");
    [super layoutSubviews];
    if (!self.items) {
        return;
    }
    [self layoutItems];
}

- (void)layoutItems {
    NSLog(@"  ---  刷新数据后重新布局  ---  ");
    self.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    CGFloat startX = self.firstItemX;
    NSLog(@"  CGRectGetHeight(self.bounds) : %f  self.itemHeight : %f",CGRectGetHeight(self.bounds),self.itemHeight);
    for (int i = 0; i < self.items.count; i++) {
        TOPPickerItem *item = [self.items objectAtIndex:i];
        item.frame = CGRectMake(startX, CGRectGetHeight(self.bounds)-self.itemHeight, self.itemWidth, self.itemHeight);
        startX += self.itemWidth;
    }
    self.scrollView.contentSize = CGSizeMake(MAX(startX+CGRectGetWidth(self.bounds)-self.firstItemX-self.itemWidth *.5, startX), CGRectGetHeight(self.bounds));
    [self setItemAtContentOffset:self.scrollView.contentOffset];
    NSLog(@" self.scrollView.contentOffset.width: %f  self.scrollView.contentOffset.height: %f  self.scrollView.contentOffset.x: %f",self.scrollView.contentSize.width,self.scrollView.contentSize.height,self.scrollView.contentOffset.x);
}

#pragma mark - public Method（GetData）
- (void)reloadData {
    for (TOPPickerItem *item in self.items) {
        [item removeFromSuperview];
    }
    [self.items removeAllObjects];
    NSInteger count = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfItemAtPickerScrollView:)]) {
        count = [self.dataSource numberOfItemAtPickerScrollView:self];
    }
    for (NSInteger i = 0; i < count; i++) {
        TOPPickerItem *item = nil;
        if ([self.dataSource respondsToSelector:@selector(pickerScrollView:itemAtIndex:)]) {
            item = [self.dataSource pickerScrollView:self itemAtIndex:i];
        }
        if (item) {
            item.originalSize = CGSizeMake(self.itemWidth, self.itemHeight);
            [self.items addObject:item];
            [self.scrollView addSubview:item];
            item.index = i;
        }
    }
    [self layoutItems];
}

- (void)scollToSelectdIndex:(NSInteger)index {
    [self selectItemAtIndex:index];
}

#pragma mark - Helper
- (void)setItemAtContentOffset:(CGPoint)offset {
    NSInteger centerIndex = roundf(offset.x / self.itemWidth);//返回最接近_X的整数
    NSLog(@" setItemAtContentOffset： %ld  移动距离offset——x： %f",(long)centerIndex,offset.x);
    for (int i = 0; i < self.items.count; i++) {
        TOPPickerItem * item = [self.items objectAtIndex:i];
        [self itemInCenterBack:item];
        if (centerIndex == i) {
            [self itemInCenterChange:item];
            _seletedIndex = centerIndex;
        }
    }
}

- (void)scollToItemViewAtIndex:(NSInteger)index animated:(BOOL)animated {
    CGPoint point = CGPointMake(index * _itemWidth,self.scrollView.contentOffset.y);
    NSLog(@"  ---  scollToItemViewAtIndex  --- index: %ld  point: %f",index,point.x);
    [UIView animateWithDuration:kAnimationTime animations:^{
        [self.scrollView setContentOffset:point];
    } completion:^(BOOL finished) {
        [self setItemAtContentOffset:point];
    }];
}

- (void)setCenterContentOffset:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    NSLog(@" scrollView offsetX : %f",offsetX);
    if (offsetX < 0) {
        offsetX = self.itemWidth * 0.5;
    } else if (offsetX > (self.items.count - 1) * self.itemWidth) {
        offsetX = (self.items.count - 1) * self.itemWidth;
    }
    NSInteger value = roundf(offsetX / self.itemWidth);
    NSLog(@" value : %ld  offsetX : %f",value,offsetX);
    [self selectItemAtIndex:value];
    [UIView animateWithDuration:kAnimationTime animations:^{
        [scrollView setContentOffset:CGPointMake(self.itemWidth * value, scrollView.contentOffset.y)];
    } completion:^(BOOL finished) {
        [self setItemAtContentOffset:scrollView.contentOffset];
    }];
    
}

#pragma mark - delegate
- (void)selectItemAtIndex:(NSInteger)index {
    NSLog(@"点击选中index ： %ld",index);
    _seletedIndex = index;
    [self scollToItemViewAtIndex:_seletedIndex animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerScrollView:didSelecteItemAtIndex:)]) {
        [self.delegate pickerScrollView:self didSelecteItemAtIndex:_seletedIndex];
    }
}

- (void)itemInCenterChange:(TOPPickerItem*)item {
    if ([self.delegate respondsToSelector:@selector(itemForIndexChange:)]) {
        [self.delegate itemForIndexChange:item];
    }
}

- (void)itemInCenterBack:(TOPPickerItem*)item {
    if ([self.delegate respondsToSelector:@selector(itemForIndexBack:)]) {
        [self.delegate itemForIndexBack:item];
    }
}

#pragma mark - scrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (int i = 0; i < self.items.count; i++) {
        TOPPickerItem * item = [self.items objectAtIndex:i];
        [self itemInCenterBack:item];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"  --  scrollViewDidEndDecelerating  --  ");
    [self setCenterContentOffset:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        NSLog(@"  --  scrollViewDidEndDragging  --  ");
        [self setCenterContentOffset:scrollView];
    }
}

@end
