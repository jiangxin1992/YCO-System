//
//  DD_UserMessageHeadView.m
//  YCO SPACE
//
//  Created by yyj on 16/9/14.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_UserMessageHeadView.h"

#import "DD_UserMessageModel.h"

@implementation DD_UserMessageHeadView
{
    UILabel *_title;
    UIImageView *_redCircle;
    UIButton *_notBtn;
    UIButton *_pulldownBtn;
}

-(instancetype)initWithFrame:(CGRect)frame WithUserMessageModel:(DD_UserMessageModel *)messageModel WithSection:(NSInteger )section  WithBlock:(void(^)(NSString *type,NSInteger section))block
{
    self=[super initWithFrame:frame];
    if(self)
    {
        _messageModel=messageModel;
        _block=block;
        _section=section;
        self.backgroundColor=_define_white_color;
        self.userInteractionEnabled=YES;
//        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAction:)]];
        [self bk_whenTapped:^{
            _block(@"click",_section);
        }];
        _title=[UILabel getLabelWithAlignment:0 WithTitle:_messageModel.messageCategory WithFont:15.0f WithTextColor:nil WithSpacing:0];
        [self addSubview:_title];
        [_title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kEdge);
            make.centerY.mas_equalTo(self);
        }];
        if(!_pulldownBtn)
        {
            _pulldownBtn = [UIButton getCustomBackImgBtnWithImageStr:@"System_Triangle" WithSelectedImageStr:@"System_UpTriangle"];
        }
        [self addSubview:_pulldownBtn];
        _pulldownBtn.userInteractionEnabled=NO;
        _pulldownBtn.selected=_messageModel.is_expand;
        [_pulldownBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-kEdge);
            make.centerY.mas_equalTo(self);
            make.height.mas_equalTo(14);
            make.width.mas_equalTo(15);
        }];
        
        if(_messageModel.isNotice)
        {
            // 23 18
            if(!_notBtn)
            {
                _notBtn=[UIButton getCustomBackImgBtnWithImageStr:@"User_Trumpet_Normal" WithSelectedImageStr:@"User_Trumpet_Select"];
            }
            [self addSubview:_notBtn];
            [_notBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(_title.mas_right).with.offset(6);
                make.centerY.mas_equalTo(_title.mas_centerY);
                make.height.mas_equalTo(18);
                make.width.mas_equalTo(25);
            }];
            if(_messageModel.unReadMessageNumber)
            {
                _notBtn.selected=YES;
            }else
            {
                _notBtn.selected=NO;
            }
        }else
        {
            _redCircle=[UIImageView getCustomImg];
            [self addSubview:_redCircle];
            _redCircle.layer.masksToBounds=YES;
            _redCircle.layer.cornerRadius=3;
            _redCircle.backgroundColor=_define_light_red_color;
            if(_messageModel.readStatus)
            {
                _redCircle.hidden=YES;
            }else
            {
                _redCircle.hidden=NO;
            }
            [_redCircle mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(_title.mas_right).with.offset(7);
                make.bottom.mas_equalTo(_title.mas_top).with.offset(0);
                make.width.height.mas_equalTo(6);
            }];
        }
        
    }
    return self;
}
//-(void)clickAction:(UIGestureRecognizer *)ges
//{
//    _block(@"click",_section);
//}
@end
