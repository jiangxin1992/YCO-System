//
//  DD_DesignerItemViewController.m
//  DDAY
//
//  Created by yyj on 16/6/12.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_DesignerItemViewController.h"

#import "MJRefresh.h"

#import "DD_GoodsDetailViewController.h"
#import "DD_ShopViewController.h"

#import "Waterflow.h"
#import "WaterflowCell.h"

#import "DD_ItemTool.h"
#import "DD_ImageModel.h"
#import "DD_ItemsModel.h"

@interface DD_DesignerItemViewController ()<WaterflowDataSource,WaterflowDelegate>

@end

@implementation DD_DesignerItemViewController
{
    Waterflow *mywaterflow;
    NSMutableArray *_dataArr;
    NSInteger _page;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
}
#pragma mark - 初始化
-(instancetype)initWithDesignerID:(NSString *)DesignerID WithBlock:(void(^)(NSString *type,DD_ItemsModel *model))block
{
    self=[super init];
    if(self)
    {
        _DesignerID=DesignerID;
        _block=block;
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
    _page=1;
    _dataArr=[[NSMutableArray alloc] init];
}
-(void)PrepareUI{}
#pragma mark - RequestData
-(void)RequestData
{
    NSDictionary *_parameters=@{@"page":[NSNumber numberWithInteger:_page],@"token":[DD_UserModel getToken],@"designerId":_DesignerID};
    [[JX_AFNetworking alloc] GET:@"designer/queryDesignerColorItems.do" parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            NSArray *modelArr=[DD_ItemsModel getItemsModelArr:[data objectForKey:@"items"]];
            if(modelArr.count)
            {
                if(_page==1)
                {
                    [_dataArr removeAllObjects];//删除所有数据
                }
                [_dataArr addObjectsFromArray:modelArr];
                [mywaterflow reloadData];
            }else
            {
                if(_page==1)
                {
                    [_dataArr removeAllObjects];//删除所有数据
                    [mywaterflow reloadData];
                }
            }
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
        [mywaterflow.mj_header endRefreshing];
        [mywaterflow.mj_footer endRefreshing];
        
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [mywaterflow.mj_header endRefreshing];
        [mywaterflow.mj_footer endRefreshing];
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
}
#pragma mark - UIConfig
-(void)UIConfig
{
    [self CreateTableview];
    [self MJRefresh];
}
-(void)CreateTableview
{

    mywaterflow = [[Waterflow alloc] init];
    
    mywaterflow.frame = CGRectMake(0, 0, ScreenWidth,ScreenHeight-kNavHeight-145-28);
    
    mywaterflow.dataSource = self;
    
    mywaterflow.delegate = self;
    
    
    [self.view addSubview:mywaterflow];
    
    
}
#pragma mark - MJRefresh
-(void)MJRefresh
{
    //    MJRefreshNormalHeader *header= [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    NSArray *refreshingImages=[regular getGifImg];
    
    //     Set the ordinary state of animated images
    [header setImages:refreshingImages duration:1.5 forState:MJRefreshStateIdle];
    //     Set the pulling state of animated images（Enter the status of refreshing as soon as loosen）
    [header setImages:refreshingImages duration:1.5 forState:MJRefreshStatePulling];
    //     Set the refreshing state of animated images
    [header setImages:refreshingImages duration:1.5 forState:MJRefreshStateRefreshing];
    
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    mywaterflow.mj_header = header;
    
    MJRefreshAutoNormalFooter *_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [_footer setTitle:@"" forState:MJRefreshStateNoMoreData];
    [_footer setTitle:@"" forState:MJRefreshStateIdle];
    [_footer setTitle:@"" forState:MJRefreshStatePulling];
    [_footer setTitle:@"" forState:MJRefreshStateRefreshing];
    [_footer setTitle:@"" forState:MJRefreshStateWillRefresh];
    _footer.refreshingTitleHidden = YES;
    _footer.stateLabel.textColor = _define_light_gray_color1;
    mywaterflow.mj_footer = _footer;
    
    [mywaterflow.mj_header beginRefreshing];

}
-(void)loadNewData
{
    // 进入刷新状态后会自动调用这个block
    _page=1;
    [self RequestData];
}
-(void)loadMoreData
{
    // 进入刷新状态后会自动调用这个block
    _page+=1;
    [self RequestData];
}
#pragma mark - UITableViewDelegate
// cell的个数，必须实现
- (NSUInteger)numberOfCellsInWaterflow:(Waterflow *)waterflow{
    
    return _dataArr.count+1;
}
// 返回cell，必须实现
- (WaterflowCell *)waterflow:(Waterflow *)waterflow cellAtIndex:(NSUInteger)index{
    if(index)
    {
        
        DD_ItemsModel *item=_dataArr[index-1];
        DD_ImageModel *imgModel=item.pics[0];
        CGFloat _height=((ScreenWidth-water_margin*2-water_Spacing)/2)*([imgModel.height floatValue]/[imgModel.width floatValue]);
        return [DD_ItemTool getHomePageCustomWaterflowCell:waterflow cellAtIndex:index-1 WithItemsModel:item WithHeight:_height];
    }else
    {
        return [WaterflowCell waterflowCellWithWaterflow:waterflow];
    }
    
}
// 这个方法可选不是必要的，默认是3列
- (NSUInteger)numberOfColumnsInWaterflow:(Waterflow *)waterflow{
    return 2;
}
// 返回每一个cell的高度，非必要，默认为80
- (CGFloat)waterflow:(Waterflow *)waterflow heightAtIndex:(NSUInteger)index{
    if(index)
    {
        DD_ItemsModel *item=_dataArr[index-1];
        if(item.pics)
        {
            DD_ImageModel *imgModel=item.pics[0];
            CGFloat _height=((ScreenWidth-water_margin*2-water_Spacing)/2)*([imgModel.height floatValue]/[imgModel.width floatValue]);
            return _height+56+water_Top;
        }
        return 56+water_Top+44;
    }else
    {
        return 0;
    }
    
}
// 间隔，非必要，默认均为10
- (CGFloat)waterflow:(Waterflow *)waterflow marginOfWaterflowMarginType:(WaterflowMarginType)type{
    switch (type) {
            
        case WaterflowMarginTypeLeft:return water_margin;
        case WaterflowMarginTypeRight:return water_margin;
        case WaterflowMarginTypeRow:return water_Spacing;
            //        case WaterflowMarginTypeColumn:return water_Bottom;
        case WaterflowMarginTypeColumn:return 0;
        case WaterflowMarginTypeBottom:return water_Bottom;
//        case WaterflowMarginTypeTop:return _isReadBenefit?0:BenefitHeight;
        default:return 0;

    }
}
// 非必要
- (void)waterflow:(Waterflow *)waterflow didSelectCellAtIndex:(NSUInteger)index{

    if(index)
    {
        DD_ItemsModel *_model=_dataArr[index-1];
        _block(@"detail",_model);
    }
    
}
#pragma mark - SomeAction
//跳转购物车
-(void)PushShopView
{
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
}


#pragma mark - Other
- (void)viewWillAppear:(BOOL)animated
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
