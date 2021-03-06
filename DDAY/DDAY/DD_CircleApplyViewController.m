//
//  DD_CircleApplyViewController.m
//  DDAY
//
//  Created by yyj on 16/6/23.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_CircleApplyViewController.h"

#import "QiniuSDK.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#import "DD_CircleCustomTagViewController.h"
#import "DD_CircleApplyDesignerViewController.h"
#import "DD_CricleShowViewController.h"
#import "DD_CirclePushlishPreViewController.h"
//#import "DD_RemarksViewController.h"

#import "DD_CircleApplyInfoView.h"
#import "DD_CircleChooseDetailView.h"
#import "DD_CircleTagsView.h"
#import "DD_CircleInfoImgView.h"
#import "DD_CircleFitPersonView.h"
#import "DD_CircleChooseStyleView.h"

#import "DD_CirclePublishTool.h"
#import "DD_CircleFavouriteDesignerModel.h"
#import "DD_CircleModel.h"
#import "DD_CricleChooseItemModel.h"

@interface DD_CircleApplyViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation DD_CircleApplyViewController
{
    UIScrollView *_scrollView;
    DD_CircleModel *_CircleModel;//发布视图model
    
    DD_CircleApplyInfoView *_infoView;//交互视图
    UIView *container;//_scrollView的view
    
    UILabel *statusLabel;
    
