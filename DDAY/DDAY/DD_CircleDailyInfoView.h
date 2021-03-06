//
//  DD_CircleDailyInfoView.h
//  YCO SPACE
//
//  Created by yyj on 16/9/13.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_BaseView.h"

@class DD_CircleInfoSuggestView;
@class DD_CircleDailyInfoImgView;
@class DD_CircleModel;

@interface DD_CircleDailyInfoView : DD_BaseView

/**
 * 初始化
 */
-(instancetype)initWithCircleModel:(DD_CircleModel *)model WithBlock:(void (^)(NSString *type,long index))block;

/** 搭配建议*/
@property (nonatomic,strong) DD_CircleInfoSuggestView *commentview;

/** 搭配图*/
@property (nonatomic,strong) DD_CircleDailyInfoImgView *imgView;

/** 发布视图model/管理*/
@property (nonatomic,strong)DD_CircleModel *CircleModel;

/** 回调block*/
@property(nonatomic,copy) void (^block)(NSString *type,long index);

@end
