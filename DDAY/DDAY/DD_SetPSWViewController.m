//
//  DD_SetPSWViewController.m
//  DDAY
//
//  Created by yyj on 16/5/21.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_SetPSWViewController.h"

#import "DD_LoginViewController.h"
#import "DD_GoodsViewController.h"
#import "DD_CustomViewController.h"

#import "DD_LoginTextView.h"

@interface DD_SetPSWViewController ()
//<UITextFieldDelegate>

@end

@implementation DD_SetPSWViewController
{
    UITextField *_PSWTextfield;
    BOOL _isInRegister;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self UIConfig];
    
}
-(instancetype)initWithParameters:(NSDictionary *)parameters WithThirdPartLogin:(NSInteger )thirdPartLogin WithBlock:(void (^)(NSString *type))successblock
{
    self=[super init];
    if(self)
    {
        _parameters=parameters;
        _thirdPartLogin=thirdPartLogin;
        _successblock=successblock;
    }
    return self;
}
#pragma mark - UIConfig
-(void)UIConfig
{
    _isInRegister=NO;
    DD_NavBtn *backBtn=[DD_NavBtn getBackBtn];
    [self.view addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame=CGRectMake(10, kStatusBarHeight, CGRectGetWidth(backBtn.frame), CGRectGetHeight(backBtn.frame));
    [backBtn setEnlargeEdge:20];
    
    UILabel *title=[UILabel getLabelWithAlignment:1 WithTitle:@"注册账号" WithFont:IsPhone6_gt?18.0f:15.0f WithTextColor:nil WithSpacing:0];
    title.font=[regular getSemiboldFont:17.0f];
    [self.view addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(19+kStatusBarHeight);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(19);
        make.centerX.mas_equalTo(self.view);
    }];
    
    _PSWTextfield=[UITextField getTextFieldWithPlaceHolder:@"设置登录密码" WithAlignment:0 WithFont:15.0f WithTextColor:nil WithLeftView:[[DD_LoginTextView alloc] initWithFrame:CGRectMake(0, 0, 35, 50) WithImgStr:@"Login_PWD" WithSize:CGSizeMake(17, 27) isLeft:YES WithBlock:^(NSString *type) {
        
    }] WithRightView:nil WithSecureTextEntry:YES];
    [self.view addSubview:_PSWTextfield];
    _PSWTextfield.returnKeyType=UIReturnKeyDone;
//    _PSWTextfield.delegate=self;
    __block DD_SetPSWViewController *setVC=self;
    [_PSWTextfield setBk_shouldReturnBlock:^BOOL(UITextField *textField) {
        [textField resignFirstResponder];
        [setVC registerAction];
        return YES;
    }];
    [_PSWTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(50);
        make.right.mas_equalTo(-50);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(self.view).with.offset((IsPhone6_gt?250:kIPhone5s?196:165)+kStatusBarHeight);
    }];
    
    UIButton *registerBtn=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:18.0f WithSpacing:20.0f WithNormalTitle:@"注    册" WithNormalColor:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
    registerBtn.backgroundColor=_define_black_color;
    [self.view addSubview:registerBtn];
    [registerBtn addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(50);
        make.right.mas_equalTo(-50);
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(_PSWTextfield.mas_bottom).with.offset(IsPhone5_gt?45:28);
    }];
}
#pragma mark - SomeAction
/**
 * 返回
 */
-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 * 注册验证
 */
-(void)registerAction
{
    if([NSString isNilOrEmpty:_PSWTextfield.text])
    {
        [self presentViewController:[regular alertTitle_Simple:NSLocalizedString(@"content_empty", @"")] animated:YES completion:nil];
    }else
    {
        if([regular checkPassword:_PSWTextfield.text])
        {
            [self enterRegisterAction];
        }else
        {
            [self presentViewController:[regular alertTitle_Simple:NSLocalizedString(@"login_psw_form", @"")] animated:YES completion:nil];
        }
    }
}

/**
 * 注册
 */
-(void)enterRegisterAction
{
    if(!_isInRegister)
    {
        JXLOG(@"----register-time----");
        if(_thirdPartLogin==1)
        {
            _isInRegister=YES;
            NSDictionary *parameters=@{@"phone":_phone,@"password":[regular md5:_PSWTextfield.text],@"deviceToken":[DD_UserModel getDeviceToken]};
            [[JX_AFNetworking alloc] GET:@"user/v1_0_7/regist.do" parameters:parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
                _isInRegister=NO;
                if(success)
                {
                    // 本地化数据
                    [DD_UserModel setLocalUserInfo:data];
                    // 更新当前权限状态
                    //            [regular UpdateRoot];
                    // 更新友盟用户统计和渠道
                    [regular updateProfileSignInWithPUID];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"rootChange" object:@"login"];
                    [((DD_CustomViewController *)[DD_CustomViewController sharedManager]).goodsCtn loadNewData];
                    _successblock(@"success");
                    //            回到登录发起页面
                    NSArray *controllers=self.navigationController.viewControllers;
                    [controllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if([obj isKindOfClass:[DD_LoginViewController class]])
                        {
                            if(idx>0)
                            {
                                [self.navigationController popToViewController:controllers[idx-1] animated:YES];
                            }
                        }
                    }];
                    
                }else
                {
                    [self presentViewController:successAlert animated:YES completion:nil];
                }
                
            } failure:^(NSError *error, UIAlertController *failureAlert) {
                _isInRegister=NO;
                [self presentViewController:failureAlert animated:YES completion:nil];
            }];
        }else
        {
            _isInRegister=YES;
            NSMutableDictionary *parameters=[[NSMutableDictionary alloc] initWithDictionary:_parameters];
            [parameters setValue:_phone forKey:@"phone"];
            [parameters setValue:[regular md5:_PSWTextfield.text] forKey:@"password"];
            [parameters setValue:[DD_UserModel getDeviceToken] forKey:@"deviceToken"];
            [[JX_AFNetworking alloc] GET:@"user/v1_0_7/thirdPlatFormRegistSucess.do" parameters:parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
                _isInRegister=NO;
                if(success)
                {
                    // 本地化数据
                    [DD_UserModel setLocalUserInfo:data];
                    // 更新当前权限状态
                    //            [regular UpdateRoot];
                    // 更新友盟用户统计和渠道
                    [regular updateProfileSignInWithPUID];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"rootChange" object:@"login"];
                    [((DD_CustomViewController *)[DD_CustomViewController sharedManager]).goodsCtn loadNewData];
                    _successblock(@"success");
                    //            回到登录发起页面
                    NSArray *controllers=self.navigationController.viewControllers;
                    [controllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if([obj isKindOfClass:[DD_LoginViewController class]])
                        {
                            if(idx>0)
                            {
                                [self.navigationController popToViewController:controllers[idx-1] animated:YES];
                            }
                        }
                    }];
                    
                }else
                {
                    [self presentViewController:successAlert animated:YES completion:nil];
                }
            } failure:^(NSError *error, UIAlertController *failureAlert) {
                _isInRegister=NO;
                [self presentViewController:failureAlert animated:YES completion:nil];
            }];
        }
    }
}

#pragma mark - Other
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [regular dismissKeyborad];
}
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
    
}
//#pragma mark - UITextFieldDelegate
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//    if(textField == _PSWTextfield)
//    {
//
//        [self registerAction];
//    }
//    return YES;
//}
@end
