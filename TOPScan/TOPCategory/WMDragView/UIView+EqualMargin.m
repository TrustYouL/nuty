#import "UIView+EqualMargin.h"
#import "Masonry.h"

@implementation UIView (EqualMargin)

- (void) top_distributeSpacingHorizontallyWith:(NSArray*)views
{
    if (views.count) {
        NSMutableArray *spaces = [NSMutableArray arrayWithCapacity:views.count+1];
        
        for ( int i = 0 ; i < views.count+1 ; ++i )
        {
            UIView *v = [UIView new];
            v.backgroundColor = [UIColor clearColor];
            [spaces addObject:v];
            [self addSubview:v];
            
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(v.mas_height);
            }];
        }
        
        UIView *v0 = spaces[0];
        
        __weak __typeof(&*self)ws = self;
        
        [v0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(ws.mas_leading);
            make.centerY.equalTo(((UIView*)views[0]).mas_centerY);
        }];
        
        UIView *lastSpace = v0;
        for ( int i = 0 ; i < views.count; ++i )
        {
            UIView *obj = views[i];
            UIView *space = spaces[i+1];
            
            [obj mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(lastSpace.mas_trailing);
            }];
            
            [space mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(obj.mas_trailing);
                make.centerY.equalTo(obj.mas_centerY);
                make.width.equalTo(v0);
            }];
            
            lastSpace = space;
        }
        
        [lastSpace mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(ws.mas_trailing);
        }];
    }
}
- (void) distributeSpacingVerticallyWith:(NSArray*)views
{
    if (views.count) {
        NSMutableArray *spaces = [NSMutableArray arrayWithCapacity:views.count+1];
        
        for ( int i = 0 ; i < views.count+1 ; ++i )
        {
            UIView *v = [UIView new];
            [spaces addObject:v];
            [self addSubview:v];
            
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(v.mas_height);
            }];
        }
        
        
        UIView *v0 = spaces[0];
        
        __weak __typeof(&*self)ws = self;
        
        [v0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(ws.mas_top);
            make.centerX.equalTo(((UIView*)views[0]).mas_centerX);
        }];
        
        UIView *lastSpace = v0;
        for ( int i = 0 ; i < views.count; ++i )
        {
            UIView *obj = views[i];
            UIView *space = spaces[i+1];
            
            [obj mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastSpace.mas_bottom);
            }];
            
            [space mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(obj.mas_bottom);
                make.centerX.equalTo(obj.mas_centerX);
                make.height.equalTo(v0);
            }];
            
            lastSpace = space;
        }
        
        [lastSpace mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(ws.mas_bottom);
        }];
    }
}

@end
