//
//  DD_GoodsDetailViewController.m
//  DDAY
//
//  Created by yyj on 16/5/22.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_GoodsDetailViewController.h"

#import "DD_ShopViewController.h"
#import "DD_ClearingViewController.h"
#import "DD_DDAYMeetViewController.h"
#import "DD_DesignerHomePageViewController.h"
#import "ImageViewController.h"
#import "DD_LoginViewController.h"
#import "DD_ClearingDoneViewController.h"
#import "DD_TarentoHomePageViewController.h"
#import "DD_CircleDetailViewController.h"
#import "DD_MoreCircleViewController.h"
#import "DD_ShowRoomDetailViewController.h"
#import "DD_BenefitListViewController.h"
#import "DD_CustomViewController.h"

#import "DD_GoodsInformView.h"
#import "DD_GoodsDesignerView.h"
#import "DD_GoodsCircleView.h"
#import "DD_GoodsFabricView.h"
#import "DD_GoodsSendAndReturnsView.h"
#import "DD_GoodsK_POINTView.h"
#import "DD_GoodsSimilarView.h"
#import "DD_ChooseSizeView.h"
#import "DD_DrawManageView.h"
#import "DD_GoodsTabBar.h"
#import "DD_ShareView.h"
#import "DD_BenefitView.h"

#import "DD_ShareTool.h"
#import "DD_ColorsModel.h"
#import "DD_ClearingModel.h"
#import "DD_GoodsDetailModel.h"
#import "DD_OtherItemModel.h"
#import "DD_SizeAlertModel.h"
#import "DD_ImageModel.h"
#import "DD_GoodSeriesModel.h"
#import "DD_GoodsDesignerModel.h"
#import "DD_CircleListModel.h"
#import "DD_OrderItemModel.h"
#import "DD_ShowRoomModel.h"
#import "DD_GoodsItemModel.h"
#import "DD_ItemsModel.h"


@interface DD_GoodsDetailViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate>

__bool(isExpanded);

@end

