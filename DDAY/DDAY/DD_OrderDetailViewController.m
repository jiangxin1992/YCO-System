//
//  DD_OrderDetailViewController.m
//  DDAY
//
//  Created by yyj on 16/6/7.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_OrderDetailViewController.h"

#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"

#import "DD_OrderRefundViewController.h"
#import "DD_OrderLogisticsViewController.h"
#import "DD_GoodsDetailViewController.h"
#import "DD_ClearingDoneViewController.h"

#import "DD_OrderTabBar.h"
#import "DD_OrderDetailFootView.h"
#import "DD_ClearingTableViewCell.h"
#import "DD_OrderDetailHeadView.h"

#import "DD_OrderTool.h"
#import "DD_OrderDetailModel.h"
#import "DD_ItemsModel.h"

@interface DD_OrderDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@end

@implementation DD_OrderDetailViewController
{
    DD_OrderDetailModel *_OrderDetailModel;
    UITableView *_tableview;
    DD_OrderTabBar *_tabBar;
    DD_OrderDetailFootView *_footView;
    DD_OrderDetailHeadView *_headView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self RequestData];
}
#pragma mark - 初始化
-(instancetype)initWithModel:(DD_OrderModel *)model WithBlock:(void (^)(NSString *type,NSDictionary *resultDic))block
{
    self=[super init];
    if(self)
    {
        _block=block;
//        model.orderStatus=1;
        _OrderModel=model;
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
    /**
     * 支付宝回调。
     * 客户端回调，会回调AppDelegate里面的支付宝结算回调中
     * 通过通知，发送回调消息
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payAction:) name:@"payAction" object:nil];
}
-(void)PrepareUI
{
    self.navigationItem.titleView=[regular returnNavView:NSLocalizedString(@"order_detail", @"") withmaxwidth:200];//设置标题
}
#pragma mark - UIConfig
-(void)UIConfig
{
    [self UpdateTabBar];
    [self CreateTableView];
}
-(void)CreateTableView
{
    _tableview=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableview];
    //    消除分割线
    _tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableview.delegate=self;
    _tableview.dataSource=self;
    _tableview.tableHeaderView=[[UIView alloc]initWithFrame:CGRectMake(0,0,0,0.1)];
    _tableview.tableFooterView=[[UIView alloc]initWithFrame:CGRectMake(0,0,0,0.1)];
    [_tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(kNavHeight);
        make.bottom.mas_equalTo(_tabBar.mas_top).with.offset(0);
    }];
}

/**
 * 创建总结视图 FootView
 */
-(void)UpdateFootView
{
    if(!_footView)
    {
        _footView=[[DD_OrderDetailFootView alloc] initWithOrderDetailModel:_OrderDetailModel WithOrderModel:_OrderModel WithBlock:^(NSString *type, CGFloat height) {
            if([type isEqualToString:@"height"])
            {
                //高度调整
                _footView.frame=CGRectMake(0, 0, ScreenWidth, height);
                _tableview.tableFooterView=_footView;
            }else if([type isEqualToString:@"contact"])
            {
                //联系客服
                [self contactAction];
            }else if([type isEqualToString:@"refund"])
            {
                //退货（退款）
                [self RefundAction];
            }
        }];
        _footView.frame=CGRectMake(0, 0, ScreenWidth, 0);
        _tableview.tableFooterView = _headView;
    }else
    {
        _footView.orderModel=_OrderModel;
        _footView.orderDetailModel=_OrderDetailModel;
        [_footView SetState];
    }
    
}
/**
 * 创建／更新headview视图
 */
-(void)UpdateHeadView
{

    if(!_headView)
    {
        _headView=[[DD_OrderDetailHeadView alloc] initWithOrderDetailModel:_OrderDetailModel WithOrderModel:_OrderModel WithBlock:^(NSString *type, CGFloat height, NSString *phonenum) {
            if([type isEqualToString:@"height"])
            {
                //高度调整
                _headView.frame=CGRectMake(0, 0, ScreenWidth, height);
                _tableview.tableHeaderView=_headView;
            }else if([type isEqualToString:@"count_end"])
            {
                //计时结束(订单关闭)
                [self OrderEndAction];
            }else if([type isEqualToString:@"phone_click"])
            {
                //打电话
                [self CallActionWithPhoneNum:phonenum];
            }else if([type isEqualToString:@"enter_logistics"])
            {
                //跳转物流详情页
                [self checkLogisticsInfo];
            }
        }];
        _headView.frame=CGRectMake(0, 0, ScreenWidth, 0);
        _tableview.tableHeaderView = _headView;
    }else
    {
        _headView.orderModel=_OrderModel;
        _headView.orderDetailModel=_OrderDetailModel;
        [_headView SetState];
    }
}
/**
 * 创建／更新 tabbar
 */
-(void)UpdateTabBar
{
    if(!_tabBar)
    {
        _tabBar=[[DD_OrderTabBar alloc] initWithOrderModel:_OrderModel WithBlock:^(NSString *type) {
            if([type isEqualToString:@"pay"])
            {
                //            支付
                [self PayActionWithTradeOrderCode:_OrderDetailModel.orderInfo.tradeOrderCode];
                
            }else if([type isEqualToString:@"confirm"])
            {
                //            确认收货
                [self ConfirmAction];
            }
        }];
        [self.view addSubview:_tabBar];
        [_tabBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
        }];
    }else
    {
        _tabBar.orderModel=_OrderModel;
        [_tabBar SetState];
    }
}
#pragma mark - RequestData
-(void)RequestData
{
    NSString *_url=nil;
    NSDictionary *_parameters=nil;
    if(_OrderModel.isPay)
    {
        _url=@"order/querySubOrderDetail.do";
        _parameters=@{@"token":[DD_UserModel getToken],@"orderCode":_OrderModel.subOrderCode};
    }else
    {
        _url=@"order/queryOrderDetail.do";
        _parameters=@{@"token":[DD_UserModel getToken],@"tradeOrderCode":_OrderModel.tradeOrderCode};
    }
    
    [[JX_AFNetworking alloc] GET:_url parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            _OrderDetailModel=[DD_OrderDetailModel getOrderDetailModel:data];
            [self UpdateTabBar];
            [self UpdateFootView];
            [self UpdateHeadView];
            [_tableview reloadData];
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
}
#pragma mark  UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *phoneStr = [NSString stringWithFormat:@"tel://%@",alertView.title];
    if (buttonIndex == 0) {
        
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
    }
}
#pragma mark - TableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    子订单数量
    NSArray *_orderList=_OrderDetailModel.orderInfo.orderList;
    DD_OrderModel *__OrderModel=[_orderList objectAtIndex:section];
    return __OrderModel.itemList.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    子订单数量
    return _OrderDetailModel.orderInfo.orderList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    数据还未获取时候
    if(_OrderDetailModel==nil)
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
    
    //获取到数据以后
    static NSString *cellid=@"cell_p";
    DD_ClearingTableViewCell *cell=[_tableview dequeueReusableCellWithIdentifier:cellid];
    if(!cell)
    {
        cell=[[DD_ClearingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid IsOrderDetail:YES WithBlock:nil];
    }
    NSArray *_orderList=_OrderDetailModel.orderInfo.orderList;
    DD_OrderModel *__OrderModel=[_orderList objectAtIndex:indexPath.section];
    DD_OrderItemModel *_item=[__OrderModel.itemList objectAtIndex:indexPath.row];
    cell.ClearingModel=[DD_OrderTool getClearingOrderModel:_item];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *_orderList=_OrderDetailModel.orderInfo.orderList;
    DD_OrderModel *__OrderModel=[_orderList objectAtIndex:indexPath.section];
    DD_OrderItemModel *_item=[__OrderModel.itemList objectAtIndex:indexPath.row];
    
    DD_ItemsModel *_ItemsModel=[[DD_ItemsModel alloc] init];
    _ItemsModel.g_id=_item.itemId;
    _ItemsModel.colorCode=_item.colorCode;
    DD_GoodsDetailViewController *_GoodsDetailView=[[DD_GoodsDetailViewController alloc] initWithModel:_ItemsModel WithBlock:^(DD_ItemsModel *model, NSString *type) {
        
    }];
    [self.navigationController pushViewController:_GoodsDetailView animated:YES];
}
#pragma mark - SomeActions
/**
 * 更新视图
 */
-(void)updateView
{
    _headView.orderModel=_OrderModel;
    _headView.orderDetailModel=_OrderDetailModel;
    [_headView SetState];
    
    _footView.orderModel=_OrderModel;
    _footView.orderDetailModel=_OrderDetailModel;
    [_footView SetState];
    
    _tabBar.orderModel=_OrderModel;
    [_tabBar SetState];
    
    [_tableview reloadData];
}
/**
 * 返回 
 * 取消线程
 */
-(void)backAction
{
    [_headView dispatch_cancel];
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 * 订单关闭
 */
-(void)OrderEndAction
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"订单已关闭" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dialAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _block(@"reload",nil);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert addAction:dialAction];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 * 电话
 */
-(void)CallActionWithPhoneNum:(NSString *)phoneNumber
{
    NSString *phoneStr = [NSString stringWithFormat:@"tel://%@",phoneNumber];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:phoneNumber message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dialAction = [UIAlertAction actionWithTitle:@"呼叫" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:cancelAction];
        [alert addAction:dialAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:phoneNumber message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"呼叫", nil];
        
        [alertView show];
    }
}
/**
 * 退款
 */
