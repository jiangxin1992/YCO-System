//
//  DD_ShowRoomViewController.m
//  YCO SPACE
//
//  Created by yyj on 16/8/19.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_ShowRoomViewController.h"

#import "MJRefresh.h"

#import "DD_ShowRoomDetailViewController.h"

#import "DD_ShowRoomSimpleCell.h"

#import "DD_ShowRoomModel.h"


@interface DD_ShowRoomViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation DD_ShowRoomViewController
{
    UITableView *_tableview;
    NSMutableArray *_dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData
{
    _dataArr=[[NSMutableArray alloc] init];
}
-(void)PrepareUI
{
    self.navigationItem.titleView=[regular returnNavView:NSLocalizedString(@"user_showroom", @"") withmaxwidth:200];
}

#pragma mark - UIConfig
-(void)UIConfig
{
    [self CreateTableView];
    [self MJRefresh];
}
-(void)CreateTableView
{
    _tableview=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    [self.view addSubview:_tableview];
    //    消除分割线
    _tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableview.delegate=self;
    _tableview.dataSource=self;
    [_tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
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
    [_tableview.mj_header beginRefreshing];
    
}
-(void)loadNewData
{
    // 进入刷新状态后会自动调用这个block
    [self RequestData];
}
#pragma mark - RequestData
-(void)RequestData
{
    [[JX_AFNetworking alloc] GET:@"physicalStore/queryPhysicalStores.do" parameters:@{@"token":[DD_UserModel getToken]} success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            [_dataArr removeAllObjects];//删除所有数据
            [_dataArr addObjectsFromArray:[DD_ShowRoomModel getShowRoomModelArr:[data objectForKey:@"stores"]]];
            [_tableview reloadData];

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

    return 101;
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
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid ];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    static NSString *cellid=@"showroom_cell";
    DD_ShowRoomSimpleCell *cell=[_tableview dequeueReusableCellWithIdentifier:cellid];
    if(!cell)
    {
        cell=[[DD_ShowRoomSimpleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }

    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.showRoomModel=_dataArr[indexPath.section];
    cell.showDownLine=_dataArr.count>1?YES:NO;
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DD_ShowRoomModel *roomModel=_dataArr[indexPath.section];
    DD_ShowRoomDetailViewController *showroom=[[DD_ShowRoomDetailViewController alloc] initWithShowRoomID:roomModel.s_id];
    showroom.title=roomModel.storeName;
    [self.navigationController pushViewController:showroom animated:YES];
}
#pragma mark - Other

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
