#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPAddFolderView : UIView
@property (nonatomic,strong)UITextField * tField; 
@property (nonatomic,copy)NSString * picName;
@property (nonatomic,copy)NSString * tagsName;
@property (nonatomic,copy)NSString * placeholder;
@property (nonatomic,copy)void (^top_clickToHide)(void);
@property (nonatomic,copy)void (^top_clickToSendString)(NSString * editString);
@end

NS_ASSUME_NONNULL_END
