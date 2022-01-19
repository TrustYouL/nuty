#import <UIKit/UIKit.h>

@class TOPOptionButton;

@protocol TOPOptionButtonDelegate <NSObject>

- (void)didSelectOptionInHWOptionButton:(TOPOptionButton *)optionButton withBtnType:(NSString *)btnType;

@end

@interface TOPOptionButton : UIView
@property (nonatomic, copy) NSString * btnType;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) BOOL showSearchBar; //default is NO.
@property (nonatomic, weak) id<TOPOptionButtonDelegate> delegate;

@end

