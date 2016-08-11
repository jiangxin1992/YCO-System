//
//  DD_BaseViewController.m
//  DDAY
//
//  Created by yyj on 16/5/20.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_BaseViewController.h"

#import "DD_LoginViewController.h"

@interface DD_BaseViewController ()

@end

@implementation DD_BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=_define_backview_color;
    
    self.navigationController.navigationBar.barTintColor = _define_white_color;
    //   应对导航栏黑线问题（异常）
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        NSArray *list=self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView=(UIImageView *)obj;
                NSArray *list2=imageView.subviews;
                for (id obj2 in list2) {
                    if ([obj2 isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView2=(UIImageView *)obj2;
                        imageView2.hidden=YES;
                    }
                }
            }
        }
    }
    DD_NavBtn *backBtn=[DD_NavBtn getBackBtn];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
}
-(void)hideBackNavBtn
{
    self.navigationItem.leftBarButtonItem=nil;
}
/**
 * 跳转登录界面
 */
-(void)pushLoginView
{
    if(![DD_UserModel isLogin])
    {
        DD_LoginViewController *_login=[[DD_LoginViewController alloc] initWithBlock:^(NSString *type) {
            if([type isEqualToString:@"success"])
            {
                
            }
        }];
        [self.navigationController pushViewController:_login animated:YES];
    }
}
-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[DD_CustomViewController sharedManager] tabbarHide];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
