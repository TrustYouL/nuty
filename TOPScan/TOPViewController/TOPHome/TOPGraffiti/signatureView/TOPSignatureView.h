#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TOPSignatureView : UIView

{
    CGPoint _start;
    CGPoint _move;
    CGMutablePathRef _path;
    NSMutableArray *_pathArray;
    CGFloat _lineWidth;
    UIColor *_color;
    int minX,maxX,minY,maxY;

}
@property (nonatomic,assign)CGFloat lineWidth;
@property (nonatomic,strong)UIColor *color;
@property (nonatomic,strong)NSMutableArray *pathArray;
@property (strong, nonatomic) NSMutableArray *reDoArray;
@property (nonatomic, assign) BOOL isAlreadySignture;
@property (nonatomic, copy) void(^addDrawPathBlock)(void);
@property (nonatomic, copy) void(^touchBeginBlock)(void);
@property (nonatomic, assign) BOOL enableDrawing;
@property (nonatomic, assign) BOOL beingDrawing;
-(UIImage*)getDrawingImg;
-(void)undo;
-(void)redo;
-(void)clear;
@end

NS_ASSUME_NONNULL_END
