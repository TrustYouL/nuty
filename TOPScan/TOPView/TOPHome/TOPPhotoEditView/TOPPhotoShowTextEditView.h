#import <UIKit/UIKit.h>
#import "TOPTextView.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPPhotoShowTextEditView : UIView
@property (nonatomic ,strong)DocumentModel * model;
@property (nonatomic ,strong)TOPTextView * textView;
@property (nonatomic ,strong)UIButton * topRightBtn;
@property (nonatomic ,strong)TOPImageTitleButton * languBtn;
@property (nonatomic ,strong)TOPImageTitleButton * endPointBtn;
@property (nonatomic ,copy)NSString * languBtnTitle;
@property (nonatomic ,copy)NSString * endpointString;
@property (nonatomic ,copy)void(^top_clickRightBtnChangeFream)(BOOL isSelect,BOOL isFirstResponder);
@property (nonatomic ,copy)void(^top_sendBackText)(NSString * text);
@property (nonatomic ,copy)void(^top_clickShowLanguageView)(void);
@property (nonatomic ,copy)void(^top_clickShowEndPointView)(NSString * endpointString);
@property (nonatomic ,copy)NSString * netWorkState; 
@end 

NS_ASSUME_NONNULL_END
