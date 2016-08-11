//
//  DD_GoodsViewController.m
//  DDAY
//
//  Created by yyj on 16/5/20.
//  Copyright © 2016年 YYJ. All rights reserved.
//
#import "DD_GoodsDetailViewController.h"

#import "DD_ItemTool.h"
#import "DD_GoodsViewController.h"
#import "DD_ItemsModel.h"
#import "DD_GoodsCategoryModel.h"
#import "MJRefresh.h"
#import "DD_ShopViewController.h"
#import "Waterflow.h"
#import "WaterflowCell.h"
#import "DD_GoodsListView.h"

#import "DD_GoodsListTableViewCell.h"
#import "DD_GoodsListTableView.h"

@interface DD_GoodsViewController ()<WaterflowDataSource,WaterflowDelegate>

@end

@implementation DD_GoodsViewController
{
    Waterflow *mywaterflow;
    NSMutableArray *_dataArr;
    NSInteger _page;
    
    NSString *_categoryName;
    NSString *_categoryID;
    
    DD_GoodsListTableView *listTableView;
    NSMutableArray *_categoryArr;
    DD_GoodsListView *titleView;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self hideBackNavBtn];
    [self PrepareData];
    [self PrepareUI];
}
-(void)PrepareData
{
    _page=1;
    _dataArr=[[NSMutableArray alloc] init];
    _categoryArr=[[NSMutableArray alloc] init];
    _categoryName=@"";
    _categoryID=@"";
    
}
-(void)PrepareUI
{
    self.navigationItem.titleView=[regular returnNavView:NSLocalizedString(@"goods_title", @"") withmaxwidth:200];

    DD_NavBtn *shopBtn=[DD_NavBtn getShopBtn];
    [shopBtn addTarget:self action:@selector(PushShopView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:shopBtn];

    titleView=[[DD_GoodsListView alloc] initWithFrame:CGRectMake(0, 0, 170, 40)];
    [titleView setImage:[UIImage imageNamed:@"System_Triangle"] forState:UIControlStateNormal];
    
    [titleView setImage:[UIImage imageNamed:@"System_UpTriangle"] forState:UIControlStateSelected];
    [titleView setTitle:@"类别" forState:UIControlStateNormal];
    titleView.titleLabel.font=[regular getSemiboldFont:17.0f];
    [titleView addTarget:self action:@selector(ChooseCategoryAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView=titleView;
    
    if(_noTabbar)
    {
        DD_NavBtn *backBtn=[DD_NavBtn getBackBtn];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchDown];
        self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:backBtn];
    }
}
-(void)ChooseCategoryAction:(UIButton *)btn
{
    if(btn.selected)
    {
        btn.selected=NO;
//        hide
        [UIView animateWithDuration:0.5 animations:^{
            listTableView.frame=CGRectMake(0, -(ScreenHeight-ktabbarHeight-kNavHeight), ScreenWidth, ScreenHeight-ktabbarHeight-kNavHeight);
        } completion:^(BOOL finished) {
            [self listTableViewHide];
        }];
        
    }else
    {
        btn.selected=YES;
        listTableView=[[DD_GoodsListTableView alloc] initWithFrame:CGRectMake(0, -(ScreenHeight-ktabbarHeight-kNavHeight), ScreenWidth, ScreenHeight-ktabbarHeight-kNavHeight) style:UITableViewStylePlain WithBlock:^(NSString *type,NSString *categoryName,NSString *categoryID) {

            btn.selected=NO;
            if([type isEqualToString:@"click"])
            {
                [titleView setTitle:categoryName forState:UIControlStateNormal];
            }else if([type isEqualToString:@"all"])
            {
                [titleView setTitle:@"类别" forState:UIControlStateNormal];
            }
            _categoryName=categoryName;
            _categoryID=categoryID;
            [mywaterflow.header beginRefreshing];
            [self listTableViewHide];

        }];
        [self.view addSubview:listTableView];
        [UIView animateWithDuration:0.5 animations:^{
            listTableView.frame=CGRectMake(0, kNavHeight, ScreenWidth, ScreenHeight-ktabbarHeight-kNavHeight);
        }];
        [self RequestListData];
    }
}
-(void)listTableViewHide
{
    [listTableView removeFromSuperview];
    listTableView=nil;
    [_categoryArr removeAllObjects];
}
#pragma mark - RequestData
-(void)RequestData
{
    
    NSMutableDictionary *_parameters=[[NSMutableDictionary alloc] initWithDictionary:@{@"page":[NSNumber numberWithInteger:_page],@"token":[DD_UserModel getToken]}];
    if(![_categoryName isEqualToString:@""])
    {
        if([_categoryID isEqualToString:@""])
        {
            [_parameters setObject:_categoryName forKey:@"catOneName"];
        }else
        {
            [_parameters setObject:_categoryID forKey:@"catTwoId"];
        }
    }
    [[JX_AFNetworking alloc] GET:@"item/queryColorItemsByCategory.do" parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
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
            }
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
        [mywaterflow.header endRefreshing];
        [mywaterflow.footer endRefreshing];

    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [mywaterflow.header endRefreshing];
        [mywaterflow.footer endRefreshing];
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
}
-(void)RequestListData
{
    [[JX_AFNetworking alloc] GET:@"item/querySearchCategory.do" parameters:@{@"token":[DD_UserModel getToken]} success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            [_categoryArr addObjectsFromArray:[DD_GoodsCategoryModel getGoodsCategoryModelArr:[data objectForKey:@"category"]]];
            NSLog(@"_categoryModel=%@",_categoryArr);
            if(listTableView&&_categoryArr.count)
            {
                listTableView.categoryArr=_categoryArr;
            }
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
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
    
    if(_noTabbar)
    {
        mywaterflow.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight+ktabbarHeight);
    }else
    {
        mywaterflow.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    }
    
    
    mywaterflow.dataSource = self;
    
    mywaterflow.delegate = self;
    
//    mywaterflow.showsVerticalScrollIndicator=NO;
    
    [self.view addSubview:mywaterflow];
}
#pragma mark - MJRefresh
-(void)MJRefresh
{
    mywaterflow.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        _page=1;
        [self RequestData];
    }];
    
    mywaterflow.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        _page+=1;
        [self RequestData];
    }];
    
    [mywaterflow.header beginRefreshing];
}
#pragma mark - SomeAction
/**
 * 返回
 */
