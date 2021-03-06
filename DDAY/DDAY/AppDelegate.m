//
//  AppDelegate.m
//  DDAY
//
//  Created by yyj on 16/5/19.
//  Copyright © 2016年 YYJ. All rights reserved.
//
//
//                            _ooOoo_
//                           o8888888o
//                           88" . "88
//                           (| -_- |)
//                            O\ = /O
//                        ____/`---'\____
//                      .   ' \\| |// `.
//                       / \\||| : |||// \
//                     / _||||| -:- |||||- \
//                       | | \\\ - /// | |
//                     | \_| ''\---/'' | |
//                      \ .-\__ `-` ___/-. /
//                   ___`. .' /--.--\ `. . __
//                ."" '< `.___\_<|>_/___.' >'"".
//               | | : `- \`.;`\ _ /`;.`/ - ` : | |
//                 \ \ `-. \_ __\ /__ _/ .-` / /
//         ======`-.____`-.___\_____/___.-`____.-'======
//                            `=---='
//
//         .............................................
//                  佛祖镇楼                  BUG辟易
//          佛曰:
//                  写字楼里写字间，写字间里程序员；
//                  程序人员写程序，又拿程序换酒钱。
//                  酒醒只在网上坐，酒醉还来网下眠；
//                  酒醉酒醒日复日，网上网下年复年。
//                  但愿老死电脑间，不愿鞠躬老板前；
//                  奔驰宝马贵者趣，公交自行程序员。
//                  别人笑我忒疯癫，我笑自己命太贱；
//                  不见满街漂亮妹，哪个归得程序员？

#import "AppDelegate.h"

#import "DD_StartViewController.h"
#import "DD_StartViewPlayer.h"
#import "DD_CustomViewController.h"

//支付宝
#import <AlipaySDK/AlipaySDK.h>

#import <UserNotifications/UserNotifications.h>

//ShareSDK
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//新浪微博SDK头文件<
#import "WeiboSDK.h"

#import <Bugly/Bugly.h>

#import "DD_NOTInformClass.h"

#define kGtAppId           @"xj4QqJvMWb6XvatHms1gx2"
#define kGtAppKey          @"IgCKHHEC326WiTBEZv8Nx1"
#define kGtAppSecret       @"dk9YyBRyA0AhoSUht6QbL5"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate
{
    BOOL _is_first_register;//是否是第一次提交设备token
    DD_StartViewPlayer *_startPlayer;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _is_first_register=YES;

    [UITableView appearance].estimatedRowHeight = 0;
    [UITableView appearance].estimatedSectionHeaderHeight = 0;
    [UITableView appearance].estimatedSectionFooterHeight = 0;

    [Bugly startWithAppId:@"900056338"];

    /**初始化ShareSDK应用

     @param activePlatforms
     使用的分享平台集合
     @param importHandler (onImport)
     导入回调处理，当某个平台的功能需要依赖原平台提供的SDK支持时，需要在此方法中对原平台SDK进行导入操作
     @param configurationHandler (onConfiguration)
     配置回调处理，在此方法中根据设置的platformType来填充应用配置信息
     */

    [ShareSDK registerActivePlatforms:@[
                                        @(SSDKPlatformTypeSinaWeibo),
                                        @(SSDKPlatformTypeMail),
                                        @(SSDKPlatformTypeSMS),
                                        @(SSDKPlatformTypeCopy),
                                        @(SSDKPlatformTypeWechat),
                                        @(SSDKPlatformTypeQQ)
                                        ]
                             onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             case SSDKPlatformTypeSinaWeibo:
                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                 break;
             default:
                 break;
         }
     }
                      onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {

         switch (platformType)
         {
             case SSDKPlatformTypeSinaWeibo:
                 //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                 [appInfo SSDKSetupSinaWeiboByAppKey:@"2022235857"
                                           appSecret:@"fbe2d9fb0a424a467dd0318fa8295e50"
                                         redirectUri:@"http://www.yunejian.com"
                                            authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wxe2ea6aa89451b133"
                                       appSecret:@"17b086d438ce9ef142a038c3d2f3fd2b"];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:@"1105186495"
                                      appKey:@"zFPAbHeISGj51SPB"
                                    authType:SSDKAuthTypeBoth];
                 break;
             default:
                 break;
         }
       }];
    
    // 通过个推平台分配的appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    // 注册 APNs
    [self registerRemoteNotification];

    //1.创建窗口
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    _startController=[[DD_StartViewController alloc] init];
//    self.window.rootViewController = _startController ;
    
    _startPlayer=[[DD_StartViewPlayer alloc] init];
    self.window.rootViewController = _startPlayer ;
