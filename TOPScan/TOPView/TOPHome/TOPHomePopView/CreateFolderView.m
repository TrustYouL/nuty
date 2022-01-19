//
//  CreateFolderView.m
//  SimpleScan
//
//  Created by admin3 on 2020/6/3.
//  Copyright © 2020 admin3. All rights reserved.
//

#import "CreateFolderView.h"
@interface CreateFolderView ()<UITextFieldDelegate>
@property (nonatomic ,strong)UILabel *titleLabel;
@property (nonatomic, strong)UIButton *cancleBtn;
@property (nonatomic, strong)UIView  *bgView;
@property (nonatomic, strong)UIButton *sureBtn;
@property (nonatomic, strong)UIView *lineView1;
@property (nonatomic, strong)UIView *lineView2;

@end
@implementation CreateFolderView


- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.layer.cornerRadius = Adapt_scaleL(6);
        self.layer.masksToBounds = YES;
        [self setUpUI];
    }
    return self;
}

- (UILabel*)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, Adapt_scaleL(30))];
        _titleLabel.text = @"New Folder";
        _titleLabel.font = [self boldFontsWithSize:16];
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
- (UIView*)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(Adapt_scaleL(10), CGRectGetMaxY(self.titleLabel.frame), self.frame.size.width - Adapt_scaleL(20), Adapt_scaleL(20))];
          _bgView.layer.cornerRadius = 3;
        _bgView.layer.borderWidth = 0.2;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UITextField*)folderField{
    if (!_folderField) {
        _folderField = [[UITextField alloc] initWithFrame:CGRectMake(Adapt_scaleL(10), CGRectGetMaxY(self.titleLabel.frame), self.frame.size.width - Adapt_scaleL(20), Adapt_scaleL(30))];
        _folderField.font = [self fontsWithSize:16];
        _folderField.textColor = UIColor.blackColor;
        _folderField.layer.cornerRadius = 3;
        _folderField.layer.borderWidth = 0.2;
        _folderField.layer.masksToBounds = YES;
        _folderField.delegate = self;
         _folderField.clearButtonMode = UITextFieldViewModeWhileEditing;
      
    }
    return _folderField;;
}
- (UIView*)lineView1{
    if (!_lineView1) {
        _lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - Adapt_scaleL(41),self.frame.size.width,0.5)];
        _lineView1.backgroundColor = UIColor.grayColor;
    }
    return _lineView1;
}
- (UIView*)lineView2{
    if (!_lineView2) {
        _lineView2 = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2,self.frame.size.height - Adapt_scaleL(41),0.5,Adapt_scaleL(41))];
        _lineView2.backgroundColor = UIColor.grayColor;
    }
    return _lineView2;
}
- (UIButton*)cancleBtn{
    if (!_cancleBtn) {
        _cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancleBtn.frame = CGRectMake(0,self.frame.size.height - Adapt_scaleL(40), self.frame.size.width/2, Adapt_scaleL(40));
        [_cancleBtn setTitle:NSLocalizedString(@"simpleScan.cancel", @"") forState:UIControlStateNormal];
        _cancleBtn.tag = 10;
        [_cancleBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
        [_cancleBtn addTarget:self action:@selector(clickFolderAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancleBtn;
}
//- (UIButton*)sureBtn{
//    if (!_sureBtn) {
//        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _sureBtn.frame = CGRectMake(self.frame.size.width/2,self.frame.size.height - Adapt_scaleL(40), self.frame.size.width/2, Adapt_scaleL(40));
//        [_sureBtn setTitle:@"Sure" forState:UIControlStateNormal];
//        [_sureBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
//        _sureBtn.tag = 11;
//        [_sureBtn addTarget:self action:@selector(clickFolderAction:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _sureBtn;
//}

- (UIButton*)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.frame = CGRectMake(0,self.frame.size.height - Adapt_scaleL(40), self.frame.size.width, Adapt_scaleL(40));
        [_sureBtn setTitle:@"Sure" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
        [_sureBtn setBackgroundImage:[AppTools createImageWithColor:UIColor.orangeColor] forState:UIControlStateNormal];
        _sureBtn.tag = 11;
        [_sureBtn addTarget:self action:@selector(clickFolderAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}
- (void)setUpUI{
    self.folderField.text = @"123";
    [self addSubview:self.titleLabel];
  //   [self addSubview:self.bgView];
    [self addSubview:self.folderField];
   
//    [self addSubview:self.lineView1];
//    [self addSubview:self.lineView2];
    //[self addSubview:self.cancleBtn];
    [self addSubview:self.sureBtn];

}

- (void)clickFolderAction:(UIButton*)btn{
    if (self.sureHandler) {
        self.sureHandler(btn.tag - 10);
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSLog(@"hhhhhhhh");
    if (self.fieldtextHandler) {
        self.fieldtextHandler(textField.text);
    }
}
@end
