#import "TOPTextField.h"

@implementation TOPTextField

-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x+20, bounds.origin.y, bounds.size.width -40, bounds.size.height);//更好理解些
    return inset;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x+20, bounds.origin.y, bounds.size.width-40, bounds.size.height);//更好理解些
    return inset;
}

-(CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x+20, bounds.origin.y, bounds.size.width-60, bounds.size.height);//更好理解些
    return inset;
}

@end
