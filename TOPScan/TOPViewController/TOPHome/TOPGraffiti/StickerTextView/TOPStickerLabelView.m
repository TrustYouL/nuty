#import "TOPStickerLabelView.h"
#import "UIImageView+SSTouch.h"

@interface TOPStickerLabelView()<UIGestureRecognizerDelegate>
@property (strong, nonatomic) UIImageView *editTextCtrl;
@property (strong, nonatomic) UIImageView *transformCtrl;
@property (strong, nonatomic) UIImageView *removeCtrl;
@property (nonatomic) CGPoint lastCtrlPoint;
@property (nonatomic) UIPinchGestureRecognizer *pinchGesture;     //捏合手势
@property (nonatomic) UIRotationGestureRecognizer *rotateGesture; //旋转手势
@property (nonatomic) UIPanGestureRecognizer *panGesture;         //拖动手势
@property (assign, nonatomic) CGFloat totalScale;
@property (nonatomic, strong) UIView *maskView;//遮罩层

@end

@implementation TOPStickerLabelView

#define CTRL_RADIUS 12 //控制图的半径
#define edgeDistance  40//label左右总边距

#define kStickerMinScale 0.2f
#define kStickerMaxScale 10.0f

- (instancetype)init {
    self = [super init];
    if (self) {
        _labText = @"";
        _textColor = [UIColor top_textColor:[UIColor whiteColor] defaultColor:[UIColor blackColor]];
        self.totalScale = 1.0;
        self.totalRotation = 0.0;
        self.fontsize = 18;
        _originalPoint = CGPointMake(0.5, 0.5);//默认参考点为中心点
        [self addGestureRecognizer:self.panGesture];//添加拖动手势
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(top_handleTap:)];
        [tapRecognizer setNumberOfTapsRequired:1];
        [tapRecognizer setDelegate:self];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (instancetype)initWithContentView:(UIView *)contentView {
    self = [super init];
    if (self) {
        self.totalScale = 1.0;
        self.totalRotation = 0.0;
        self.fontsize = 18;
        self.contentView = contentView;
        [self setControllItem];
        _originalPoint = CGPointMake(0.5, 0.5);
        [self addGestureRecognizer:self.panGesture];//添加拖动手势
    }
    return self;
}

- (UILabel *)contentLab:(NSString *)labStr {
    CGSize labSize = [self top_contentLabSize:labStr];
    CGFloat width = labSize.width, height = labSize.height;
    CGFloat superViewHeight = [[NSUserDefaults standardUserDefaults] floatForKey:@"superViewHeight"];
    if (!superViewHeight) {
        superViewHeight = TOPScreenHeight - TOPNavBarAndStatusBarHeight;
    }
    UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake((TOPScreenWidth-width)/2, (superViewHeight - height) / 2, width, height)];
    textView.text = labStr;
    textView.textColor = self.textColor;
    textView.font = [UIFont systemFontOfSize:self.fontsize];
    textView.textAlignment = height > 36 ? NSTextAlignmentNatural : NSTextAlignmentCenter;
    textView.layer.backgroundColor = [UIColor clearColor].CGColor;
    textView.numberOfLines = 0;
    textView.lineBreakMode = NSLineBreakByCharWrapping;
    textView.layer.borderWidth = 1.0;
    textView.layer.cornerRadius = 5;
    textView.layer.borderColor = kTopicBlueColor.CGColor;
    textView.layer.allowsEdgeAntialiasing = YES;
    return textView;
}

#pragma mark - setter  方法
- (void)setContentView:(UIView *)contentView {
    if (_contentView) {
        [_contentView removeFromSuperview];
        _contentView = nil;
        self.transform = CGAffineTransformIdentity;
    }
    _contentView = contentView;
    self.frame = _contentView.frame;
    _contentView.frame = self.bounds;
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:_contentView atIndex:0];
}

