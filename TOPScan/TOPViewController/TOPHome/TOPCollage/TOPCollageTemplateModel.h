#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPCollageTemplateModel : NSObject
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *iconName;
@property (copy, nonatomic) NSString *selectedIconName;
@property (assign, nonatomic) BOOL isSelected;
@property (assign, nonatomic) TOPCollageTemplateType templateType;

@end

NS_ASSUME_NONNULL_END
