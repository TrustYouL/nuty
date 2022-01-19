//
//  SCMainPreviewView.h
//  SimpleScan
//
//  Created by admin3 on 2021/9/1.
//  Copyright © 2021 admin3. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCMainPreviewView : UIView
@property (nonatomic ,copy)void(^previewFunctionType)(NSInteger tag);
@property (nonatomic,strong)DocumentModel * lastModel;
/**
 size = CGSizeMake(50, 20)是广告显示出来时的情况
 size = CGSizeMake(75, 50)是广告不显示出来时的情况
 size.with是self.centerView到self的顶部距离  即mas_top为size.with
 size.hight是self.emailBtn底部到self的底部距离
 */
- (void)top_setupUI:(CGSize)size;
- (void)setCenterViewSubViews;
@end

NS_ASSUME_NONNULL_END
