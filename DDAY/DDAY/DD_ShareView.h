//
//  DD_ShareView.h
//  YCO SPACE
//
//  Created by yyj on 16/8/22.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_BaseView.h"

@class DD_BenefitInfoModel;

@interface DD_ShareView : DD_BaseView 

-(instancetype)initWithType:(NSString *)type WithParams:(NSDictionary *)params WithBlock:(void(^)(NSString *type,DD_BenefitInfoModel *model))block;
//-(instancetype)initWithTitle:(NSString *)title Content:(NSString *)content WithImg:(NSString *)img WithUrl:(NSString *)url WithBlock:(void(^)(NSString *type))block;

@property (nonatomic,copy) void (^block)(NSString *type,DD_BenefitInfoModel *model);

/** 分享标题*/
__string(title);

/** 分享内容*/
__string(content);

/** 分享图片*/
__string(img);

/** 分享url*/
__string(url);

/** 类型*/
__string(type);

/** 参数*/
__dict(params);

@end