    UIButton *_preView;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SomePrepare];
    [self UIConfig];
    
    [self RequestData];
}
#pragma mark - 初始化
-(instancetype)initWithBlock:(void (^)(NSString *))block
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
    //    获取初始化 搭配model
    _CircleModel=[DD_CircleModel getCircleModel];
    [regular UpdateRoot];
}
-(void)PrepareUI{}
#pragma mark - RequestData
-(void)RequestData
{
    [self getStatus];
}
-(void)getStatus
{
/**
 * 0：申请中，1通过，2不通过 -1表示还未申请
 */
    [[JX_AFNetworking alloc] GET:@"share/getApplyStatus.do" parameters:@{@"token":[DD_UserModel getToken]} success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            _CircleModel.status=[[data objectForKey:@"status"] integerValue];
            NSString *nav_title=@"";
            if(_CircleModel.status==-1)
            {
                nav_title=@"申请成为达人";
                [self CreateContentView];
            }else if(_CircleModel.status==0)
            {
                nav_title=@"审核中";
                [self CreateStatusLabel:@"审核中"];
                
            }else if(_CircleModel.status==1)
            {
                nav_title=@"成功变身达人";
                [self CreateStatusLabel:@"成功变身达人"];
            }else if(_CircleModel.status==2)
            {
                nav_title=@"申请被拒";
                [self CreateContentView];
            }
            self.navigationItem.titleView=[regular returnNavView:nav_title withmaxwidth:200];
            
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
}

-(void)getTags
{
    NSDictionary *_parameters=@{@"token":[DD_UserModel getToken]};
    [[JX_AFNetworking alloc] GET:@"share/queryTags.do" parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            //            更新_detailModel
            [DD_CirclePublishTool SetWithDict:data WithCircleModel:_CircleModel];
            //            更新标签和适合人群视图
            [_infoView.tagsView setState];
            [_infoView.fitPersonView setState];
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
    [self CreateScrollView];
    
}
-(void)CreateScrollView
{
    _scrollView=[[UIScrollView alloc] init];
    [self.view addSubview:_scrollView];
    container = [UIView new];
    [_scrollView addSubview:container];
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_scrollView);
        make.width.mas_equalTo(_scrollView);
    }];
}
-(void)CreateTabbar
{
    _preView=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:18.0f WithSpacing:0 WithNormalTitle:@"预   览" WithNormalColor:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
    [self.view addSubview:_preView];
    _preView.backgroundColor=_define_black_color;
    [_preView addTarget:self action:@selector(SubmitAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_preView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kInteractionHeight);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-kSafetyZoneHeight);
    }];
}
-(void)CreateContentView
{
    //    创建搭配界面
    [self CreateInforView];
    [self getTags];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-kTabbarHeight);
        // 让scrollview的contentSize随着内容的增多而变化
        make.bottom.mas_equalTo(_infoView.mas_bottom).with.offset(0);
    }];
    [self CreateTabbar];
}
-(void)CreateInforView
{
    _infoView=[[DD_CircleApplyInfoView alloc] initWithCircleModel:_CircleModel WithBlock:^(NSString *type,long index) {

        if([type isEqualToString:@"chooseStyle"])
        {
            //            款式选择
            [self PushChooseDetailView];
        }else if([type isEqualToString:@"choose_pic"])
        {
            //            选择搭配图
            [self ChooseImg];
        }else if([type isEqualToString:@"show_pic"])
        {
            //            显示搭配图
            [self ShowImgWithIndex:index];
        }
        else if([type isEqualToString:@"choose_item"])
        {
            //            款式选择视图更新
            [_infoView.chooseStyleView updateImageView];
        }else if([type isEqualToString:@"submit"])
        {
            //            提交
            [self SubmitAction];
        }else if([type isEqualToString:@"delete_choose_item"])
        {
            //            删除已选款式
            [self deleteChooseItem:index];
            
        }else if([type isEqualToString:@"person_tag_delete"])
        {
            //            适合人群标签删除
            [DD_CirclePublishTool TagDelete:index WithType:2 WithCircleModel:_CircleModel];
            [_infoView.fitPersonView setState];
        }else if([type isEqualToString:@"person_tag_add"])
        {
            //            适合人群标签添加
            [DD_CirclePublishTool TagAdd:index WithType:2 WithCircleModel:_CircleModel];
            [_infoView.fitPersonView setState];
        }else if([type isEqualToString:@"circle_tag_delete"])
        {
            //            标签删除
            [DD_CirclePublishTool TagDelete:index WithType:1 WithCircleModel:_CircleModel];
            [_infoView.tagsView setState];
        }else if([type isEqualToString:@"circle_tag_add"])
        {
            //            标签添加
            [DD_CirclePublishTool TagAdd:index WithType:1 WithCircleModel:_CircleModel];
            [_infoView.tagsView setState];
        }else if([type isEqualToString:@"add_custom_tag"])
        {
            //            添加自定义标签
            [self CustomTag];
        }else if([type isEqualToString:@"delete_pic"])
        {
            [self DeleteImgWithIndex:index];
        }else if([type isEqualToString:@"num_limit"])
        {
            [self presentViewController:[regular alertTitle_Simple:@"搭配建议不能超过200字"] animated:YES completion:nil];
        }
    }];
    [container addSubview:_infoView];
    [_infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(container.mas_left).with.offset(0);
        make.right.mas_equalTo(container.mas_right).with.offset(0);
        make.top.mas_equalTo(container.mas_top).with.offset(0);
    }];
    
}
-(void)CreateStatusLabel:(NSString *)str
{
    statusLabel=[[UILabel alloc] init];
    [self.view addSubview:statusLabel];
    statusLabel.text=str;
    statusLabel.textAlignment=1;
    statusLabel.font=[regular getFont:25];
    statusLabel.textColor=_define_light_gray_color1;
    
    [statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.left.and.right.mas_equalTo(0);
        make.height.mas_equalTo(300);
    }];
    
    [_preView removeFromSuperview];
}
#pragma mark - SomeAction
-(void)backAction
{
    if(_CircleModel.status==-1||_CircleModel.status==2)
    {
        [self presentViewController:[regular alertTitleCancel_Simple:@"放弃编辑？" WithBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }] animated:YES completion:nil];
    }else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
