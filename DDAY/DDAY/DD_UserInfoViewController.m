//
//  DD_UserInfoViewController.m
//  DDAY
//
//  Created by yyj on 16/5/22.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_UserInfoViewController.h"

#import "QiniuSDK.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#import "DD_AlertViewController.h"
#import "DD_SexViewController.h"
#import "DD_UserInfo_AlertPSWViewController.h"
#import "DD_BodyViewController.h"
//#import "DD_AddressViewController.h"

#import "DD_UserCell.h"

#import "DD_UserInfoTool.h"

@interface DD_UserInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation DD_UserInfoViewController
{
    UITableView *_tableview;
    NSArray *_dataArr;
    NSDictionary *_datadict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self CreateTableView];
    if(_usermodel)
    {
        [_tableview reloadData];
        
    }else
    {
        [self RequestData];
    }
    
    
}
#pragma mark - 初始化
-(instancetype)initWithModel:(DD_UserModel *)usermodel WithBlock:(void (^)(NSString *type ,DD_UserModel *model))block
{
    self=[super init];
    if(self)
    {
        _block=block;
        _usermodel=usermodel;
    }
    return self;
}
-(instancetype)initWithBlock:(void (^)(NSString *type ,DD_UserModel *model))block
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
    _datadict=[DD_UserInfoTool getUserInfoListMap];
    _dataArr=[DD_UserInfoTool getUserInfoListArr];
}
-(void)PrepareUI
{
    self.navigationItem.titleView=[regular returnNavView:NSLocalizedString(@"user_info_title", @"") withmaxwidth:200];
}
-(void)RequestData
{
    [[JX_AFNetworking alloc] GET:@"user/queryUserInfo.do" parameters:@{@"token":[DD_UserModel getToken]} success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            _usermodel=[DD_UserModel getUserModel:[data objectForKey:@"user"]];
            if(_usermodel)
            {
                if([_usermodel.userType integerValue]!=[DD_UserModel getUserType])
                {
                    [regular UpdateRoot];
                }
                [_tableview reloadData];
                //                    [self RequestNewFansStatus];
            }
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
}
#pragma mark - SomeAction

/**
 * 跳转修改密码界面
 */
-(void)alertPSW
{
    DD_UserInfo_AlertPSWViewController *_AlertPSW=[[DD_UserInfo_AlertPSWViewController alloc] init];
    _AlertPSW.title=[_datadict objectForKey:@"alertPSW"];
    [self.navigationController pushViewController:_AlertPSW animated:YES ];
}
/**
 * 跳转昵称性别职业更改界面
 */
-(void)pushAlertViewWithContent:(NSString *)content WithTitle:(NSString *)title WithKey:(NSString *)key
{
    if([key isEqualToString:@"gender"])
    {
        DD_SexViewController *sexView=[[DD_SexViewController alloc] initWithModel:_usermodel WithSex:_usermodel.sex WithBlock:^(DD_UserModel *model) {
            _usermodel=model;
            _block(@"info_update",_usermodel);
            [_tableview reloadData];
        }];
        sexView.title=title;
        [self.navigationController pushViewController:sexView animated:YES];
    }else
    {
        DD_AlertViewController *_AlertView=[[DD_AlertViewController alloc] initWithModel:_usermodel WithKey:key WithContent:content WithBlock:^(DD_UserModel *model) {
            _usermodel=model;
            _block(@"info_update",_usermodel);
            [_tableview reloadData];
        }];
        _AlertView.title=title;
        [self.navigationController pushViewController:_AlertView animated:YES];

    }
}
/**
 * 跳转身材信息修改界面
 */
-(void)pushBodyViewWithTitle:(NSString *)title
{
    DD_BodyViewController *bodyView=[[DD_BodyViewController alloc] initWithModel:_usermodel WithBlock:^(DD_UserModel *model) {
        _usermodel=model;
        _block(@"info_update",_usermodel);
        [_tableview reloadData];
    }];
    bodyView.title=title;
    [self.navigationController pushViewController:bodyView animated:YES];
}
#pragma mark - 更换头像
/**
 * 更换头像
 */
-(void)ChangeHeadView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"") style:UIAlertActionStyleCancel handler:nil];

    UIAlertAction *take_photosAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"take_photos", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            //打开相机
            [self loadImageWithType:UIImagePickerControllerSourceTypeCamera];
        }else
        {
            JXLOG(@"不能打开相机");
        }
    }];
    
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"open_album", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            [self loadImageWithType:UIImagePickerControllerSourceTypePhotoLibrary];
        }else
        {
            JXLOG(@"无法打开相册");
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:take_photosAction];
    [alertController addAction:archiveAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
/**
 * 创建Alertview
 */
-(void)ShowAlertview:(NSString *)title
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [regular pushSystem];
    }];
    [alertController addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
/**
 * 弹出相机/相册
 */
-(void)pushPickerWithType:(UIImagePickerControllerSourceType)type
{
    //创建图片选取器
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    //设置选取器类型
    picker.sourceType = type;
    //编辑
    picker.allowsEditing = YES;
    if ([picker.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        NSArray *list=self.navigationController.navigationBar.subviews;
        
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView=(UIImageView *)obj;
                NSArray *list2=imageView.subviews;
                
                [list2 enumerateObjectsUsingBlock:^(id  _Nonnull obj2, NSUInteger idx2, BOOL * _Nonnull stop2) {
                    if ([obj2 isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView2=(UIImageView *)obj2;
                        imageView2.hidden=YES;
                    }
                }];
                
            }
        }];
    }
    //弹出
    [self presentViewController:picker animated:YES completion:nil];

}
/**
 * 打开相机/相册
 */