//    self.window.rootViewController = [DD_CustomViewController sharedManager];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [_startPlayer pushMainView];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
   
    [GeTuiSdk resetBadge]; //重置角标计数
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; // APP 清空角标
    //DD_CustomViewController出现的时候调用
    if(((DD_CustomViewController *)[DD_CustomViewController sharedManager]).isVisible)
    {
        [DD_UserModel SigninAction];
        [DD_UserModel CheckVersion];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark - 用户通知(推送) _自定义方法

/** 注册 APNs */
- (void)registerRemoteNotification {
    /*
     警告：Xcode8 需要手动开启"TARGETS -> Capabilities -> Push Notifications"
     */

    /*
     警告：该方法需要开发者自定义，以下代码根据 APP 支持的 iOS 系统不同，代码可以对应修改。
     以下为演示代码，注意根据实际需要修改，注意测试支持的 iOS 系统都能获取到 DeviceToken
     */
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 // Xcode 8编译会调用
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!error) {
                JXLOG(@"request authorization succeeded!");
            }
        }];

        [[UIApplication sharedApplication] registerForRemoteNotifications];
#else // Xcode 7编译会调用
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                       UIRemoteNotificationTypeSound |
                                                                       UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
}

#pragma mark - 用户通知(推送)回调 _IOS 8.0以上使用

/** 已登记用户通知 */
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // 注册远程通知（推送）
    [application registerForRemoteNotifications];
}
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    /// Background Fetch 恢复SDK 运行
    [GeTuiSdk resume];
    completionHandler(UIBackgroundFetchResultNewData);
}
#pragma mark - 远程通知(推送)回调

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    JXLOG(@"\n>>>[DeviceToken Success]:%@\n\n", token);

    // 向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
    [DD_UserModel setDeviceToken:token];

//    if(_is_first_register)
//    {
        _is_first_register=NO;
    
        [self connectedDeviceToken:token];
//    }
}

-(void)connectedDeviceToken:(NSString *)deviceToken
{

    NSDictionary *_parameters=@{@"deviceToken":deviceToken,@"token":[DD_UserModel getToken]};
    [[JX_AFNetworking alloc] GET:@"user/setUserDeviceToken.do" parameters:_parameters success:^(BOOL success, NSDictionary *data, UIAlertController *successAlert) {
        if(success)
        {
            JXLOG(@"111");
        }else
        {
            JXLOG(@"111");
        }
    } failure:^(NSError *error, UIAlertController *failureAlert) {
        JXLOG(@"111");
    }];
}
/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    JXLOG(@"\n>>>[DeviceToken Error]:%@\n\n", error.description);
}
#pragma mark - APP运行中接收到通知(推送)处理

/** APP已经接收到“远程”通知(推送) - (App运行在后台/App运行在前台) */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber = 0; // 标签
    
    JXLOG(@"\n>>>[Receive RemoteNotification]:%@\n\n", userInfo);
}

