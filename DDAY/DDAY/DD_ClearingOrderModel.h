//
//  DD_ClearingOrderModel.h
//  DDAY
//
//  Created by yyj on 16/5/18.
//  Copyright © 2016年 mike_xie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DD_baseModel.h"

@interface DD_ClearingOrderModel : DD_baseModel

/**
 * 获取订单model arr
 */
+(NSArray *)getClearingOrderModelArray:(NSArray *)arrdata;

/**
 * 获取订单model
 */
+(DD_ClearingOrderModel *)getClearingOrderModel:(NSDictionary *)dict;

/**
 * 获取当前OrderModel 当前时间戳下的价格str
 */
-(NSString *)getPriceStr;

/**
 * 获取当前OrderModel 当前时间戳下的价格
 */
-(NSString *)getPrice;

/** 颜色ID*/
__string(colorId);

/** 颜色名*/
__string(colorName);

/** 颜色代码*/
__string(colorCode);

/** 类别*/
__string(categoryName);

/** 发布会后是否恢复原价*/
__bool(discountEnable);

/** 商品ID*/
__string(itemId);

/** 商品名*/
__string(itemName);

/** 所购买商品数量*/
__string(numbers);

/** 原价*/
__string(originalPrice);

/** 商品图片*/
__string(pic);

/** 商品现价*/
__string(price);

/** 发布会结束时间*/
__long(saleEndTime);

/** 发布会开始时间*/
__long(saleStartTime);

/** 所属系列的ID*/
__string(seriesId);

/** 所属系列名称*/
__string(seriesName);

/** 所选尺寸ID*/
__string(sizeId);

/** 所选尺寸名称*/
__string(sizeName);

/** 品牌名*/
__string(brandName);

@end
