//
//  DD_StartView.h
//  YCO SPACE
//
//  Created by yyj on 16/9/30.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_BaseView.h"

@interface DD_StartView : DD_BaseView

-(instancetype)initWithBlock:(void (^)(NSString *type))block;

@property (nonatomic,copy) void (^block)(NSString *type);

@end