- (void)setLabText:(NSString *)labText {
    if (labText) {
        [[NSUserDefaults standardUserDefaults] setObject:labText forKey:TOP_TRGraffitiLabelTextKey];
    }
    if (labText.length) {
        _labText = labText;
        UILabel *lab = [self contentLab:_labText];
        self.contentView = lab;
        [self setControllItem];
    } else {
        if (_contentView) {
            [self removeStickerLabel];
        } else {
            [self top_showInputView];
        }
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (textColor) {
        _textColor = textColor;
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:textColor];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:TOP_TRGraffitiLabelTextColorKey];
        if ([self.contentView isKindOfClass:[UILabel class]]) {
            UILabel *lab = (UILabel *)self.contentView;
            lab.textColor = _textColor;
        }
    }
}

#pragma mark -- 设置按钮
- (void)setControllItem {
    if (![self.gestureRecognizers containsObject:self.pinchGesture]) {
        [self addGestureRecognizer:self.pinchGesture];
    }
    if (![self.gestureRecognizers containsObject:self.rotateGesture]) {
        [self addGestureRecognizer:self.rotateGesture];
    }
    [self setEditTextCtrlImage:[UIImage imageNamed:@"top_signature_edit"]];
    [self setRemoveCtrlImage:[UIImage imageNamed:@"top_signature_delete"]];
    [self setTransformCtrlImage:[UIImage imageNamed:@"top_signature_resize"]];
}

#pragma mark -- 设置按钮图片
- (void)setEditTextCtrlImage:(UIImage *)image {
    self.editTextCtrl.backgroundColor = [UIColor clearColor];
    self.editTextCtrl.image = image;
    
    self.editTextCtrl.layer.shadowColor = RGBA(8, 29, 41, 0.5).CGColor;
    self.editTextCtrl.layer.shadowOffset = CGSizeMake(0,1);
    self.editTextCtrl.layer.shadowOpacity = 1;
    self.editTextCtrl.layer.shadowRadius = 3;
    self.editTextCtrl.clipsToBounds = NO;
}

- (void)setRemoveCtrlImage:(UIImage *)image {
    self.removeCtrl.backgroundColor = [UIColor clearColor];
    self.removeCtrl.image = image;
    
    self.removeCtrl.layer.shadowColor = RGBA(8, 29, 41, 0.5).CGColor;
    self.removeCtrl.layer.shadowOffset = CGSizeMake(0,1);
    self.removeCtrl.layer.shadowOpacity = 1;
    self.removeCtrl.layer.shadowRadius = 3;
    self.removeCtrl.clipsToBounds = NO;
}

- (void)setTransformCtrlImage:(UIImage *)image {
    self.transformCtrl.backgroundColor = [UIColor clearColor];
    self.transformCtrl.image = image;
    
    self.transformCtrl.layer.shadowColor = RGBA(8, 29, 41, 0.5).CGColor;
    self.transformCtrl.layer.shadowOffset = CGSizeMake(0,1);
    self.transformCtrl.layer.shadowOpacity = 1;
    self.transformCtrl.layer.shadowRadius = 3;
    self.transformCtrl.clipsToBounds = NO;
}

