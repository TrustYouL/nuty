#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSuggestionModel : NSObject
@property (nonatomic ,copy)NSString * suggestionType;
@property (nonatomic ,copy)NSString * suggestionDetail;
@property (nonatomic ,copy)NSString * userEmail;
@property (nonatomic ,strong)NSMutableArray * picArray;
@property (nonatomic ,assign)BOOL selectState;
@end

NS_ASSUME_NONNULL_END
