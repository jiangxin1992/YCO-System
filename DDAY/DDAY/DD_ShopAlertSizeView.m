//
//  DD_ShopAlertSizeView.m
//  YCO SPACE
//
//  Created by yyj on 16/8/2.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_ShopAlertSizeView.h"

#import "DD_SizeModel.h"
#import "DD_ShopItemModel.h"
#import "DD_SizeAlertModel.h"

@implementation DD_ShopAlertSizeView
{
    NSMutableArray *_sizeBtnArr;
    NSString *_sizeID;
    NSString *_sizeName;
    NSInteger _count;
    
    UILabel *warnLabel;
    
}

#pragma mark - 初始化
-(instancetype)initWithSizeAlertModel:(DD_SizeAlertModel *)SizeAlertModel WithItem:(DD_ShopItemModel *)ItemModel WithBlock:(void (^)(NSString *type,NSString *sizeId,NSString *sizeName,NSInteger count))block
{
    
    self=[super init];
    if(self)
    {
        _SizeAlertModel=SizeAlertModel;
        _block=block;
        _ItemModel=ItemModel;
        _sizeID=_ItemModel.sizeId;
        _count=[_ItemModel.number integerValue];
        [self SomePrepare];
        [self UIConfig];
    }
    return self;
}
//-(void)NULLAction{}
+(CGFloat )getHeightWithSizeAlertModel:(DD_SizeAlertModel *)SizeAlertModel WithItem:(DD_ShopItemModel *)ItemModel
{
    DD_ShopAlertSizeView *_sizeView = [[DD_ShopAlertSizeView alloc] initWithSizeAlertModel:SizeAlertModel WithItem:ItemModel WithBlock:^(NSString *type, NSString *sizeId, NSString *sizeName, NSInteger count) {
        
    }];
    [_sizeView layoutIfNeeded];
    CGRect frame =  _sizeView.confirmBtn.frame;
    return frame.origin.y + frame.size.height;
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData
{
    _sizeBtnArr=[[NSMutableArray alloc] init];
}
-(void)PrepareUI
{
    self.userInteractionEnabled=YES;
//    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(NULLAction)]];
    [self bk_whenTapped:^{
//        NULLAction
    }];
    self.backgroundColor=_define_white_color;
}
#pragma mark - UIConfig
-(void)UIConfig
{
    
//    [regular getRoundNum:[_ItemModel getPrice]]
    UILabel *priceLabel=[UILabel getLabelWithAlignment:0 WithTitle:[[NSString alloc] initWithFormat:@"￥%@",[regular getRoundNum:[_ItemModel getPrice]]] WithFont:15.0f WithTextColor:_define_black_color WithSpacing:0];
    [self addSubview:priceLabel];
    priceLabel.font=[regular getSemiboldFont:15.0f];
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(18);
        make.left.mas_equalTo(kEdge);
    }];
    
    warnLabel=[UILabel getLabelWithAlignment:0 WithTitle:@"库存紧张" WithFont:12.0f WithTextColor:_define_light_red_color WithSpacing:0];
    [self addSubview:warnLabel];
    [warnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(priceLabel.mas_right).with.offset(10);
        make.centerY.mas_equalTo(priceLabel);
    }];
    warnLabel.hidden=YES;
    
    __block UIView *lastView=nil;
    // 间距为10
    __block int intes = 10;
    __block int num = 0;
    __block CGFloat _x_p=kEdge;
    [_SizeAlertModel.size enumerateObjectsUsingBlock:^(DD_SizeModel *_sizeModel, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *_btn=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:17.0f WithSpacing:0 WithNormalTitle:_sizeModel.sizeName WithNormalColor:nil WithSelectedTitle:_sizeModel.sizeName WithSelectedColor:_define_white_color];
        [self addSubview:_btn];
        
        if(_sizeModel.stock)
        {
            [_btn setTitleColor:_define_black_color forState:UIControlStateNormal];
            _btn.backgroundColor=_define_white_color;
            _btn.userInteractionEnabled=YES;
            [regular setBorder:_btn];
            if([_sizeModel.sizeId isEqualToString:_ItemModel.sizeId])
            {
                if(_sizeModel.stock<=2)
                {
                    warnLabel.hidden=NO;
                }else
                {
                    warnLabel.hidden=YES;
                }
                _btn.selected=YES;
                [_btn setBackgroundColor:_define_black_color];
                
            }else
            {
                _btn.selected=NO;
                [_btn setBackgroundColor:_define_white_color];
            }
        }else
        {
            [_btn setTitleColor:_define_light_gray_color1 forState:UIControlStateNormal];
            _btn.backgroundColor=_define_white_color;
            _btn.userInteractionEnabled=YES;
        }
        [_sizeBtnArr addObject:_btn];
        _btn.tag=100+idx;
        [_btn addTarget:self action:@selector(chooseSizeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat __width=[regular getWidthWithHeight:28 WithContent:_sizeModel.sizeName WithFont:[regular getFont:13.0f]]+25;
        if((_x_p+__width+intes)>ScreenWidth-kEdge)
        {
            num++;
            _x_p=kEdge;
        }
        
        [_btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(priceLabel.mas_bottom).offset(23+35*num);
            make.left.mas_equalTo(_x_p);
            make.width.mas_equalTo(__width);
            make.height.mas_equalTo(28);
        }];
        if((_x_p+__width+intes)>ScreenWidth-kEdge)
        {
        }else
        {
            _x_p+=__width+intes;
        }
        //        [_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        //            if(lastView)
        //            {
        //                make.left.mas_equalTo(lastView.mas_right).with.offset(23);
        //            }else
        //            {
        //                make.left.mas_equalTo(kEdge);
        //            }
        //            make.top.mas_equalTo(IsPhone6_gt?25:15);
        //            make.width.mas_equalTo(28);
        //            make.height.mas_equalTo(28);
        //        }];
        lastView=_btn;
    }];
    
    UIImageView *sizeBriefImg=nil;
    if(_SizeAlertModel.sizeBriefPic&&![_SizeAlertModel.sizeBriefPic isEqualToString:@""])
    {
        CGFloat _imgHeight=(((CGFloat)_SizeAlertModel.sizeBriefPicHeight)/((CGFloat)_SizeAlertModel.sizeBriefPicWidth))*(ScreenWidth-kEdge*2);
        sizeBriefImg=[UIImageView getCustomImg];
        [self addSubview:sizeBriefImg];
        sizeBriefImg.contentMode=2;
        [regular setZeroBorder:sizeBriefImg];
        [sizeBriefImg JX_ScaleAspectFill_loadImageUrlStr:_SizeAlertModel.sizeBriefPic WithSize:800 placeHolderImageName:nil radius:0];
        [sizeBriefImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kEdge);
            make.right.mas_equalTo(-kEdge);
            make.top.mas_equalTo(lastView.mas_bottom).with.offset(IsPhone6_gt?25:15);
            make.height.mas_equalTo(_imgHeight);
        }];
    }
    
    _confirmBtn=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:18.0f WithSpacing:0 WithNormalTitle:@"确   定" WithNormalColor:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
    [self addSubview:_confirmBtn];
    _confirmBtn.backgroundColor=_define_black_color;
    [_confirmBtn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if(sizeBriefImg)
        {
            make.top.mas_equalTo(sizeBriefImg.mas_bottom).with.offset(IsPhone6_gt?25:15);
        }else
        {
            make.top.mas_equalTo(lastView.mas_bottom).with.offset(IsPhone6_gt?25:15);
        }
//        make.right.mas_equalTo(-kEdge);
//        make.left.mas_equalTo(kEdge);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kTabbarHeight);
    }];
}
-(void)confirmAction
{
    if([_sizeID isEqualToString:_ItemModel.sizeId])
    {
        _block(@"no_alert",_sizeID,_sizeName,_count);
    }else
    {
        _block(@"alert",_sizeID,_sizeName,_count);
    }
}

