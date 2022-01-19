//
//  SCRecentHeadView.h
//  SimpleScan
//
//  Created by admin3 on 2021/9/1.
//  Copyright © 2021 admin3. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCRecentHeadView : UIView
@property (nonatomic ,strong)UIView * bgView;
@property (nonatomic ,strong)UILabel * headLab;

@property (nonatomic ,copy)void(^selectAllItem)(void);
@end

NS_ASSUME_NONNULL_END
