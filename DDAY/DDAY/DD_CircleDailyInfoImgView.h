//
//  DD_CircleDailyInfoImgView.h
//  YCO SPACE
//
//  Created by yyj on 16/9/13.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_BaseView.h"

@class DD_CircleModel;

@interface DD_CircleDailyInfoImgView : DD_BaseView

/**
 * 初始化
 */
-(instancetype)initWithCircleModel:(DD_CircleModel *)CircleModel WithBlock:(void (^)(NSString *type,NSInteger index))block;

/**
 * 重新设置当前视图
 */
-(void)setState;

/** 搭配图片*/
@property (nonatomic,strong) DD_CircleModel *circleModel;

/** 回调block*/
@property(nonatomic,copy) void (^block)(NSString *type,NSInteger index);

@end
