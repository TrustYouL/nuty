#import "TOPLocalFlowLayout.h"

@implementation TOPLocalFlowLayout
-(UIUserInterfaceLayoutDirection)effectiveUserInterfaceLayoutDirection {
    if (isRTL()) {
        return UIUserInterfaceLayoutDirectionRightToLeft;
    }
    return UIUserInterfaceLayoutDirectionLeftToRight;
}

- (BOOL)flipsHorizontallyInOppositeLayoutDirection{
    return  YES;
}
@end
