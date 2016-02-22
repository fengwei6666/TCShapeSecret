//
//  TCShapeView.h
//  TCShapeSecret
//
//  Created by wei feng on 3/2/15.
//  Copyright (c) 2015 wei feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCShapeView : UIView

@property (retain, nonatomic) UIColor *selectColor;
@property (retain, nonatomic) UIColor *nomalColor;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) BOOL selected;

@end
