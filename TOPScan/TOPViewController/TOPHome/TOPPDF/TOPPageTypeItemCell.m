//
//  TOPPageTypeItemCell.m
//  SimpleScan
//
//  Created by GLA on 2021/1/22.
//  Copyright © 2021 admin3. All rights reserved.
//

#import "TOPPageTypeItemCell.h"
#import "TOPPageNumModel.h"
#import "TOPPageDirectionModel.h"

@implementation TOPPageTypeItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self top_configContentView];
    }
    return self;
}

- (void)top_configContentView {
    [self.contentView addSubview:self.showView];
    [self.contentView addSubview:self.typeLab];
    [self.contentView addSubview:self.numLab];
    [self top_sd_layoutSubViews];
}

- (void)top_sd_layoutSubViews {
    UIView *contentView = self.contentView;
    [self.showView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(51, 54));
    }];
    [self.typeLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(contentView);
        make.top.equalTo(contentView).offset(54);
        make.height.mas_equalTo(28);
    }];
}

- (void)top_configCellWithData:(TOPPageNumModel *)model {
    [self numLabUpdateLayout:model.pageNumLayout];
    self.showView.image = model.isHigh ? [UIImage imageNamed:model.typeHighImage] : [UIImage imageNamed:model.typeImage];
    self.typeLab.text = model.typeTitle;
    self.numLab.textColor = model.isHigh ? kTopicBlueColor : kTabbarNormal;
}

- (void)top_configDirectionCellWithData:(TOPPageDirectionModel *)model {
    self.showView.image = model.isHigh ? [UIImage imageNamed:model.typeHighImage] : [UIImage imageNamed:model.typeImage];
    self.typeLab.text = model.typeTitle;
}

- (void)numLabUpdateLayout:(TOPPDFPageNumLayoutType)layoutType {
    switch (layoutType) {
        case TOPPDFPageNumLayoutTypeNull:
            self.numLab.hidden = YES;
            break;
        case TOPPDFPageNumLayoutTypeTopLeft:
        case TOPPDFPageNumLayoutTypeTopCenter:
        case TOPPDFPageNumLayoutTypeTopRight:
            self.numLab.hidden = NO;
            [self top_mas_resetLayout:1.0];
            break;
        case TOPPDFPageNumLayoutTypeBottomLeft:
        case TOPPDFPageNumLayoutTypeBottomCenter:
        case TOPPDFPageNumLayoutTypeBottomRight:
            self.numLab.hidden = NO;
            [self top_mas_resetLayout:42];
            break;
        default:
            break;
    }
    if (layoutType == TOPPDFPageNumLayoutTypeNull) {
        self.numLab.textAlignment = NSTextAlignmentCenter;
    } else if (layoutType == TOPPDFPageNumLayoutTypeBottomLeft || layoutType == TOPPDFPageNumLayoutTypeTopLeft) {
        self.numLab.textAlignment = NSTextAlignmentNatural;
    } else if (layoutType == TOPPDFPageNumLayoutTypeBottomCenter || layoutType == TOPPDFPageNumLayoutTypeTopCenter) {
        self.numLab.textAlignment = NSTextAlignmentCenter;
    } else if (layoutType == TOPPDFPageNumLayoutTypeBottomRight || layoutType == TOPPDFPageNumLayoutTypeTopRight) {
        self.numLab.textAlignment = NSTextAlignmentRight;
    }
}
- (void)top_mas_resetLayout:(CGFloat)topH{
    [self.numLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(7);
        make.trailing.equalTo(self.contentView).offset(-7);
        make.top.equalTo(self.contentView).offset(topH);
        make.height.mas_equalTo(10);
    }];
}
#pragma mark -- lazy
- (UIImageView *)showView {
    if (!_showView) {
        UIImageView *classImageView = [[UIImageView alloc] init];
        classImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:classImageView];
        _showView = classImageView;
    }
    return _showView;
}

- (UILabel *)typeLab {
    if (!_typeLab) {
        UILabel *noClassLab = [[UILabel alloc] init];
        noClassLab.textColor = RGB(187, 187, 187);
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_R_FONT_(9);
        noClassLab.text = @"";
        noClassLab.numberOfLines = 2;
        noClassLab.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:noClassLab];
        _typeLab = noClassLab;
    }
    return _typeLab;
}

- (UILabel *)numLab {
    if (!_numLab) {
        UILabel *noClassLab = [[UILabel alloc] init];
        noClassLab.textColor = kTabbarNormal;
        noClassLab.textAlignment = NSTextAlignmentCenter;
        noClassLab.font = PingFang_R_FONT_(10);
        noClassLab.text = @"1";
        [self.contentView addSubview:noClassLab];
        _numLab = noClassLab;
    }
    return _numLab;
}

@end
