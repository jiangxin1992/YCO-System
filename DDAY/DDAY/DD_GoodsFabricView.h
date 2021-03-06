//
//  DD_GoodsFabricView.h
//  YCO SPACE
//
//  Created by yyj on 16/7/30.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_BaseView.h"

@class DD_GoodsItemModel;

@interface DD_GoodsFabricView : DD_BaseView

-(instancetype)initWithGoodsItem:(DD_GoodsItemModel *)item WithBlock:(void (^)(NSString *type))block;

__block_type(block, type);

__bool(is_show);

@property (nonatomic,strong)DD_GoodsItemModel *item;

@end
