//
//  DD_DesignerModel.m
//  DDAY
//
//  Created by yyj on 16/5/22.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_DesignerModel.h"

#import "DD_ImageModel.h"

@implementation DD_DesignerModel
+(DD_DesignerModel *)getDesignerModel:(NSDictionary *)dict
{
    DD_DesignerModel *_DesignerModel=[DD_DesignerModel mj_objectWithKeyValues:dict];
    _DesignerModel.items=[DD_ImageModel getImageModelArr:[dict objectForKey:@"items"]];
    return _DesignerModel;
}
+(NSArray *)getDesignerModelArr:(NSArray *)arr
{
    NSMutableArray *itemsArr=[[NSMutableArray alloc] init];
    [arr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        [itemsArr addObject:[self getDesignerModel:dict]];
    }];

    return itemsArr;
}
@end
