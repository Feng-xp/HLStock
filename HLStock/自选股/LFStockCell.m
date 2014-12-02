//
//  LFStockCell.m
//  HLStock
//
//  Created by qzp on 14/11/22.
//  Copyright (c) 2014年 HuiLian. All rights reserved.
//

#import "LFStockCell.h"

@interface LFStockCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nowPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;

@property (nonatomic)   UIView *lineView;

@end

@implementation LFStockCell

- (void)awakeFromNib {
    // Initialization code
    self.lineView = [[UIView alloc] init];
    
    _lineView.translatesAutoresizingMaskIntoConstraints = NO;
    _lineView.backgroundColor = [UIColor colorWithWhite:235/255.0 alpha:1];
    [self addSubview:_lineView];

    NSArray *hConstrains = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[_lineView]-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(_lineView)];
    NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_lineView(1)]|" options:NSLayoutFormatAlignAllBottom metrics:nil views:NSDictionaryOfVariableBindings(_lineView)];
    
    [self addConstraints:hConstrains];
    [self addConstraints:vConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadCellWithData:(NSDictionary *)dict
{
    NSString *stockID = [dict allKeys][0];
    NSArray *stockValues = dict[stockID];
    if (![stockValues isKindOfClass:[NSNull class]] && [stockValues count] > 5) {

        CGFloat currentPrice = [stockValues[3] floatValue];
        CGFloat yesterdayPrice = [stockValues[2] floatValue];
        if (currentPrice == 0) {
            currentPrice = yesterdayPrice;
        }
        self.nowPriceLabel.text = [NSString stringWithFormat:@"%.2f",currentPrice];
        self.nameLabel.text = stockValues[0];
        self.codeLabel.text = [stockID substringFromIndex:2];
        
        CGFloat diff = currentPrice - yesterdayPrice;
        UIColor *textColor = nil;
        NSString *sign = nil;
        if (diff > 0) {
            textColor = [UIColor redColor];
            sign = @"+";
        }
        else if (diff < 0){
            textColor = [UIColor colorWithRed:22.0/255.0 green:150.0/255.0 blue:130.0/255.0 alpha:1];
            sign = @"-";
        }
        else {
            textColor = [UIColor lightGrayColor];
            sign = @"+";
        }
        _rangeLabel.text = [NSString stringWithFormat:@"%@%.2f%@",sign,fabsf(diff)/yesterdayPrice * 100 + 0.004,@"%"];
        [self setLabelTextColor:textColor];
    }
    [self setNeedsLayout];
}

- (void)setLabelTextColor:(UIColor *)color
{
    self.rangeLabel.textColor = color;
}

@end
