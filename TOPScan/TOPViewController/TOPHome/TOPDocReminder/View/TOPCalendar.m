//
//  TOPCalendar.m
//  TOPCalendar
//
//  Created by wqb on 2017/1/12.
//  Copyright © 2017年 hero_wqb. All rights reserved.
//

#import "TOPCalendar.h"
#import "TOPOptionButton.h"
/*
#define KCol 7

#define KMaxCount 37
#define KBtnTag 100
#define KTipsW 85
#define KBtnW ([UIScreen mainScreen].bounds.size.width-14-KTipsW)/7
#define KBtnH ([UIScreen mainScreen].bounds.size.width-14-KTipsW)/7
#define KShowYearsCount 100
 */
#define KMainColor [UIColor colorWithRed:0.0f green:139/255.0f blue:125/255.0f alpha:1.0f]
#define KbackColor [UIColor colorWithRed:173/255.0f green:212/255.0f blue:208/255.0f alpha:1.0f]

@interface TOPCalendar ()<UIPickerViewDelegate, UIPickerViewDataSource, TOPOptionButtonDelegate>

@property (nonatomic, strong) NSArray *weekArray;
@property (nonatomic, strong) NSArray *timeArray;
@property (nonatomic, strong) NSArray *yearArray;
@property (nonatomic, strong) NSArray *monthArray;
@property (nonatomic, strong) NSArray *compareArray;
@property (nonatomic, strong) UIPickerView *timePicker;
@property (nonatomic, weak) UIView *calendarView;
@property (nonatomic, weak) TOPOptionButton *yearBtn;
@property (nonatomic, weak) TOPOptionButton *monthBtn;
@property (nonatomic, weak) UILabel *weekLabel;
@property (nonatomic, weak) UILabel *yearLabel;
@property (nonatomic, weak) UILabel *monthLabel;
@property (nonatomic, weak) UILabel *dayLabel;
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger day;
@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;
@property (nonatomic, assign) NSInteger currentYear;
@property (nonatomic, assign) NSInteger currentMonth;
@property (nonatomic, assign) NSInteger currentDay;
@property (nonatomic, assign) NSInteger KCol;
@property (nonatomic, assign) NSInteger KMaxCount;
@property (nonatomic, assign) NSInteger KBtnTag;
@property (nonatomic, assign) CGFloat KTipsW;
@property (nonatomic, assign) CGFloat KBtnW;
@property (nonatomic, assign) CGFloat KBtnH;
@property (nonatomic, assign) NSInteger KShowYearsCount;

@end

@implementation TOPCalendar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 15;
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:RGBA(235, 235, 235, 1.0)];
        self.KCol = 7;
        self.KMaxCount = 37;
        self.KBtnTag = 100;
        self.KTipsW = 80;
        self.KBtnW = (self.frame.size.width-self.KTipsW)/7;
        self.KBtnH = (self.frame.size.width-self.KTipsW)/7;;
        self.KShowYearsCount = 100;

    }
    
    return self;
}

- (void)top_getDataSource{
    _weekArray = @[@"SUN", @"MON", @"TUE", @"WED", @"THU", @"FRI", @"SAT"];
    _timeArray = @[@[@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23"], @[@"00",@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59"]];
    
    NSInteger firstYear = _year - self.KShowYearsCount / 2;
    NSMutableArray *yearArray = [NSMutableArray array];
    for (int i = 0; i < self.KShowYearsCount; i++) {
        [yearArray addObject:[NSString stringWithFormat:@"%ld", firstYear + i]];
    }
    _yearArray = yearArray;
    _compareArray = @[@{@"Jan":@"1"},
                      @{@"Feb":@"2"},
                      @{@"Mar":@"3"},
                      @{@"Apr":@"4"},
                      @{@"May":@"5"},
                      @{@"Jun":@"6"},
                      @{@"Jul":@"7"},
                      @{@"Aug":@"8"},
                      @{@"Sep":@"9"},
                      @{@"Oct":@"10"},
                      @{@"Nov":@"11"},
                      @{@"Dec":@"12"}];
    NSMutableArray * tempArray = [NSMutableArray new];
    for (NSDictionary * dic in _compareArray) {
        if (dic.allKeys.count>0) {
            NSString * keyStr = dic.allKeys[0];
            [tempArray addObject:keyStr];
        }
    }
    _monthArray = [tempArray copy];
}