-(void)RefundAction
{
    [self presentViewController:[regular alertTitleCancel_Simple:NSLocalizedString(@"order_if_refund_order", @"") WithBlock:^{
        [self.navigationController pushViewController:[[DD_OrderRefundViewController alloc] initWithModel:_OrderDetailModel WithBlock:^(NSString *type) {
            if([type isEqualToString:@"update"])
            {
                //更新当前状态
//                [_tableview reloadData];
//                _tabBar.orderInfo=_OrderDetailModel.orderInfo;
//                [_tabBar UIConfig];
//                _AddressView.DetailModel=_OrderDetailModel;
//                [_AddressView SetState];
            }
        }] animated:YES];
    }] animated:YES completion:nil];
    
}
/**
 * 查看物流信息
 */
-(void)checkLogisticsInfo
{
    if(_OrderDetailModel.orderInfo.orderList.count)
    {
        DD_OrderModel *_order=[_OrderDetailModel.orderInfo.orderList objectAtIndex:0];
        [self.navigationController pushViewController:[[DD_OrderLogisticsViewController alloc] initWithModel:_order WithBlock:nil] animated:YES];
    }
}
/**
 * 支付回调
 */
-(void)payAction:(NSNotification *)not
{   
    if([self isVisible])
    {
        if([self haveClearingDoneView])
        {
            NSDictionary *resultDic=@{@"resultStatus":[not.object objectForKey:@"resultStatus"],@"tradeOrderCode":[not.object objectForKey:@"tradeOrderCode"]};
            [self popToClearingBeforeViewWithResultDic:resultDic];
        }else
        {
            DD_ClearingDoneViewController *_DoneView=[[DD_ClearingDoneViewController alloc] initWithReturnCode:[not.object objectForKey:@"resultStatus"] WithTradeOrderCode:[not.object objectForKey:@"tradeOrderCode"] WithType:@"detail_order_havenot_clearing_done" WithBlock:^(NSString *type) {
                //                            if(type)
            }];
            [self.navigationController pushViewController:_DoneView animated:YES];
        }
    }
    
}
/**
 * 前面是否有 DD_ClearingDoneViewController
 */
