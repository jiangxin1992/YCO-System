//
//  DD_OrderLogisticsCell.h
//  YCO SPACE
//
//  Created by yyj on 16/8/24.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TTTAttributedLabel.h"

#import "DD_OrderLogisticsModel.h"

@interface DD_OrderLogisticsCell : UITableViewCell<TTTAttributedLabelDelegate>

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithBlock:(void(^)(NSString *type,NSString *phoneNum))block;

+ (CGFloat)heightWithModel:(DD_OrderLogisticsModel *)model;

@property(nonatomic,copy) void (^block)(NSString *type,NSString *phoneNum);
__view(downLine);

@property (nonatomic,strong)DD_OrderLogisticsModel *logisticsModel;
-(void)setLogisticsModel:(DD_OrderLogisticsModel *)logisticsModel IsFirst:(BOOL )isFirst IsLast:(BOOL )isLast;
@end