- (void)hiddenCtrl {
    self.transformCtrl.hidden = YES;
    self.editTextCtrl.hidden = YES;
    self.removeCtrl.hidden = YES;
    if ([self.contentView isKindOfClass:[UILabel class]]) {
        UILabel *lab = (UILabel *)self.contentView;
        lab.layer.borderWidth = 0.0;
        lab.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (void)showCtrl {
    self.transformCtrl.hidden = NO;
    self.editTextCtrl.hidden = NO;
    self.removeCtrl.hidden = NO;
    if ([self.contentView isKindOfClass:[UILabel class]]) {
        UILabel *lab = (UILabel *)self.contentView;
        lab.layer.borderWidth = 1.0;
        lab.layer.borderColor = kTopicBlueColor.CGColor;
    }
}

#pragma mark - 手势响应事件
- (void)top_handleTap:(UITapGestureRecognizer *)gesture {
    if (gesture.view == self) {
        [self showCtrl];
    }
}
#pragma mark -- 旋转
- (void)rotate:(UIRotationGestureRecognizer *)gesture {
    NSUInteger touchCount = gesture.numberOfTouches;
    if (touchCount <= 1) {
        return;
    }
    self.totalRotation += gesture.rotation;
    self.transform = CGAffineTransformRotate(self.transform, gesture.rotation);
    gesture.rotation = 0;
}

#pragma mark -- 缩放
- (void)pinch:(UIPinchGestureRecognizer *)gesture {
    NSUInteger touchCount = gesture.numberOfTouches;
    if (touchCount <= 1) {
        return;
    }
    CGFloat scale = gesture.scale;
    [self scaleView:scale];
    self.totalScale = self.totalScale *gesture.scale;
    gesture.scale = 1;
}

- (void)scaleView:(CGFloat)scale {
    if (scale * self.totalScale <= kStickerMinScale) {
        scale = 1;
    } else if (scale * self.totalScale >= kStickerMaxScale) {
        scale = 1;
    }
    if ([self.contentView isKindOfClass:[UILabel class]]) {
        UILabel *lab = (UILabel *)self.contentView;
        self.fontsize = scale * self.fontsize;
        lab.font = [UIFont systemFontOfSize:self.fontsize];
        
        CGSize labSize = [self top_contentLabSize:lab.text];
        CGFloat labHeight = self.fontsize * 7/6 + 6;
        CGFloat contentHeight = MAX(labHeight, labSize.height);
        self.bounds = CGRectMake(self.bounds.origin.x,
                                 self.bounds.origin.y,
                                 labSize.width,
                                 contentHeight);
    } else {
        self.bounds = CGRectMake(self.bounds.origin.x,
                                 self.bounds.origin.y,
                                 self.bounds.size.width * scale,
                                 self.bounds.size.height * scale);
    }
}

- (CGSize)top_contentLabSize:(NSString *)labStr {
    CGFloat width = 0, height = 36;
    CGSize size = [TOPAppTools sizeWithFont:self.fontsize textSizeWidht:width textSizeHeight:height text:labStr];
    if (size.width > TOPScreenWidth - edgeDistance || ([labStr rangeOfString:@"\n"].location !=NSNotFound)) {
        CGFloat maxW = [TOPAppTools labMaxWidth:labStr withFontSize:self.fontsize];
        width =  MIN((TOPScreenWidth - edgeDistance), maxW);
        CGSize size2 = [TOPAppTools sizeWithFont:self.fontsize textSizeWidht:width textSizeHeight:0 text:labStr];
        height = size2.height;
        if ([self.contentView isKindOfClass:[UILabel class]]) {
            UILabel *lab = (UILabel *)self.contentView;
            lab.textAlignment = NSTextAlignmentNatural;
        }
    } else {
        width = size.width;
        if ([self.contentView isKindOfClass:[UILabel class]]) {
            UILabel *lab = (UILabel *)self.contentView;
            lab.textAlignment = NSTextAlignmentCenter;
        }
    }
    return CGSizeMake(width+10, height);
}

#pragma mark -- 平移
- (void)pan:(UIPanGestureRecognizer *)gesture {
    CGPoint pt = [gesture translationInView:self.superview];
    self.center = CGPointMake(self.center.x + pt.x , self.center.y + pt.y);
    [gesture setTranslation:CGPointMake(0, 0) inView:self.superview];
}

#pragma mark -- 缩放旋转图标控制
- (void)transformCtrlPan:(UIPanGestureRecognizer *)gesture {

    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.lastCtrlPoint = [self convertPoint:self.transformCtrl.center toView:self.superview];
        return;
    }

    CGPoint ctrlPoint = [gesture locationInView:self.superview];
    if (ctrlPoint.x > 0 && ctrlPoint.y > 0) {
        [self scaleFitWithCtrlPoint:ctrlPoint];
        [self rotateAroundOPointWithCtrlPoint:ctrlPoint];
        self.lastCtrlPoint = ctrlPoint;
    }
    
}

#pragma mark -- 缩放实现
- (void)scaleFitWithCtrlPoint:(CGPoint)ctrlPoint {
    CGPoint oPoint = [self convertPoint:[self getRealOriginalPoint] toView:self.superview];
    self.center = oPoint;

    CGFloat preDistance = [self distanceWithStartPoint:self.center endPoint:self.lastCtrlPoint];
    CGFloat newDistance = [self distanceWithStartPoint:self.center endPoint:ctrlPoint];
    CGFloat scale = newDistance / preDistance;
    [self scaleView:scale];
    if (scale * self.totalScale <= kStickerMinScale) {
        scale = 1;
    } else if (scale * self.totalScale >= kStickerMaxScale) {
        scale = 1;
    }
    self.totalScale = self.totalScale * scale;
}
#pragma mark - 旋转 --- 实现
- (void)rotateAroundOPointWithCtrlPoint:(CGPoint)ctrlPoint {
    CGPoint oPoint = [self convertPoint:[self getRealOriginalPoint] toView:self.superview];
    self.center = CGPointMake(self.center.x - (self.center.x - oPoint.x),
                              self.center.y - (self.center.y - oPoint.y));


    float angle = atan2(self.center.y - ctrlPoint.y, ctrlPoint.x - self.center.x);
    float lastAngle = atan2(self.center.y - self.lastCtrlPoint.y, self.lastCtrlPoint.x - self.center.x);
    angle = - angle + lastAngle;
    self.transform = CGAffineTransformRotate(self.transform, angle);
    self.totalRotation += angle;
}

#pragma mark - 移除StickerView
- (void)removeCtrlTap:(UITapGestureRecognizer *)gesture {
    [self removeStickerLabel];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer.view == self) {
        CGPoint p = [touch locationInView:self];
        if (CGRectContainsPoint(self.editTextCtrl.frame, p)||
            CGRectContainsPoint(self.removeCtrl.frame, p) ||
            CGRectContainsPoint(self.transformCtrl.frame, p)) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 编辑文字
- (void)editTextCtrlPan:(UITapGestureRecognizer *)gesture {
    [self top_showInputView];
}

#pragma mark -- 编辑完成
- (void)didEditedText:(NSString *)text textColor:(UIColor *)color{
    if (color) {
        self.textColor = color;
    }
    if (text && ![self.labText isEqualToString:text]) {
        self.labText = text;
        if (self.totalRotation) {
            self.transform = CGAffineTransformRotate(self.transform, self.totalRotation);
        }
        if (self.totalScale != 1) {
            [self scaleView:self.totalScale];
        }
    }
}

#pragma mark -- 计算两点间距
- (CGFloat)distanceWithStartPoint:(CGPoint)start endPoint:(CGPoint)end {
    CGFloat x = start.x - end.x;
    CGFloat y = start.y - end.y;
    return sqrt(x * x + y * y);
}

#pragma mark -- 计算文本宽度
- (CGSize)sizeWithFont:(CGFloat)fontSize textSizeWidht:(CGFloat)widht textSizeHeight:(CGFloat)height text:(NSString *)text {
    if (widht == MAXFLOAT || widht == CGFLOAT_MAX || widht == 0) {
        CGRect rect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingTruncatesLastVisibleLine|   NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil];
        return CGSizeMake(rect.size.width + 6, height);
    } else if (height == MAXFLOAT || height == CGFLOAT_MAX || height == 0) {
        CGRect rect = [text boundingRectWithSize:CGSizeMake(widht, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|   NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil];
        
        return CGSizeMake(widht, rect.size.height + 6);
    }
    return CGSizeMake(0, 0);
}

#pragma mark -- 输入控件消失
- (void)top_hiddenInputView {
    [UIView animateWithDuration:0.3
                     animations:^{
        self.maskView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 1.5);
    } completion:^(BOOL finished) {
        [self.inputTextView removeFromSuperview];
        self.inputTextView = nil;
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }];
}

- (void)removeStickerLabel {
    if (self.deleteTextLabBlock) {
        self.deleteTextLabBlock();
    }
    [self removeFromSuperview];
}

#pragma mark -- 弹出输入框、键盘
- (void)top_showInputView {
    self.maskView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 1.5);
    [self.maskView addSubview:self.inputTextView];
    self.inputTextView.textFld.text = self.labText;
    self.inputTextView.currentColor = self.textColor;
    [UIView animateWithDuration:0.3
                     animations:^{
        [self.inputTextView top_beginEditing];
        self.maskView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
        [self.inputTextView getTextViewHeightWithText:self.labText];
    } completion:^(BOOL finished) {
        
    }];
}
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    self.inputTextView.currentColor = self.textColor;
}
#pragma mark -- getter
- (CGPoint)getRealOriginalPoint {
    return CGPointMake(self.bounds.size.width * self.originalPoint.x,
                       self.bounds.size.height * self.originalPoint.y);
}

