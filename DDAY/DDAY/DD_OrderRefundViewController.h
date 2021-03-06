//
//  DD_OrderRefundViewController.h
//  DDAY
//
//  Created by yyj on 16/6/8.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_BaseViewController.h"

@class DD_OrderDetailModel;

@interface DD_OrderRefundViewController : DD_BaseViewController

-(instancetype)initWithModel:(DD_OrderDetailModel *)model WithBlock:(void (^)(NSString *type,long status))block;

@property(nonatomic,copy) void (^block)(NSString *type,long status);

@property (nonatomic,strong)DD_OrderDetailModel *OrderModel;

@end
