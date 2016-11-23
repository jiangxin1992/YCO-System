//
//  DD_CircleDetailHeadView.h
//  DDAY
//
//  Created by yyj on 16/6/23.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DD_OrderItemModel;
@class DD_CircleListModel;

@interface DD_CircleDetailHeadView : UIView

/**
 * 初始化
 */
-(instancetype)initWithCircleListModel:(DD_CircleListModel *)model IsHomePage:(BOOL )isHomePage WithBlock:(void (^)(NSString *type,NSInteger index,DD_OrderItemModel *item))block;

+ (CGFloat)heightWithModel:(DD_CircleListModel *)model;

/**
 * 更新
 */
-(void)setState;

/**
 * 更新
 */
//-(void)update;

/** 搭配model*/
@property (nonatomic,strong) DD_CircleListModel *listModel;

/** 回调block*/
@property(nonatomic,copy) void (^block)(NSString *type,NSInteger index,DD_OrderItemModel *item);

__view(contentView);

__label(timeLabel);

__bool(isHomePage);

@end
