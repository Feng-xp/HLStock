//
//  HLStockViewCell.h
//  HLStock
//
//  Created by qzp on 14/11/10.
//  Copyright (c) 2014年 HuiLian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLStockViewCell : UITableViewCell

@property (nonatomic,readonly)  UILabel *stockIDLable;
@property (nonatomic,readonly)  UILabel *stockNameLabel;
@property (nonatomic,readonly)  UILabel *stockPriceLabel;

- (void)loadData:(NSDictionary *)dict;

@end
