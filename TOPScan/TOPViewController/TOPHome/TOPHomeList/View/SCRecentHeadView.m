//
//  SCRecentHeadView.m
//  SimpleScan
//
//  Created by admin3 on 2021/9/1.
//  Copyright © 2021 admin3. All rights reserved.
//

#import "SCRecentHeadView.h"

@implementation SCRecentHeadView
- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.layer.cornerRadius = 10;
        [self top_setupUI];
    }
    return self;
}
- (void)top_setupUI{
    UIView * bgView = [UIView new];
    bgView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.bgView = bgView;
    
    UILabel * headLab = [UILabel new];
    headLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
    headLab.textAlignment = NSTextAlignmentNatural;
    headLab.font = [UIFont boldSystemFontOfSize:17];
    headLab.text = @"Recent Docs";
    self.headLab = headLab;
    
    UIButton * selectBtn = [UIButton new];
    [selectBtn setImage:[UIImage imageNamed:@"top_recentList_select"] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(clickSelectBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:bgView];
    [self addSubview:headLab];
    [self addSubview:selectBtn];
    
    [bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.top.equalTo(self).offset(10);
    }];
    [headLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(15);
        make.size.mas_equalTo(CGSizeMake(200, 20));
    }];
    [selectBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-15);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.bgView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.headLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
}
- (void)clickSelectBtn{
    if (self.selectAllItem) {
        self.selectAllItem();
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