/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
    //    后台运行 applicationState = UIApplicationStateBackground
    //    点击横条 applicationState = UIApplicationStateInactive
    //    app打开的情况下 applicationState = UIApplicationStateActive
    if(application.applicationState==UIApplicationStateInactive)
    {
        JXLOG(@"applicationState=%ld",application.applicationState);
        // 处理APN
        JXLOG(@"\n>>>[Receive RemoteNotification - Background Fetch]:%@\n\n", userInfo);
        
        completionHandler(UIBackgroundFetchResultNewData);
        NSData* data=[[[userInfo objectForKey:@"aps"] objectForKey:@"category"] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict=[NSJSONSerialization  JSONObjectWithData:data options:0 error:nil];
        if([[dict objectForKey:@"type"]isEqualToString:@"NEWFANS"])
        {
            //        新增粉丝
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NEWFANS_NOT" object:nil];
        }else if([[dict objectForKey:@"type"]isEqualToString:@"DOYENAPPLY"])
        {
            //        申请达人审核进度通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DOYENAPPLY_NOT" object:nil];
        }else if([[dict objectForKey:@"type"]isEqualToString:@"REFUNDAPPLY"])
        {
            //        申请退款的通知
            
        }else if([[dict objectForKey:@"type"]isEqualToString:@"NEWSERIES"])
        {
            //        新的线上发布会通知
            [DD_NOTInformClass SET_NEWSERIES_NOT_SERIESID:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NEWSERIES_NOT" object:nil];
        }else if([[dict objectForKey:@"type"]isEqualToString:@"STARTSERIES"])
        {
            //        已报名线上发布会开始的通知
            [DD_NOTInformClass SET_STARTSERIES_NOT_SERIESID:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"STARTSERIES_NOT" object:nil];
            
        }else if([[dict objectForKey:@"type"]isEqualToString:@"REPLYCOMMENT"])
        {
            //        评论回复的通知
            [DD_NOTInformClass SET_REPLYCOMMENT_NOT_COMMENT:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"REPLYCOMMENT_NOT" object:nil];
            
        }else if([[dict objectForKey:@"type"]isEqualToString:@"COMMENTSHARE"])
        {
            //        评论的通知
            [DD_NOTInformClass SET_COMMENTSHARE_NOT_COMMENT:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"COMMENTSHARE_NOT" object:nil];
        }else if([[dict objectForKey:@"type"]isEqualToString:@"NEWLIVESERIES"])
        {
            //        新的线下发布会通知
            [DD_NOTInformClass SET_NEWLIVESERIES_NOT_SERIESID:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NEWLIVESERIES_NOT" object:nil];
        }else if([[dict objectForKey:@"type"]isEqualToString:@"STARTLIVESERIES"])
        {
            //        已报名线下发布会开始的通知
            [DD_NOTInformClass SET_STARTLIVESERIES_NOT_SERIESID:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"STARTLIVESERIES_NOT" object:nil];
        }
    }
    // 将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

//  iOS 10: App在前台获取到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    JXLOG(@"willPresentNotification：%@", notification.request.content.userInfo);

    // 根据APP需要，判断是否要提示用户Badge、Sound、Alert
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

//  iOS 10: 点击通知进入App时触发，在该方法内统计有效用户点击数
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {

    JXLOG(@"didReceiveNotification：%@", response.notification.request.content.userInfo);

    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if( [UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {

        // 处理APN
        JXLOG(@"\n>>>[Receive RemoteNotification - Background Fetch]:%@\n\n", userInfo);

        completionHandler(UIBackgroundFetchResultNewData);
        NSData* data=[[[userInfo objectForKey:@"aps"] objectForKey:@"category"] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict=[NSJSONSerialization  JSONObjectWithData:data options:0 error:nil];

        if([[dict objectForKey:@"type"]isEqualToString:@"NEWFANS"])
        {
            //        新增粉丝
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NEWFANS_NOT" object:nil];
        }else if([[dict objectForKey:@"type"]isEqualToString:@"DOYENAPPLY"])
        {
            //        申请达人审核进度通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DOYENAPPLY_NOT" object:nil];
        }else if([[dict objectForKey:@"type"]isEqualToString:@"REFUNDAPPLY"])
        {
            //        申请退款的通知

        }else if([[dict objectForKey:@"type"]isEqualToString:@"NEWSERIES"])
        {
            //        新的发布会通知
            [DD_NOTInformClass SET_NEWSERIES_NOT_SERIESID:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NEWSERIES_NOT" object:nil];
        }else if([[dict objectForKey:@"type"]isEqualToString:@"STARTSERIES"])
        {
            //        已报名发布会开始的通知
            [DD_NOTInformClass SET_STARTSERIES_NOT_SERIESID:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"STARTSERIES_NOT" object:nil];

        }else if([[dict objectForKey:@"type"]isEqualToString:@"REPLYCOMMENT"])
        {
            //        评论回复的通知
            [DD_NOTInformClass SET_REPLYCOMMENT_NOT_COMMENT:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"REPLYCOMMENT_NOT" object:nil];

        }else if([[dict objectForKey:@"type"]isEqualToString:@"COMMENTSHARE"])
        {
            //        评论的通知
            [DD_NOTInformClass SET_COMMENTSHARE_NOT_COMMENT:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"COMMENTSHARE_NOT" object:nil];
        }else if([[dict objectForKey:@"type"]isEqualToString:@"NEWLIVESERIES"])
        {
            //        新的线下发布会通知
            [DD_NOTInformClass SET_NEWLIVESERIES_NOT_SERIESID:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NEWLIVESERIES_NOT" object:nil];
        }else if([[dict objectForKey:@"type"]isEqualToString:@"STARTLIVESERIES"])
        {
            //        已报名线下发布会开始的通知
            [DD_NOTInformClass SET_STARTLIVESERIES_NOT_SERIESID:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"STARTLIVESERIES_NOT" object:nil];
        }
    }

    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo];

    completionHandler();
}

#endif

#pragma mark - GeTuiSdkDelegate

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    
    // [4-EXT-1]: 个推SDK已注册，返回clientId
    JXLOG(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    JXLOG(@"\n>>>[GexinSdk error]:%@\n\n", [error localizedDescription]);
}


/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    //收到个推消息
    NSString *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding];
    }

    NSString *msg = [NSString stringWithFormat:@"taskId=%@,messageId:%@,payloadMsg:%@%@",taskId,msgId, payloadMsg,offLine ? @"<离线消息>" : @""];
    JXLOG(@"\n>>>[GexinSdk ReceivePayload]:%@\n\n", msg);
}


/** SDK收到sendMessage消息回调 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // [4-EXT]:发送上行消息结果反馈
    NSString *msg = [NSString stringWithFormat:@"sendmessage=%@,result=%d", messageId, result];
    JXLOG(@"\n>>>[GexinSdk DidSendMessage]:%@\n\n", msg);
}

/** SDK运行状态通知 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // [EXT]:通知SDK运行状态
    JXLOG(@"\n>>>[GexinSdk SdkState]:%u\n\n", aStatus);
}

/** SDK设置推送模式回调 */
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    if (error) {
        JXLOG(@"\n>>>[GexinSdk SetModeOff Error]:%@\n\n", [error localizedDescription]);
        return;
    }
    
    JXLOG(@"\n>>>[GexinSdk SetModeOff]:%@\n\n", isModeOff ? @"开启" : @"关闭");
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSDictionary *dict=nil;
            if([[resultDic objectForKey:@"result"] isEqualToString:@""])
            {
                if([DD_UserModel getTradeOrderCode])
                {
                    
                    dict=@{
                           @"resultStatus":[resultDic objectForKey:@"resultStatus"]
                           ,@"tradeOrderCode":[DD_UserModel getTradeOrderCode]
                           };
                }
            }else
            {
                dict=@{
                       @"resultStatus":[resultDic objectForKey:@"resultStatus"]
                       ,@"tradeOrderCode":[self get_out_trade_no_WithResult:[resultDic objectForKey:@"result"]]
                       };
            }
            
            if(dict)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"payAction" object:dict];
            }
        }];
    }
    return YES;
}
// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSDictionary *dict=nil;
            if([[resultDic objectForKey:@"result"] isEqualToString:@""])
            {
                if([DD_UserModel getTradeOrderCode])
                {
                    
                    dict=@{
                           @"resultStatus":[resultDic objectForKey:@"resultStatus"]
                           ,@"tradeOrderCode":[DD_UserModel getTradeOrderCode]
                           };
                }
            }else
            {
                dict=@{
                       @"resultStatus":[resultDic objectForKey:@"resultStatus"]
                       ,@"tradeOrderCode":[self get_out_trade_no_WithResult:[resultDic objectForKey:@"result"]]
                       };
            }
            
            if(dict)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"payAction" object:dict];
            }
        }];
    }
    return YES;
}
-(NSString *)get_out_trade_no_WithResult:(NSString *)result
{
    NSArray *array = [result componentsSeparatedByString:@"\""];
    for (int i=0; i<array.count; i++) {
        NSString *str=array[i];
        if([str isEqualToString:@"&out_trade_no="])
        {
            return array[i+1];
            break;
        }
    }
    return @"";
}
//-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
//{
//    DD_CustomViewController *shareCustomView=[DD_CustomViewController sharedManager];
//    [shareCustomView cleanCache];
//    
//}
@end
