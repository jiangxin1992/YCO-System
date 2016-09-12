//
//  DD_GoodK-POINTView.h
//  YCO SPACE
//
//  Created by yyj on 16/7/30.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DD_ShowRoomModel.h"

@interface DD_GoodsK_POINTView : UIView

-(instancetype)initWithShowRoomModelArr:(NSArray *)showroomArr WithBlock:(void (^)(NSString *type,DD_ShowRoomModel *model))block;

__array(showroomArr);
__bool(is_show);
@property(nonatomic,copy) void (^block)(NSString *type,DD_ShowRoomModel *model);

@end
