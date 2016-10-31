//
//  DD_IntegralModel.h
//  YCO SPACE
//
//  Created by yyj on 2016/10/31.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DD_IntegralModel : NSObject

/**
 * 获取积分model数组
 */
+(NSArray *)getIntegralModelArr:(NSArray *)arr;

/**
 * 获取积分model
 */
+(DD_IntegralModel *)getIntegralModel:(NSDictionary *)dict;

/**
 * 内容
 */
__string(tips);
/**
 * 1进
 * 0出
 */
__bool(pointType);
/**
 * 积分数量
 */
__int(points);
__string(pointStr);
/**
 * 创建时间
 */

__long(happenTime);
__string(createTime);
@end
