//
//  DD_ShowRoomModel.m
//  YCO SPACE
//
//  Created by yyj on 16/8/19.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_ShowRoomModel.h"

#import "DD_ImageModel.h"

@implementation DD_ShowRoomModel
+(DD_ShowRoomModel *)getShowRoomModel:(NSDictionary *)dict
{
    DD_ShowRoomModel *_ShowRoomModel=[DD_ShowRoomModel mj_objectWithKeyValues:dict];
    _ShowRoomModel.s_id=[[NSString alloc] initWithFormat:@"%lld",[[dict objectForKey:@"id"] longLongValue]];
    _ShowRoomModel.pics=[DD_ImageModel getImageModelArr:[dict objectForKey:@"pics"]];
    _ShowRoomModel.listImg=[DD_ImageModel getImageModel:[dict objectForKey:@"picInfo"]];
    return _ShowRoomModel;
}
+(NSArray *)getShowRoomModelArr:(NSArray *)arr
{
    NSMutableArray *itemsArr=[[NSMutableArray alloc] init];
    [arr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        [itemsArr addObject:[self getShowRoomModel:dict]];
    }];

    return itemsArr;
}
@end
