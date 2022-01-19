//
//  TOPGirdDocDetailTypeThirdCell.h
//  SimpleScan
//
//  Created by admin3 on 2021/11/23.
//  Copyright © 2021 admin3. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPGirdDocDetailTypeThirdCell : UICollectionViewCell
@property (nonatomic, strong)DocumentModel *model;
@property (nonatomic, strong)UIButton       *choseBtn;
@property (nonatomic, strong)UIImageView    *imgV;
@property (nonatomic, strong)UIButton       *showBackBtn;
@property (nonatomic, strong)UITextView     *textView;
@property (nonatomic, strong)UITextView     *ocrTV;
@property (nonatomic, strong)UIButton       *noteBtn;
@property (nonatomic, strong)UIButton       *ocrBtn;
@property (nonatomic, strong)UILabel        *titleLabel;
@property (nonatomic, strong)UILabel        *dateLabel;
@property (nonatomic, strong)UILabel        *numLabel;
@property (nonatomic, strong)UIView         *coverView;
@property (nonatomic, strong)UIImageView    *selectStateImg;
@property (nonatomic, copy) void(^top_ChoseBtnBlock)(BOOL isSelect);
@property (nonatomic, copy) void(^top_clickToJump)(void);
@property (nonatomic, copy) void(^top_clickOCRToJump)(void);
@property (nonatomic, copy) NSString * markCellId;

- (UIImageView *)currentImageView;
- (void)setModel:(DocumentModel * _Nonnull)model  index:(NSString*)index;
- (void)top_showSelectBtn;
@end

NS_ASSUME_NONNULL_END
