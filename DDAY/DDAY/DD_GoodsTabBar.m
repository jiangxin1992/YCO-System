//
//  DD_GoodsTabBar.m
//  YCO SPACE
//
//  Created by yyj on 16/7/30.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_GoodsTabBar.h"

@implementation DD_GoodsTabBar
-(instancetype)initWithBlock:(void (^)(NSString *))block
{
    self=[super init];
    if(self)
    {
        _block=block;
        self.backgroundColor=_define_white_color;
        [self UIConfig];
    }
    return self;
}
#pragma mark - UIConfig
-(void)UIConfig
{
    UIView *view=[UIView getCustomViewWithColor:_define_black_color];
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(3);
        make.left.and.right.mas_equalTo(view.superview).with.offset(0);
        make.top.mas_equalTo(view.superview).with.offset(0);
    }];
    
    UIButton *buyBtn=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:18.0f WithSpacing:0 WithNormalTitle:@"购买" WithNormalColor:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
    [self addSubview:buyBtn];
    buyBtn.backgroundColor=_define_black_color;
    [buyBtn addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
    [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.left.mas_equalTo(26);
        make.width.mas_equalTo(140);
        make.centerY.mas_equalTo(self);
    }];
    
}
#pragma mark - SomeAction
-(void)clickAction
{
    _block(@"buy");
}
@end
