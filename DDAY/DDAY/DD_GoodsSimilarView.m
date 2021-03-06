//
//  DD_GoodsSimilarView.m
//  YCO SPACE
//
//  Created by yyj on 16/8/3.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_GoodsSimilarView.h"

#import "DD_OrderItemModel.h"

@implementation DD_GoodsSimilarView
-(instancetype)initWithGoodsSimilarArr:(NSArray *)similarArr WithBlock:(void (^)(NSString *type,DD_OrderItemModel *itemModel))block
{
    self=[super init];
    if(self)
    {
        _similarArr=similarArr;
        _block=block;
        [self UIConfig];
    }
    return self;
}
-(void)UIConfig
{
    self.backgroundColor=_define_white_color;
    UILabel *SimilarTitleLabel=[UILabel getLabelWithAlignment:1 WithTitle:@"相似款式" WithFont:15.0f WithTextColor:nil WithSpacing:0];
    [self addSubview:SimilarTitleLabel];
    [SimilarTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kEdge);
        make.top.mas_equalTo(self).with.offset(13);
        if(!_similarArr.count)
        {
            make.bottom.mas_equalTo(self.mas_bottom).with.offset(-20);
        }
    }];
    
    __block UIImageView *lastView=nil;
    __block CGFloat _width=(ScreenWidth-kEdge*2-kEdge)/2.0f;
    
    [_similarArr enumerateObjectsUsingBlock:^(DD_OrderItemModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *img=[UIImageView getCustomImg];
        [self addSubview:img];
        img.tag=100+idx;
        img.userInteractionEnabled=YES;
        //        [img addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)]];
        [img bk_whenTapped:^{
            //            图片点击
            NSInteger index=img.tag-100;
            DD_OrderItemModel *itemModel=_similarArr[index];
            _block(@"img_click",itemModel);
        }];
        [img JX_ScaleAspectFill_loadImageUrlStr:model.pic WithSize:800 placeHolderImageName:nil radius:0];
        img.contentMode=1;
        [img mas_makeConstraints:^(MASConstraintMaker *make) {
            if(lastView)
            {
                make.left.mas_equalTo(lastView.mas_right).with.offset(kEdge);
            }else
            {
                make.left.mas_equalTo(kEdge);
                make.bottom.mas_equalTo(self.mas_bottom).with.offset(-20);
            }
            make.top.mas_equalTo(SimilarTitleLabel.mas_bottom).with.offset(11);
            make.width.mas_equalTo(_width);
            make.height.mas_equalTo(IsPhone6_gt?205:178);
        }];
        lastView=img;
    }];

}
//-(void)imgClick:(UIGestureRecognizer *)ges
//{
//    
//    NSInteger index=ges.view.tag-100;
//    DD_OrderItemModel *itemModel=_similarArr[index];
//    
//    _block(@"img_click",itemModel);
//}
@end
