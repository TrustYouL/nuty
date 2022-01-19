#import "TOPTextView.h"

@implementation TOPTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.clearBtn];
    }
    return self;
}
- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    CGRect originalRect = [super caretRectForPosition:position];
    originalRect.size.height = 23;
    return originalRect;
}

- (void)clickClearBtn {
    [self becomeFirstResponder];
    self.text = @"";
}

- (UIButton *)clearBtn {
    if (!_clearBtn) {
        UIButton *ovalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        ovalBtn.frame = CGRectMake(TOPScreenWidth - 20 - 10, 10, 20, 20);
        [ovalBtn setImage:[UIImage imageNamed:@"top_menu_close"] forState:UIControlStateNormal];
        [ovalBtn addTarget:self action:@selector(clickClearBtn) forControlEvents:UIControlEventTouchUpInside];
        ovalBtn.hidden = YES;
         _clearBtn = ovalBtn;
    }
    return _clearBtn;
}

@end
