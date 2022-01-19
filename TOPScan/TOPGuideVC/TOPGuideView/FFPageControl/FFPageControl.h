#import <UIKit/UIKit.h>

@interface FFPageControl : UIControl

@property(nonatomic, strong) Class dotViewClass;
@property(nonatomic, strong) UIImage *dotImage;
@property(nonatomic, strong) UIImage *currentDotImage;
@property(nonatomic, strong) UIColor *dotColor;
@property(nonatomic, strong) UIColor *currentDotColor;
@property(nonatomic) CGSize dotSize;
@property(nonatomic) double gapBetweenDots;
@property(nonatomic) NSInteger numberOfPages;
@property(nonatomic) NSInteger currentPage;
@property(nonatomic) BOOL hidesForSinglePage;
- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;
@end