#pragma mark -- 编辑图标
- (UIImageView *)editTextCtrl {
    if (!_editTextCtrl) {
        CGRect frame = CGRectMake(self.bounds.size.width - CTRL_RADIUS,
                                  0 - CTRL_RADIUS,
                                  CTRL_RADIUS * 2,
                                  CTRL_RADIUS * 2);
        _editTextCtrl = [[UIImageView alloc] initWithFrame:frame];
        _editTextCtrl.backgroundColor = [UIColor clearColor];
        _editTextCtrl.userInteractionEnabled = YES;
        _editTextCtrl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_editTextCtrl];

        UITapGestureRecognizer *panGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editTextCtrlPan:)];
        [_editTextCtrl addGestureRecognizer:panGesture];
    }
    return _editTextCtrl;
}

#pragma mark -- 旋转、缩放图标
- (UIImageView *)transformCtrl {
    if (!_transformCtrl) {
        CGRect frame = CGRectMake(self.bounds.size.width - CTRL_RADIUS,
                                  self.bounds.size.height - CTRL_RADIUS,
                                  CTRL_RADIUS * 2,
                                  CTRL_RADIUS * 2);
        _transformCtrl = [[UIImageView alloc] initWithFrame:frame];
        _transformCtrl.backgroundColor = [UIColor clearColor];
        _transformCtrl.userInteractionEnabled = YES;
        _transformCtrl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_transformCtrl];

        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(transformCtrlPan:)];
        [_transformCtrl addGestureRecognizer:panGesture];
    }
    return _transformCtrl;
}

