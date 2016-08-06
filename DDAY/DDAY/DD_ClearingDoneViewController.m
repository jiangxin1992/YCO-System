//
//  DD_ClearingDoneViewController.m
//  DDAY
//
//  Created by yyj on 16/5/26.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_ClearingDoneViewController.h"
#import "DD_GoodsViewController.h"
#import "DD_OrderDetailViewController.h"
#import "DD_ClearingViewController.h"
#import "DD_OrderModel.h"

@interface DD_ClearingDoneViewController ()

@end

@implementation DD_ClearingDoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
#pragma mark - 初始化
-(instancetype)initWithReturnCode:(NSString *)code WithTradeOrderCode:(NSString *)tradeOrderCode WithType:(NSString *)type WithBlock:(void (^)(NSString *type))block
{
    self=[super init];
    if(self)
    {
        _tradeOrderCode=tradeOrderCode;
        _type=type;
        _code=code;
        _block=block;
        [self SomePrepare];
        [self UIConfig];
    }
    return self;
}
#pragma mark - SomePrepare
-(void)SomePrepare
{
    [self hideBackNavBtn];
    [self PrepareData];
    [self PrepareUI];
}

-(void)PrepareData{}
-(void)PrepareUI
{
    DD_NavBtn *backBtn=[DD_NavBtn getBackBtn];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    NSString *title=nil;
    if([_code integerValue]==9000)
    {
        title=@"支付成功";
    }else
    {
        title=@"支付失败";
    }
    self.navigationItem.titleView=[regular returnNavView:title withmaxwidth:150];
    
}
#pragma mark - UIConfig
/**
 * 根据支付状态设置不同的界面
 */
-(void)UIConfig
{
//    System_paid
    NSString *title=nil;
    if([_code integerValue]==9000)
    {
        title=@"支付成功";
    }else
    {
        title=@"支付失败";
    }
    UIButton *btn=[UIButton getCustomBackImgBtnWithImageStr:@"System_paid" WithSelectedImageStr:nil];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(((ScreenHeight/2.0f)-kNavHeight-ktabbarHeight));
        make.height.width.mas_equalTo(72);
    }];
    
    UILabel *titleLabel=[UILabel getLabelWithAlignment:1 WithTitle:title WithFont:17.0f WithTextColor:nil WithSpacing:0];
    [self.view addSubview:titleLabel];
    titleLabel.font=[regular getSemiboldFont:17.0f];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(btn.mas_bottom).with.offset(10);
    }];
    [titleLabel sizeToFit];
    
    CGFloat _jiange=(ScreenWidth-121*2)/3.0f;
    NSArray *titleArr=@[@"查看订单",@"其他发布品"];
    for (int i=0; i<titleArr.count; i++) {
        UIButton *actionbtn=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:18.0f WithSpacing:0 WithNormalTitle:titleArr[i] WithNormalColor:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
        [self.view addSubview:actionbtn];
        actionbtn.backgroundColor=_define_black_color;
        [actionbtn mas_makeConstraints:^(MASConstraintMaker *make) {
            if(i==0)
            {
                [actionbtn addTarget:self action:@selector(checkOrderAction) forControlEvents:UIControlEventTouchUpInside];
                make.left.mas_equalTo(_jiange);
            }else
            {
                [actionbtn addTarget:self action:@selector(otherItemAction) forControlEvents:UIControlEventTouchUpInside];
                make.right.mas_equalTo(-_jiange);
            }
            make.width.mas_equalTo(121);
            make.height.mas_equalTo(40);
            make.top.mas_equalTo(titleLabel.mas_bottom).with.offset(47);
        }];
    }
    
}
#pragma mark - SomeAction
/**
 * 查看订单
 */
-(void)checkOrderAction
{
    [[JX_AFNetworking alloc] GET:@"order/queryTradeOrderInfo.do" parameters:@{@"tradeOrderCode":_tradeOrderCode,@"token":[DD_UserModel getToken]} success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            NSArray *getArr=[DD_OrderModel getOrderModelArr:[data objectForKey:@"orders"]];
            if(getArr.count)
            {
                DD_OrderModel *order=[getArr objectAtIndex:0];
                [self.navigationController pushViewController:[[DD_OrderDetailViewController alloc] initWithModel:order WithBlock:nil] animated:YES];

            }
            
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
}
/**
 * 其他发布品
 */
-(void)otherItemAction
{
    DD_GoodsViewController *goodView=[[DD_GoodsViewController alloc] init];
    goodView.noTabbar=YES;
    [self.navigationController pushViewController:goodView animated:YES];
}
/**
 * 返回结算界面之前的那个界面
 * type 类型 clear（结算页面处） order（订单列表处） detail_order（订单详情处）
 * 每个类型的返回页面有所差别 故分开处理
 */
-(void)backAction
{
    if([_type isEqualToString:@"clear"])
    {
        NSArray *controllers=self.navigationController.viewControllers;
        for (int i=0; i<controllers.count; i++) {
            id obj=controllers[i];
            if([obj isKindOfClass:[DD_ClearingViewController class]])
            {
                if(i>0)
                {
                    [self.navigationController popToViewController:controllers[i-1] animated:YES];
                }
            }
        }
    }else if([_type isEqualToString:@"order"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }else if([_type isEqualToString:@"detail_order"])
    {
        NSArray *controllers=self.navigationController.viewControllers;
        for (int i=0; i<controllers.count; i++) {
            id obj=controllers[i];
            if([obj isKindOfClass:[DD_OrderDetailViewController class]])
            {
                if(i>0)
                {
                    [self.navigationController popToViewController:controllers[i-1] animated:YES];
                }
            }
        }
    }
}
#pragma mark - Other
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"DD_ClearingDoneViewController"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"DD_ClearingDoneViewController"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
