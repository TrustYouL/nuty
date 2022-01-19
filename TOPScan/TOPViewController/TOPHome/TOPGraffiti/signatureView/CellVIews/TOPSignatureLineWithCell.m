
#import "TOPSignatureLineWithCell.h"

@implementation TOPSignatureLineWithCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setLineWidth:(NSInteger)lineWidth
{
    _lineWidth = lineWidth;
    self.lineWithConstraint.constant = lineWidth;
    self.lineHeightConstraint.constant = lineWidth;
    self.lineWithView.clipsToBounds = YES;
    self.lineWithView.layer.cornerRadius = lineWidth/2;
    
}
@end