-(BOOL)haveClearingDoneView
{
    NSArray *controllers=self.navigationController.viewControllers;
    for (int i=0; i<controllers.count; i++) {
        id obj=controllers[i];
        if([obj isKindOfClass:[DD_ClearingDoneViewController class]])
        {
            return YES;
        }
    }
    return NO;
}
/**
 * 跳转到 DD_ClearingDoneViewController的前一页
 */
-(void)popToClearingBeforeViewWithResultDic:(NSDictionary *)resultDic
{
    NSArray *controllers=self.navigationController.viewControllers;
    for (int i=0; i<controllers.count; i++) {
        id obj=controllers[i];
        if([obj isKindOfClass:[DD_ClearingDoneViewController class]])
        {
            if(i)
            {
                DD_BaseViewController *base=controllers[i-1];
                [self.navigationController popToViewController:base animated:YES];
                [base pushCleaingDoneViewWithResultDic:resultDic WithType:@"detail_order_have_clearing_done"];
            }
        }
    }
}

/**
 * 删除订单
 */
-(void)DelectAction
{

    [self presentViewController:[regular alertTitleCancel_Simple:NSLocalizedString(@"order_if_delete_order", @"") WithBlock:^{
        if(_OrderDetailModel.orderInfo.orderList.count)
        {
            DD_OrderModel *_order=[_OrderDetailModel.orderInfo.orderList objectAtIndex:0];
            NSDictionary *_parameters=@{@"token":[DD_UserModel getToken],@"orderCode":_order.subOrderCode};
            [[JX_AFNetworking alloc] GET:@"order/deleteOrder.do" parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
                if(success)
                {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"已成功删除订单" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }else
                {
                    [self presentViewController:successAlert animated:YES completion:nil];
                }
            } failure:^(NSError *error, UIAlertController *failureAlert) {
                [self presentViewController:failureAlert animated:YES completion:nil];
            }];
        }
    }] animated:YES completion:nil];
    
    
}
/**
 * 确认收货
 */
