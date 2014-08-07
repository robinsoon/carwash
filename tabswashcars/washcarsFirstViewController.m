//
//  washcarsFirstViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-9.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "washcarsFirstViewController.h"

#import "userLoginViewController.h"

@interface washcarsFirstViewController ()

@end

//为了让滚动视图能够接收触摸事件，以隐藏键盘，做如下扩展
@implementation UIScrollView (UITouchEvent)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

@end

@implementation washcarsFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.iSelectedIndex = 0;
    self.mainscrollview.contentSize = CGSizeMake(306,185);
    [self.mainscrollview addSubview:self.subview1];
    [self.mainscrollview addSubview:self.subview2];
    [self.mainscrollview addSubview:self.subview3];
    [self.mainscrollview addSubview:self.subview4];
    //[self.mainscrollview addSubview:self.subviewitem];
    //[self.mainscrollview addSubview:self.subviewnext];
    self.mainscrollview.hidden = true;
    self.homebkgmode.hidden = true;
    
    //刷新列表的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AccountRefresh:)
                                                 name:@"AccountRefreshNotification"
                                               object:nil];
    //刷新服务列表的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ServiceRefresh:)
                                                 name:@"ServiceRefreshNotification"
                                               object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    //首页已显示，检查一下网络状况
    //务必在首页展示完成后再启动其它逻辑，否则会导致载入迟缓影响体验
    if(_isInital == false){
        //初始化逻辑只能执行一次
        NSLog(@"√已载入首页");
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate NetworkReachability];
        [delegate LoadMapManger];
        [delegate LoadConfig];
        
        
        //判断用户是否需要定位信息，如果已有存档则不执行定位。
        //延迟执行定位
        if (!delegate.isLimited ) {
            //非限制版有自动定位
            if((delegate.userAreaID==nil)||([delegate.userAreaID isEqualToString:@""]))
            {
                [self performSelector:@selector(DelayLocation) withObject:nil afterDelay:1.8f];
            }
        }
        
        if ((delegate.userid!=nil)&&(![delegate.userid isEqualToString:@""] )) {
            //存在userid 说明有记录登录用户，允许自动登录校验身份
            [self performSelector:@selector(DelayLogin) withObject:nil afterDelay:2.3f];
        }
        
        _isInital = true;
    }else{
    
    
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"MemoryWarning!");
}

#pragma mark - Page Functions

//延迟定位
- (void)DelayLocation
{
    
    //根据本地存储的位置信息判断是否有必要执行以下逻辑
    
    //询问用户是否继续
    NSLog(@"启动延迟定位，识别所在城市!");
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    [delegate showNotify:@"欢迎您安装了去洗车应用，本地服务需要定位您当前的位置。" HoldTimes:1.8f];
    self.tabBarController.selectedIndex = 1;
    
}

//延迟登录
- (void)DelayLogin
{
    
    //根据本地存储的位置信息判断是否有必要执行以下逻辑
    
    //询问用户是否继续
    NSLog(@"启动延迟登录");
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:@"欢迎您安装了去洗车应用，本地服务需要定位您当前的位置。" HoldTimes:1.8f];
    //self.tabBarController.selectedIndex = 1;
    
    userLoginViewController *LoginView = [userLoginViewController alloc];
    
    [LoginView autoLogin:delegate.username password:delegate.password ];
    
    //NSLog(@"启动延迟登录完毕");
}

//更新账户信息
- (void)AccountRefresh:(NSNotification*)notification
{
    NSLog(@"更新账户信息");
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    userLoginViewController *LoginView = [userLoginViewController alloc];
    
    [LoginView autoLogin:delegate.username password:delegate.password ];
}

