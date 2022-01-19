#define THScreenW [UIScreen mainScreen].bounds.size.width
#define THScreenH [UIScreen mainScreen].bounds.size.height
#define THWParam [UIScreen mainScreen].bounds.size.width/375.0f
#define THfloat(a) a
#define WhiteView_W 250
#define WhiteView_H 300
#import "TOPScrollChooseView.h"

@interface TOPScrollChooseView()<UIPickerViewDataSource, UIPickerViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) UIView * fatherView;//textField下面的父试图
@property (strong, nonatomic) UILabel * fieldFather;//textField下面的lab
@property (strong, nonatomic) UIView * clearView;
@property (strong, nonatomic) UIPickerView *pickerView;

@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *confirmButton;
@property (assign, nonatomic) NSInteger selectedValue;
@property (strong, nonatomic) NSArray *questionArray;
@property (assign, nonatomic) NSInteger defaultDesc;
@property (strong, nonatomic) UITextField * textField;
@property (assign, nonatomic) BOOL isFirst;//每次弹出textField时 第一次输入内容覆盖掉原有的数字 然后输入的内容才是拼接的
@end

@implementation TOPScrollChooseView


- (instancetype)initWithQuestionArray:(NSArray *)questionArray withDefaultDesc:(NSInteger )defaultDesc {
    
    if (self = [super init]) {
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
        
        UIView * homeBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOPScreenWidth, TOPScreenHeight)];
        homeBackView.backgroundColor = [UIColor clearColor];
        [self addSubview:homeBackView];
        [homeBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.top.equalTo(self);
        }];
        
        UITapGestureRecognizer * homeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_homeTapAction:)];
        [homeBackView addGestureRecognizer:homeTap];
        
        //白色的背景图
        UIView *whiteView = [[UIView alloc]initWithFrame:CGRectMake((TOPScreenWidth-WhiteView_W)/2, (TOPScreenHeight-WhiteView_H)/2, WhiteView_W, WhiteView_H)];
        whiteView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor];
        whiteView.layer.masksToBounds = YES;
        whiteView.layer.cornerRadius = 8;
        self.whiteView = whiteView;
        [self addSubview:whiteView];
        [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.mas_equalTo(WhiteView_W);
            make.height.mas_equalTo(WhiteView_H);
        }];
        
        //pickerView后面的视图 点击时添加pickerView
        UIView * pickBackView = [[UIView alloc]initWithFrame:CGRectMake(0, THfloat(45), WhiteView_W, WhiteView_H-THfloat(45))];
        UITapGestureRecognizer * pickBackTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_pickBackTapAction:)];
        [pickBackView addGestureRecognizer:pickBackTap];
    
        //中间位置的点击视图
        UIView * clearView = [[UIView alloc]initWithFrame:CGRectMake(10, (WhiteView_H-THfloat(45)-THfloat(35))/2+THfloat(45), WhiteView_W-20, THfloat(35))];
        clearView.backgroundColor = [UIColor clearColor];
        clearView.userInteractionEnabled = YES;
        
        //按钮所在区域
        UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(0,0,WhiteView_W,THfloat(45))];
        [viewBg setBackgroundColor:[UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:TOPAppBackgroundColor]];
        [whiteView addSubview:viewBg];
        [viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(whiteView);
            make.height.mas_equalTo(45);
        }];
        
        //创建取消 确定按钮
        UIButton *cannel = [UIButton buttonWithType:UIButtonTypeCustom];
        cannel.frame = CGRectMake(THfloat(20), 0, THfloat(50), THfloat(44));
        [cannel setTitle:NSLocalizedString(@"topscan_cancel", @"") forState:0];
        cannel.titleLabel.font = [UIFont systemFontOfSize:THfloat(16)];
        [cannel setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        cannel.tag = 1;
        [cannel addTarget:self action:@selector(top_cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewBg addSubview:cannel];
        [cannel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(viewBg).offset(20);
            make.top.equalTo(viewBg);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(44);
        }];
        
        UIButton *confirm = [UIButton buttonWithType:UIButtonTypeCustom];
        confirm.frame = CGRectMake(WhiteView_W - THfloat(70), 0, THfloat(50), THfloat(44));
        [confirm setTitle:NSLocalizedString(@"topscan_ok", @"") forState:0];
        confirm.titleLabel.font = [UIFont systemFontOfSize:THfloat(16)];
        [confirm setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
        confirm.tag = 2;
        [confirm addTarget:self action:@selector(top_confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewBg addSubview:confirm];
        [confirm mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(viewBg).offset(-20);
            make.top.equalTo(viewBg);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(44);
        }];

        self.questionArray = questionArray;
        self.defaultDesc = defaultDesc;
        [whiteView addSubview:pickBackView];
        [whiteView addSubview:self.pickerView];
        [whiteView addSubview:clearView];
        [pickBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(whiteView);
            make.top.equalTo(whiteView).offset(45);
        }];
        
        [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(whiteView);
            make.top.equalTo(whiteView).offset(45);
        }];
        [clearView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(whiteView).offset(10);
            make.trailing.equalTo(whiteView).offset(-10);
            make.top.equalTo(whiteView).offset((WhiteView_H-THfloat(45)-THfloat(35))/2+THfloat(45));
            make.height.mas_equalTo(35);
        }];
        
        UITapGestureRecognizer * clearTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_clearTapAction:)];
        [clearView addGestureRecognizer:clearTap];
        //改变pickerView分割线的颜色
        [self changeSpearatorLineColor];
    }
    
    return self;
}