- (void)setDefaultInfo{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAppDarkBackgroundColor defaultColor:[UIColor whiteColor]];
    [_timePicker selectRow:_hour inComponent:0 animated:NO];
    [_timePicker selectRow:_minute inComponent:1 animated:NO];
    _currentYear = _year;
    _currentMonth = _month;
    _currentDay = _day;
}

- (void)top_creatControl{
    //左侧显示视图
    UIView *tipsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.KTipsW, self.frame.size.height)];
    tipsView.backgroundColor = TOPAPPGreenColor;
    [self addSubview:tipsView];
    
    //星期标签
    UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.KTipsW, self.KBtnH+15)];
    weekLabel.backgroundColor = TOPAPPGreenColor;
    weekLabel.textColor = [UIColor whiteColor];
    weekLabel.textAlignment = NSTextAlignmentCenter;
    [tipsView addSubview:weekLabel];
    self.weekLabel = weekLabel;
    
    //年份标签
    UILabel *yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(weekLabel.frame) + 20, self.KTipsW, self.KBtnH)];
    yearLabel.textColor = KbackColor;
    yearLabel.textAlignment = NSTextAlignmentCenter;
    yearLabel.font = [UIFont systemFontOfSize:26.0f];
    [tipsView addSubview:yearLabel];
    self.yearLabel = yearLabel;
    
    //月份标签
    UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(yearLabel.frame), self.KTipsW, 30)];
    monthLabel.textColor = [UIColor whiteColor];
    monthLabel.textAlignment = NSTextAlignmentCenter;
    monthLabel.font = [UIFont systemFontOfSize:26.0f];
    [tipsView addSubview:monthLabel];
    self.monthLabel = monthLabel;
    
    //日期标签
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(monthLabel.frame) + 30, self.KTipsW, 120)];
    dayLabel.textColor = [UIColor whiteColor];
    dayLabel.textAlignment = NSTextAlignmentCenter;
    dayLabel.font = [UIFont systemFontOfSize:66];
    [tipsView addSubview:dayLabel];
    self.dayLabel = dayLabel;
    
    CGFloat yearBtnW = 70.0f;
    CGFloat monthbtnW = 60.0f;
    CGFloat todayBtnW = 70.0f;
    CGFloat padding = (self.bounds.size.width - self.KTipsW - yearBtnW - monthbtnW - todayBtnW - self.KBtnW * 2) * 0.25;
    
    //年份按钮
    TOPOptionButton *yearBtn = [[TOPOptionButton alloc] initWithFrame:CGRectMake(self.KTipsW + padding, 0, yearBtnW, self.KBtnH)];
    yearBtn.btnType = @"1";
    yearBtn.array = _yearArray;
    yearBtn.row = self.KShowYearsCount / 2;
    yearBtn.delegate = self;
    [self addSubview:yearBtn];
    self.yearBtn = yearBtn;
    
    //上一月
    UIButton *preBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(yearBtn.frame) + padding, 0, self.KBtnW, self.KBtnH)];
    [preBtn setImage:[UIImage imageNamed:@"top_left"] forState:UIControlStateNormal];
    [preBtn addTarget:self action:@selector(top_preBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:preBtn];
    
    //月份按钮
    TOPOptionButton *monthBtn = [[TOPOptionButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(preBtn.frame), 0, monthbtnW, self.KBtnH)];
    monthBtn.btnType = @"2";
    monthBtn.array = _monthArray;
    monthBtn.row = _month - 1;
    monthBtn.delegate = self;
    [self addSubview:monthBtn];
    self.monthBtn = monthBtn;
    
    //下一月
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(monthBtn.frame), 0, self.KBtnW, self.KBtnH)];
    [nextBtn setImage:[UIImage imageNamed:@"top_right"] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(top_nextBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextBtn];
    
    //返回今天按钮
    UIButton *backTodayBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nextBtn.frame) + padding, 0, todayBtnW, self.KBtnH)];
    backTodayBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [backTodayBtn setTitleColor:[UIColor top_viewControllerBackGroundColor:RGBA(180, 180, 180, 1.0) defaultColor:[UIColor blackColor]] forState:UIControlStateNormal];
    [backTodayBtn setTitle:NSLocalizedString(@"topscan_remindreturn", @"") forState:UIControlStateNormal];
    [backTodayBtn addTarget:self action:@selector(top_backTodayBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backTodayBtn];
    
    //星期标签
    for (int i = 0; i < _weekArray.count; i++) {
        UILabel *week = [[UILabel alloc] initWithFrame:CGRectMake(self.KTipsW + self.KBtnW * i, self.KBtnH, self.KBtnW, self.KBtnH)];
        week.textAlignment = NSTextAlignmentCenter;
        week.font = [UIFont systemFontOfSize:14];
        week.text = _weekArray[i];
        [self addSubview:week];
    }
    
    //日历核心视图
    UIView *calendarView = [[UIView alloc] initWithFrame:CGRectMake(self.KTipsW, self.KBtnH * 2, self.KBtnW * 7, self.KBtnH * 6)];
    [self addSubview:calendarView];
    self.calendarView = calendarView;
    
    for (int i = 0; i < self.KMaxCount; i++) {
        CGFloat btnX = i % self.KCol * self.KBtnW;
        CGFloat btnY = i / self.KCol * self.KBtnH;
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, self.KBtnW, self.KBtnH)];
        btn.tag = i + self.KBtnTag;
        btn.layer.cornerRadius = self.KBtnW * 0.5;
        btn.layer.masksToBounds = YES;
        [btn setTitle:[NSString stringWithFormat:@"%d", i + 1] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor top_viewControllerBackGroundColor:[UIColor whiteColor] defaultColor:RGBA(51, 51, 51, 1.0)] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn setBackgroundImage:[self top_imageWithColor:TOPAPPGreenColor] forState:UIControlStateHighlighted];
        [btn setBackgroundImage:[self top_imageWithColor:TOPAPPGreenColor] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(top_dateBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [calendarView addSubview:btn];
    }
    
    //确认按钮
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(backTodayBtn.frame), self.height-self.KBtnH-15, yearBtnW, self.KBtnH)];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [sureBtn setTitle:NSLocalizedString(@"topscan_ok", @"") forState:UIControlStateNormal];
    [sureBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(top_sureBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sureBtn];
    
    //取消按钮
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(sureBtn.frame) - yearBtnW, self.height-self.KBtnH-15, yearBtnW, self.KBtnH)];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [cancelBtn setTitle:NSLocalizedString(@"topscan_cancel",@"") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:TOPAPPGreenColor forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(top_cancelBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
    //时间选择器
    _timePicker = [[UIPickerView alloc] init];
    _timePicker.backgroundColor = TOPAPPGreenColor;
    _timePicker.hidden = YES;
    _timePicker.delegate = self;
    _timePicker.dataSource = self;
    [self addSubview:_timePicker];
}

//set方法
- (void)setShowTimePicker:(BOOL)showTimePicker{
    _showTimePicker = showTimePicker;
    if (showTimePicker) {
        _timePicker.hidden = NO;
        _dayLabel.frame = CGRectMake(0, CGRectGetMaxY(_monthLabel.frame) + 10, self.KTipsW, 120);
        _timePicker.frame = CGRectMake(5, self.height-100, self.KTipsW - 10, 88);
    }else {
        _timePicker.hidden = YES;
        _dayLabel.frame = CGRectMake(0, CGRectGetMaxY(_monthLabel.frame) + 30, 200, 120);
    }
}

//上一月按钮点击事件
- (void)top_preBtnOnClick{
    if (_month == 1) {
        if (_yearBtn.row == 0) return;
        _year --;
        _month = 12;
        _yearBtn.row --;
    }else {
        _month --;
    }
    
    _monthBtn.row = _month - 1;
    [self top_reloadData];
}

//下一月按钮点击事件
- (void)top_nextBtnOnClick{
    if (_month == 12) {
        if (_yearBtn.row == self.KShowYearsCount - 1) return;
        _year ++;
        _month = 1;
        _yearBtn.row ++;
    }else {
        _month ++;
    }
    
    _monthBtn.row = _month - 1;
    [self top_reloadData];
}

//返回今天
- (void)top_backTodayBtnOnClick{
    _year = _currentYear;
    _month = _currentMonth;
    _monthBtn.row = _month - 1;
    _yearBtn.row = self.KShowYearsCount / 2;
    
    [self top_reloadData];
}

//刷新数据
- (void)top_reloadData{
    NSInteger totalDays = [self numberOfDaysInMonth];
    NSInteger firstDay = [self firstDayOfWeekInMonth];
    
    for (int i = 0; i<_compareArray.count; i++) {
        NSDictionary * dic = _compareArray[i];
        NSString * dicKey = dic.allKeys[0];
        if ([dic[dicKey] intValue] == _month) {
            _monthBtn.title = dicKey;
        }
    }
    _yearLabel.text = [NSString stringWithFormat:@"%ld", _year];
    _yearBtn.title = [NSString stringWithFormat:@"%ld", _year];
    _monthLabel.text = _monthBtn.title;
    for (int i = 0; i < self.KMaxCount; i++) {
        UIButton *btn = (UIButton *)[self.calendarView viewWithTag:i + self.KBtnTag];
        btn.selected = NO;
        
        if (i < firstDay - 1 || i > totalDays + firstDay - 2) {
            btn.enabled = NO;
            [btn setTitle:@"" forState:UIControlStateNormal];
        }else {
            if (_year == _currentYear && _month == _currentMonth) {
                if (btn.tag - self.KBtnTag - (firstDay - 2) == _currentDay) {
                    btn.selected = YES;
                    _day = _currentDay;
                    _weekLabel.text = [NSString stringWithFormat:@"%@", _weekArray[(btn.tag - self.KBtnTag) % 7]];
                    _dayLabel.text = [NSString stringWithFormat:@"%ld", _day];
                }
            }else {
                if (i == firstDay - 1) {
                    btn.selected = YES;
                    _day = btn.tag - self.KBtnTag - (firstDay - 2);
                    _weekLabel.text = [NSString stringWithFormat:@"%@", _weekArray[(btn.tag - self.KBtnTag) % 7]];
                    _dayLabel.text = [NSString stringWithFormat:@"%ld", _day];
                }
            }
            btn.enabled = YES;
            [btn setTitle:[NSString stringWithFormat:@"%ld", i - (firstDay - 1) + 1] forState:UIControlStateNormal];
        }
    }
}

//获取当前时间
- (void)getCurrentDate{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate date]];
    _year = [components year];
    _month = [components month];
    _day = [components day];
    _hour = [components hour];
    _minute = [components minute];
}

