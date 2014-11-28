//
//  LFBaseViewController.m
//  HLStock
//
//  Created by qzp on 14/11/22.
//  Copyright (c) 2014年 HuiLian. All rights reserved.
//

#import "LFBaseViewController.h"

@interface LFBaseViewController ()

@end

@implementation LFBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)barHeight
{
    CGFloat height = self.navigationController.navigationBar.height;
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        height += 20;
    }
    return height;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation NS_AVAILABLE_IOS(6_0) {
    return UIInterfaceOrientationPortrait;
}

@end
