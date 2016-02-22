//
//  TCShapeSecretView.h
//  TCShapeSecret
//
//  Created by wei feng on 3/2/15.
//  Copyright (c) 2015 wei feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCShapeSecretView;

/**
 *  @brief 手势完成之后的回调
 *
 *  @param secretView 手势密码视图
 *  @param result     手势结果（记录了手势的路径 an array of numbers）
 */
typedef void(^TCComepleteBlock)(TCShapeSecretView *secretView, NSArray *result);

/**
 *  @brief 手势密码视图
 */
@interface TCShapeSecretView : UIView


@property (retain, nonatomic) UIColor *trackColor;          ///< 手势路径的颜色
@property (retain, nonatomic) UIColor *nomalColor;          ///< 图形边框颜色

/**
 *  @brief 开始识别手势密码
 *
 *  @param completeHandler 手势密码结果回调
 */
- (void)beginSecretGesture:(TCComepleteBlock )completeHandler;


/**
 *  @brief 用指定的颜色显示指定的手势密码
 *
 *  @param secretArray  密码数组
 *  @param trackColor   路径颜色
 *  @param duration     显示时间
 */
//- (void)showSecretGestureView:(NSArray *)secretArray trackColor:(UIColor *)trackColor
//                     duration:(CGFloat)duration;

@end
