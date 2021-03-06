//
//  DD_OrderDetailModel.h
//  DDAY
//
//  Created by yyj on 16/6/7.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DD_baseModel.h"

@class DD_OrderDetailInfoModel;
@class DD_AddressModel;
@class DD_OrderLogisticsModel;

@interface DD_OrderDetailModel : DD_baseModel
/**
 * 获取解析model
 */
+(DD_OrderDetailModel *)getOrderDetailModel:(NSDictionary *)dict;

/** 订单信息*/
@property (nonatomic,strong)DD_OrderDetailInfoModel *orderInfo;

/** 订单地址*/
@property (nonatomic,strong)DD_AddressModel *address;

/** 订单物流信息*/
@property (nonatomic,strong)DD_OrderLogisticsModel *logisticsModel;

@end
