#import "TOPMenuButton.h"

@interface TOPMenuButton ()

@property (nonatomic, copy) MenuAction action;

@end

@implementation TOPMenuButton

- (instancetype)initWithMenu:(TOPMenuItem *)item
{
    return [self initWithTitle:item.title icon:item.icon action:item.action];
}

- (instancetype)initWithTitle:(NSString *)title action:(MenuAction)action
{
    return [self initWithTitle:title icon:nil action:action];
}

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon action:(MenuAction)action
{
    self = [super init];
    if (self)
    {
        self.title = title;
        self.icon = icon;
        self.action = action;
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
       
        [self setImage:icon forState:UIControlStateNormal];
        [self addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (instancetype)initWithBackground:(UIImage *)icon action:(MenuAction)action
{
    self = [super init];
    if (self)
    {
        self.icon = icon;
        self.action = action;
        [self setBackgroundImage:icon forState:UIControlStateNormal];
        [self addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}


- (void)setClickAction:(MenuAction)action
{
    self.action = action;
    [self addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onClick:(id)sender
{
    if (_action) {
        _action(self);
    }
    
}
@end
