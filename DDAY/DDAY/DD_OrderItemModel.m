//
//  DD_OrderItemModel.m
//  DDAY
//
//  Created by yyj on 16/6/6.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_OrderItemModel.h"

@implementation DD_OrderItemModel
+(NSArray *)getOrderItemModelArr:(NSArray *)arr
{
    NSMutableArray *itemsArr=[[NSMutableArray alloc] init];
    [arr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        [itemsArr addObject:[DD_OrderItemModel mj_objectWithKeyValues:dict]];
    }];

    return itemsArr;
}
@end
