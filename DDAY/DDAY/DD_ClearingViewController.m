//
//  DD_ClearingViewController.m
//  DDAY
//
//  Created by yyj on 16/5/18.
//  Copyright © 2016年 mike_xie. All rights reserved.
//

#import "DD_ClearingViewController.h"

#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"

#import "DD_ClearingTableViewCell.h"
#import "DD_RemarksViewController.h"
#import "DD_AddressViewController.h"
#import "DD_ChooseBenefitListViewController.h"

#import "DD_SetAddressBtn.h"
#import "DD_ClearingTabbar.h"

#import "DD_ClearingTool.h"
#import "DD_ClearingSeriesModel.h"
#import "DD_CityTool.h"
#import "DD_BenefitInfoModel.h"
#import "DD_AddressModel.h"
#import "DD_ClearingView.h"
#import "DD_ClearingModel.h"

#import "RSAEncryptor.h"

@interface DD_ClearingViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableDictionary *_dataDict;
    NSMutableArray *_dataArr;
    
    UITableView *_tableview;
    
    DD_ClearingTabbar *_tabBar;
    
    DD_SetAddressBtn *_AddressBtn;// 选择地址按钮
    
    NSString *remarksStr;// 订单备注 默认为空
    
    NSString *payWay;//alipay  wechat unionpay
}

@end

@implementation DD_ClearingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    [self AnalysisData];
    [self CreateHeadView];
    [self CreateFootView];
    [self CreateTabBar];
}

#pragma mark - 初始化
-(instancetype)initWithModel:(DD_ClearingModel *)_model WithBlock:(void (^)(NSString *type,NSDictionary *resultDic))block
{
    self=[super init];
    if(self)
    {
        _Clearingmodel=_model;
        _successblock=block;
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
    payWay=@"alipay";
    remarksStr=@"";
    _dataDict=[[NSMutableDictionary alloc] init];
    _dataArr=[[NSMutableArray alloc] init];
    /**
     * 支付宝回调。
     * 客户端回调，会回调AppDelegate里面的支付宝结算回调中
     * 通过通知，发送回调消息
     */
      
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payAction:) name:@"payAction" object:nil];
}
-(void)PrepareUI{
    
    self.navigationItem.titleView=[regular returnNavView:NSLocalizedString(@"checkorder_title", @"") withmaxwidth:200];
}
#pragma mark - UIConfig
-(void)UIConfig
{
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
        make.edges.mas_equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, kTabbarHeight, 0));
    }];
}

/**
 * 确认订单按钮
 */
-(void)CreateTabBar
{
    NSInteger _freight=[_Clearingmodel.freight integerValue];
    CGFloat _Freight=_dataArr.count*_freight;
    CGFloat _count=[[_dataDict objectForKey:@"subTotal"] floatValue];
    CGFloat _countPrice=_count+_Freight;
    
    _tabBar=[[DD_ClearingTabbar alloc] initWithClearingModel:_Clearingmodel WithCountPrice:_countPrice WithCount:_count WithBlock:^(NSString *type) {
        if([type isEqualToString:@"confirm"])
        {
            [self ConfirmAction];
        }
    }];
    [self.view addSubview:_tabBar];
    
    [_tabBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(kTabbarHeight);
    }];
}
/**
 * 创建地址视图 HeadView
 */