-(void)DeleteImgWithIndex:(long )index
{
    NSDictionary *_parameters=@{@"token":[DD_UserModel getToken],@"key":[_CircleModel.picArr[index] objectForKey:@"key"]};
    [[JX_AFNetworking alloc] GET:@"file/deleteQiNiuFile.do" parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            [_CircleModel.picArr removeObjectAtIndex:index];
            [_infoView.imgView setState];
        }else
        {
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        [self presentViewController:failureAlert animated:YES completion:nil];
    }];
    
}
/**
 * 提交
 */
-(void)SubmitAction
{
    if([_CircleModel.remark isEqualToString:@""])
    {
        [self presentViewController:[regular alertTitle_Simple:@"请填写搭配建议"] animated:YES completion:nil];
    }else if(_CircleModel.chooseItem.count==0)
    {
        [self presentViewController:[regular alertTitle_Simple:@"请先选择款式"] animated:YES completion:nil];
    }else if(_CircleModel.picArr.count==0)
    {
        [self presentViewController:[regular alertTitle_Simple:@"请先上传搭配图"] animated:YES completion:nil];
    }
    else if([_CircleModel.designerModel.likeDesignerName isEqualToString:@""])
    {
        [self presentViewController:[regular alertTitle_Simple:@"请先选择设计师"] animated:YES completion:nil];
    }else if([_CircleModel.designerModel.likeReason isEqualToString:@""])
    {
        [self presentViewController:[regular alertTitle_Simple:@"请先填写理由"] animated:YES completion:nil];
    }else
    {
        DD_CirclePushlishPreViewController *PreView=[[DD_CirclePushlishPreViewController alloc] initWithCircleModel:_CircleModel WithType:@"apply" WithBlock:^(NSString *type) {
            if([type isEqualToString:@"update_status"])
            {
                [_scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [obj removeFromSuperview];
                }];

                NSString *nav_title=@"";
                if(_CircleModel.status==-1)
                {
                    nav_title=@"申请成为达人";
                    [self CreateContentView];
                }else if(_CircleModel.status==0)
                {
                    nav_title=@"审核中";
                    [self CreateStatusLabel:@"审核中"];
    
                }else if(_CircleModel.status==1)
                {
                    nav_title=@"成功变身达人";
                    [self CreateStatusLabel:@"成功变身达人"];
                }else if(_CircleModel.status==2)
                {
                    nav_title=@"申请被拒";
                    [self CreateContentView];
                }
                self.navigationItem.titleView=[regular returnNavView:nav_title withmaxwidth:200];
            }
        }];
        [self.navigationController pushViewController:PreView animated:YES];
        
    }
}
/**
 * 跳转自定义标签界面
 */
-(void)CustomTag
{
    [self.navigationController pushViewController:[[DD_CircleCustomTagViewController alloc] initWithCircleModel:_CircleModel WithBlock:^(NSString *type, DD_CricleTagItemModel *tagModel) {
        //        添加新的标签
        if([type isEqualToString:@"add_new_tag"])
        {
            //            _detailModel中添加新的自定义tag
            [DD_CirclePublishTool addCustomModel:tagModel WithCircleModel:_CircleModel];
            //            tagsview更新
            [_infoView.tagsView setState];
        }
    }] animated:YES];
}
/**
 * 选择最喜爱的设计师
 */
//-(void)ChooseFavouriteDesigner
//{
//    [self.navigationController pushViewController:[[DD_CircleApplyDesignerViewController alloc] initWithBlock:^(NSString *type,DD_CircleApplyDesignerModel *designer) {
//        if([type isEqualToString:@"choose_design"])
//        {
//            _CircleModel.designerModel.likeDesignerId=designer.designerId;
//            _CircleModel.designerModel.likeDesignerName=designer.designerName;
//            [_infoView.designerView setState];
//        }
//    }] animated:YES];
//}
/**
 * 跳转填写备注界面
 */