- (UIView *)fatherView{
    if (!_fatherView) {
        _fatherView = [[UILabel alloc]initWithFrame:CGRectMake(8, (WhiteView_H-THfloat(45)-THfloat(38))/2+THfloat(45), WhiteView_W-16, THfloat(38))];
        _fatherView.backgroundColor= [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:RGBA(225, 225, 225, 1.0)];
        _fatherView.layer.cornerRadius = 10;
        _fatherView.layer.masksToBounds = YES;
        _fatherView.layer.borderColor = [UIColor clearColor].CGColor;
        _fatherView.userInteractionEnabled = YES;
        [_fatherView addSubview:self.fieldFather];
        [_fatherView addSubview:self.textField];
        [self.fieldFather mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_fatherView).offset(7);
            make.trailing.equalTo(_fatherView).offset(-7);
            make.top.equalTo(_fatherView);
            make.height.mas_equalTo(38);
        }];
        
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_fatherView).offset(7);
            make.trailing.equalTo(_fatherView).offset(-7);
            make.top.equalTo(_fatherView);
            make.height.mas_equalTo(38);
        }];
    }
    return _fatherView;
}

- (UILabel *)fieldFather{
    if (!_fieldFather) {
        _fieldFather = [[UILabel alloc]initWithFrame:CGRectMake(7,0, WhiteView_W-16-7, THfloat(38))];
        _fieldFather.backgroundColor= [UIColor clearColor];
        _fieldFather.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 0.8)];
        _fieldFather.font = [UIFont systemFontOfSize:23];
        _fieldFather.textAlignment = NSTextAlignmentCenter;
    }
    return _fieldFather;
}

- (UITextField *)textField{
    if (!_textField) {
        _textField = [[UITextField alloc]initWithFrame:CGRectMake(7,0, WhiteView_W-16-7, THfloat(38))];
        _textField.delegate=self;
        _textField.returnKeyType=UIReturnKeyDone;
        _textField.keyboardType=UIKeyboardTypeNumberPad;
        _textField.backgroundColor= [UIColor clearColor];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.tintColor = [UIColor clearColor];
        _textField.inputAccessoryView = [UIView new];
        _textField.layer.cornerRadius = 10;
        _textField.layer.masksToBounds = YES;
        _textField.layer.borderColor = [UIColor clearColor].CGColor;
        _textField.textColor = [UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 0.8)];
        _textField.font=[UIFont systemFontOfSize:23];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(top_tapAction:)];
        [_textField addGestureRecognizer:tap];
    }
    return _textField;
}
#pragma mark - action

