//
//  DD_UserCollectCircleViewController.m
//  DDAY
//
//  Created by yyj on 16/6/13.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_UserCollectCircleViewController.h"

#import "Waterflow.h"
#import "WaterflowCell.h"
#import "DD_ImageModel.h"

#import "DD_CircleListCell.h"

@interface DD_UserCollectCircleViewController ()<WaterflowDataSource,WaterflowDelegate>

@end

@implementation DD_UserCollectCircleViewController
{
    Waterflow *mywaterflow;
    NSMutableArray *_dataArr;
    NSInteger _page;
    
    void (^cellBlock)(NSString *type,NSInteger index,DD_OrderItemModel *item);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
}
#pragma mark - 初始化
-(instancetype)initWithBlock:(void(^)(NSString *type,DD_CircleListModel *model,DD_OrderItemModel *item))block
{
    self=[super init];
    if(self)
    {
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
    [[JX_AFNetworking alloc] GET:@"share/queryCollectShares.do" parameters:@{@"page":[NSNumber numberWithInteger:_page],@"token":[DD_UserModel getToken]} success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            NSArray *modelArr=[DD_CircleListModel getCircleListImgModelArr:[data objectForKey:@"shares"]];
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
    [self CreateWaterFlow];
    [self MJRefresh];
}
-(void)CreateWaterFlow
{
    mywaterflow = [[Waterflow alloc] init];
    
    
    mywaterflow.frame = CGRectMake(0, 17, ScreenWidth,ScreenHeight-36-64-17);
    
    mywaterflow.dataSource = self;
    
    mywaterflow.delegate = self;
    
    [self.view addSubview:mywaterflow];
}
#pragma mark - MJRefresh
-(void)MJRefresh
{
    mywaterflow.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        _page=1;
        [self RequestData];
    }];
    
    mywaterflow.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        _page+=1;
        [self RequestData];
    }];
    
    [mywaterflow.mj_header beginRefreshing];
}
#pragma mark - SomeAction


#pragma mark - WaterflowDelegate

// cell的个数，必须实现
- (NSUInteger)numberOfCellsInWaterflow:(Waterflow *)waterflow{
    
    return _dataArr.count+1;
}
// 返回cell，必须实现
- (WaterflowCell *)waterflow:(Waterflow *)waterflow cellAtIndex:(NSUInteger)index{
    if(index)
    {
        WaterflowCell *cell = [WaterflowCell waterflowCellWithWaterflow:waterflow];
        DD_CircleListModel *listModel=[_dataArr objectAtIndex:index-1];
        if(listModel.pics.count)
        {
            DD_ImageModel *imgModel=[listModel.pics objectAtIndex:0];
            UIImageView *img=[UIImageView getCustomImg];
            [cell addSubview:img];
            img.contentMode=2;
            [regular setZeroBorder:img];
            [img JX_ScaleAspectFill_loadImageUrlStr:imgModel.pic WithSize:800 placeHolderImageName:nil radius:0];
            [img mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(0);
                make.top.mas_equalTo(water_Top);
            }];
        }
        return cell;
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
        DD_CircleListModel *listModel=[_dataArr objectAtIndex:index-1];
        if(listModel.pics.count)
        {
            DD_ImageModel *imgModel=[listModel.pics objectAtIndex:0];
            CGFloat _height=((ScreenWidth-water_margin*2-water_Spacing)/2)*([imgModel.height floatValue]/[imgModel.width floatValue]);
            return _height+water_Top;
        }
        return 0;
    }else{
      return 0;
    }
}
// 间隔，非必要，默认均为10
- (CGFloat)waterflow:(Waterflow *)waterflow marginOfWaterflowMarginType:(WaterflowMarginType)type{
    switch (type) {
        case WaterflowMarginTypeLeft:return water_margin;
        case WaterflowMarginTypeRight:return water_margin;
        case WaterflowMarginTypeRow:return water_Spacing;
        case WaterflowMarginTypeColumn:return water_Bottom;
        case WaterflowMarginTypeBottom:return water_Bottom;
        default:return 0;
    }
}
// 非必要
- (void)waterflow:(Waterflow *)waterflow didSelectCellAtIndex:(NSUInteger)index{
    if(index)
    {
        DD_CircleListModel *listModel=[_dataArr objectAtIndex:index-1];
        _block(@"push_circle_detail",listModel,nil);
    }
   
}


#pragma mark - Others
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(mywaterflow)
    {
        _page=1;
        [self RequestData];
    }
    [MobClick beginLogPageView:@"DD_UserCollectCircleViewController"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"DD_UserCollectCircleViewController"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
