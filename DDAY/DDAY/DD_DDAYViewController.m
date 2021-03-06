//
//  DD_DDAYViewController.m
//  DDAY
//
//  Created by yyj on 16/5/20.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_DDAYViewController.h"

#import "MJRefresh.h"

#import "DD_ShopViewController.h"
#import "DD_DDAYDetailViewController.h"
#import "DD_DDAYDetailOfflineViewController.h"
#import "CalendarViewController.h"
#import "DD_CustomViewController.h"

#import "DD_DDAYCell.h"
#import "DD_DDAYOfflineCell.h"

#import "DD_DDAYModel.h"
#import "DD_NOTInformClass.h"

@interface DD_DDAYViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation DD_DDAYViewController
{
    NSMutableArray *_dataArr;
    NSInteger _page;
    void (^ddayblock)(NSInteger index,NSString *type);
    
    UITableView *_tableview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self SomeBlock];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rootChange:) name:@"rootChange" object:nil];
}
-(void)PrepareUI
{
    self.navigationItem.titleView=[regular returnNavView:NSLocalizedString(@"dday_title", @"") withmaxwidth:200];
    DD_NavBtn *shopBtn=[DD_NavBtn getShopBtn];
//    [shopBtn addTarget:self action:@selector(PushShopView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:shopBtn];
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
    UIButton *_calendarBtn=[DD_NavBtn getNavBtnIsLeft:YES WithSize:CGSizeMake(25, 25) WithImgeStr:@"DDAY_Calendar"];
//    [_calendarBtn addTarget:self action:@selector(PushCalendarView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:_calendarBtn];
    [_calendarBtn bk_addEventHandler:^(id sender) {
        //        跳转日历
        [self.navigationController pushViewController:[[CalendarViewController alloc] init] animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
     
}
#pragma mark - SomeBlock
-(void)SomeBlock
{
    __block NSArray *__dataArr=_dataArr;
    __block UITableView *__tableview=_tableview;
    __block DD_DDAYViewController *_dayView=self;
    ddayblock=^(NSInteger index,NSString *type)
    {
        if([type isEqualToString:@"cancel"]||[type isEqualToString:@"join"])
        {
            if(![DD_UserModel isLogin])
            {
                [_dayView presentViewController:[regular alertTitleCancel_Simple:NSLocalizedString(@"login_first", @"") WithBlock:^{
                    [_dayView pushLoginView];
                }] animated:YES completion:nil];
            }else
            {
                DD_DDAYModel *dayModel=__dataArr[index];
                NSString *url=nil;
                if([type isEqualToString:@"cancel"])
                {
                    url=@"series/quitSeries.do";
                }else if([type isEqualToString:@"join"])
                {
                    url=@"series/joinSeries.do";
                }
                [[JX_AFNetworking alloc] GET:url parameters:@{@"token":[DD_UserModel getToken],@"seriesId":dayModel.s_id} success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
                    if(success)
                    {
                        dayModel.isJoin=[[data objectForKey:@"isJoin"] boolValue];
                        dayModel.isQuotaLimt=[[data objectForKey:@"isQuotaLimt"] boolValue];
                        dayModel.leftQuota=[[data objectForKey:@"leftQuota"] longLongValue];
                        [__tableview reloadData];
                    }else
                    {
                        [_dayView presentViewController:successAlert animated:YES completion:nil];
                    }
                } failure:^(NSError *error, UIAlertController *failureAlert) {
                    [_dayView presentViewController:failureAlert animated:YES completion:nil];
                }];
            }
        }else if([type isEqualToString:@"push_detail"])
        {
            DD_DDAYModel *ddaymodel=__dataArr[index];
            [_dayView enterDDAYDetailView:ddaymodel];
        }
    };
}
#pragma mark - UIConfig
-(void)UIConfig
{
    [self CreateTableview];
    [self MJRefresh];
}
-(void)CreateTableview
{
    _tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableview];
    //    消除分割线
    _tableview.backgroundColor=_define_backview_color;
    _tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableview.delegate=self;
    _tableview.dataSource=self;
    CGFloat bottom = -kTabbarHeight-(IsPhone6_gt?16:0);
    [_tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(bottom);
    }];
}

