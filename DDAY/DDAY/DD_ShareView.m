//
//  DD_ShareView.m
//  YCO SPACE
//
//  Created by yyj on 16/8/22.
//  Copyright © 2016年 YYJ. All rights reserved.
//

#import "DD_ShareView.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>

#import "DD_CustomBtn.h"

#import "DD_ShareTool.h"

@implementation DD_ShareView
{
    NSDictionary *ListMap;
    NSArray *ListArr;
}

#pragma mark - 初始化
-(instancetype)initWithTitle:(NSString *)title Content:(NSString *)content WithImg:(NSString *)img WithBlock:(void(^)(NSString *type))block
{
    self=[super init];
    if(self)
    {
        _block=block;
        _title=title;
        _content=content;
        _img=img;
        [self SomePrepare];
        [self UIConfig];
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
    ListMap=[DD_ShareTool getShareListMap];
    ListArr=[DD_ShareTool getShareListArr];
}
-(void)PrepareUI{}

#pragma mark - UIConfig
-(void)UIConfig
{
//    getShareListMap
//    getShareListArr
    self.backgroundColor=_define_white_color;
    UILabel *labelTitle=[UILabel getLabelWithAlignment:2 WithTitle:@"分享到" WithFont:15.0f WithTextColor:nil WithSpacing:0];
    [self addSubview:labelTitle];
    [labelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.width.mas_equalTo(83);
        make.left.mas_equalTo(0);
    }];
    [labelTitle sizeToFit];
    
    
    CGFloat _jiange_x=(ScreenWidth-50*4-(IsPhone6_gt?35:25)*2)/3.0f;
    UIView *lastView=nil;
    for (int i=0; i<ListArr.count; i++) {
        DD_CustomBtn *btn=[DD_CustomBtn getCustomImgBtnWithImageStr:[ListMap objectForKey:[ListArr objectAtIndex:i]] WithSelectedImageStr:nil];
        [self addSubview:btn];
        btn.type=[ListArr objectAtIndex:i];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            if(i%4==0)
            {
                make.left.mas_equalTo(IsPhone6_gt?35:25);
            }else
            {
                make.left.mas_equalTo(lastView.mas_right).with.offset(_jiange_x);
            }
            make.width.height.mas_equalTo(50);
            if(i/4==0)
            {
                make.top.mas_equalTo(labelTitle.mas_bottom).with.offset(20);
            }else
            {
                make.top.mas_equalTo(lastView.mas_bottom).with.offset(20);
            }
        }];
        lastView=btn;
    }
    
    UIButton *cancelBtn=[UIButton getCustomTitleBtnWithAlignment:0 WithFont:18.0f WithSpacing:0 WithNormalTitle:@"取   消" WithNormalColor:_define_white_color WithSelectedTitle:nil WithSelectedColor:nil];
    [self addSubview:cancelBtn];
    cancelBtn.backgroundColor=_define_black_color;
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(ktabbarHeight);
    }];
    
}
-(void)cancelAction
{
    _block(@"cancel");
}
-(void)btnClick:(DD_CustomBtn *)btn
{
    NSString *_type=btn.type;
    if([_type isEqualToString:@"wechat"])
    {
//        微信
        [self ShareActionWithType:SSDKPlatformSubTypeWechatSession];
    }else if([_type isEqualToString:@"wechat_friend"])
    {
//        朋友圈
        [self ShareActionWithType:SSDKPlatformSubTypeWechatTimeline];
    }else if([_type isEqualToString:@"sina"])
    {
//        微博
        [self ShareActionWithType:SSDKPlatformTypeSinaWeibo];
    }else if([_type isEqualToString:@"qq"])
    {
//        QQ
        [self ShareActionWithType:SSDKPlatformSubTypeQQFriend];
    }else if([_type isEqualToString:@"copy"])
    {
//        复制
        [self ShareActionWithType:SSDKPlatformTypeCopy];
    }
}
-(void)ShareActionWithType:(SSDKPlatformType )platformType
{
    //1、创建分享参数（必要）
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:_content
                                     images:[UIImage imageNamed:_img]
                                        url:[NSURL URLWithString:@"http://mob.com"]
                                      title:_title
                                       type:SSDKContentTypeAuto];
    
    // 定制新浪微博的分享内容
//    [shareParams SSDKSetupSinaWeiboShareParamsByText:@"定制新浪微博的分享内容" title:nil image:[UIImage imageNamed:@"传入的图片名"] url:nil latitude:0 longitude:0 objectID:nil type:SSDKContentTypeAuto];
//    // 定制微信好友的分享内容
//    [shareParams SSDKSetupWeChatParamsByText:@"定制微信的分享内容" title:@"title" url:[NSURL URLWithString:@"http://mob.com"] thumbImage:nil image:[UIImage imageNamed:@"传入的图片名"] musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeAuto forPlatformSubType:SSDKPlatformSubTypeWechatSession];// 微信好友子平台
    
    //2、分享
    [ShareSDK share:platformType parameters:shareParams onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        _block(@"cancel");
        
        switch (state) {
                
            case SSDKResponseStateBegin:
            {
                break;
            }
            case SSDKResponseStateSuccess:
            {
                NSString *title=nil;
                //Facebook Messenger、WhatsApp等平台捕获不到分享成功或失败的状态，最合适的方式就是对这些平台区别对待
                if (platformType == SSDKPlatformTypeFacebookMessenger)
                {
                    break;
                }else if(platformType==SSDKPlatformTypeCopy)
                {
                    title=@"已复制";
                    
                }else
                {
                    title=@"分享成功";
                    
                }
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
                
                
                break;
            }
            case SSDKResponseStateFail:
            {
                if (platformType == SSDKPlatformTypeSMS && [error code] == 201)
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                    message:@"失败原因可能是：1、短信应用没有设置帐号；2、设备不支持短信应用；3、短信应用在iOS 7以上才能发送带附件的短信。"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    break;
                }
                else if(platformType == SSDKPlatformTypeMail && [error code] == 201)
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                    message:@"失败原因可能是：1、邮件应用没有设置帐号；2、设备不支持邮件应用；"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    break;
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                    message:[NSString stringWithFormat:@"%@",error]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    break;
                }
                break;
            }
            case SSDKResponseStateCancel:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享已取消"
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
                break;
            }
            default:
                break;
        }
    }];
}
@end