//
//  HLStockViewCell.m
//  HLStock
//
//  Created by qzp on 14/11/10.
//  Copyright (c) 2014年 HuiLian. All rights reserved.
//

#import "HLStockViewCell.h"

@interface HLStockViewCell ()

@property (nonatomic)   UIView *lineView;

@end

@implementation HLStockViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _stockIDLable = [self createLabel];
        [self.contentView addSubview:_stockIDLable];
        
        _stockNameLabel = [self createLabel];
        [self.contentView addSubview:_stockNameLabel];
        
        _stockPriceLabel = [self createLabel];
        [self.contentView addSubview:_stockPriceLabel];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _lineView.backgroundColor = [UIColor lightGrayColor];
//        [self.contentView addSubview:_lineView];
    }
    return self;
}

- (UILabel *)createLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, self.contentView.frame.size.height)];
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = _stockIDLable.frame;
    _stockIDLable.frame = CGRectMake(0, 0, rect.size.width, self.contentView.frame.size.height);
    
    rect = _stockNameLabel.frame;
    _stockNameLabel.frame = CGRectMake(75, 0, rect.size.width, self.contentView.frame.size.height);
    
    rect = _stockPriceLabel.frame;
    _stockPriceLabel.frame = CGRectMake(self.contentView.frame.size.width - rect.size.width - 10, 0, rect.size.width, self.contentView.frame.size.height);
    
    _lineView.frame = CGRectMake(0, self.contentView.frame.size.height - .5, self.contentView.frame.size.width, .5);
}

- (void)loadData:(NSDictionary *)dict
{
    NSString *stockID = [dict allKeys][0];
    _stockIDLable.text = [stockID substringWithRange:NSMakeRange(2, [stockID length] - 2)];
    [_stockIDLable sizeToFit];
    
    NSArray *stockValues = dict[stockID];
    if (stockValues != nil && ![stockValues isKindOfClass:[NSNull class]]) {
        _stockNameLabel.text = stockValues[0];
        [_stockNameLabel sizeToFit];
        
        CGFloat currentPrice = [stockValues[3] floatValue];
        CGFloat yesterdayPrice = [stockValues[2] floatValue];
        CGFloat diff = currentPrice - yesterdayPrice;
        UIColor *textColor = nil;
        NSString *sign = nil;
        if (diff > 0) {
            textColor = [UIColor redColor];
            sign = @"+";
        }
        else if (diff < 0){
            textColor = [UIColor greenColor];
            sign = @"-";
        }
        else {
            textColor = [UIColor whiteColor];
            sign = @"+";
        }
        _stockPriceLabel.text = [NSString stringWithFormat:@"%@(%@%.2f)",stockValues[3],sign,fabsf(diff)];
        _stockPriceLabel.textColor = textColor;
        [_stockPriceLabel sizeToFit];
    }
    [self setNeedsLayout];
}

@end
