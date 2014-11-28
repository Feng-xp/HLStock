//
//  LFAddStockViewController.h
//  HLStock
//
//  Created by qzp on 14/11/22.
//  Copyright (c) 2014年 HuiLian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFBaseViewController.h"

typedef void(^addActionBlock)(NSString *code);

@interface LFAddStockViewController : LFBaseViewController

@property (nonatomic,copy)  addActionBlock action;

@end
