//
//  StickerView.h
//  StickerDemo
//
//  Created by CKJ on 16/1/26.
//  Copyright © 2016年 CKJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StickerViewDelegate;

@interface StickerView : UIView

@property (assign, nonatomic) BOOL enabledControl; // determine the control view is shown or not, default is YES
@property (assign, nonatomic) BOOL enabledDeleteControl; // default is YES
@property (assign, nonatomic) BOOL enabledShakeAnimation; // default is YES
@property (assign, nonatomic) BOOL enabledBorder; // default is YES
@property (assign, nonatomic) BOOL enabledMove; // default is YES
@property (assign, nonatomic) BOOL enabledInteraction; // default is YES

@property (strong, nonatomic) UIImage *contentImage;
@property (assign, nonatomic) id<StickerViewDelegate> delegate;

- (instancetype)initWithContentFrame:(CGRect)frame contentImage:(UIImage *)contentImage;
/// 旋转图片
/// @param rotation  旋转角度
- (void)rotateContentView:(CGFloat)rotation;

- (void)performTapOperation;

- (void)showCtrl;
- (void)hiddenCtrl;

@end

@protocol StickerViewDelegate <NSObject>

@optional

- (void)top_stickerViewDidTapContentView:(StickerView *)stickerView;

- (void)top_stickerViewDidTapDeleteControl:(StickerView *)stickerView;

- (UIImage *)stickerView:(StickerView *)stickerView imageForRightTopControl:(CGSize)recommendedSize;

- (void)top_stickerViewDidTapRightTopControl:(StickerView *)stickerView; // Effective when resource is provided.

- (UIImage *)stickerView:(StickerView *)stickerView imageForLeftBottomControl:(CGSize)recommendedSize;

- (void)stickerViewDidTapLeftBottomControl:(StickerView *)stickerView; // Effective when resource is provided.

- (void)top_stickerViewBeMoving:(StickerView *)stickerView withPoint:(CGPoint)point;//移动中
- (void)stickerViewDidMoveEnd:(StickerView *)stickerView;//移动结束

@end
