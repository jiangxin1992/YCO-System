//
//  DD_OrderHeadView.h
//  DDAY
//
//  Created by yyj on 16/6/6.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_BaseView.h"

@class DD_OrderModel;

@interface DD_OrderHeadView : DD_BaseView

-(instancetype)initWithFrame:(CGRect)frame WithOrderModel:(DD_OrderModel *)orderModel WithSection:(NSInteger )Section WithBlock:(void(^)(NSString *type,NSInteger Section))block;

@property (nonatomic,strong)DD_OrderModel *orderModel;

@property (nonatomic,assign)NSInteger Section;

/** cell 回调*/
@property (nonatomic,copy) void (^block)(NSString *type,NSInteger Section);

@end
