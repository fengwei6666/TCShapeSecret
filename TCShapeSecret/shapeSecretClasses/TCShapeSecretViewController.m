//
//  TCShapeSecretViewController.m
//  TCShapeSecret
//
//  Created by wei feng on 3/2/15.
//  Copyright (c) 2015 wei feng. All rights reserved.
//

#import "TCShapeSecretViewController.h"
#import "TCShapeSecretView.h"

static TCShapeSecretViewController *shareSecretViewController = nil;
static NSString *kSecretkey = @"secretkey";

@interface TCShapeSecretViewController ()
{
    BOOL _isShowing;
    NSInteger _errCount;
}

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet TCShapeSecretView *secretShapeView;
@property (copy, nonatomic) NSArray *secretArray;

- (void)beginHandleGestureSecret;
- (IBAction)forgetGestureSecret:(id)sender;

@end

@implementation TCShapeSecretViewController

+ (id)shareTCShapeSecretViewController
{
    if (shareSecretViewController)
    {
        return shareSecretViewController;
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareSecretViewController = [[TCShapeSecretViewController alloc] initWithNibName:@"TCShapeSecretViewController" bundle:nil];
    });
    
    return shareSecretViewController;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        _isShowing = NO;
        _errCount = 5;
    }
    return self;
}

- (NSArray *)secretArray
{
    if (_secretArray == nil)
    {
        _secretArray = [[NSUserDefaults standardUserDefaults] objectForKey:kSecretkey];
    }
    
    if (_secretArray == nil)
    {
        _secretArray = [[NSArray alloc] init];
    }
    
    return _secretArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.secretShapeView.nomalColor = [UIColor lightGrayColor];
    self.secretShapeView.trackColor = [UIColor blueColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    _isShowing = YES;
    [self beginHandleGestureSecret];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _isShowing = NO;
}

#pragma mark - privite

- (void)beginHandleGestureSecret
{
    self.messageLabel.textColor = [UIColor blackColor];
    [self.iconImageView setImage:[self imageFromShapeSecretView]];
    
    //手势图案不少于3个点的连接，可以设置
    NSInteger min = 3;
    
    if ([self.secretArray count] < min)
    {
        self.messageLabel.text = @"请绘制解锁图案";
        
        [self.secretShapeView beginSecretGesture:^(TCShapeSecretView *secretView, NSArray *result) {
            if ([result count] < min)
            {
                self.messageLabel.text = @"手势图案不少于3个点的连接";
                self.messageLabel.textColor = [UIColor redColor];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self beginHandleGestureSecret];
                });
            }
            else
            {
                self.secretArray = result;
                self.messageLabel.text = @"请再次绘制解锁图案";
                [self.iconImageView setImage:[self imageFromShapeSecretView]];
                
                [self.secretShapeView beginSecretGesture:^(TCShapeSecretView *secretView, NSArray *result) {
                    BOOL success = NO;
                    
                    if ([self.secretArray count] == [result count])
                    {
                        success = YES;

                        for (NSInteger i = 0; i < [self.secretArray count]; i++)
                        {
                            if ([self.secretArray[i] integerValue] != [result[i] integerValue])
                            {
                                success = NO;
                                break;
                            }
                        }
                    }
                    
                    if (success)
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:self.secretArray forKey:kSecretkey];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [self dismissViewControllerAnimated:YES completion:NULL];
                    }
                    else
                    {
                        _secretArray = nil;
                        self.messageLabel.textColor = [UIColor redColor];
                        self.messageLabel.text = @"两次手势密码不一致,请重新设置";
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self beginHandleGestureSecret];
                        });
                    }
                }];
            }
        }];

    }
    else
    {
        if (_errCount == 5)
        {
            self.messageLabel.text = @"请绘制解锁图案";
        }
        else
        {
            self.messageLabel.textColor = [UIColor redColor];
        }
        
        [self.secretShapeView beginSecretGesture:^(TCShapeSecretView *secretView, NSArray *result) {
            BOOL success = NO;
            
            if ([self.secretArray count] == [result count])
            {
                success = YES;
                
                for (NSInteger i = 0; i < [self.secretArray count]; i++)
                {
                    if ([self.secretArray[i] integerValue] != [result[i] integerValue])
                    {
                        success = NO;
                        break;
                    }
                }
            }
            
            if (success)
            {
                _errCount = 5;
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
            else
            {
                _errCount--;
                if (_errCount > 0)
                {
                    self.messageLabel.textColor = [UIColor redColor];
                    self.messageLabel.text = [NSString stringWithFormat:@"密码错误,还可以再输入%ld次", _errCount];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self beginHandleGestureSecret];
                    });
                }
                else
                {
                    self.messageLabel.textColor = [UIColor redColor];
                    self.messageLabel.text = @"输入密码错误超过上限，请找回密码";
                }
            }
        }];
    }
}

- (IBAction)forgetGestureSecret:(id)sender
{
    [self resetGestureSecret];
    NSLog(@"forgetting gesture secret");
}

- (UIImage *)imageFromShapeSecretView
{
    UIGraphicsBeginImageContextWithOptions(self.secretShapeView.frame.size, NO, [UIScreen mainScreen].scale);
    [self.secretShapeView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - public

- (void)resetGestureSecret
{
    _secretArray = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSecretkey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self beginHandleGestureSecret];
}

@end
