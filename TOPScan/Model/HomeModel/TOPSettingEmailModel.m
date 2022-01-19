#define MyselfEmail @"myselfEmail"
#define ToEmail @"toEmail"
#define Subject @"subject"
#define Body @"body"

#import "TOPSettingEmailModel.h"

@implementation TOPSettingEmailModel

- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.myselfEmail forKey:MyselfEmail];
    [coder encodeObject:self.toEmail forKey:ToEmail];
    [coder encodeObject:self.subject forKey:Subject];
    [coder encodeObject:self.body forKey:Body];
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super init]) {
        self.myselfEmail = [coder decodeObjectForKey:MyselfEmail];
        self.toEmail = [coder decodeObjectForKey:ToEmail];
        self.subject = [coder decodeObjectForKey:Subject];
        self.body = [coder decodeObjectForKey:Body];
    }
    return self;
}
@end
