//
//  TOPShowImgMoreCell.m
//  SimpleScan
//
//  Created by admin3 on 2022/1/13.
//  Copyright © 2022 admin3. All rights reserved.
//

#import "TOPShowImgMoreCell.h"

@implementation TOPShowImgMoreCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _iconImg = [UIImageView new];
        
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:17];
        _titleLab.textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(34, 34, 34, 1.0)];
        _titleLab.textAlignment = NSTextAlignmentNatural;
        
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineMostDarkColor defaultColor:RGBA(235, 235, 235, 1.0)];
      
        [self.contentView addSubview:_iconImg];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:_lineView];
        [self top_creatUI];
    }
    return self;
}

- (void)top_creatUI{
    UIView * contentView = self.contentView;

    [_iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(30);
        make.centerY.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_iconImg.mas_trailing).offset(25);
        make.centerY.equalTo(contentView);
    }];
    
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(30);
        make.trailing.equalTo(contentView).offset(-20);
        make.bottom.equalTo(contentView);
        make.height.mas_equalTo(1.0);
    }];
    
    [self.vipLogoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.titleLab.mas_trailing).offset(10);
        make.centerY.equalTo(contentView);
        make.height.width.mas_equalTo(16);
        make.trailing.lessThanOrEqualTo(contentView).offset(-20);
    }];
}
- (void)setMoreDic:(NSDictionary *)moreDic{
    _moreDic = moreDic;
    _iconImg.image = [UIImage imageNamed:moreDic[@"icon"]];
    _titleLab.text = moreDic[@"title"];
    self.vipLogoView.hidden = ![moreDic[@"showVip"] integerValue];
}
#pragma mark -- lazy
- (UIImageView *)vipLogoView {
    if (!_vipLogoView) {
        UIImage *noClassImg = [UIImage imageNamed:@"top_vip_logo"];
        UIImageView *noClass = [[UIImageView alloc] initWithImage:noClassImg];
        [self.contentView addSubview:noClass];
        noClass.hidden = YES;
        _vipLogoView = noClass;
    }
    return _vipLogoView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
