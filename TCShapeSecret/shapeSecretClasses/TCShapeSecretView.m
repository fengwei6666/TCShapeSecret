//
//  TCShapeSecretView.m
//  TCShapeSecret
//
//  Created by wei feng on 3/2/15.
//  Copyright (c) 2015 wei feng. All rights reserved.
//

#import "TCShapeSecretView.h"
#import "TCShapeView.h"

static CGFloat kDistence = 30;

@interface TCShapeSecretView()
{
    BOOL _allowGesture;
    CGPoint _currentPoint;
    NSMutableArray *_secretArray;
    NSMutableArray *_shapesArray;
}

@property (assign, nonatomic) BOOL allowGesture;
@property (copy,   nonatomic) TCComepleteBlock completionHandler;
@property (retain, nonatomic) NSMutableArray *shapesArray;
@property (retain, nonatomic) UIColor *showColor;
@property (retain, nonatomic) NSArray *showArray;

- (void)loadShapeViews;
- (void)gestureBegin;
- (void)gestureAddSecretNumber:(NSNumber *)number;
- (void)gestureComplete;

@end

@implementation TCShapeSecretView

- (instancetype)init
{
    if (self = [super init])
    {
        self.allowGesture = NO;
        _currentPoint = CGPointZero;
        
        if (_secretArray == nil)
        {
            _secretArray = [[NSMutableArray alloc] initWithCapacity:9];
        }
        
        [self loadShapeViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.allowGesture = NO;
        _currentPoint = CGPointZero;
        
        if (_secretArray == nil)
        {
            _secretArray = [[NSMutableArray alloc] initWithCapacity:9];
        }
        
        [self loadShapeViews];
    }
    return self;
}

- (void)awakeFromNib
{
    self.allowGesture = NO;
    _currentPoint = CGPointZero;
    
    if (_secretArray == nil)
    {
        _secretArray = [[NSMutableArray alloc] initWithCapacity:9];
    }
    
    [self loadShapeViews];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    for (NSInteger i = 0; i < [_secretArray count]; i++)
    {
        NSInteger numberValue = [_secretArray[i] integerValue];
        
        if (numberValue < [self.shapesArray count])
        {
            TCShapeView *shapeView = (TCShapeView *)[self.shapesArray objectAtIndex:numberValue];
            CGPoint point1 = shapeView.center;
            CGPoint point2 = _currentPoint;
            
            if ((i + 1) < [_secretArray count])
            {
                NSInteger numberValue_d = [_secretArray[i+1] integerValue];
                
                if (numberValue_d < [self.shapesArray count])
                {
                    TCShapeView *shape_d = (TCShapeView *)[self.shapesArray objectAtIndex:numberValue_d];
                    point2 = shape_d.center;
                }
            }

            CGPathMoveToPoint(path, &CGAffineTransformIdentity, point1.x, point1.y);
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, point2.x, point2.y);
        }
    }
    
    CGColorRef color = self.showColor ? self.showColor.CGColor : self.trackColor.CGColor;
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextSetLineWidth(context, 3);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextRestoreGState(context);
}

- (void)setTrackColor:(UIColor *)trackColor
{
    if (_trackColor != trackColor)
    {
        _trackColor = trackColor;
        
        [self.shapesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TCShapeView *shapeView = (TCShapeView *)obj;
            if (shapeView)
            {
                shapeView.selectColor = trackColor;
            }
        }];
        
        [self setNeedsDisplay];
    }
}

- (void)setNomalColor:(UIColor *)nomalColor
{
    if (_nomalColor != nomalColor)
    {
        _nomalColor = nomalColor;
        
        [self.shapesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TCShapeView *shapeView = (TCShapeView *)obj;
            if (shapeView)
            {
                shapeView.nomalColor = nomalColor;
            }
        }];
        
        [self setNeedsDisplay];
    }
}

- (void)setAllowGesture:(BOOL)allowGesture
{
    _allowGesture = allowGesture;
    
    self.userInteractionEnabled = allowGesture;
}

