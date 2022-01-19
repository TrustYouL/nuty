#import <Foundation/Foundation.h>
#import "TOPMenuAbleItem.h"

@interface TOPMenuItem : NSObject<TOPMenuAbleItem>
{
@protected
    NSString    *_title;
    UIImage     *_icon;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) MenuAction action;
@end