-(void)loadImageWithType:(UIImagePickerControllerSourceType)type
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (author == AVAuthorizationStatusRestricted || author == AVAuthorizationStatusDenied){
        
        [self presentViewController:[regular alertTitleCancel_Simple:NSLocalizedString(@"system_album", @"") WithBlock:^{
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }] animated:YES completion:nil];
    }else if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied)
    {
        [self presentViewController:[regular alertTitleCancel_Simple:NSLocalizedString(@"system_camera", @"") WithBlock:^{
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }] animated:YES completion:nil];
    }else
    {
        if(kIOSVersions_v9)
        {
            PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
            if (author == PHAuthorizationStatusDenied) {
                //无权限
                [self ShowAlertview:NSLocalizedString(@"system_album_no_root", @"")];
            }else{
                [self pushPickerWithType:type];
            }
            
        }else
        {
            //        相册
            ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
            if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
                //无权限
                [self ShowAlertview:NSLocalizedString(@"system_album_no_root", @"")];
            }else
            {
                [self pushPickerWithType:type];
            }
        }
    }
}
/**
 * 上传七牛文件后回调
 */
-(void)uploadImage:(NSString *)key
{
    [[JX_AFNetworking alloc] GET:@"user/qiNiuUpLoadCallBack.do" parameters:@{@"token":[DD_UserModel getToken],@"key":key} success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
//            更换头像
            _usermodel=[DD_UserModel getUserModel:[data objectForKey:@"user"]];
            [_tableview reloadData];
            _block(@"info_update",_usermodel);
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
}
#pragma mark - UIConfig

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
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picke
{
    [picke dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //    获取选择图片并选择适合的压缩比例
    UIImage *originImage = info[UIImagePickerControllerEditedImage];
    NSData *data1 = UIImageJPEGRepresentation(originImage, 0.5f);
    //    获取七牛上传文件所需的token(问后台要)
    [[JX_AFNetworking alloc] GET:@"user/getQiNiuToken.do" parameters:@{@"token":[DD_UserModel getToken]} success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            NSString *upLoadToken=[data objectForKey:@"upLoadToken"];
            
            //            通过qiniu sdk上传图片
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putData:data1 key:nil token:upLoadToken
                      complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          // statusCode200表示成功
                          if(info.statusCode==200)
                          {
                              //把这个返回的标示（key）传给后台
                              [self uploadImage:resp[@"key"]];
                          }else
                          {
                              [self presentViewController:[regular alertTitle_Simple:NSLocalizedString(@"system_img_upload_fail", @"")] animated:YES completion:nil];
                          }
                          
                      } option:nil];
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
    
    
}
#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
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

    NSString *_key=_dataArr[indexPath.section];
    if([_key isEqualToString:@"head"])
    {
        //获取到数据以后
        static NSString *cellid=@"cell_head";
        DD_UserCell *cell=[_tableview dequeueReusableCellWithIdentifier:cellid];
        if(!cell)
        {
            cell=[[DD_UserCell alloc] initWithImageStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        }
        cell.image=_usermodel.head;
        cell.title=[_datadict objectForKey:_dataArr[indexPath.section]];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }

    //获取到数据以后
    static NSString *cellid=@"cell_f_title";
    DD_UserCell *cell=[_tableview dequeueReusableCellWithIdentifier:cellid];
    if(!cell)
    {
        cell=[[DD_UserCell alloc] initWithF_titleStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    cell.title=[_datadict objectForKey:_dataArr[indexPath.section]];
    NSString *_f_title=nil;
    if([_key isEqualToString:@"nickname"])
    {
        _f_title=_usermodel.nickName;
    }else if([_key isEqualToString:@"sex"])
    {
        _f_title=[_usermodel getSexStr];
        
    }else if([_key isEqualToString:@"career"])
    {
        _f_title=_usermodel.career;
    }else if([_key isEqualToString:@"body"])
    {
        
        if([_usermodel.height integerValue]!=0&&[_usermodel.weight integerValue]!=0)
        {
            _f_title=[[NSString alloc] initWithFormat:@"%@/%@",_usermodel.height,_usermodel.weight];
        }else
        {
            _f_title=@"";
        }
    }else
    {
        _f_title=@"";
    }
    cell.f_title=_f_title;
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *_key=_dataArr[indexPath.section];
    if([_key isEqualToString:@"head"])
    {
        //        更换头像
        [self ChangeHeadView];
        
    }else if([_key isEqualToString:@"nickname"])
    {
        
        //        更换昵称
        [self pushAlertViewWithContent:_usermodel.nickName WithTitle:[_datadict objectForKey:@"nickname"] WithKey:@"nickName"];

    }else if([_key isEqualToString:@"sex"])
    {
        //        更改性别
        [self pushAlertViewWithContent:[_usermodel getSexStr] WithTitle:[_datadict objectForKey:@"sex"] WithKey:@"gender"];
        
        
    }else if([_key isEqualToString:@"career"])
    {
        //        更改职业
        [self pushAlertViewWithContent:_usermodel.career WithTitle:[_datadict objectForKey:@"career"] WithKey:@"career"];
        
    }else if([_key isEqualToString:@"body"])
    {
        //        更改身材信息
        [self pushBodyViewWithTitle:[_datadict objectForKey:@"body"]];
        
    }
//    else if([_key isEqualToString:@"address"])
//    {
//        //        跳转收获地址管理界面
//        [self pushAddressView];
//    }
}


#pragma mark - Other
-(void)viewWillAppear:(BOOL)animated
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
