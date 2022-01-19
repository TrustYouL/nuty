#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol TOPImageBrowsingViewDelegate <NSObject>
@optional
- (void)top_imageBrowsingShowDidScrollZoom;
@end
@interface TOPImageBrowsingView : UIScrollView
@property (assign, nonatomic) id<TOPImageBrowsingViewDelegate> browsingDelegate;
@property (assign, nonatomic) BOOL highDefinition;
@property (nonatomic, strong) UIImage *mainImage;

- (void)top_resetHighImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
