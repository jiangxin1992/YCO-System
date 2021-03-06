//
//  DD_GoodsListTableView.h
//  YCO SPACE
//
//  Created by yyj on 16/8/1.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DD_GoodsListTableView : UITableView

__array(categoryArr);

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style WithBlock:(void (^)(NSString *type,NSString *categoryOneName,NSString *categoryTwoName,NSString *categoryID))block;

@property(nonatomic,copy) void (^block)(NSString *type,NSString *categoryOneName,NSString *categoryTwoName,NSString *categoryID);

@end
