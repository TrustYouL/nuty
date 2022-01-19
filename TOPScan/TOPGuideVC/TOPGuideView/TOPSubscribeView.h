#import <UIKit/UIKit.h>
#import "GKCycleScrollView.h"
#import "FFPageControl.h"
#import "TOPPurchasepayModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TOPSubscribeView : UIView<GKCycleScrollViewDataSource,GKCycleScrollViewDelegate,UITextViewDelegate>
@property (nonatomic ,strong)TOPPurchasepayModel * purModel;
@property (nonatomic ,strong)NSMutableArray * dataArray;
@property (nonatomic ,copy)NSString * freeString;
@property (nonatomic ,copy)NSString * confirmString;
@property (nonatomic ,assign)CGSize currentSize;
@property (nonatomic ,copy)void(^top_subscribeEvent)(TOPSubscribeEvent eventTag);
@property (nonatomic ,copy)void(^top_subscribePrivacyURL)(NSString * urlString);
@end

NS_ASSUME_NONNULL_END
