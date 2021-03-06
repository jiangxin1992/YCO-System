//
//  DD_CircleCommentSignBoard.h
//  DDAY
//
//  Created by yyj on 16/6/23.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_BaseView.h"

@interface DD_CircleCommentSignBoard : DD_BaseView

/**
 * 初始化
 */
-(instancetype)initWithBlock:(void (^)(NSString *type, NSString *content,CGFloat height))block;

/** 回调block*/
@property(nonatomic,copy) void (^block)(NSString *type, NSString *content,CGFloat height);

/** 输入框 用于外部调用文本框内容*/
@property (nonatomic,strong) UITextView *commentField;

@end
