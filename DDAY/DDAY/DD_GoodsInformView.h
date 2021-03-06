//
//  DD_GoodInformView.h
//  DDAY
//
//  Created by yyj on 16/5/23.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_BaseView.h"

@class DD_GoodsDetailModel;

@interface DD_GoodsInformView : DD_BaseView

-(instancetype)initWithGoodsDetailModel:(DD_GoodsDetailModel *)model WithBlock:(void (^)(NSString *type))block;

-(void)setState;

@property (nonatomic,strong) DD_GoodsDetailModel *detailModel;

@property (nonatomic,copy) void (^block)(NSString *type);

@end