//-(void)PushRemarksViewWithNum:(NSInteger )num WithType:(NSString *)_type
//{
//    NSString *pushStr=@"";
//    NSString *title=@"";
//    if([_type isEqualToString:@"suggest_remarks"])
//    {
//        pushStr=_CircleModel.remark;
//        title=@"搭配建议";
//    }else if([_type isEqualToString:@"like_reason_remarks"])
//    {
//        pushStr=_CircleModel.designerModel.likeReason;
//        title=@"喜爱ta的理由";
//    }
//    
//    [self.navigationController pushViewController:[[DD_RemarksViewController alloc] initWithRemarks:pushStr WithLimit:num WithTitle:title WithBlock:^(NSString *type, NSString *content) {
//        //        备注界面点击完成
//        if([type isEqualToString:@"done"])
//        {
//            if(_infoView)
//            {
//                if([_type isEqualToString:@"suggest_remarks"])
//                {
//                    //                remarksview中更新内容
//                    [_infoView.remarksView setRemarksWithWebView:content];
//                    //                _detailModel中更新备注内容
//                    _CircleModel.remark=content;
//                }else if([_type isEqualToString:@"like_reason_remarks"])
//                {
//                    //                likeReasonView中更新内容
//                    [_infoView.likeReasonView setRemarksWithWebView:content];
//                    //                _detailModel中更新备注内容
//                    _CircleModel.designerModel.likeReason=content;
//                }
//            }
//        }
//    }] animated:YES];
//}
/**
 * 跳转款式选择界面
 */
-(void)PushChooseDetailView
{
    [self.navigationController pushViewController:[[DD_CircleChooseDetailView alloc] initWithCircleModel:_CircleModel WithLimitNum:5 WithBlock:^(NSString *type,NSInteger index) {
        if([type isEqualToString:@"choose_item"])
        {
            //            款式选择视图更新
            [_infoView.chooseStyleView updateImageView];
        }else if([type isEqualToString:@"delete_choose_item"])
        {
            [_infoView.chooseStyleView updateImageView];
        }
    }] animated:YES];
}
/**
 * 删除已选款式
 */
-(void)deleteChooseItem:(NSInteger )index
{   
    //            删除已选款式
    DD_CricleChooseItemModel *item=_CircleModel.chooseItem[index];
    //    删除item 对应的已选款式
    item.isSelect=NO;
    [DD_CirclePublishTool delChooseItemModel:item WithCircleModel:_CircleModel];
    [_infoView.chooseStyleView updateImageView];
}
/**
 * 选择搭配图
 */
-(void)ChooseImg
{
    if(_CircleModel.picArr.count<8)
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
    }else
    {
        [self presentViewController:[regular alertTitle_Simple:@"最多可上传8张搭配图"] animated:YES completion:nil];
    }
    
}
/**
 * 跳转搭配图放大视图
 */
-(void)ShowImgWithIndex:(long )index
{
    
    [self.navigationController pushViewController:[[DD_CricleShowViewController alloc] initWithCircleModel:_CircleModel WithIndex:index WithBlock:^(NSString *type) {
        if([type isEqualToString:@"delete"])
        {
            [_CircleModel.picArr removeObjectAtIndex:index];
            [_infoView.imgView setState];
        }
    }] animated:YES];
}
#pragma mark - 打开相册
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
    picker.allowsEditing = NO;
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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [regular dismissKeyborad];
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

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picke
{
    [picke dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //    获取选择图片
    UIImage *originImage = info[UIImagePickerControllerOriginalImage];
    //    压缩比例0.8
    NSData *data1 = UIImageJPEGRepresentation(originImage, 0.8f);
    //    获取七牛上传文件所需的token
    [[JX_AFNetworking alloc] GET:@"user/getQiNiuToken.do" parameters:@{@"token":[DD_UserModel getToken]} success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            NSString *upLoadToken=[data objectForKey:@"upLoadToken"];
            
            //            上传qiniu
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putData:data1 key:nil token:upLoadToken
                      complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          if(info.statusCode==200)
                          {
                              [_CircleModel.picArr addObject:@{
                                                               @"key":resp[@"key"]
                                                               ,@"data":originImage}];
                              [_infoView.imgView setState];
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
