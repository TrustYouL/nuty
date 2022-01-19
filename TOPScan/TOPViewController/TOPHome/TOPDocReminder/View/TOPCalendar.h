#import <UIKit/UIKit.h>

@class TOPCalendar;

@protocol TOPCalendarDelegate <NSObject>
- (void)top_calendar:(TOPCalendar *)calendar didClickSureButtonWithDate:(NSString *)date;
- (void)top_clickToDismiss;
@end

@interface TOPCalendar : UIView
@property (nonatomic, assign) BOOL showTimePicker;
@property (nonatomic, copy)NSDate * currentDate;
@property (nonatomic, weak) id<TOPCalendarDelegate> delegate;
@property (nonatomic, copy)void(^top_clickToDismiss)(void);
//- (void)show;
- (void)dismiss;

@end
