//
//  TOPFunctionHeaderView.m
//  SimpleScan
//
//  Created by admin3 on 2022/1/14.
//  Copyright © 2022 admin3. All rights reserved.
//

#import "TOPFunctionHeaderView.h"

@implementation TOPFunctionHeaderView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont boldSystemFontOfSize:15];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)];
        [self addSubview:_titleLab];
        [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(15);
            make.bottom.equalTo(self).offset(-10);
            make.size.mas_equalTo(CGSizeMake(250, 20));
        }];
    }
    return self;
}
@end
