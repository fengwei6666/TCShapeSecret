//
//  TCShapeView.m
//  TCShapeSecret
//
//  Created by wei feng on 3/2/15.
//  Copyright (c) 2015 wei feng. All rights reserved.
//

#import "TCShapeView.h"

@implementation TCShapeView

- (instancetype)init
{
    if (self = [super init])
    {
        self.backgroundColor = [UIColor clearColor];
        _selectColor = [UIColor blueColor];
        _nomalColor = [UIColor lightGrayColor];
        _selected = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        _selectColor = [UIColor blueColor];
        _nomalColor = [UIColor lightGrayColor];
        _lineWidth = 1;
        _selected = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint center = CGPointMake(CGRectGetWidth(rect)/2, CGRectGetHeight(rect)/2);
    CGFloat radius = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/2;
    CGColorRef color = _selected ? _selectColor.CGColor : _nomalColor.CGColor;
    
    if (_selected)
    {
        CGContextSaveGState(context);
        CGFloat fillRadius = radius/2;
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddArc(path, &CGAffineTransformIdentity, center.x, center.y, fillRadius, 0, 2 * M_PI, true);
        CGContextSetFillColorWithColor(context, color);
        CGContextAddPath(context, path);
        CGPathRelease(path);
        CGContextDrawPath(context, kCGPathFill);
        CGContextRestoreGState(context);
    }

    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, color);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, &CGAffineTransformIdentity, center.x, center.y, radius-_lineWidth, 0, 2 * M_PI, true);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    CGContextSetLineWidth(context, _lineWidth);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
}

- (void)setSelectColor:(UIColor *)selectColor
{
    if (_selectColor != selectColor)
    {
        _selectColor = selectColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setNomalColor:(UIColor *)nomalColor
{
    if (_nomalColor != nomalColor)
    {
        _nomalColor = nomalColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected)
    {
        _selected = selected;
        
        [self setNeedsDisplay];
    }
}

@end