//根据位置和开通城市对数据访问控制
- (void)LoactionViewControl{
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    //delegate.userDistrict
    //delegate.userCitySupported
    //delegate.userAreaID
    
    if ((delegate.userAreaID == nil)||([delegate.userAreaID isEqualToString:@""])) {
        return;
    }

    //枣庄等地
    if (([delegate.userAreaID isEqualToString:@"2464"])||([delegate.userAreaID isEqualToString:@"298"])) {
        //枣庄，滕州
        _btnItem4.hidden = false;
        _btnItem3.hidden = false;
        _btnItem5.hidden = false;
        
        _subviewnext.hidden = false;

        _txtItem2.hidden = false;
        _txtItem3.hidden = false;
        _txtItem4.hidden = false;

        return;
    }
    
    
    
    
    if ((delegate.userCitySupported ==nil)||([delegate.userCitySupported isEqualToString:@""]))
    {
        
    }
    
    delegate.categorylist = @"139";
    _btnItem4.hidden = true;
    _btnItem3.hidden = true;
    _btnItem5.hidden = true;
    
    _txtItem2.hidden = true;
    _txtItem3.hidden = true;
    _txtItem4.hidden = true;

    
    _subviewnext.hidden = true;
    
    _subview1.hidden = true;
    _subview2.hidden = true;
    _subview3.hidden = true;
    _subview4.hidden = true;
    
    //_btnItem9.hidden = true;
    //_btnItem10.hidden = true;
    //_btnItem8.hidden = true;
    //_btnItem1.hidden = true;
    
    if (([delegate.userAreaID isEqualToString:@"2463"])||([delegate.userAreaID isEqualToString:@"0"])) {
        //薛城
        _btnItem3.hidden = false;
        _btnItem4.hidden = false;
        _btnItem5.hidden = false;
        
        _txtItem2.hidden = false;
        _txtItem3.hidden = false;
        _txtItem4.hidden = false;

    }


}

-(void)ServiceRefresh:(NSNotification*)notification {
    [self LoactionViewControl];
}

//首页按钮
//小类点击事件
- (void)gotoSubService:(NSString *)serviceID PageName:(NSString *)itemname {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",itemname ];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    delegate.categorylist = serviceID;
    delegate.userServiceName =itemname;
    self.tabBarController.selectedIndex = 2;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
}


//设定显示的栏目
- (void)showSubItems:(int)ItemIndex{
    
    if (self.iSelectedIndex == ItemIndex) {
        self.mainscrollview.hidden = true;
        self.iSelectedIndex = 0;
        self.homebkgmode.hidden = true;
        return;
    }
    
    self.mainscrollview.hidden = false;
    self.homebkgmode.hidden = false;
    self.iSelectedIndex = ItemIndex;
    switch (ItemIndex) {
        case 0:
            _subview1.hidden = true;
            _subview2.hidden = true;
            _subview3.hidden = true;
            _subview4.hidden = true;
            break;
        case 1:
            _subview1.hidden = false;
            _subview2.hidden = true;
            _subview3.hidden = true;
            _subview4.hidden = true;
            break;
        case 2:
            _subview2.hidden = false;
            _subview1.hidden = true;
            _subview3.hidden = true;
            _subview4.hidden = true;
            break;
        case 3:
            _subview3.hidden = false;
            _subview1.hidden = true;
            _subview2.hidden = true;
            _subview4.hidden = true;
            break;
        case 4:
            _subview4.hidden = false;
            _subview1.hidden = true;
            _subview2.hidden = true;
            _subview3.hidden = true;
            
            break;
        case 5:
            return;
            break;
    }
    
    //根据需要显示不同的子页面
    
    
    
    
}


#pragma mark - Button Event Processor
//洗车
- (IBAction)btnItem2Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"洗车" ];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    delegate.userServiceName =@"洗车服务";
    delegate.categorylist = @"139";
    self.tabBarController.selectedIndex = 2;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
}

//打蜡
- (IBAction)btnItem4Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"打蜡" ];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    delegate.userServiceName =@"打蜡服务";
    delegate.categorylist = @"141";
    self.tabBarController.selectedIndex = 2;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
}

//贴膜
- (IBAction)btnItem3Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"贴膜" ];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    delegate.userServiceName =@"贴膜服务";
    delegate.categorylist = @"176";
    self.tabBarController.selectedIndex = 2;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
}



//保养
- (IBAction)btnItem5Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"套餐" ];
    
    //washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    
    [self gotoSubService:@"181" PageName:@"美容套餐"];
    /*
    delegate.categorylist = @"186"; //漆面翻新
    self.tabBarController.selectedIndex = 2;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
    */
}

- (IBAction)btnItem6Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"救援" ];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    [delegate showNotify:_lsNotifyTitle HoldTimes:2];
    
}