- (void)setCurrentDate:(NSDate *)currentDate{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:currentDate];
    _year = [components year];
    _month = [components month];
    _day = [components day];
    _hour = [components hour];
    _minute = [components minute];
//    [self setDefaultInfo];
    //获取数据源
    [self top_getDataSource];
    
    //创建控件
    [self top_creatControl];
    
    //初始化设置
    [self setDefaultInfo];
    
    //刷新数据
    [self top_reloadData];
}
//根据选中日期，获取相应NSDate
- (NSDate *)top_getSelectDate{
    //初始化NSDateComponents，设置为选中日期
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = _year;
    dateComponents.month = _month;
    
    return [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] dateFromComponents:dateComponents];
}

//获取目标月份的天数
- (NSInteger)numberOfDaysInMonth{
    //获取选中日期月份的天数
    return [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[self top_getSelectDate]].length;
}

//获取目标月份第一天星期几
- (NSInteger)firstDayOfWeekInMonth{
    //获取选中日期月份第一天星期几，因为默认日历顺序为“日一二三四五六”，所以这里返回的1对应星期日，2对应星期一，依次类推
    return [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfYear forDate:[self top_getSelectDate]];
}

//根据颜色返回图片
- (UIImage *)top_imageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//选中日期时调用
- (void)top_dateBtnOnClick:(UIButton *)btn{
    _day = btn.tag - self.KBtnTag - ([self firstDayOfWeekInMonth] - 2);
    _weekLabel.text = [NSString stringWithFormat:@"%@", _weekArray[(btn.tag - self.KBtnTag) % 7]];
    _dayLabel.text = [NSString stringWithFormat:@"%ld", _day];
    
    if (btn.selected) return;
    
    for (int i = 0; i < self.KMaxCount; i++) {
        UIButton *button = [self.calendarView viewWithTag:i + self.KBtnTag];
        button.selected = NO;
    }
    
    btn.selected = YES;
}