-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
//跳转购物车
-(void)PushShopView
{
    DD_ShopViewController *_shop=[[DD_ShopViewController alloc] init];
    [self.navigationController pushViewController:_shop animated:YES];
}

#pragma mark - UITableViewDelegate
// cell的个数，必须实现
- (NSUInteger)numberOfCellsInWaterflow:(Waterflow *)waterflow{
    
    return _dataArr.count;
}
// 返回cell，必须实现
- (WaterflowCell *)waterflow:(Waterflow *)waterflow cellAtIndex:(NSUInteger)index{
    DD_ItemsModel *item=[_dataArr objectAtIndex:index];
    DD_ImageModel *imgModel=[item.pics objectAtIndex:0];
    CGFloat _height=((ScreenWidth-13*3-10*2)/2)*([imgModel.height floatValue]/[imgModel.width floatValue]);
    return [DD_ItemTool getCustomWaterflowCell:waterflow cellAtIndex:index WithItemsModel:item WithHeight:_height];
}
// 这个方法可选不是必要的，默认是3列
- (NSUInteger)numberOfColumnsInWaterflow:(Waterflow *)waterflow{
    return 2;
}
// 返回每一个cell的高度，非必要，默认为80
- (CGFloat)waterflow:(Waterflow *)waterflow heightAtIndex:(NSUInteger)index{
    DD_ItemsModel *item=[_dataArr objectAtIndex:index];
    if(item.pics)
    {
        DD_ImageModel *imgModel=[item.pics objectAtIndex:0];
        CGFloat _height=((ScreenWidth-13*3-10*2)/2)*([imgModel.height floatValue]/[imgModel.width floatValue]);
        return _height+95;
    }
    return 95;
}
// 间隔，非必要，默认均为10
- (CGFloat)waterflow:(Waterflow *)waterflow marginOfWaterflowType:(WaterflowMarginType)type{
    return 13;
}
// 非必要
- (void)waterflow:(Waterflow *)waterflow didSelectCellAtIndex:(NSUInteger)index{
    
    DD_ItemsModel *_model=[_dataArr objectAtIndex:index];
    DD_GoodsDetailViewController *_GoodsDetail=[[DD_GoodsDetailViewController alloc] initWithModel:_model WithBlock:^(DD_ItemsModel *model, NSString *type) {
        //        if(type)
    }];
    [self.navigationController pushViewController:_GoodsDetail animated:YES];
}

#pragma mark - Other
-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    if(_noTabbar)
    {
        [[DD_CustomViewController sharedManager] tabbarHide];
    }else
    {
        [[DD_CustomViewController sharedManager] tabbarAppear];
    }
    [MobClick beginLogPageView:@"DD_GoodsViewController"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"DD_GoodsViewController"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
