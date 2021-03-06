//
//  DD_ShopTool.m
//  DDAY
//
//  Created by yyj on 16/5/27.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_ShopTool.h"

#import "DD_ShopModel.h"
#import "DD_ShopItemModel.h"
#import "DD_ShopSeriesModel.h"

@implementation DD_ShopTool
+(void)removeItemModelWithIndexPath:(NSIndexPath *)indexPath WithModel:(DD_ShopModel *)ShopModel
{
    NSInteger Section=indexPath.section;
    NSInteger _seriesNormalCount=ShopModel.seriesNormal.count;
    NSInteger _seriesInvalidCount=_seriesNormalCount+ShopModel.seriesInvalid.count;
    if(Section<_seriesNormalCount)
    {
        //        处于上架中（发布中/发布结束中）
        DD_ShopSeriesModel *_SeriesModel=ShopModel.seriesNormal[Section];
        NSMutableArray *itemArr=[[NSMutableArray alloc] initWithArray:_SeriesModel.items];
        [itemArr removeObjectAtIndex:indexPath.row];
        if(itemArr.count)
        {
            _SeriesModel.items=itemArr;
        }else
        {
            [regular dispatch_cancel:_SeriesModel.timer];
            NSMutableArray *seriesArr=[[NSMutableArray alloc] initWithArray:ShopModel.seriesNormal];
            [seriesArr removeObjectAtIndex:Section];
            ShopModel.seriesNormal=seriesArr;
        }
        
    }else if(Section<_seriesInvalidCount)
    {
        //        处于下架处
        DD_ShopSeriesModel *_SeriesModel=ShopModel.seriesInvalid[_seriesInvalidCount-Section-1];
        NSMutableArray *itemArr=[[NSMutableArray alloc] initWithArray:_SeriesModel.items];
        [itemArr removeObjectAtIndex:indexPath.row];
        if(itemArr.count)
        {
            _SeriesModel.items=itemArr;
        }else
        {
            [regular dispatch_cancel:_SeriesModel.timer];
            NSMutableArray *seriesArr=[[NSMutableArray alloc] initWithArray:ShopModel.seriesInvalid];
            [seriesArr removeObjectAtIndex:_seriesInvalidCount-Section-1];
            ShopModel.seriesInvalid=seriesArr;
        }
        
    }
}

+(void)setItemModelWithIndexPath:(NSIndexPath *)indexPath WithModel:(DD_ShopModel *)ShopModel WithItemModel:(DD_ShopItemModel *)ItemModel
{
    
    NSInteger Section=indexPath.section;
    NSInteger _seriesNormalCount=ShopModel.seriesNormal.count;
    NSInteger _seriesInvalidCount=_seriesNormalCount+ShopModel.seriesInvalid.count;
    if(Section<_seriesNormalCount)
    {
        //        处于上架中（发布中/发布结束中）
        DD_ShopSeriesModel *_SeriesModel=ShopModel.seriesNormal[Section];
        NSMutableArray *itemArr=[[NSMutableArray alloc] initWithArray:_SeriesModel.items];
        itemArr[indexPath.row]=ItemModel;
        _SeriesModel.items=itemArr;
        
    }else if(Section<_seriesInvalidCount)
    {
        //        处于上架中（发布中/发布结束中）
        DD_ShopSeriesModel *_SeriesModel=ShopModel.seriesInvalid[_seriesInvalidCount-Section-1];
        NSMutableArray *itemArr=[[NSMutableArray alloc] initWithArray:_SeriesModel.items];
        itemArr[indexPath.row]=ItemModel;
        _SeriesModel.items=itemArr;

    }
}

