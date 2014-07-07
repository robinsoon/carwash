//
//  washcarsAppDelegate.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-9.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "washcarsAppDelegate.h"
#import "AlixPayResult.h"
#import "DataVerifier.h"
#import "PayViewController.h"
#import "AliPayViewController.h"


BMKMapManager* _mapManager;
@implementation washcarsAppDelegate
@synthesize window;
//@synthesize navigationController;

//告诉代理启动基本完成程序准备开始运行
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //初始化所有的全局变量
    NSLog(@"å应用启动标记");
    //_iPs_URL=@"http://www.2345mall.com:8080/"; //请求数据接口模板--地址
    //_iPs_URL=@"http://58.96.169.123/yz/"; //请求数据接口模板--地址
    _iPs_URL=staticURL;
    //更新初始化用户数据 //用户配置文件将使用PList存储
    _userid = @"2692";
    _username = @"robin";
    _password = @"robincome";
    _userpoints = 0;
    _usermoney = 0;
    _isLogin = true;
    _isbusiness = false;
    _phone = @"";
    _isAutoLogin = true;
    _isreachChanged = false;        //网络连接变更
    _reachStatus=@"";               //网络连接状态
    //_userAreaID = @"298";
    //禁止加载应用的过程中做复杂的业务，以防卡死在黑屏阶段
    //首页加载完成以后再去处理初始化工作

    return YES;
}


//当应用程序将要入非活动状态执行，在此期间，应用程序不接收消息或事件，比如来电话了
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"•应用挂起转至后台");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

//当应用程序入活动状态，激活
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"ç应用活动状态");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"¶应用退出标记");
    [self SaveConfig];
}

//侦测网络连接
- (void)NetworkReachability
{
	//Change the host name here to change the server you want to monitor.
    NSString *remoteHostName = @"www.baidu.com";
    NSLog(@"检测可用的网络：%@",remoteHostName);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //开启网络状况的监听
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
	[self.hostReachability startNotifier];
	[self updateInterfaceWithReachability:self.hostReachability];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
	[self.internetReachability startNotifier];
	[self updateInterfaceWithReachability:self.internetReachability];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
	[self.wifiReachability startNotifier];
	[self updateInterfaceWithReachability:self.wifiReachability];

}

//地图的初始化
- (void)LoadMapManger
{
    // 要使用百度地图，请先启动BaiduMapManager
    NSLog(@"初始化地图服务");
    _mapManager = [[BMKMapManager alloc]init];
    
    //授权码1 公司
	BOOL ret = [_mapManager start:@"Y4CpZgkKGjylsjOAXgsNa329" generalDelegate:self];
    
    //授权码1 私人
    //BOOL ret = [_mapManager start:@"ZW1T9NczNV0pIY0yjd3e06qM" generalDelegate:self];
    
	if (!ret) {
		NSLog(@"manager start failed!");
	}
}

//独立客户端回调函数
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	
	[self parse:url application:application];
	return YES;
}

- (void)parse:(NSURL *)url application:(UIApplication *)application {
    
    //结果处理
    AlixPayResult* result = [self handleOpenURL:url];
    
	if (result)
    {
		
		if (result.statusCode == 9000)
        {
            NSLog(@"交易成功");
            
            [self showNotify:@"交易成功！您的支付已经完成。" HoldTimes:1];
            
            //isPayCompletion
            NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"isPayCompletion", nil];

            //传递消息
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"UserPayCompletionNotification"
             object:nil
             userInfo:dataDict];
            
            return;
			/*
			 *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
			 */
            
            //交易成功
//            NSString* key = @"签约帐户后获取到的支付宝公钥";
//			id<DataVerifier> verifier;
//            verifier = CreateRSADataVerifier(key);
//
//			if ([verifier verifyString:result.resultString withSign:result.signString])
//            {
//                //验证签名成功，交易结果无篡改
//			}
            
        }
        else
        {
            //交易失败
            NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"isPayCompletion", nil];
            
            //传递消息
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"UserPayCompletionNotification"
             object:nil
             userInfo:dataDict];
            
        }
    }
    else
    {
        //失败
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"isPayCompletion", nil];
        
        //传递消息
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"UserPayCompletionNotification"
         object:nil
         userInfo:dataDict];
    }
    
}