@implementation DD_GoodsDetailViewController
{
    DD_GoodsDetailModel *_DetailModel;//单品model
    
    UIScrollView *_scrollview;
    UIImageView *mengban;//蒙板
    UIImageView *mengban_share;
    DD_ChooseSizeView *sizeView;
    
    DD_GoodsInformView *_InformView;//信息视图
    DD_GoodsDesignerView *_DesignerView;//设计师系列视图
    DD_GoodsCircleView *_CircleView;//搭配师说
    DD_GoodsFabricView *_FabricView;//材质与护理
    DD_GoodsSendAndReturnsView *_ReturnView;//寄送与退换
    DD_GoodsK_POINTView *_K_PonitView;//YCO SPACE 体验店
    DD_GoodsSimilarView *_SimilarView;//相似款式
    
    DD_GoodsTabBar *tabbar;
    
    UIPageViewController *_pageViewControler;//单品图片浏览
    DD_DrawManageView *ManageView;//自定义pageControler
    
    UIView *container;//_scrollView的view
    
    CGFloat _mengban_size_Height;
    
    DD_ShareView *shareView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self SomePrepare];
    [self CreateScrollView];
    [self RequestData];

}
#pragma mark - 初始化
-(instancetype)initWithModel:(DD_ItemsModel *)model WithBlock:(void (^)(DD_ItemsModel *model,NSString *type))block
{
    self=[super init];
    if(self)
    {
        _block=block;
        _model=model;
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
    _isExpanded=YES;
    
}
-(void)PrepareUI
{
    
    DD_NavBtn *shopBtn=[DD_NavBtn getShopBtn];
//    [shopBtn addTarget:self action:@selector(PushShopView) forControlEvents:UIControlEventTouchUpInside];
    [shopBtn bk_addEventHandler:^(id sender) {
//        跳转购物车
        if(![DD_UserModel isLogin])
        {
            [self presentViewController:[regular alertTitleCancel_Simple:NSLocalizedString(@"login_first", @"") WithBlock:^{
                [self pushLoginView];
            }] animated:YES completion:nil];
        }else
        {
            DD_ShopViewController *_shop=[[DD_ShopViewController alloc] init];
            [self.navigationController pushViewController:_shop animated:YES];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    DD_NavBtn *shareBtn=[DD_NavBtn getNavBtnIsLeft:NO WithSize:CGSizeMake(25, 25) WithImgeStr:@"Share_Navbar"];
//    [shareBtn addTarget:self action:@selector(ShareAction) forControlEvents:UIControlEventTouchUpInside];
    [shareBtn bk_addEventHandler:^(id sender) {
        [self ShareAction];
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItems=@[[[UIBarButtonItem alloc] initWithCustomView:shopBtn]
                                              ,[[UIBarButtonItem alloc] initWithCustomView:shareBtn]
                                              ];

    self.navigationItem.titleView=[regular returnNavView:@"单品" withmaxwidth:110];
}
#pragma mark - UIConfig
-(void)CreateScrollView
{
    _scrollview=[[UIScrollView alloc] init];
    [self.view addSubview:_scrollview];
    container = [UIView new];
    [_scrollview addSubview:container];
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_scrollview);
        make.width.mas_equalTo(_scrollview);
    }];
}
-(void)UIConfig
{
    [self CreateImgScreenView];
    [self CreateInformView];
    [self CreateDesignerView];
    [self CreateCircleView];
    [self CreateFabricView];
    [self CreateSendAndReturnsView];
    [self CreateKPOINTView];
    [self CreateSimilarItems];
    [self CreateTabbar];
}
-(void)CreateImgScreenView
{
    DD_ColorsModel *_colorModel=[_DetailModel getColorsModel];
    [_pageViewControler.view removeFromSuperview];
    [ManageView removeFromSuperview];
    
    if(_colorModel.pics.count)
    {
        //    创建pageViewControler（活动图片浏览视图）
        _pageViewControler = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        [container addSubview:_pageViewControler.view];
        ImageViewController *imgvc = [[ImageViewController alloc] initWithSize:CGSizeMake(ScreenWidth-(IsPhone6_gt?60:49)-kEdge*2, IsPhone6_gt?363:301) WithType:@"model" WithIsFit:NO WithContentModeIsFill:NO WithBlock:^(NSString *type, NSInteger index) {
        }];
        imgvc.array=_colorModel.pics;
        imgvc.view.backgroundColor =  _define_clear_color;
        [regular setBorder:_pageViewControler.view];
        imgvc.currentPage = 0;
        [_pageViewControler setViewControllers:@[imgvc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        _pageViewControler.delegate = self;
        _pageViewControler.dataSource = self;
        [_pageViewControler.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kEdge);
            make.right.mas_equalTo(-kEdge);
            make.top.mas_equalTo(12);
            make.height.mas_equalTo(IsPhone6_gt?363:301);
        }];
        
        ManageView=[[DD_DrawManageView alloc] initWithImgCount:_colorModel.pics.count];
        [container addSubview:ManageView];
        ManageView.userInteractionEnabled=NO;
        ManageView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"Item_Frame"]];
        
        [ManageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_pageViewControler.view.mas_right).with.offset(-1);
            make.bottom.mas_equalTo(_pageViewControler.view).with.offset(-1);
            make.top.mas_equalTo(_pageViewControler.view).with.offset(1);
            make.width.mas_equalTo(IsPhone6_gt?60:49);
        }];
        
    }else
    {
        _pageViewControler = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        [container addSubview:_pageViewControler.view];
        [_pageViewControler.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(30);
            make.right.mas_equalTo(-30);
            make.top.mas_equalTo(12);
            make.height.mas_equalTo(IsPhone6_gt?363:301);
        }];
    }
}
-(void)CreateInformView
{
    _InformView=[[DD_GoodsInformView alloc] initWithGoodsDetailModel:_DetailModel WithBlock:^( NSString *type) {
        if([type isEqualToString:@"color_select"])
        {
//            颜色（款式）选择之后的回调
            [self CreateImgScreenView];
            [tabbar setState];
        }else if([type isEqualToString:@"collect"])
        {
            //            收藏
            if(![DD_UserModel isLogin])
            {
                [self presentViewController:[regular alertTitleCancel_Simple:NSLocalizedString(@"login_first", @"") WithBlock:^{
                    [self pushLoginView];
                }] animated:YES completion:nil];
            }else
            {
                [self Colloct_Action];
            } 
        }else if([type isEqualToString:@"check_othergoods"]){
            //查看其余发布品

            JXLOG(@"check_othergoods");
            [self.navigationController pushViewController:[[DD_DDAYMeetViewController alloc] initWithType:@"meet" WithSeriesID:_DetailModel.item.series.s_id WithBlock:nil] animated:YES];
        }
    }];
    [container addSubview:_InformView];
    [_InformView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(container).with.offset((IsPhone6_gt?363:301)+12);
        make.left.and.right.mas_equalTo(0);
    }];

}
-(void)CreateDesignerView
{
    _DesignerView=[[DD_GoodsDesignerView alloc] initWithGoodsDetailModel:_DetailModel WithBlock:^(NSString *type,NSInteger index) {
        
        if([type isEqualToString:@"follow"]||[type isEqualToString:@"unfollow"])
        {
            if(![DD_UserModel isLogin])
            {
                [self presentViewController:[regular alertTitleCancel_Simple:NSLocalizedString(@"login_first", @"") WithBlock:^{
                    [self pushLoginView];
                }] animated:YES completion:nil];
            }else
            {
                [self followAction:type];
            }
            
        }else if([type isEqualToString:@"designer"])
        {
            [self PushDesignerView];
        }else if([type isEqualToString:@"item"])
        {
            [self PushItemView:index];
        }else if([type isEqualToString:@"servies"])
        {
            //            跳转系列详情
        }
    }];
    [container addSubview:_DesignerView];
    [_DesignerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_InformView.mas_bottom).with.offset(0);
        make.left.and.right.mas_equalTo(0);
    }];
    
}
-(void)CreateCircleView
{
    if(_DetailModel.circle)
    {
        _CircleView=[[DD_GoodsCircleView alloc] initWithGoodsItem:_DetailModel.circle WithBlock:^(NSString *type,DD_OrderItemModel *item) {
            if([type isEqualToString:@"head_click"])
            {
                if([_DetailModel.circle.userType integerValue]==2)
                {
                    //                设计师
                    DD_DesignerHomePageViewController *_DesignerHomePage=[[DD_DesignerHomePageViewController alloc] init];
                    _DesignerHomePage.designerId=_DetailModel.circle.userId;
                    [self.navigationController pushViewController:_DesignerHomePage animated:YES];
                }else if([_DetailModel.circle.userType integerValue]==4)
                {
                    //                达人
                    [self.navigationController pushViewController:[[DD_TarentoHomePageViewController alloc] initWithUserId:_DetailModel.circle.userId] animated:YES];
                }else
                {
                    [self presentViewController:[regular alertTitle_Simple:NSLocalizedString(@"no_homepage", @"")] animated:YES completion:nil];
                }
            }else if([type isEqualToString:@"item_click"])
            {
                DD_ItemsModel *_item=[[DD_ItemsModel alloc] init];
                _item.g_id=item.itemId;
                _item.colorCode=item.colorCode;
                DD_GoodsDetailViewController *_GoodsDetail=[[DD_GoodsDetailViewController alloc] initWithModel:_item WithBlock:^(DD_ItemsModel *model, NSString *type) {
                    //        if(type)
                }];
                [self.navigationController pushViewController:_GoodsDetail animated:YES];
            }else if([type isEqualToString:@"enter_detail"])
            {
                [self.navigationController pushViewController:[[DD_CircleDetailViewController alloc] initWithCircleListModel:_DetailModel.circle WithShareID:_DetailModel.circle.shareId IsHomePage:NO WithBlock:^(NSString *type) {
                    
                }] animated:YES];
            }else if([type isEqualToString:@"more_circle"])
            {
//                JXLOG(@"更多搭配");
                [self.navigationController pushViewController:[[DD_MoreCircleViewController alloc] initWithColorCode:_model.colorCode WithItemId:_model.g_id] animated:YES];
            }
        }];
        [container addSubview:_CircleView];
        [_CircleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_DesignerView.mas_bottom);
            make.left.and.right.mas_equalTo(0);
        }];
    }else
    {
        _CircleView=[[DD_GoodsCircleView alloc] init];
        [container addSubview:_CircleView];
        [_CircleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_DesignerView.mas_bottom);
            make.left.height.right.mas_equalTo(0);
        }];
        
    }
    
}
-(void)CreateFabricView
{
    
    _FabricView=[[DD_GoodsFabricView alloc] initWithGoodsItem:_DetailModel.item WithBlock:^(NSString *type) {
        if([type isEqualToString:@"click"])
        {
            _FabricView.is_show=!_FabricView.is_show;
        }
    }];
    [container addSubview:_FabricView];
    _FabricView.is_show=NO;
    [_FabricView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_CircleView.mas_bottom);
        make.left.and.right.mas_equalTo(0);
    }];
}
-(void)CreateSendAndReturnsView
{
    _ReturnView=[[DD_GoodsSendAndReturnsView alloc] initWithGoodsItem:_DetailModel.item WithBlock:^(NSString *type) {
        if([type isEqualToString:@"click"])
        {
            _ReturnView.is_show=!_ReturnView.is_show;
        }
    }];
    [container addSubview:_ReturnView];
    _ReturnView.is_show=NO;
    [_ReturnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_FabricView.mas_bottom);
        make.left.and.right.mas_equalTo(0);
    }];
}
-(void)CreateKPOINTView
{
    if(_DetailModel.physicalStore.count)
    {
        _K_PonitView=[[DD_GoodsK_POINTView alloc] initWithShowRoomModelArr:_DetailModel.physicalStore WithBlock:^(NSString *type,DD_ShowRoomModel *model) {
            if([type isEqualToString:@"click"])
            {
                _K_PonitView.is_show=!_K_PonitView.is_show;
            }else if([type isEqualToString:@"choose"])
            {
                DD_ShowRoomDetailViewController *showroom=[[DD_ShowRoomDetailViewController alloc] initWithShowRoomID:model.s_id];
                showroom.title=model.storeName;
                [self.navigationController pushViewController:showroom animated:YES];
            }
        }];
        [container addSubview:_K_PonitView];
        _K_PonitView.is_show=NO;
        [_K_PonitView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_ReturnView.mas_bottom);
            make.left.and.right.mas_equalTo(0);
        }];
    }else
    {
        _K_PonitView=[[DD_GoodsK_POINTView alloc] init];
        [container addSubview:_K_PonitView];
        [_K_PonitView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_ReturnView.mas_bottom);
            make.left.height.right.mas_equalTo(0);
        }];
    }
    
}
-(void)CreateSimilarItems
{
    if(_DetailModel.similarItems.count)
    {
        _SimilarView=[[DD_GoodsSimilarView alloc] initWithGoodsSimilarArr:_DetailModel.similarItems WithBlock:^(NSString *type, DD_OrderItemModel *itemModel) {
            if([type isEqualToString:@"img_click"])
            {
                DD_ItemsModel *_ItemsModel=[[DD_ItemsModel alloc] init];
                _ItemsModel.g_id=itemModel.itemId;
                _ItemsModel.colorCode=itemModel.colorCode;
                DD_GoodsDetailViewController *_GoodsDetailView=[[DD_GoodsDetailViewController alloc] initWithModel:_ItemsModel WithBlock:^(DD_ItemsModel *model, NSString *type) {
                    
                }];
                [self.navigationController pushViewController:_GoodsDetailView animated:YES];
                
            }
        }];
        [container addSubview:_SimilarView];
        [_SimilarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_K_PonitView.mas_bottom);
            make.left.and.right.mas_equalTo(0);
        }];
        [_scrollview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.bottom.mas_equalTo(-kTabbarHeight);
            // 让scrollview的contentSize随着内容的增多而变化
            make.bottom.mas_equalTo(_SimilarView.mas_bottom).with.offset(48);
        }];
    }else
    {
        [_scrollview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.bottom.mas_equalTo(-kTabbarHeight);
            // 让scrollview的contentSize随着内容的增多而变化
            make.bottom.mas_equalTo(_K_PonitView.mas_bottom).with.offset(48);
        }];
    }

}
-(void)CreateTabbar
{
    if(!tabbar)
    {
        tabbar=[[DD_GoodsTabBar alloc] initWithColorModel:[_DetailModel getColorsModel] WithBlock:^(NSString *type) {
            if([type isEqualToString:@"buy"])
            {
                [self Shop_Buy_Action:@"buy"];
            }else if([type isEqualToString:@"cannot_buy"])
            {
                JXLOG(@"兄弟 买不了了");
            }
        }];
        [self.view addSubview:tabbar];
        [tabbar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }else
    {
        tabbar.colorModel=[_DetailModel getColorsModel];
        [tabbar setState];
    }
}
#pragma mark - RequestData
-(void)RequestData
{
    [[JX_AFNetworking alloc] GET:@"item/v1_0_7/queryItemDetailByColorCode.do" parameters:@{@"token":[DD_UserModel getToken],@"itemId":_model.g_id,@"colorCode":_model.colorCode} success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            _DetailModel=[DD_GoodsDetailModel getGoodsDetailModel:data];
            JXLOG(@"%@",_DetailModel);
            [self UIConfig];
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
}

#pragma  mark-pageViewController代理方法
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    
    DD_ColorsModel *_colorModel=[_DetailModel getColorsModel];
    
    ImageViewController *vc = (ImageViewController*)viewController;
    NSInteger index = vc.currentPage;
    index ++ ;
    
    ImageViewController *imgvc = [[ImageViewController alloc] initWithSize:CGSizeMake(ScreenWidth-(IsPhone6_gt?60:49)-30*2, IsPhone6_gt?363:301) WithType:@"model" WithIsFit:NO WithContentModeIsFill:NO WithBlock:^(NSString *type, NSInteger index) {
    }];
    imgvc.array=_colorModel.pics;
    imgvc.view.backgroundColor =  _define_clear_color;
    imgvc.maxPage = _colorModel.pics.count-1;
    imgvc.currentPage = index;
    return imgvc;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    DD_ColorsModel *_colorModel=[_DetailModel getColorsModel];
    ImageViewController *vc = (ImageViewController*)viewController;
    NSInteger index = vc.currentPage;
    index -- ;
    
    ImageViewController *imgvc = [[ImageViewController alloc] initWithSize:CGSizeMake(ScreenWidth-(IsPhone6_gt?60:49)-30*2, IsPhone6_gt?363:301) WithType:@"model" WithIsFit:NO WithContentModeIsFill:NO WithBlock:^(NSString *type, NSInteger index) {
    }];
    imgvc.array=_colorModel.pics;
    imgvc.view.backgroundColor =  _define_clear_color;
    imgvc.maxPage =_colorModel.pics.count-1;
    imgvc.currentPage = index;
    return imgvc;
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    ImageViewController *vc =  pageViewController.viewControllers[0];
    [ManageView changeSelectNum:vc.currentPage];
    return;
}


#pragma mark - SomeAction
/**
 * 跳转登录界面
 */
-(void)pushLoginView
{
    if(![DD_UserModel isLogin])
    {
        [mengban removeFromSuperview];
        mengban=nil;
        DD_LoginViewController *_login=[[DD_LoginViewController alloc] initWithBlock:^(NSString *type) {
            if([type isEqualToString:@"success"])
            {
                
            }
        }];
        [self.navigationController pushViewController:_login animated:YES];
    }
}

//蒙板消失
-(void)mengban_dismiss
{
    [UIView animateWithDuration:0.5 animations:^{
        sizeView.frame=CGRectMake(0, ScreenHeight, ScreenWidth, _mengban_size_Height);
    } completion:^(BOOL finished) {
        [mengban removeFromSuperview];
        mengban=nil;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }];

}

//收藏
-(void)Colloct_Action
{
    NSString *_url=nil;
    if(_DetailModel.item.isCollect)
    {
//        取消收藏
        _url=@"item/delCollectItem.do";
    }else
    {
//        收藏
        _url=@"item/collectItem.do";
    }
    DD_ColorsModel *colorModel=[_DetailModel getColorsModel];
    NSDictionary *_parameters=@{@"itemId":_DetailModel.item.itemId,@"colorId":_DetailModel.item.colorId,@"colorCode":colorModel.colorCode,@"token":[DD_UserModel getToken]};
    [[JX_AFNetworking alloc] GET:_url parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            if([_DetailModel.item.colorId isEqualToString:[data objectForKey:@"colorId"]])
            {
                _DetailModel.item.isCollect=!_DetailModel.item.isCollect;
                [_InformView setState];
            }
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
    
}
//关注
-(void)followAction:(NSString *)type
{
    NSString *url=nil;
    if([type isEqualToString:@"follow"])
    {
        url=@"designer/careDesigner.do";
    }else if([type isEqualToString:@"unfollow"])
    {
        url=@"designer/unCareDesigner.do";
    }
    NSDictionary *_parameters=@{@"token":[DD_UserModel getToken],@"designerId":_DetailModel.designer.designerId};
    [[JX_AFNetworking alloc] GET:url parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            _DetailModel.guanzhu=[[data objectForKey:@"guanzhu"] boolValue];
            _DesignerView.detailModel=_DetailModel;
            [_DesignerView UpdateFollowBtnState];
            
            [((DD_CustomViewController *)[DD_CustomViewController sharedManager]) updateDesignerListDataWithID:_DetailModel.designer.designerId WithFollowState:_DetailModel.guanzhu];
            
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
}

//shop buy
-(void)Shop_Buy_Action:(NSString *)type
{
    if(![DD_UserModel isLogin])
    {
        [self presentViewController:[regular alertTitleCancel_Simple:NSLocalizedString(@"login_first", @"") WithBlock:^{
            [self pushLoginView];
        }] animated:YES completion:nil];
    }else
    {
        DD_ColorsModel *_colorModel=[_DetailModel getColorsModel];
        NSDictionary *_parameters=@{@"token":[DD_UserModel getToken],@"itemId":_DetailModel.item.itemId,@"colorCode":_colorModel.colorCode};
        [[JX_AFNetworking alloc] GET:@"item/getItemSizeInfo.do" parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
            if(success)
            {
                if(!mengban)
                {
//                    [_detailModel getDiscountPriceStr]
                    DD_SizeAlertModel *sizeAlertModel=[DD_SizeAlertModel getSizeAlertModel:data];
                    
                    [self.navigationController setNavigationBarHidden:YES animated:YES];
                    mengban=[UIImageView getMaskImageView];
                    [self.view addSubview:mengban];
//                    [mengban addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mengban_dismiss)]];
                    [mengban bk_whenTapped:^{
                        [self mengban_dismiss];
                    }];
                    sizeView=[[DD_ChooseSizeView alloc] initWithColorModel:_colorModel WithPrice:[_DetailModel getDiscountPriceStr] WithSizeAlertModel:sizeAlertModel WithBlock:^(NSString *type,NSString *sizeid,NSString *colorid,NSInteger count) {
                        if([type isEqualToString:@"shop"]||[type isEqualToString:@"buy"])
                        {
                            
                            if([sizeid isEqualToString:@""])
                            {
                                [self presentViewController:[regular alertTitle_Simple:@"请先选择尺寸"] animated:YES completion:nil];
                            }else
                            {
                                if(count)
                                {
                                    if(![DD_UserModel isLogin])
                                    {
                                        [self presentViewController:[regular alertTitleCancel_Simple:NSLocalizedString(@"login_first", @"") WithBlock:^{
                                            [self pushLoginView];
                                        }] animated:YES completion:nil];
                                    }else
                                    {
                                        [self mengban_dismiss];
                                        if([type isEqualToString:@"shop"])
                                        {
                                            //                加入购物车
                                            [self ShopAction:sizeid WithNum:count];
                                        }else if([type isEqualToString:@"buy"])
                                        {
                                            //                购买
                                            [self BuyAction:sizeid WithNum:count];
                                        }
                                    }
                                    
                                }
                            }
                            
                        }else if([type isEqualToString:@"stock_warning"])
                        {
                            [self presentViewController:[regular alertTitle_Simple:@"库存不足"] animated:YES completion:nil];
                        }else if([type isEqualToString:@"no_stock"])
                        {
                            [self presentViewController:[regular alertTitle_Simple:@"已售罄"] animated:YES completion:nil];
                        }
                        
                    }];
                    [mengban addSubview:sizeView];
                    _mengban_size_Height=[DD_ChooseSizeView getHeightWithColorModel:_colorModel WithPrice:[_DetailModel getDiscountPriceStr] WithSizeAlertModel:sizeAlertModel];
                    sizeView.frame=CGRectMake(0, ScreenHeight, ScreenWidth, _mengban_size_Height);
                    [UIView animateWithDuration:0.5 animations:^{
                        sizeView.frame=CGRectMake(0, ScreenHeight-_mengban_size_Height, ScreenWidth, _mengban_size_Height);
                    }];
                }
                
            }else
            {
                [self presentViewController:successAlert animated:YES completion:nil];
            }
        } failure:^(NSError *error, UIAlertController *failureAlert) {
            [self presentViewController:failureAlert animated:YES completion:nil];
        }];
    }
    
}
//购买动作
-(void)BuyAction:(NSString *)sizeid WithNum:(NSInteger )count
{
    DD_ColorsModel *clolorModel=[_DetailModel getColorsModel];
    NSArray *_itemArr=@[@{@"itemId":_DetailModel.item.itemId,@"colorCode":clolorModel.colorCode,@"colorId":_DetailModel.item.colorId,@"sizeId":sizeid,@"number":[[NSString alloc] initWithFormat:@"%ld",count],@"price":[_DetailModel getPrice],@"originalPrice":_DetailModel.item.originalPrice}];
    
    NSDictionary *_parameters=@{@"token":[DD_UserModel getToken],@"buyItems":[_itemArr mj_JSONString]};
    [[JX_AFNetworking alloc] GET:@"item/buyCheck.do" parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            DD_ClearingModel *_ClearingModel=[DD_ClearingModel getClearingModel:data];
            [self.navigationController pushViewController:[[DD_ClearingViewController alloc] initWithModel:_ClearingModel WithBlock:^(NSString *type,NSDictionary *resultDic) {
                if([type isEqualToString:@"pay_back"]&&[resultDic objectForKey:@"resultStatus"]&&[resultDic objectForKey:@"tradeOrderCode"])
                {
                    [self.navigationController pushViewController:[[DD_ClearingDoneViewController alloc] initWithReturnCode:[resultDic objectForKey:@"resultStatus"] WithTradeOrderCode:[resultDic objectForKey:@"tradeOrderCode"] WithType:@"clear" WithBlock:^(NSString *type) {
                        
                    }] animated:YES];
                    
                }
            }] animated:YES];
            
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
}
//加入购物车动作
-(void)ShopAction:(NSString *)sizeid WithNum:(NSInteger )count
{
    
    DD_ColorsModel * colorModel=[_DetailModel getColorModelNameWithID:_DetailModel.item.colorId];

    NSArray *_itemArr=@[@{
                            @"itemId":_DetailModel.item.itemId
                            ,@"itemName":_DetailModel.item.itemName
                            ,@"colorId":_DetailModel.item.colorId
                            ,@"sizeId":sizeid
                            ,@"sizeName":[_DetailModel.item getSizeNameWithID:sizeid]
                            ,@"categoryName":_DetailModel.item.categoryName
                            ,@"colorName":colorModel.colorName
                            ,@"colorCode":colorModel.colorCode
                            
                            ,@"discountEnable":[NSNumber numberWithBool:_DetailModel.item.discountEnable]
                            ,@"seriesId":_DetailModel.item.series.s_id
                            ,@"seriesName":_DetailModel.item.series.name
                            ,@"designerId":_DetailModel.designer.designerId
                            ,@"brandName":_DetailModel.designer.brandName
                            
                            ,@"number":[[NSString alloc] initWithFormat:@"%ld",count]
                            ,@"price":[_DetailModel getPrice]
                            ,@"originalPrice":_DetailModel.item.originalPrice
                            ,@"pics":[_DetailModel.item getPicsArr]
                            
                            ,@"saleEndTime":[NSNumber numberWithLong:_DetailModel.item.saleEndTime*1000]
                            ,@"saleStartTime":[NSNumber numberWithLong:_DetailModel.item.saleStartTime*1000]
                            ,@"signEndTime":[NSNumber numberWithLong:_DetailModel.item.signEndTime*1000]
                            ,@"signStartTime":[NSNumber numberWithLong:_DetailModel.item.signStartTime*1000]
                            }
                        ];
    
    NSDictionary *_parameters=@{@"token":[DD_UserModel getToken],@"items":[_itemArr mj_JSONString]};
    [[JX_AFNetworking alloc] GET:@"item/putToShoppingCart.do" parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            [self presentViewController:[regular alertTitle_Simple:NSLocalizedString(@"shop_success", @"")] animated:YES completion:nil];
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
    
}

//跳转单品详情页
-(void)PushItemView:(NSInteger )index
{
    DD_OtherItemModel *_OtherItem=_DetailModel.item.otherItems[index];
    DD_ItemsModel *_ItemsModel=[[DD_ItemsModel alloc] init];
    _ItemsModel.g_id=_OtherItem.itemId;
    _ItemsModel.colorCode=_OtherItem.colorCode;
    DD_GoodsDetailViewController *_GoodsDetailView=[[DD_GoodsDetailViewController alloc] initWithModel:_ItemsModel WithBlock:nil];
    [self.navigationController pushViewController:_GoodsDetailView animated:YES];
}
//跳转设计师页面
-(void)PushDesignerView
{
    DD_DesignerHomePageViewController *_designer=[[DD_DesignerHomePageViewController alloc] init];
    _designer.designerId=_DetailModel.designer.designerId;
    [self.navigationController pushViewController:_designer animated:YES];
}
//蒙板消失
-(void)mengban_dismiss_share
{
    [UIView animateWithDuration:0.5 animations:^{
        shareView.frame=CGRectMake(0, ScreenHeight, ScreenWidth, CGRectGetHeight(shareView.frame));
    } completion:^(BOOL finished) {
        [mengban_share removeFromSuperview];
        mengban_share=nil;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }];
    
}
//分享
-(void)ShareAction
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    mengban_share=[UIImageView getMaskImageView];
    [self.view addSubview:mengban_share];
//    [mengban_share addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mengban_dismiss_share)]];
    [mengban_share bk_whenTapped:^{
        [self mengban_dismiss_share];
    }];
    shareView=[[DD_ShareView alloc] initWithType:@"goods_detail" WithParams:@{@"detailModel":_DetailModel} WithBlock:^(NSString *type,DD_BenefitInfoModel *model) {
        if([type isEqualToString:@"cancel"])
        {
            [self mengban_dismiss_share];
        }else if([type isEqualToString:@"benefit"])
        {
            [self showBenefitWithModel:model];
        }
    }];

    [mengban_share addSubview:shareView];
    
    CGFloat _height=[DD_ShareTool getHeight];
    shareView.frame=CGRectMake(0, ScreenHeight, ScreenWidth, _height);
    [UIView animateWithDuration:0.5 animations:^{
        shareView.frame=CGRectMake(0, ScreenHeight-CGRectGetHeight(shareView.frame), ScreenWidth, CGRectGetHeight(shareView.frame));
    }];
}
-(void)showBenefitWithModel:(DD_BenefitInfoModel *)model
{
    DD_BenefitView *_benefitView=[DD_BenefitView sharedManagerWithModel:model WithBlock:^(NSString *type) {
        
        [self.view.window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:[DD_BenefitView class]])
            {
                DD_BenefitView *sss=(DD_BenefitView *)obj;
                [sss removeFromSuperview];
            }
        }];
        
        if([type isEqualToString:@"close"])
        {
            
        }else if([type isEqualToString:@"enter"])
        {
            [self.navigationController pushViewController:[[DD_BenefitListViewController alloc] init] animated:YES];
        }
    }];
    [self.view.window addSubview:_benefitView];
}
//跳转购物车视图
//-(void)PushShopView
//{
//    if(![DD_UserModel isLogin])
//    {
//        [self presentViewController:[regular alertTitleCancel_Simple:NSLocalizedString(@"login_first", @"") WithBlock:^{
//            [self pushLoginView];
//        }] animated:YES completion:nil];
//    }else
//    {
//        DD_ShopViewController *_shop=[[DD_ShopViewController alloc] init];
//        [self.navigationController pushViewController:_shop animated:YES];
//    }
//}

#pragma mark - Other
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