+(BOOL)isInvalidWithSection:(NSInteger )section WithModel:(DD_ShopModel *)ShopModel
{
    NSInteger _seriesNormalCount=ShopModel.seriesNormal.count;
    NSInteger _seriesInvalidCount=_seriesNormalCount+ShopModel.seriesInvalid.count;
    if(section<_seriesNormalCount)
    {
        //        处于上架中（发布中/发布结束中）
        return NO;
        
    }else if(section<_seriesInvalidCount)
    {
        //        处于下架处
        
        return YES;
        
    }
    return NO;
}
+(DD_ShopItemModel *)getNumberOfRowsIndexPath:(NSIndexPath *)indexPath WithModel:(DD_ShopModel *)ShopModel
{
    NSInteger Section=indexPath.section;
    NSInteger _seriesNormalCount=ShopModel.seriesNormal.count;
    NSInteger _seriesInvalidCount=_seriesNormalCount+ShopModel.seriesInvalid.count;
    if(Section<_seriesNormalCount)
    {
        //        处于上架中（发布中/发布结束中）
        DD_ShopSeriesModel *_SeriesModel=ShopModel.seriesNormal[Section];
        return _SeriesModel.items[indexPath.row];
        
    }else if(Section<_seriesInvalidCount)
    {
        //        处于下架处
        DD_ShopSeriesModel *_SeriesModel=ShopModel.seriesInvalid[_seriesInvalidCount-Section-1];
        return _SeriesModel.items[indexPath.row];
        
    }
    return nil;
}
+(void)selectAllWithModel:(DD_ShopModel *)ShopModel WithSelect:(BOOL )is_select
{

    [ShopModel.seriesNormal enumerateObjectsUsingBlock:^(DD_ShopSeriesModel *_SeriesModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [_SeriesModel.items enumerateObjectsUsingBlock:^(DD_ShopItemModel *item, NSUInteger idx2, BOOL * _Nonnull stop2) {
            item.is_select=is_select;
        }];
    }];
}
+(NSString *)getAllPriceWithModel:(DD_ShopModel *)ShopModel
{
    __block CGFloat _price=0;
    [ShopModel.seriesNormal enumerateObjectsUsingBlock:^(DD_ShopSeriesModel *_SeriesModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [_SeriesModel.items enumerateObjectsUsingBlock:^(DD_ShopItemModel *item, NSUInteger idx2, BOOL * _Nonnull stop2) {
            if(item.is_select)
            {
                _price+=[item getPrice]*[item.number integerValue];
            }
        }];
    }];
    [ShopModel.seriesInvalid enumerateObjectsUsingBlock:^(DD_ShopSeriesModel *_SeriesModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [_SeriesModel.items enumerateObjectsUsingBlock:^(DD_ShopItemModel *item, NSUInteger idx2, BOOL * _Nonnull stop2) {
            if(item.is_select)
            {
                _price+=[item getPrice]*[item.number integerValue];
            }
        }];
    }];
    return [[NSString alloc] initWithFormat:@"总计￥%@",[regular getRoundNum:_price]];
}
+(NSArray *)getConfirmArrWithModel:(DD_ShopModel *)ShopModel
{
    NSMutableArray *confrimArr=[[NSMutableArray alloc] init];
    
    [ShopModel.seriesNormal enumerateObjectsUsingBlock:^(DD_ShopSeriesModel *_SeriesModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [_SeriesModel.items enumerateObjectsUsingBlock:^(DD_ShopItemModel *item, NSUInteger idx2, BOOL * _Nonnull stop2) {
            if(item.is_select)
            {
                [confrimArr addObject:@{@"itemId":item.itemId,@"colorId":item.colorId,@"colorCode":item.colorCode,@"sizeId":item.sizeId,@"number":item.number,@"price":[[NSString alloc] initWithFormat:@"%@",[regular getRoundNum:[item getPrice]]]}];
            }
        }];
    }];
    
    [ShopModel.seriesInvalid enumerateObjectsUsingBlock:^(DD_ShopSeriesModel *_SeriesModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [_SeriesModel.items enumerateObjectsUsingBlock:^(DD_ShopItemModel *item, NSUInteger idx2, BOOL * _Nonnull stop2) {
            if(item.is_select)
            {
                [confrimArr addObject:@{@"itemId":item.itemId,@"colorId":item.colorId,@"sizeId":item.sizeId,@"number":@"1",@"price":[[NSString alloc] initWithFormat:@"%@",[regular getRoundNum:[item getPrice]]]}];
            }
        }];
    }];

    return confrimArr;
    
}
+(void)selectAllWithModel:(DD_ShopModel *)ShopModel WithSelect:(BOOL )is_select WithSection:(NSInteger)section
{
    NSInteger _seriesNormal=ShopModel.seriesNormal.count;
    NSInteger _seriesInvalidCount=_seriesNormal+ShopModel.seriesInvalid.count;
    if(section<_seriesNormal)
    {
        //        处于上架中（发布中/发布结束中）
        DD_ShopSeriesModel *_SeriesModel=ShopModel.seriesNormal[section];
        [_SeriesModel.items enumerateObjectsUsingBlock:^(DD_ShopItemModel *item, NSUInteger idx, BOOL * _Nonnull stop) {
            item.is_select=is_select;
        }];

    }else if(section<_seriesInvalidCount)
    {
        //        处于下架处
        DD_ShopSeriesModel *_SeriesModel=ShopModel.seriesInvalid[_seriesInvalidCount-section-1];
        [_SeriesModel.items enumerateObjectsUsingBlock:^(DD_ShopItemModel *item, NSUInteger idx, BOOL * _Nonnull stop) {
            item.is_select=is_select;
        }];

    }
}
+(BOOL)selectAllWithModel:(DD_ShopModel *)ShopModel WithSection:(NSInteger)section
{
    __block BOOL isSelect=YES;
    NSInteger _seriesNormal=ShopModel.seriesNormal.count;
    NSInteger _seriesInvalidCount=_seriesNormal+ShopModel.seriesInvalid.count;
    if(section<_seriesNormal)
    {
        //        处于上架中（发布中/发布结束中）
        DD_ShopSeriesModel *_SeriesModel=ShopModel.seriesNormal[section];
        [_SeriesModel.items enumerateObjectsUsingBlock:^(DD_ShopItemModel *item, NSUInteger idx, BOOL * _Nonnull stop) {
            if(!item.is_select)
            {
                isSelect=NO;
                *stop=YES;
            }
        }];

    }else if(section<_seriesInvalidCount)
    {
        //        处于下架处
        DD_ShopSeriesModel *_SeriesModel=ShopModel.seriesInvalid[_seriesInvalidCount-section-1];
        [_SeriesModel.items enumerateObjectsUsingBlock:^(DD_ShopItemModel *item, NSUInteger idx, BOOL * _Nonnull stop) {
            if(!item.is_select)
            {
                isSelect=NO;
                *stop=YES;
            }
        }];

    }
    return isSelect;
}
+(BOOL)selectAllWithModel:(DD_ShopModel *)ShopModel
{
    if(ShopModel.seriesNormal.count)
    {
        __block BOOL isSelect=YES;
        [ShopModel.seriesNormal enumerateObjectsUsingBlock:^(DD_ShopSeriesModel *_SeriesModel, NSUInteger idx, BOOL * _Nonnull stop) {
            [_SeriesModel.items enumerateObjectsUsingBlock:^(DD_ShopItemModel *item, NSUInteger idx2, BOOL * _Nonnull stop2) {
                if(!item.is_select)
                {
                    isSelect=NO;
                    *stop=YES;
//                    *stop2=YES;
                }
            }];
        }];

        return isSelect;
    }else
    {
        return NO;
    }
}
+(DD_ShopSeriesModel *)getNumberSection:(NSInteger )section WithModel:(DD_ShopModel *)ShopModel
{
    NSInteger _seriesNormal=ShopModel.seriesNormal.count;
    NSInteger _seriesInvalidCount=_seriesNormal+ShopModel.seriesInvalid.count;
    if(section<_seriesNormal)
    {
        //        处于上架中（发布中/发布结束中）
        return ShopModel.seriesNormal[section];
        
        
    }else if(section<_seriesInvalidCount)
    {
        //        处于下架处
        return ShopModel.seriesInvalid[_seriesInvalidCount-section-1];
        
    }
    return nil;
}
+(NSInteger )getSectionNumWithModel:(DD_ShopModel *)ShopModel
{
    return ShopModel.seriesNormal.count+ShopModel.seriesInvalid.count;
}
+(NSInteger )getNumberOfRowsInSection:(NSInteger )Section WithModel:(DD_ShopModel *)ShopModel
{
    NSInteger _seriesNormal=ShopModel.seriesNormal.count;
    NSInteger _seriesInvalidCount=_seriesNormal+ShopModel.seriesInvalid.count;
    if(Section<_seriesNormal)
    {
//        处于上架中（发布中/发布结束中）
        DD_ShopSeriesModel *_SeriesModel=ShopModel.seriesNormal[Section];
        return _SeriesModel.items.count;
        
    }else if(Section<_seriesInvalidCount)
    {
//        处于下架处
        DD_ShopSeriesModel *_SeriesModel=ShopModel.seriesInvalid[_seriesInvalidCount-Section-1];
        return _SeriesModel.items.count;
        
    }
    return 0;
}
+(NSInteger )getInvalidSectionNum:(DD_ShopModel *)ShopModel
{
    
    if(ShopModel.seriesNormal.count)
    {
        return ShopModel.seriesNormal.count-1;
    }
    return 0;
}
+(UIView *)getViewFooter
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    view.backgroundColor =  _define_clear_color;
    UIView *backview=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 38)];
    [view addSubview:backview];
    backview.backgroundColor= _define_clear_color;
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(20,0, ScreenWidth-40, 38)];
    [backview addSubview:label];
    label.textColor=_define_black_color;
    label.textAlignment=1;
    
    label.text=@"失效款式";
    
    return view;
}



@end
