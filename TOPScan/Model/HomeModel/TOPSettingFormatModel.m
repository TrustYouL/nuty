#define FormatString @"formatString"
#define IsSelect @"isSelect"
#import "TOPSettingFormatModel.h"

@implementation TOPSettingFormatModel

- (instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super init]) {
        self.formatString = [coder decodeObjectForKey:FormatString];
        self.isSelect = [coder decodeBoolForKey:IsSelect];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.formatString forKey:FormatString];
    [coder encodeBool:self.isSelect forKey:IsSelect];
}
@end
