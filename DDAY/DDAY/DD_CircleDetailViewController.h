//
//  DD_CircleDetailViewController.h
//  DDAY
//
//  Created by yyj on 16/6/22.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_BaseViewController.h"

@class DD_CircleListModel;

@interface DD_CircleDetailViewController : DD_BaseViewController

/**
 * 初始化 根据shareId
 */
-(instancetype)initWithCircleListModel:(DD_CircleListModel *)ListModel WithShareID:(NSString *)ShareID IsHomePage:(BOOL )isHomePage WithBlock:(void (^)(NSString *type))block;

/** 搭配list model*/
@property (nonatomic,strong)DD_CircleListModel *ListModel;

/** 搭配ID*/
__string(ShareID);

/** 是否从主页进入*/
__bool(isHomePage);

/** 回调block*/
__block_type(block, type);

@end
