//
//  DD_GoodCircleView.h
//  YCO SPACE
//
//  Created by yyj on 16/7/30.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DD_GoodsCircleView : UIView

-(instancetype)initWithBlock:(void (^)(NSString *type))block;

__block_type(block, type);
@end