-(void)ConfirmAction
{
    [self presentViewController:[regular alertTitleCancel_Simple:NSLocalizedString(@"order_if_confirm", @"") WithBlock:^{
        if(_OrderDetailModel.orderInfo.orderList.count)
        {
            DD_OrderModel *_order=[_OrderDetailModel.orderInfo.orderList objectAtIndex:0];
            [[JX_AFNetworking alloc] GET:@"order/confirmOrder.do" parameters:@{@"token":[DD_UserModel getToken],@"orderCode":_order.subOrderCode} success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
                if(success)
                {
                    //更新当前状态
                    
//                    _OrderModel.orderStatus=3;
//                    [_tableview reloadData];
//                    DD_OrderModel *__OrderModel=[_tabBar.orderInfo.orderList objectAtIndex:0];
//                    __OrderModel.orderStatus=3;
//                    [_tabBar UIConfig];
                }else
                {
                    [self presentViewController:successAlert animated:YES completion:nil];
                }
            } failure:^(NSError *error, UIAlertController *failureAlert) {
                [self presentViewController:failureAlert animated:YES completion:nil];
            }];
        }
    }] animated:YES completion:nil];
    
    
}

/**
 * 取消订单
 */
-(void)CancelAction
{

    [self presentViewController:[regular alertTitleCancel_Simple:NSLocalizedString(@"order_if_cancel_order", @"") WithBlock:^{
        NSDictionary *_parameters = @{@"token":[DD_UserModel getToken],@"tradeOrderCode":_OrderDetailModel.orderInfo.tradeOrderCode};
        [[JX_AFNetworking alloc] GET:@"order/v1_0_7/cancelOrder.do" parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
            if(success)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"已成功取消订单" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if([self haveClearingDoneView])
                    {
                        [self popToClearingBeforeView];
                    }else
                    {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    
                }];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }else
            {
                [self presentViewController:successAlert animated:YES completion:nil];
            }
        } failure:^(NSError *error, UIAlertController *failureAlert) {
            [self presentViewController:failureAlert animated:YES completion:nil];
        }];
    }] animated:YES completion:nil];
   
}

/**
 * 跳转到 DD_ClearingDoneViewController的前一页
 */
-(void)popToClearingBeforeView
{
    NSArray *controllers=self.navigationController.viewControllers;
    for (int i=0; i<controllers.count; i++) {
        id obj=controllers[i];
        if([obj isKindOfClass:[DD_ClearingDoneViewController class]])
        {
            if(i)
            {
                DD_BaseViewController *base=controllers[i-1];
                [self.navigationController popToViewController:base animated:YES];
            }
        }
    }
}

/**
 * 联系客服
 */
-(void)contactAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"") style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *take_photosAction = [UIAlertAction actionWithTitle:@"联系客服" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"tel://%@",_OrderDetailModel.orderInfo.customerServicePhone]]];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:take_photosAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
/**
 * 继续支付
 */
-(void)PayActionWithTradeOrderCode:(NSString *)tradeOrderCode
{
    [[JX_AFNetworking alloc] GET:@"order/orderExpireCheck.do" parameters:@{@"token":[DD_UserModel getToken],@"tradeOrderCode":_OrderModel.tradeOrderCode} success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            //不验证直接获取orderSpec 发起支付
            NSDictionary *_parameters=@{@"token":[DD_UserModel getToken],@"tradeOrderCode":tradeOrderCode};
            [[JX_AFNetworking alloc] GET:@"order/queryOrderPayParams.do" parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
                if(success)
                {
                    NSString *appScheme = @"DDAY";
                    //            payParam
                    NSString *orderSpec = [data objectForKey:@"payParam"];
                    JXLOG(@"orderSpec = %@",orderSpec);
                    id<DataSigner> signer = CreateRSADataSigner([data objectForKey:@"privateKey"]);
                    NSString *signedString = [signer signString:orderSpec];
                    NSString *orderString = nil;
                    if (signedString != nil) {
                        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                                       orderSpec, signedString, @"RSA"];
                        JXLOG(@"%@",orderString);
                        [DD_UserModel setTradeOrderCode:[data objectForKey:@"tradeOrderCode"]];
                        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                            if([self haveClearingDoneView])
                            {
                                NSDictionary *_resultDic=@{@"resultStatus":[resultDic objectForKey:@"resultStatus"],@"tradeOrderCode":[data objectForKey:@"tradeOrderCode"]};
                                [self popToClearingBeforeViewWithResultDic:_resultDic];
                            }else
                            {
                                [self.navigationController pushViewController:[[DD_ClearingDoneViewController alloc] initWithReturnCode:[resultDic objectForKey:@"resultStatus"] WithTradeOrderCode:[data objectForKey:@"tradeOrderCode"] WithType:@"detail_order_havenot_clearing_done" WithBlock:^(NSString *type) {
                                }] animated:YES];
                            }
                        }];
                    }
                }else
                {
                    [self presentViewController:successAlert animated:YES completion:nil];
                }
            } failure:^(NSError *error, UIAlertController *failureAlert) {
                [self presentViewController:failureAlert animated:YES completion:nil];
            }];
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
    
}
#pragma mark - Other
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(_tableview)
    {
        [self RequestData];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - 弃用代码

@end