- (NSMutableArray *)shapesArray
{
    if (_shapesArray == nil)
    {
        _shapesArray = [[NSMutableArray alloc] initWithCapacity:9];
        CGFloat width = (MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) - kDistence * 2)/3;
        
        for (NSInteger i = 0; i < 9; i++)
        {
            TCShapeView *shapeView = [[TCShapeView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
            shapeView.selected = NO;
            shapeView.selectColor = self.trackColor;
            shapeView.nomalColor = self.nomalColor;
            shapeView.lineWidth = 1;
            
            [_shapesArray addObject:shapeView];
        }
    }
    
    return _shapesArray;
}

- (void)loadShapeViews
{
    for (UIView *subview in self.subviews)
    {
        if ([subview isKindOfClass:[TCShapeView class]])
        {
            [subview removeFromSuperview];
        }
    }
    
    for (NSInteger i = 0; i < [self.shapesArray count]; i++)
    {
        TCShapeView *shapeView = (TCShapeView *)[self.shapesArray objectAtIndex:i];
        
        if (shapeView)
        {
            CGRect shapeFrame = shapeView.frame;
            CGFloat leftSpace = (CGRectGetWidth(self.frame) - kDistence*2 - CGRectGetWidth(shapeFrame)*3)/2;
            CGFloat topSpace = (CGRectGetHeight(self.frame) - kDistence*2 - CGRectGetHeight(shapeFrame)*3)/2;
            
            NSInteger h = i/3;
            NSInteger v = i%3;
            shapeFrame.origin.x = leftSpace + v * (CGRectGetWidth(shapeFrame) + kDistence);
            shapeFrame.origin.y = topSpace + h * (CGRectGetHeight(shapeFrame) + kDistence);
            [shapeView setFrame:shapeFrame];
            [self addSubview:shapeView];
        }
    }
}

#pragma mark - public

- (void)beginSecretGesture:(TCComepleteBlock)completeHandler
{
    self.completionHandler = completeHandler;
    [_secretArray removeAllObjects];
    [self.shapesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TCShapeView *shapeView = (TCShapeView *)obj;
        if (shapeView)
        {
            shapeView.selected = NO;
        }
    }];
    _currentPoint = CGPointZero;
    self.allowGesture = YES;
    [self setNeedsDisplay];
}

- (void)showSecretGestureView:(NSArray *)secretArray trackColor:(UIColor *)trackColor
                     duration:(CGFloat)duration
{
    if (secretArray && [secretArray count] > 0)
    {
        self.showArray = secretArray;
        self.showColor = trackColor;
        [self setNeedsDisplay];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.showArray = nil;
            self.showColor = nil;
            [self setNeedsDisplay];
        });
    }
}

#pragma mark - gesture

- (void)gestureBegin
{

}

- (void)gestureAddSecretNumber:(NSNumber *)number
{
    if (![_secretArray containsObject:number])
    {
        [_secretArray addObject:number];
        
        if ([number integerValue] < [self.shapesArray count])
        {
            TCShapeView *shapeView = (TCShapeView *)[self.shapesArray objectAtIndex:[number integerValue]];
            
            if (shapeView)
            {
                shapeView.selected = YES;
            }
        }
    }
}

- (void)gestureComplete
{
    if (self.completionHandler)
    {
        self.allowGesture = NO;
        self.completionHandler(self, _secretArray);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self gestureBegin];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    _currentPoint = point;
    
    [self.shapesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TCShapeView *shapeView = (TCShapeView *)obj;
        if (CGRectContainsPoint(shapeView.frame, point))
        {
            [self gestureAddSecretNumber:[NSNumber numberWithInteger:idx]];
        }
    }];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    _currentPoint = point;
    
    [self.shapesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TCShapeView *shapeView = (TCShapeView *)obj;
//        CGFloat width = CGRectGetWidth(shapeView.frame);
//        CGRect rect = CGRectMake(CGRectGetMinX(shapeView.frame) + width/8, CGRectGetMinY(shapeView.frame) + width/8, width - width/4, width/4);
        if (CGRectContainsPoint(shapeView.frame, point))
        {
            [self gestureAddSecretNumber:[NSNumber numberWithInteger:idx]];
        }
    }];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self gestureComplete];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self gestureComplete];
    [self setNeedsDisplay];
}

@end
