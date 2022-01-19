#import "TOPMainTabBar.h"
#import "TOPCustomTabBarBtn.h"

@interface TOPMainTabBar ()
@property(nonatomic,strong)UIView *backV;
@property(nonatomic,strong)TOPImageTitleButton *centerBtn;
@property(nonatomic,strong)NSMutableArray *btnArr;
@property(nonatomic,copy)NSArray *titArr;
@property(nonatomic,copy)NSArray *imgArr;
@property(nonatomic,copy)NSArray *sImgArr;
@end

@implementation TOPMainTabBar
@dynamic delegate;


- (instancetype)initWithTitArr:(NSArray *)titArr imgArr:(NSArray *)imgArr sImgArr:(NSArray *)sImgArr
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
        self.btnArr = [NSMutableArray array];
        
        self.titArr = titArr;
        self.imgArr = imgArr;
        self.sImgArr = sImgArr;
        
        [self top_creatSubView];
    }
    return self;
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    self.backV.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
}
-(void)top_creatSubView{
    UIView *backV = [[UIView alloc]initWithFrame:CGRectMake(0, -1, TOPScreenWidth, TOPTabBarHeight)];
    backV.backgroundColor = [UIColor top_viewControllerBackGroundColor:TOPAPPViewMainDarkColor defaultColor:[UIColor whiteColor]];
    backV.layer.shadowColor = [UIColor blackColor].CGColor;
    backV.layer.shadowOffset = CGSizeMake(0, 0);
    backV.layer.shadowOpacity = 0.2;
    backV.clipsToBounds = NO;
    self.backV = backV;
    [self addSubview:backV];
    [backV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.top.equalTo(self).offset(-1);
    }];

    for (NSInteger index = 0; index < self.titArr.count; index ++) {
        TOPImageTitleButton *btn = [TOPImageTitleButton new];
        btn.style = EImageTopTitleBottom;
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitle:self.titArr[index] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [btn setTitleColor:TOPAPPGreenColor forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:self.sImgArr[index]] forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:self.imgArr[index]] forState:UIControlStateNormal];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [btn.titleLabel setFont:PingFang_M_FONT_(10)];
        [btn addTarget:self action:@selector(top_btnAction:) forControlEvents:UIControlEventTouchUpInside];
      
        btn.tag = 2020 +index;
        [self addSubview:btn];
        [self.btnArr addObject:btn];
        if (IS_IPAD) {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(120, 49));
            }];
        }else{
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(60, 49));
            }];
        }
        
        if (index == 0) {
            btn.selected = YES;
        }
        
        if (index == 1) {
            /*
            [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(40, 40));
            }];
             */
            self.centerBtn = btn;
        }else{
            btn.margin = UIEdgeInsetsMake(5, 0, 5, 0);
        }
    }
    [self top_distributeSpacingHorizontallyWith:self.btnArr];//按钮的等间距设置
}
#pragma mark -调整中间凸起按钮的frame
-(void)layoutSubviews{
    [super layoutSubviews];
    self.centerBtn.center = CGPointMake(TOPScreenWidth/2, 49/2);
}
#pragma mark -切换索引
-(void)top_btnAction:(TOPImageTitleButton *)btn{
    for (TOPImageTitleButton *indexBtn in self.btnArr) {
        indexBtn.selected = btn.tag == indexBtn.tag ? YES:NO;
    }

    if ([self.delegate respondsToSelector:@selector(changeIndex:)]) {
        [self.delegate changeIndex:btn.tag - 2020];
    }
    if (self.changeIndex) {
        self.changeIndex(btn.tag - 2020);
    }
}

- (void)top_currentSelect:(NSInteger)selectIndex{
    for (TOPCustomTabBarBtn * btn in self.btnArr) {
        if ([self.btnArr indexOfObject:btn] == selectIndex) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
    }
}

-(void)setTabIndex:(NSInteger)tabIndex{
    _tabIndex = tabIndex;
    [self.btnArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TOPImageTitleButton *btn = obj;
        btn.selected = idx == _tabIndex ? YES:NO;
    }];
}
#pragma mark -重写hitTest方法，去监听发布按钮的点击，目的是为了让凸出的部分点击也有反应
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    //这一个判断是关键，不判断的话push到其他页面，点击发布按钮的位置也是会有反应的，这样就不好了
    //self.isHidden == NO 说明当前页面是有tabbar的，那么肯定是在导航控制器的根控制器页面
    //在导航控制器根控制器页面，那么我们就需要判断手指点击的位置是否在发布按钮身上
    //是的话让发布按钮自己处理点击事件，不是的话让系统去处理点击事件就可以了
    if (self.isHidden == NO) {

        //将当前tabbar的触摸点转换坐标系，转换到发布按钮的身上，生成一个新的点
        CGPoint newP = [self convertPoint:point toView:self.centerBtn];

        //判断如果这个新的点是在发布按钮身上，那么处理点击事件最合适的view就是发布按钮
        if ( [self.centerBtn pointInside:newP withEvent:event]) {
            return self.centerBtn;
        }else{//如果点不在发布按钮身上，直接让系统处理就可以了

            return [super hitTest:point withEvent:event];
        }
    }

    else {//tabbar隐藏了，那么说明已经push到其他的页面了，这个时候还是让系统去判断最合适的view处理就好了
        return [super hitTest:point withEvent:event];
    }
}
#pragma mark -彻底干掉系统UITabBarItem
- (NSArray<UITabBarItem *> *)items {
    return @[];
}
- (void)setItems:(NSArray<UITabBarItem *> *)items {
}
- (void)setItems:(NSArray<UITabBarItem *> *)items animated:(BOOL)animated {
}

@end
