#import "TOPNumberCollectionViewCell.h"

@implementation TOPNumberCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 73/2;
    self.clipsToBounds = YES;
    self.numberTitleLabel.layer.cornerRadius = 73/2;
    self.numberTitleLabel.layer.borderColor = TOPAPPGreenColor.CGColor;
    self.numberTitleLabel.layer.borderWidth = 1;
}

@end
