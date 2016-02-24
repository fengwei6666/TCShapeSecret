//
//  TCShapeSecretViewController.h
//  TCShapeSecret
//
//  Created by wei feng on 3/2/15.
//  Copyright (c) 2015 wei feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCShapeSecretViewController : UIViewController

@property (assign, nonatomic, readonly) BOOL isShowing;

+ (id)shareTCShapeSecretViewController;

- (void)resetGestureSecret;

@end