#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return _timeArray.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSArray * tempArray = _timeArray[component];
    return [tempArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return _timeArray[component][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSString *time = _timeArray[component][row];
    if (component == 0) {
        _hour = [time integerValue];
    } else if (component == 1) {
        _minute = [time integerValue];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return (self.KTipsW -10-20)/2;
}
/*
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 20;
}
 */
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *pickerLabel = (UILabel *)view;
    if (!pickerLabel) {
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.textColor = [UIColor whiteColor];
        pickerView.backgroundColor = [UIColor clearColor];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.font = [UIFont systemFontOfSize:20.0f];
    }
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    if (pickerView.subviews.count>2) {
        [[pickerView.subviews objectAtIndex:1] setHidden:YES];
        [[pickerView.subviews objectAtIndex:2] setHidden:YES];
    }
    return pickerLabel;
}

#pragma mark - TOPOptionButtonDelegate
- (void)didSelectOptionInHWOptionButton:(TOPOptionButton *)optionButton withBtnType:(NSString *)btnType{
    if ([btnType isEqualToString:@"1"]) {
        _year = [optionButton.title integerValue];
        _yearBtn.title = [NSString stringWithFormat:@"%ld", _year];
    }else{
        _monthBtn.title = optionButton.title;
        for (NSDictionary * dic in _compareArray) {
            if (dic.allKeys.count>0) {
                NSString * keyStr = dic.allKeys[0];
                if ([optionButton.title isEqualToString:keyStr]) {
                    _month = [dic[keyStr] integerValue];
                }
            }
        }
    }
   
    [self top_reloadData];
}

//确认按钮点击事件
- (void)top_sureBtnOnClick{
    [self dismiss];
    
    NSString *date;
    if (_showTimePicker) {
        date = [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld", _year, _month, _day, _hour, _minute];
    }else {
        date = [NSString stringWithFormat:@"%ld-%02ld-%02ld", _year, _month, _day];
    }
//    NSString * showString = [NSString stringWithFormat:@"%@/%02ld/%ld  %02ld:%02ld", _monthBtn.title, _day, _year, _hour, _minute];
    if (_delegate && [_delegate respondsToSelector:@selector(top_calendar:didClickSureButtonWithDate:)]) {
        [_delegate top_calendar:self didClickSureButtonWithDate:date];
    }
}

//取消按钮点击事件
- (void)top_cancelBtnOnClick{
    [self dismiss];
}

//弹出视图
- (void)dismiss{
    if ([self.delegate respondsToSelector:@selector(top_clickToDismiss)]) {
        [self.delegate top_clickToDismiss];
    }
}

@end