- (AlixPayResult *)resultFromURL:(NSURL *)url {
	NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#if ! __has_feature(objc_arc)
    return [[[AlixPayResult alloc] initWithString:query] autorelease];
#else
	return [[AlixPayResult alloc] initWithString:query];
#endif
}

- (AlixPayResult *)handleOpenURL:(NSURL *)url {
	AlixPayResult * result = nil;
	
	if (url != nil && [[url host] compare:@"safepay"] == 0) {
		result = [self resultFromURL:url];
	}
    
	return result;
}

- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        
        NSLog(@"地图联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"地图授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}


//存档本地配置信息
- (void)saveUserDefaults{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:_userid forKey:@"userid"];

}

//读取本地配置信息
- (void)readUserDefaults{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _userid = [ud objectForKey:@"userid"];
}

//读取某个参数
- (NSString*)readUserDefaults:(NSString*)getKey
{
    if (![getKey isEqual:@""]) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        return [ud objectForKey:getKey];
    }
    return @"";
}



//修改某个参数
- (void)saveUserDefaults:(NSString*)ItemKey setValue:(NSString*)ParamValue
{
    if (![ItemKey isEqual:@""]) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:ParamValue forKey:ItemKey];
    }

}

//读取某个参数-- BOOL 类型
- (BOOL)readBOOLDefaults:(NSString*)getKey
{
    if (![getKey isEqual:@""]) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        return [ud boolForKey:getKey];
    }
    return false;
}

//修改某个参数-- BOOL 类型
- (void)saveBOOLDefaults:(NSString*)ItemKey setValue:(BOOL)ParamValue
{
    if (![ItemKey isEqual:@""]) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setBool:ParamValue forKey:ItemKey];
    }
    
}

//统一存取用户数据 -- 读取
- (void)LoadConfig
{
    NSString *lsValue = @"";
    NSLog(@"加载配置信息");
    lsValue = [self readUserDefaults:@"URL"];
    if (([lsValue isEqual:@""])|(lsValue ==nil)) {
        _iPs_URL = staticURL; //请求数据接口模板--地址
    }else{
        _iPs_URL = lsValue;
    }
    
    
    //更新初始化用户数据 //用户配置文件将使用PList存储
    _userid = [self readUserDefaults:@"userid"];
    _username = [self readUserDefaults:@"username"];
    _password = [self readUserDefaults:@"password"];

    _isLogin = [self readBOOLDefaults:@"islogin"];
    _isbusiness = [self readBOOLDefaults:@"isbusiness"];
    _phone = [self readUserDefaults:@"phone"];
    _isAutoLogin = [self readBOOLDefaults:@"isautologin"];

    _userpoints = [[self readUserDefaults:@"userpoints"] doubleValue];
    _usermoney = [[self readUserDefaults:@"usermoney"] doubleValue];
    
    //位置信息
    _userProvince = [self readUserDefaults:@"userprovince"];
    _userCity = [self readUserDefaults:@"usercity"];
    _userDistrict = [self readUserDefaults:@"userdistrict"];
    _userAddress  = [self readUserDefaults:@"useraddress"];
    _userAreaID  = [self readUserDefaults:@"userareaid"];
    [self ReadUserLocation];
}

//统一存取用户数据 -- 保存
- (void)SaveConfig
{
    NSLog(@"保存配置信息");
    //更新初始化用户数据 //用户配置文件将使用PList存储
    [self saveUserDefaults:@"userid" setValue:_userid];
    [self saveUserDefaults:@"username" setValue:_username];
    [self saveUserDefaults:@"password" setValue:_password];

    
    [self saveBOOLDefaults:@"islogin" setValue:_isLogin];
    [self saveBOOLDefaults:@"isbusiness" setValue:_isbusiness];
    [self saveUserDefaults:@"phone" setValue:_phone];
    [self saveBOOLDefaults:@"isautologin" setValue:_isAutoLogin];

    NSString *lsValue = [NSString  stringWithFormat:@"%f",_userpoints];
    [self saveUserDefaults:@"userpoints" setValue:lsValue];
    lsValue = [NSString  stringWithFormat:@"%f",_usermoney];
    [self saveUserDefaults:@"usermoney" setValue:lsValue];
    
    [self saveUserDefaults:@"userlatitude" setValue:_userlatitude];
    [self saveUserDefaults:@"userlongitude" setValue:_userlongitude];
    
    [self saveUserDefaults:@"userprovince" setValue:_userProvince];
    [self saveUserDefaults:@"usercity" setValue:_userCity];
    [self saveUserDefaults:@"userdistrict" setValue:_userDistrict];
    [self saveUserDefaults:@"useraddress" setValue:_userAddress];
    [self saveUserDefaults:@"userareaid" setValue:_userAreaID];
}