/**
 * 0表示没有选中尺寸
 * 大于0表示有选中尺寸
 */
-(NSInteger )getSelectSize
{
    __block NSInteger selectIdx=0;
    [_sizeBtnArr enumerateObjectsUsingBlock:^(UIButton *_btn, NSUInteger idx, BOOL * _Nonnull stop) {
        if(_btn.selected)
        {
            selectIdx=idx;
            *stop=YES;
        }
    }];
    return selectIdx;
}
-(void)chooseSizeAction:(UIButton *)btn
{
    NSInteger _index=btn.tag-100;
    
    DD_SizeModel *_sizeModel=_SizeAlertModel.size[_index];
    if(_sizeModel.stock)
    {
        [_sizeBtnArr enumerateObjectsUsingBlock:^(UIButton *_btn, NSUInteger idx, BOOL * _Nonnull stop) {
            if(_index==idx)
            {
                DD_SizeModel *_sizeModel=_SizeAlertModel.size[idx];
                if(_btn.selected)
                {
                    warnLabel.hidden=YES;
                    _btn.selected=NO;
                    _sizeID=@"";
                    _sizeName=@"";
                    _count=0;
                    [_btn setBackgroundColor:_define_white_color];
                }else
                {
                    if(_sizeModel.stock<=2)
                    {
                        warnLabel.hidden=NO;
                    }else
                    {
                        warnLabel.hidden=YES;
                    }
                    _btn.selected=YES;
                    _sizeID=_sizeModel.sizeId;
                    _sizeName=_sizeModel.sizeName;
                    [_btn setBackgroundColor:_define_black_color];
                    if(_count>_sizeModel.stock)
                    {
                        _count=_sizeModel.stock;
                    }
                }
            }else
            {
                _btn.selected=NO;
                [_btn setBackgroundColor:_define_white_color];
            }
        }];
    }else
    {
        _block(@"no_stock",_sizeID,_sizeName,_count);
    }
    
    
}


@end
