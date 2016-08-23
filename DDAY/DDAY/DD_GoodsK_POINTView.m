//
//  DD_GoodK-POINTView.m
//  YCO SPACE
//
//  Created by yyj on 16/7/30.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_GoodsK_POINTView.h"

@implementation DD_GoodsK_POINTView
{
    NSMutableArray *viewArr;
    
    MASConstraint *_hide;
    MASConstraint *_show;
    
    UIButton *backBtn;
    UILabel *label;
    UIView *lastView;
}
#pragma mark - 初始化

-(instancetype)initWithShowRoomModelArr:(NSArray *)showroomArr WithBlock:(void (^)(NSString *type))block
{
    self=[super init];
    if(self)
    {
        _block=block;
        _showroomArr=showroomArr;
        [self PrepareData];
        [self UIConfig];
    }
    return self;
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData
{
    viewArr=[[NSMutableArray alloc] init];
}
-(void)PrepareUI{}
#pragma mark - UIConfig
-(void)UIConfig
{
    backBtn=[UIButton getCustomBtn];
    [self addSubview:backBtn];
    [backBtn addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    UIView *view=[UIView getCustomViewWithColor:_define_black_color];
    [backBtn addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.and.right.mas_equalTo(view.superview).with.offset(0);
        make.bottom.mas_equalTo(view.superview).with.offset(-1);
    }];
    
    label=[UILabel getLabelWithAlignment:0 WithTitle:NSLocalizedString(@"goods_detail_k_ponit", nil) WithFont:13.0f WithTextColor:_define_black_color WithSpacing:0];
    [backBtn addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kEdge);
        make.right.mas_equalTo(-kEdge);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(38);
    }];
    
//    DD_ShowRoomModel.h
    
    for (DD_ShowRoomModel *model in _showroomArr) {
        UIView *backView=[UIView getCustomViewWithColor:nil];
        [backBtn addSubview:backView];
        [viewArr addObject:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            if(lastView)
            {
                make.top.mas_equalTo(lastView.mas_bottom).with.offset(6);
            }else
            {
                make.top.mas_equalTo(label.mas_bottom).with.offset(10);
            }
            make.left.right.mas_equalTo(0);
        }];
        
        UIImageView *_head=[UIImageView getImgWithImageStr:@"System_showroom"];
        [backView addSubview:_head];
        [_head mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kEdge);
            make.top.mas_equalTo(0);
            make.width.height.mas_equalTo(23);
        }];
        
        UILabel *storeName=[UILabel getLabelWithAlignment:0 WithTitle:model.storeName WithFont:12.0f WithTextColor:nil WithSpacing:0];
        [backView addSubview:storeName];
        [storeName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_head.mas_right).with.offset(10);
            make.bottom.mas_equalTo(_head);
        }];
        [storeName sizeToFit];
        
        UILabel *address=[UILabel getLabelWithAlignment:0 WithTitle:model.address WithFont:12.0f WithTextColor:nil WithSpacing:0];
        [backView addSubview:address];
        address.numberOfLines=1;
        [address mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kEdge);
            make.right.mas_equalTo(-kEdge);
            make.top.mas_equalTo(_head.mas_bottom).with.offset(6);
            make.bottom.mas_equalTo(backView.mas_bottom).with.offset(-6);
        }];
        [address sizeToFit];
        
        lastView=backView;
    }
    
}
#pragma mark - SomeAction
-(void)setIs_show:(BOOL)is_show
{
    _is_show=is_show;
    for (UIView *view in viewArr) {
        view.hidden=!is_show;
    }
    if(_is_show)
    {
        [_hide uninstall];
        [lastView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(backBtn.mas_bottom).with.offset(-10);
        }];
    }else
    {
        [_show uninstall];
        [label mas_updateConstraints:^(MASConstraintMaker *make) {
            _hide=make.bottom.mas_equalTo(backBtn.mas_bottom).with.offset(0);
        }];
    }
}
-(void)clickAction
{
    _block(@"click");
}
@end