//更新坐标
- (void)SetUserLocation:(NSString *)Pmlatitude longitude:(NSString *)Pmlongitude
{
    NSLog(@"保存用户位置信息");

    _userlatitude = Pmlatitude;
    _userlongitude = Pmlongitude;

}
- (void)SetUserLocation:(CLLocationCoordinate2D)PmUserpt
{
    NSLog(@"保存用户位置信息");
    
    _Userpt = PmUserpt;
    
    _userlatitude = [[NSString alloc] initWithFormat:@"%f" ,PmUserpt.latitude ];
    _userlongitude = [[NSString alloc] initWithFormat:@"%f" ,PmUserpt.longitude ];

    [self saveUserDefaults:@"userlatitude" setValue:_userlatitude];
    [self saveUserDefaults:@"userlongitude" setValue:_userlongitude];

}

- (void)ReadUserLocation
{

    _userlatitude = [self readUserDefaults:@"userlatitude"];
    _userlongitude = [self readUserDefaults:@"userlongitude"];
    
    if ((_userlatitude == nil)||([_userlatitude isEqualToString:@""])) {
        //无定位
        
        
        
        
        return;
    }
    
    CLLocationCoordinate2D PmUserpt;
    PmUserpt.latitude = [_userlatitude doubleValue];
    PmUserpt.longitude = [_userlongitude doubleValue];
    _Userpt = PmUserpt;
    
}

//
/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
	Reachability* curReach = [note object];
    _isreachChanged = true;        //网络连接变更
    
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (_isreachChanged == false){
        return;
    }
    if (reachability == self.hostReachability)
	{
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        //BOOL connectionRequired = [reachability connectionRequired];
        
        switch (netStatus) {
            case NotReachable:
                //没有连接到网络就弹出提示
                [self showNotify:@"没有发现可用的网络连接！" HoldTimes:3 ];
                NSLog(@"没有发现可用的网络连接！");
                _reachStatus=@"0";               //网络连接状态
                break;
                
            case ReachableViaWiFi:
                NSLog(@"当前网络模式：Wifi");
                _reachStatus=@"2";               //网络连接状态
                break;
                
            case ReachableViaWWAN:
                [self showNotify:@"连接使用网络2G/3G模式，请注意流量" HoldTimes:2.5 ];
                NSLog(@"当前网络模式：WLAN 2G/3G");
                _reachStatus=@"1";               //网络连接状态
                break;
            default:
                break;
        }
    }
    /*
	if (reachability == self.internetReachability)
	{
        NSLog(@"当前网络模式：WLAN 2G/3G");
        [self showNotify:@"连接使用网络2G/3G模式，请注意流量" HoldTimes:2.5 ];
    }
    
	if (reachability == self.wifiReachability)
	{
        NSLog(@"当前网络模式：Wifi");
    }
     */
}

//弹出消息框延时、后自动消失
- (void)timerFireMethod:(NSTimer*)theTimer
{
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:NO];
    
    promptAlert =NULL;
}

//弹出通知消息  延时关闭
- (void)showNotify:(NSString*)MessageContent HoldTimes:(double)holdseconds
{
    if ([MessageContent isEqual:@""]) {
        return;
    }
    
    if (0<=holdseconds) {
        holdseconds = 1.5f;
    }
    
    UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@"提示:" message:MessageContent delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:holdseconds
                                     target:self
                                   selector:@selector(timerFireMethod:)
                                   userInfo:promptAlert
                                    repeats:NO];
    
    [promptAlert show];
}

@end