- (void)top_cancelButtonAction:(UIButton *)button {
    [self top_dismissView];
}

- (void)top_confirmButtonAction:(UIButton *)button {
    [self top_dismissView];
    if ([self.textField.text integerValue] != 0){
        self.defaultDesc = [self.textField.text integerValue]-1;
        self.selectedValue = self.defaultDesc;
    }
    self.confirmBlock(self.selectedValue);
}

- (void)top_showView{
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)top_dismissView{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        [self.textField resignFirstResponder];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
}

- (void)top_homeTapAction:(UITapGestureRecognizer *)tap{
    [self top_dismissView];
    if ([self.textField.text integerValue] != 0){
        self.defaultDesc = [self.textField.text integerValue]-1;
        self.selectedValue = self.defaultDesc;
    }
    self.confirmBlock(self.selectedValue);
}

- (void)top_pickBackTapAction:(UITapGestureRecognizer *)tap{
    [self top_showPickerView];
}

- (void)top_tapAction:(UITapGestureRecognizer *)tap{
    [self top_showPickerView];
}

- (void)top_showPickerView{
    if ([self.textField.text integerValue] != 0){
        self.defaultDesc = [self.textField.text integerValue]-1;
        self.selectedValue = self.defaultDesc;
    }
   
    [self.textField resignFirstResponder];
    [self.fatherView removeFromSuperview];
    self.fatherView = nil;
    
    self.pickerView.hidden = NO;
    [self.pickerView selectRow:self.defaultDesc inComponent:0 animated:YES];
}

- (void)top_clearTapAction:(UITapGestureRecognizer *)tap{
    if (self.unableEdit) {
        return;
    }
    self.isFirst = YES;
    self.pickerView.hidden = YES;
    [self.whiteView addSubview:self.fatherView];
    [self.fatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.whiteView).offset(8);
        make.trailing.equalTo(self.whiteView).offset(-8);
        make.top.equalTo(self.whiteView).offset((WhiteView_H-THfloat(45)-THfloat(38))/2+THfloat(45));
        make.height.mas_equalTo(38);
    }];
    self.textField.text = @"";
    [self.textField becomeFirstResponder];
    self.fieldFather.text = [NSString stringWithFormat:@"%ld",self.selectedValue+1];
}
#pragma mark - pickerView 代理方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.questionArray.count;
}
-(CGFloat)pickerView:(UIPickerView*)pickerView rowHeightForComponent:(NSInteger)component {
    return THfloat(35);
}
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (row < self.questionArray.count) {
        id obj = self.questionArray[row];
        if ([obj isKindOfClass:[NSNumber class]]) {
            return [NSString stringWithFormat:@"%@",obj];
        }
    }
    return  [NSString stringWithFormat:@"%ld",(long)(row+1)];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedValue = row;
}
- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, THfloat(45), WhiteView_W, WhiteView_H-THfloat(45))];
        _pickerView.backgroundColor = [UIColor clearColor];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        
        [_pickerView selectRow:self.defaultDesc inComponent:0 animated:YES];
        [_pickerView setValue:[UIColor top_textColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forKey:@"textColor"];
        self.selectedValue = self.defaultDesc;
    }
    return _pickerView;
}
- (void)changeSpearatorLineColor{
    for (UIView * lineView in self.pickerView.subviews) {
        if (lineView.frame.size.height<1) {
            lineView.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPLineDarkColor defaultColor:TOPAppBackgroundColor];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.isFirst) {
        if ([string integerValue]>self.questionArray.count) {
            return NO;
        }else{
            self.isFirst = NO;
            self.fieldFather.text = @"";
            return YES;
        }
    }else{
        if ([string integerValue]>self.questionArray.count) {
            return NO;
        }else{
            NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
            if ([text integerValue]>self.questionArray.count) {
                return NO;
            }
        }
    }

    return YES;
}

@end
