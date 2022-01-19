
#import "TOPEraserHeaderCollectionReusableView.h"

@implementation TOPEraserHeaderCollectionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headerTitleLabel.text = NSLocalizedString(@"topscan_graffitieraser", @"");
    // Initialization code
}

@end
