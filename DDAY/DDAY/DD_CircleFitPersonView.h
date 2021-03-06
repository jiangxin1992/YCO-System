//
//  DD_CircleFitPersonView.h
//  DDAY
//
//  Created by yyj on 16/6/15.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_BaseView.h"

@class DD_CircleModel;

@interface DD_CircleFitPersonView : DD_BaseView

/**
 * 初始化
 */
-(instancetype)initWithCircleModel:(DD_CircleModel *)CircleModel WithBlock:(void (^)(NSString *type,long tag))block;

/**
 * 重新设置当前视图
 */
-(void)setState;

@property (nonatomic,strong) DD_CircleModel *circleModel;

/** 回调block*/
@property(nonatomic,copy) void (^block)(NSString *type,long tag);

@end
