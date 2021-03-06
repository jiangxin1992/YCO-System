//
//  DD_CircleListImgView.h
//  DDAY
//
//  Created by yyj on 16/6/21.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_BaseView.h"

@class DD_CircleListModel;

@interface DD_CircleListImgView : DD_BaseView

/**
 * 初始化
 */
-(instancetype)initWithCircleListModel:(DD_CircleListModel *)model WithBlock:(void (^)(NSString *type))block;

/**
 * 更新
 */
-(void)setState;

/** 搭配model*/
@property (nonatomic,strong) DD_CircleListModel *detailModel;

/** 回调block*/
__block_type(block, type);

@end