#pragma mark - RequestData
-(void)RequestData
{
    [[JX_AFNetworking alloc] GET:@"series/v1_0_7/querySeries.do" parameters:@{@"page":[NSNumber numberWithInteger:_page],@"token":[DD_UserModel getToken]} success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            NSArray *modelArr=[DD_DDAYModel getDDAYModelArr:[data objectForKey:@"series"]];
            if(modelArr.count)
            {
                if(_page==1)
                {
                    [_dataArr removeAllObjects];//删除所有数据
                }
                [_dataArr addObjectsFromArray:modelArr];
                if([DD_NOTInformClass GET_NEWSERIES_NOT_SERIESID])
                {
                    [self PushNotView:@"NEWSERIES"];
                }
                if([DD_NOTInformClass GET_STARTSERIES_NOT_SERIESID])
                {
                    [self PushNotView:@"STARTSERIES"];
                }
                if([DD_NOTInformClass GET_NEWLIVESERIES_NOT_SERIESID])
                {
                    [self PushNotView:@"NEWLIVESERIES"];
                }
                if([DD_NOTInformClass GET_STARTLIVESERIES_NOT_SERIESID])
                {
                    [self PushNotView:@"STARTLIVESERIES"];
                }
                
                [_tableview reloadData];
                
                
            }else
            {
                if(_page==1)
                {
                    [_dataArr removeAllObjects];//删除所有数据
                    [_tableview reloadData];
                }
            }
            
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
        [_tableview.mj_header endRefreshing];
        [_tableview.mj_footer endRefreshing];
        
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [_tableview.mj_header endRefreshing];
        [_tableview.mj_footer endRefreshing];
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
}
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return  kIPhone4s?568-kTabbarHeight-kStatusBarAndNavigationBarHeight:ScreenHeight-kTabbarHeight-kStatusBarAndNavigationBarHeight;
    return ScreenWidth;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    数据还未获取时候
    if(_dataArr.count==indexPath.section)
    {
        static NSString *cellid=@"cellid";
        UITableViewCell *cell=[_tableview dequeueReusableCellWithIdentifier:cellid];
        if(!cell)
        {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    DD_DDAYModel *ddaymodel=_dataArr[indexPath.section];
    
    if(ddaymodel.stype)
    {
        static NSString *cellOfflineID=@"cell_offline";
        DD_DDAYOfflineCell *cell=[_tableview dequeueReusableCellWithIdentifier:cellOfflineID];
        if(!cell)
        {
            cell=[[DD_DDAYOfflineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellOfflineID];
        }
        
        cell.DDAYModel=ddaymodel;
        cell.ddayblock=ddayblock;
        cell.index=indexPath.section;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    static NSString *cellDDAYID=@"cell_dday";
    DD_DDAYCell *cell=[_tableview dequeueReusableCellWithIdentifier:cellDDAYID];
    if(!cell)
    {
        cell=[[DD_DDAYCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellDDAYID];
    }
    
    cell.DDAYModel=ddaymodel;
    cell.ddayblock=ddayblock;
    cell.index=indexPath.section;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DD_DDAYModel *ddaymodel=_dataArr[indexPath.section];
    [self enterDDAYDetailView:ddaymodel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [regular getViewForSection];
}

#pragma mark - SomeAction
-(void)enterDDAYDetailView:(DD_DDAYModel *)ddayModel
{
    if(ddayModel.stype)
    {
        //线下
        [self.navigationController pushViewController:[[DD_DDAYDetailOfflineViewController alloc] initWithModel:ddayModel] animated:YES];
    }else
    {
        //线上
        [self.navigationController pushViewController:[[DD_DDAYDetailViewController alloc] initWithModel:ddayModel WithBlock:^(NSString *type) {
            if([type isEqualToString:@"update"])
            {
                [_tableview reloadData];
            }
        }] animated:YES];
    }
}
/**
 * 权限发生改变
 */
-(void)rootChange:(NSNotification *)not
{
    if([not.object isEqualToString:@"login"]||[not.object isEqualToString:@"logout"])
    {
        _page=1;
        [self RequestData];
    }
}

/**
 * 发布日详情页
 */
-(void)PushDDAYDetailView
{
    if(_dataArr)
    {
        [_tableview.mj_header beginRefreshing];
    }
}
/**
 * 跳转推送详情页
 */
-(void)PushNotView:(NSString *)type
{
    if(_dataArr)
    {
        NSString *_seriesId=nil;

        if([type isEqualToString:@"NEWSERIES"])
        {
            _seriesId=[DD_NOTInformClass GET_NEWSERIES_NOT_SERIESID];
        }else if([type isEqualToString:@"STARTSERIES"])
        {
            _seriesId=[DD_NOTInformClass GET_STARTSERIES_NOT_SERIESID];
        }else if ([type isEqualToString:@"NEWLIVESERIES"])
        {
            _seriesId=[DD_NOTInformClass GET_NEWLIVESERIES_NOT_SERIESID];
        }else if([type isEqualToString:@"STARTLIVESERIES"])
        {
            _seriesId=[DD_NOTInformClass GET_STARTLIVESERIES_NOT_SERIESID];
        }
        
        if(_seriesId)
        {
            [_dataArr enumerateObjectsUsingBlock:^(DD_DDAYModel *_ddaymodel, NSUInteger idx, BOOL * _Nonnull stop) {
                if([_ddaymodel.s_id isEqualToString:_seriesId])
                {
                    [self enterDDAYDetailView:_ddaymodel];
                }
            }];
        }
        if([type isEqualToString:@"NEWSERIES"])
        {
            [DD_NOTInformClass REMOVE_NEWSERIES_NOT_SERIESID];
        }else if([type isEqualToString:@"STARTSERIES"])
        {
            [DD_NOTInformClass REMOVE_STARTSERIES_NOT_SERIESID];
        }else if ([type isEqualToString:@"NEWLIVESERIES"])
        {
            [DD_NOTInformClass REMOVE_NEWLIVESERIES_NOT_SERIESID];
        }else if([type isEqualToString:@"STARTLIVESERIES"])
        {
            [DD_NOTInformClass REMOVE_STARTLIVESERIES_NOT_SERIESID];
        }
        
    }
   
}

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
    _tableview.mj_header = header;
    
    MJRefreshAutoNormalFooter *_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [_footer setTitle:@"" forState:MJRefreshStateNoMoreData];
    [_footer setTitle:@"" forState:MJRefreshStateIdle];
    [_footer setTitle:@"" forState:MJRefreshStatePulling];
    [_footer setTitle:@"" forState:MJRefreshStateRefreshing];
    [_footer setTitle:@"" forState:MJRefreshStateWillRefresh];
    _footer.refreshingTitleHidden = YES;
    _footer.stateLabel.textColor = _define_light_gray_color1;
    _tableview.mj_footer = _footer;
    
    [_tableview.mj_header beginRefreshing];
    
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
#pragma mark - Other
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[DD_CustomViewController sharedManager] tabbarAppear];
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
