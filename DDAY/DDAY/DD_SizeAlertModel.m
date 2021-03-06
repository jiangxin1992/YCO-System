//
//  DD_SizeAlertModel.m
//  YCO SPACE
//
//  Created by yyj on 16/8/3.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_SizeAlertModel.h"

#import "DD_SizeModel.h"

@implementation DD_SizeAlertModel
/**
 * 获取解析model
 */
+(DD_SizeAlertModel *)getSizeAlertModel:(NSDictionary *)dict
{
    DD_SizeAlertModel *_SizeAlertModel=[DD_SizeAlertModel mj_objectWithKeyValues:dict];
    _SizeAlertModel.size=[DD_SizeModel getSizeModelArr:[dict objectForKey:@"size"]];//获取item model数组
    return _SizeAlertModel;
}
/**
 * 获取解析数组
 */
+(NSArray *)getSizeAlertModelArr:(NSArray *)arr
{
    NSMutableArray *itemsArr=[[NSMutableArray alloc] init];
    [arr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        [itemsArr addObject:[self getSizeAlertModel:dict]];
    }];

    return itemsArr;
}
@end