- (IBAction)btnItem7Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"违章查询" ];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    [delegate showNotify:_lsNotifyTitle HoldTimes:2];
}


//大类 -- 美容
- (IBAction)btnItem1Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"美容" ];
    
    [self showSubItems:1];
    
    /*
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    
    delegate.categorylist = @"182";
     self.tabBarController.selectedIndex = 2;
     
     [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
     */
    
    
}

- (IBAction)btnItem9Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"装饰" ];
    
    
    [self showSubItems:2];
    /*
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    delegate.categorylist = @"177";
    self.tabBarController.selectedIndex = 2;

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
     */
}

- (IBAction)btnItem10Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"维修" ];
    
    [self showSubItems:3];
    /*
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    
    delegate.categorylist = @"189";
    self.tabBarController.selectedIndex = 2;

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
     */
}

- (IBAction)btnItem8Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"改装" ];
    [self showSubItems:4];
    /*
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    delegate.categorylist = @"185";
    self.tabBarController.selectedIndex = 2;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
     */
}

//美容套餐
- (IBAction)btnsubitem6Clicked:(id)sender {
    [self gotoSubService:@"181" PageName:@"美容套餐"];
}

//封釉
- (IBAction)btnsubitem1Clicked:(id)sender {
    [self gotoSubService:@"177" PageName:@"封釉"];
}

//镀膜
- (IBAction)btnsubitem2Clicked:(id)sender {
    [self gotoSubService:@"178" PageName:@"镀膜"];
}

//镀晶
- (IBAction)btnsubitem3Clicked:(id)sender {
    [self gotoSubService:@"179" PageName:@"镀晶"];
}

//空调清洗
- (IBAction)btnsubitem4Clicked:(id)sender {
    [self gotoSubService:@"183" PageName:@"空调清洗"];
}

//内饰清洗
- (IBAction)btnsubitem5Clicked:(id)sender {
    [self gotoSubService:@"182" PageName:@"内饰清洗"];
}

//维修
- (IBAction)btnsubitem31Clicked:(id)sender {
    [self gotoSubService:@"186" PageName:@"漆面翻新"];
}
- (IBAction)btnsubitem32Clicked:(id)sender {
    [self gotoSubService:@"187" PageName:@"换机油"];
}
- (IBAction)btnsubitem33Clicked:(id)sender {
    [self gotoSubService:@"186" PageName:@"凹陷修复"];////
}
- (IBAction)btnsubitem34Clicked:(id)sender {
    [self gotoSubService:@"182" PageName:@"玻璃修复"];////
}
- (IBAction)btnsubitem35Clicked:(id)sender {
    [self gotoSubService:@"188" PageName:@"焗瓷"];
}
- (IBAction)btnsubitem36Clicked:(id)sender {
    [self gotoSubService:@"189" PageName:@"抛光"];
}


//改装
- (IBAction)btnsubitem41Clicked:(id)sender {
    [self gotoSubService:@"185" PageName:@"车身改色"];
}
- (IBAction)btnsubitem42Clicked:(id)sender {
    [self gotoSubService:@"184" PageName:@"隔音"];
}
- (IBAction)btnsubitem43Clicked:(id)sender {
    [self gotoSubService:@"185" PageName:@"音响改装"];////
}
- (IBAction)btnsubitem44Clicked:(id)sender {
    [self gotoSubService:@"185" PageName:@"更换大灯"];////
}
- (IBAction)btnsubitem45Clicked:(id)sender {
    [self gotoSubService:@"188" PageName:@"中控导航"];////
}
- (IBAction)btnsubitem46Clicked:(id)sender {
    [self gotoSubService:@"185" PageName:@"其它"];
}

//装饰
- (IBAction)btnsubitem21Clicked:(id)sender {
    [self gotoSubService:@"189" PageName:@"玻璃贴膜"];////
}
- (IBAction)btnsubitem22Clicked:(id)sender {
    [self gotoSubService:@"176" PageName:@"贴膜装饰"];////
}
- (IBAction)btnsubitem23Clicked:(id)sender {
    [self gotoSubService:@"182" PageName:@"真皮座椅"];////
}
- (IBAction)btnsubitem24Clicked:(id)sender {
    [self gotoSubService:@"184" PageName:@"汽车隔音"];////
}


@end
