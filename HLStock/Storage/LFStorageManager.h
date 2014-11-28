//
//  LFStorageManager.h
//  HLStock
//
//  Created by qzp on 14/11/22.
//  Copyright (c) 2014年 HuiLian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LFStorageManager : NSObject

@property (nonatomic)   NSArray         *stockList;
@property (nonatomic)   NSDictionary    *stockData;

+ (instancetype)shareInstance;

- (void)save;
- (void)load;

@end
