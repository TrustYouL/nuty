#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TOPPickerItem,TOPHorizontalPickerView;
@protocol TOPHorizontalPickerViewDelegate
@optional
- (void)pickerScrollView:(TOPHorizontalPickerView *)menuScrollView didSelecteItemAtIndex:(NSInteger)index;
- (void)itemForIndexChange:(TOPPickerItem *)item;
- (void)itemForIndexBack:(TOPPickerItem *)item;
@end

@protocol TOPHorizontalPickerViewDataSource
- (NSInteger)numberOfItemAtPickerScrollView:(TOPHorizontalPickerView *)pickerScrollView;
- (TOPPickerItem *)pickerScrollView:(TOPHorizontalPickerView *)pickerScrollView itemAtIndex:(NSInteger)index;
@end

@interface TOPHorizontalPickerView : UIView
@property (nonatomic, assign) NSInteger seletedIndex;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, assign) CGFloat firstItemX;
@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) id dataSource;

- (void)reloadData;
- (void)scollToSelectdIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
