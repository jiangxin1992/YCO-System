//
//  DD_SetPSW_forget_ViewController.m
//  DDAY
//
//  Created by yyj on 16/5/21.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_SetPSW_forget_ViewController.h"

#import "DD_LoginTextView.h"
#import "DD_LoginViewController.h"

@interface DD_SetPSW_forget_ViewController ()
//<UITextFieldDelegate>

@end

@implementation DD_SetPSW_forget_ViewController
{
    UITextField *_PSWTextfield;
    UITextField *_repeatPSWTextfield;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self UIConfig];
}
#pragma mark - UIConfig
-(void)UIConfig
{
    DD_NavBtn *backBtn=[DD_NavBtn getBackBtn];
    [self.view addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame=CGRectMake(10, kStatusBarHeight, CGRectGetWidth(backBtn.frame), CGRectGetHeight(backBtn.frame));
    [backBtn setEnlargeEdge:20];
    
    UILabel *title=[UILabel getLabelWithAlignment:1 WithTitle:@"密码找回" WithFont:IsPhone6_gt?18.0f:15.0f WithTextColor:nil WithSpacing:0];
    title.font=[regular getSemiboldFont:17.0f];
    [self.view addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(19+kStatusBarHeight);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(19);
        make.centerX.mas_equalTo(self.view);
    }];
    
    _PSWTextfield=[UITextField getTextFieldWithPlaceHolder:@"设置新密码" WithAlignment:0 WithFont:15.0f WithTextColor:nil WithLeftView:[[DD_LoginTextView alloc] initWithFrame:CGRectMake(0, 0, 35, 50) WithImgStr:@"Login_PWD" WithSize:CGSizeMake(17, 27) isLeft:YES WithBlock:^(NSString *type) {
        
    }] WithRightView:nil WithSecureTextEntry:YES];
    [self.view addSubview:_PSWTextfield];
    _PSWTextfield.returnKeyType=UIReturnKeyDone;
//    _PSWTextfield.delegate=self;
    [_PSWTextfield setBk_shouldReturnBlock:^BOOL(UITextField *textField) {
        [textField resignFirstResponder];
        return YES;
    }];
    [_PSWTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(50);
        make.right.mas_equalTo(-50);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(self.view).with.offset(IsPhone6_gt?204:kIPhone5s?150:126);
    }];
    
    _repeatPSWTextfield=[UITextField getTextFieldWithPlaceHolder:@"再次输入密码" WithAlignment:0 WithFont:15.0f WithTextColor:nil WithLeftView:[[DD_LoginTextView alloc] initWithFrame:CGRectMake(0, 0, 35, 50) WithImgStr:@"Login_PWD" WithSize:CGSizeMake(17, 27) isLeft:YES WithBlock:^(NSString *type) {
        
    }] WithRightView:nil WithSecureTextEntry:YES];
    [self.view addSubview:_repeatPSWTextfield];
    _repeatPSWTextfield.returnKeyType=UIReturnKeyDone;
//    _repeatPSWTextfield.delegate=self;
    __block DD_SetPSW_forget_ViewController *forgetVC=self;
    [_repeatPSWTextfield setBk_shouldReturnBlock:^BOOL(UITextField *textField) {
        [textField resignFirstResponder];
        [forgetVC doneAction];
        return YES;
    }];
    [_repeatPSWTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(50);
        make.right.mas_equalTo(-50);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(_PSWTextfield.mas_bottom).with.offset(IsPhone5_gt?18:11);
    }];
    
    UIButton *registerBtn=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:18.0f WithSpacing:20.0f WithNormalTitle:@"完    成" WithNormalColor:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
    registerBtn.backgroundColor=_define_black_color;
    [self.view addSubview:registerBtn];
    [registerBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(50);
        make.right.mas_equalTo(-50);
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(_repeatPSWTextfield.mas_bottom).with.offset(IsPhone5_gt?65:47);
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
 * 完成验证
 */
-(void)doneAction
{
    if([NSString isNilOrEmpty:_PSWTextfield.text]||[NSString isNilOrEmpty:_repeatPSWTextfield.text])
    {
        [self presentViewController:[regular alertTitle_Simple:NSLocalizedString(@"content_empty", @"")] animated:YES completion:nil];
    }else
    {
        if([_repeatPSWTextfield.text isEqualToString:_PSWTextfield.text])
        {
            if([regular checkPassword:_PSWTextfield.text])
            {
                [self enterDoneAction];
            }else
            {
                [self presentViewController:[regular alertTitle_Simple:NSLocalizedString(@"login_psw_form", @"")] animated:YES completion:nil];
            }
        }else
        {
            [self presentViewController:[regular alertTitle_Simple:NSLocalizedString(@"login_code_different", @"")] animated:YES completion:nil];
        }
    }
}

/**
 * 完成
 */
-(void)enterDoneAction
{
    NSDictionary *_parameters=@{@"phone":_phone,@"password":[regular md5:_PSWTextfield.text]};
    [[JX_AFNetworking alloc] GET:@"user/resetPasswrod.do" parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            NSArray *controllers=self.navigationController.viewControllers;
            [controllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if([obj isKindOfClass:[DD_LoginViewController class]])
                {
                    [self.navigationController popToViewController:obj animated:YES];
                }
            }];
            
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
}

#pragma mark - Ohers
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
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//    if(textField==_repeatPSWTextfield)
//    {
//        [self doneAction];
//    }
//
//    return YES;
//}

@end
