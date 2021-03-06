//
//  DD_ShopEditingCell.h
//  DDAY
//
//  Created by yyj on 16/5/27.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_BaseCell.h"

@class DD_ShopModel;
@class DD_ShopItemModel;

@interface DD_ShopEditingCell : DD_BaseCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellForRowAtIndexPath:(NSIndexPath *)indexPath WithBlock:(void(^)(NSString *type,NSIndexPath *indexPath,DD_ShopModel *shopModel))block;

@property (nonatomic,strong)DD_ShopModel *shopModel;

@property (nonatomic,strong)DD_ShopItemModel *ItemModel;

@property (nonatomic,copy) void (^clickblock)(NSString *type,NSIndexPath *indexPath,DD_ShopModel *shopModel);

@property (nonatomic,strong)NSIndexPath *indexPath;

@end