-(void)CreateHeadView
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
    _AddressBtn=[DD_SetAddressBtn buttonWithType:UIButtonTypeCustom WithAddressModel:_Clearingmodel.address WithBlock:^(NSString *type) {
        if([type isEqualToString:@"address"])
        {
            //            添加收货地址
            [self.navigationController pushViewController:[[DD_AddressViewController alloc]initWithType:@"address" WithBlock:^(NSString *type, DD_AddressModel *addressModel) {
                if([type isEqualToString:@"choose_address"])
                {
                    _Clearingmodel.address=addressModel;
                    if(addressModel)
                    {
                        [_dataDict setObject:@{
                                               @"deliverName":addressModel.deliverName
                                               ,@"deliverPhone":addressModel.deliverPhone
                                               ,@"detailAddress":addressModel.detailAddress
                                               ,@"addressId":addressModel.udaId
                                               ,@"countryName":addressModel.countryName
                                               ,@"provinceName":addressModel.provinceName
                                               ,@"cityName":addressModel.cityName
                                               } forKey:@"address"];
                    }else
                    {
                        [_dataDict removeObjectForKey:@"address"];
                    }
                    _AddressBtn.AddressModel=addressModel;
                    [_AddressBtn SetState];
                    CGFloat height = [headView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                    CGRect frame = headView.frame;
                    frame.size.height = height;
                    headView.frame = frame;
                    _tableview.tableHeaderView = headView;
                }else if([type isEqualToString:@"alert_address"])
                {
                    if([addressModel.udaId isEqualToString:_Clearingmodel.address.udaId])
                    {
                        _Clearingmodel.address=addressModel;
                        _AddressBtn.AddressModel=_Clearingmodel.address;
                        [_AddressBtn SetState];
                        CGFloat height = [headView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                        CGRect frame = headView.frame;
                        frame.size.height = height;
                        headView.frame = frame;
                        _tableview.tableHeaderView = headView;
                    }
                }else if([type isEqualToString:@"add_address"])
                {
                    if(!_Clearingmodel.address)
                    {
                        _Clearingmodel.address=addressModel;
                        if(addressModel)
                        {
                            [_dataDict setObject:@{
                                                   @"deliverName":addressModel.deliverName
                                                   ,@"deliverPhone":addressModel.deliverPhone
                                                   ,@"detailAddress":addressModel.detailAddress
                                                   ,@"addressId":addressModel.udaId
                                                   ,@"countryName":addressModel.countryName
                                                   ,@"provinceName":addressModel.provinceName
                                                   ,@"cityName":addressModel.cityName
                                                   } forKey:@"address"];
                        }else
                        {
                            [_dataDict removeObjectForKey:@"address"];
                        }
                        _AddressBtn.AddressModel=addressModel;
                        [_AddressBtn SetState];
                        CGFloat height = [headView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                        CGRect frame = headView.frame;
                        frame.size.height = height;
                        headView.frame = frame;
                        _tableview.tableHeaderView = headView;
                    }
                    
                }
                
            }] animated:YES];
        }
    }];
    [headView addSubview:_AddressBtn];
    [_AddressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(headView);
    }];
    CGFloat height = [headView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect frame = headView.frame;
    frame.size.height = height;
    
    headView.frame = frame;
    _tableview.tableHeaderView = headView;
}
/**
 * 创建总结视图 FootView
 */
-(void)CreateFootView
{
    _ClearingView=[[DD_ClearingView alloc] initWithDataArr:_dataArr WithClearingModel:_Clearingmodel WithPayWay:payWay WithBlock:^(NSString *type, CGFloat height,NSString *_payway) {
        if([type isEqualToString:@"remarks"])
        {
            //            跳转remarks界面
            [self PushRemarksView];
            
        }else if([type isEqualToString:@"height"])
        {
            _ClearingView.frame=CGRectMake(CGRectGetMinX(_ClearingView.frame), CGRectGetMinY(_ClearingView.frame), ScreenWidth, height);
            _tableview.tableFooterView=_ClearingView;
        }else if([type isEqualToString:@"pay_way_change"])
        {
            payWay=_payway;
        }else if([type isEqualToString:@"choose_coupon"])
        {
            //选择优惠券
            [self.navigationController pushViewController:[[DD_ChooseBenefitListViewController alloc] initWithClearingModel:_Clearingmodel WithBlock:^(NSString *type) {
                if([type isEqualToString:@"choose_benefit"])
                {
                    [_Clearingmodel BenefitUpdate];
                    [_ClearingView SetState];
                    [_tabBar SetState];
                }
            }] animated:YES];
        }else if([type isEqualToString:@"switch"])
        {
            [_Clearingmodel IntegralUpdate];
            JXLOG(@"use_rewardPoints=%d,employ_rewardPoints=%ld",_Clearingmodel.use_rewardPoints,_Clearingmodel.employ_rewardPoints);
            [_ClearingView SetState];
            [_tabBar SetState];
        }
    }];
    _ClearingView.frame=CGRectMake(0, 0, ScreenWidth, 155);
    _tableview.tableFooterView = _ClearingView;
}

#pragma mark - AnalysisData
/**
 * 数据解析
 */
-(void)AnalysisData
{
    [_dataDict setDictionary:[_Clearingmodel getOrderInfo]];
    [_dataArr addObjectsFromArray:[[_dataDict objectForKey:@"orders"] objectForKey:@"remain"]];
    [_dataArr addObjectsFromArray:[[_dataDict objectForKey:@"orders"] objectForKey:@"saleing"]];
    [_tableview reloadData];
}

#pragma mark - SomeAction

/**
 * 获取结算页面的订单个数
 */
-(NSInteger )getGoodsCount
{
    __block NSInteger _num=0;
    [_dataArr enumerateObjectsUsingBlock:^(DD_ClearingSeriesModel *_Series, NSUInteger idx, BOOL * _Nonnull stop) {
        _num+=_Series.items.count;
    }];

    return _num;
}
/**
 * 确认订单按钮点击动作
 */
-(void)ConfirmAction
{
    if([_dataDict objectForKey:@"address"])
    {
        //    结算验证  不反悔参数
        NSDictionary *_parameters=@{@"token":[DD_UserModel getToken],@"buyItems":[[_Clearingmodel getItemsArr] mj_JSONString]};
        [[JX_AFNetworking alloc] GET:@"item/buyCheckWithOutReturnData.do" parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
            if(success)
            {
                [self CreateOrder];
            }else
            {
                [self presentViewController:successAlert animated:YES completion:nil];
            }
        } failure:^(NSError *error, UIAlertController *failureAlert) {
            [self presentViewController:failureAlert animated:YES completion:nil];
        }];
    }else
    {
        [self presentViewController:[regular alertTitle_Simple:NSLocalizedString(@"clearing_no_address", @"")] animated:YES completion:nil];
    }

}

/**
 * 订单验证通过之后，创建支付宝订单，进行支付
 */
-(void)CreateOrder
{
    if([_dataDict objectForKey:@"address"])
    {
        NSInteger _freight=[_Clearingmodel.freight integerValue];
        CGFloat _Freight=_dataArr.count*_freight;
        CGFloat _count=[[_dataDict objectForKey:@"subTotal"] floatValue];
        CGFloat _countPrice=_count+_Freight;
        DD_BenefitInfoModel *_benefitModel=[_Clearingmodel getChoosedBenefitInfo];
        CGFloat _price=_countPrice;
        if(_Clearingmodel.benefitInfo)
        {
            if(_benefitModel.amount>_price)
            {
                _price=0;
            }else
            {
                _price=_price-_benefitModel.amount;
            }
        }
        
        if(_price&&_Clearingmodel.rewardPoints&&_Clearingmodel.use_rewardPoints)
        {
            if(_price>_Clearingmodel.employ_rewardPoints)
            {
                _price=_price-_Clearingmodel.employ_rewardPoints;
            }else
            {
                _price=0;
            }
        }
        
        NSDictionary *_parameters=@{
                                    @"token":[DD_UserModel getToken]
                                    ,@"orderInfo":[[DD_ClearingTool getPayOrderInfoWithDataDict:_dataDict WithDataArr:_dataArr WithRemarks:remarksStr WithFreight:_Clearingmodel.freight] mj_JSONString]
                                    ,@"benefitId":_Clearingmodel.choosedBenefitId?_Clearingmodel.choosedBenefitId:@""
                                    ,@"deduction":_Clearingmodel.use_rewardPoints?[NSNumber numberWithLong:_Clearingmodel.employ_rewardPoints]:[NSNumber numberWithLong:0]
                                    ,@"actuallyPay":[NSNumber numberWithFloat:_price]
                                    };
        [[JX_AFNetworking alloc] GET:@"order/v1_0_7/createOrderNew" parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
            if(success)
            {
                NSString *appScheme = @"DDAY";
                NSString *orderSpec = [data objectForKey:@"order"];

                NSString *private_key_path = [[NSBundle mainBundle] pathForResource:@"private_key.p12" ofType:nil];
                NSString *private_key_encryption = [data objectForKey:@"privateKey"];
                NSString *privateKey = [RSAEncryptor decryptString:private_key_encryption privateKeyWithContentsOfFile:private_key_path password:@"yyj"];

                id<DataSigner> signer = CreateRSADataSigner(privateKey);
                NSString *signedString = [signer signString:orderSpec];
                NSString *orderString = nil;
                if (signedString != nil) {
                    orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                                   orderSpec, signedString, @"RSA"];
                    [DD_UserModel setTradeOrderCode:[data objectForKey:@"tradeOrderCode"]];
                    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                        
                        NSDictionary *_resultDic=@{@"resultStatus":[resultDic objectForKey:@"resultStatus"],@"tradeOrderCode":[data objectForKey:@"tradeOrderCode"]};
                        [self.navigationController popViewControllerAnimated:YES];
                        _successblock(@"pay_back",_resultDic);
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
        [self presentViewController:[regular alertTitle_Simple:NSLocalizedString(@"clearing_no_address", @"")] animated:YES completion:nil];
    }
}
/**
 * 跳转填写备注界面
 */
-(void)PushRemarksView
{
    [self.navigationController pushViewController:[[DD_RemarksViewController alloc] initWithRemarks:remarksStr WithLimit:0 WithTitle:@"订单备注" WithBlock:^(NSString *type, NSString *content) {
        if([type isEqualToString:@"done"])
        {
            if(_ClearingView)
            {
                [_ClearingView setRemarksWithWebView:content];
                remarksStr=content;
            }
        }
    }] animated:YES];
}
/**
 * 支付回调
 */
-(void)payAction:(NSNotification *)not
{

    if([self isVisible])
    {
        NSDictionary *resultDic=@{@"resultStatus":[not.object objectForKey:@"resultStatus"],@"tradeOrderCode":[not.object objectForKey:@"tradeOrderCode"]};
        [self.navigationController popViewControllerAnimated:YES];
        _successblock(@"pay_back",resultDic);
    }
}


#pragma mark - TableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DD_ClearingSeriesModel *_Series=_dataArr[section];
    return _Series.items.count;
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
    
    //获取到数据以后
    static NSString *cellid=@"cell_normal";
    DD_ClearingTableViewCell *cell=[_tableview dequeueReusableCellWithIdentifier:cellid];
    if(!cell)
    {
        cell=[[DD_ClearingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid IsOrderDetail:NO WithBlock:nil];
    }
    DD_ClearingSeriesModel *_Series=_dataArr[indexPath.section];
    cell.ClearingModel=_Series.items[indexPath.row];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
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
