//
//  DD_ClearingViewController.h
//  DDAY
//
//  Created by yyj on 16/5/18.
//  Copyright © 2016年 mike_xie. All rights reserved.
//

#import "DD_BaseViewController.h"

@class DD_ClearingView;
@class DD_ClearingModel;

@interface DD_ClearingViewController : DD_BaseViewController

/**
 * 结算页面初始化
 * _model:结算界面数据
 */
-(instancetype)initWithModel:(DD_ClearingModel *)_model WithBlock:(void (^)(NSString *type,NSDictionary *resultDic))block;

/** 结算界面数据*/
@property (nonatomic,strong)DD_ClearingModel *Clearingmodel;

/** 结算回调*/
@property (nonatomic,copy)void(^successblock)(NSString *type,NSDictionary *resultDic);

@property (nonatomic,strong)DD_ClearingView *ClearingView;

@end