#pragma mark -- 删除图标
- (UIImageView *)removeCtrl {
    if (!_removeCtrl) {
        CGRect frame = CGRectMake(0 - CTRL_RADIUS,
                                  0 - CTRL_RADIUS,
                                  CTRL_RADIUS * 2,
                                  CTRL_RADIUS * 2);
        _removeCtrl = [[UIImageView alloc] initWithFrame:frame];
        _removeCtrl.backgroundColor = [UIColor blackColor];
        _removeCtrl.userInteractionEnabled = YES;
        [self addSubview:_removeCtrl];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeCtrlTap:)];
        [_removeCtrl addGestureRecognizer:tapGesture];
    }
    return _removeCtrl;
}

- (UIPinchGestureRecognizer *)pinchGesture {
    if (!_pinchGesture) {
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        _pinchGesture.delegate = self;
    }
    return _pinchGesture;
}

- (UIRotationGestureRecognizer *)rotateGesture {
    if (!_rotateGesture) {
        _rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
        _rotateGesture.delegate = self;
    }
    return _rotateGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        _panGesture.delegate = self;
        _panGesture.minimumNumberOfTouches = 1;
        _panGesture.maximumNumberOfTouches = 2;
    }
    return _panGesture;
}

//遮罩层
- (UIView *)maskView {
    if (!_maskView) {
        UIView *mask = [[UIView alloc] init];
        mask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:mask];
        [mask mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(window);
        }];
        _maskView = mask;
    }
    return _maskView;
}

- (TOPInputTextView *)inputTextView {
    if (!_inputTextView) {
        __weak typeof(self) weakSelf = self;
        _inputTextView = [[TOPInputTextView alloc] init];
        _inputTextView.top_callTextCompleteBlock = ^(NSString * _Nonnull text, UIColor * _Nonnull textColor) {
            [weakSelf didEditedText:text textColor:textColor];
            [weakSelf top_hiddenInputView];
        };
        _inputTextView.top_clickCancelBlock = ^{
            [weakSelf top_hiddenInputView];
            if (!weakSelf.labText.length) {
                [weakSelf removeStickerLabel];
            }
        };
    }
    return _inputTextView;
}

@end
