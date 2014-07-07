//
//  couponsDetailViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-6-12.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "couponsDetailViewController.h"
#import "UIButton+Bootstrap.h"
#import "navMapsViewController.h"
#import "PoiSearchViewController.h"
@interface couponsDetailViewController ()

@end

@implementation couponsDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _lbCouponsCode.text = _CouponsCode;
    
    NSString *strStatus = _CouponsStatus;
    //0 未消费；1 已消费； 2 密码券过期失效； 3 密码券无效；4 退款，密码券无效；
    if ([strStatus isEqual: @"0"]) {
        _lbStatus.text = @"有效,未消费";
    }else if([strStatus isEqual: @"1"]){
        _lbStatus.text = @"已消费";
    }else if([strStatus isEqual: @"2"]){
        _lbStatus.text = @"已过期";
    }else if([strStatus isEqual: @"3"]){
        _lbStatus.text = @"无效";
    }else if([strStatus isEqual: @"4"]){
        _lbStatus.text = @"无效，已申请退款";
    }else{
        _lbStatus.text = @"无效";
    }
    
    _lbnote.text = _CouponsNote;
    _lbusedtime.text = _CouponsUsedtime;

    if ((_orderID == nil)||([_orderID isEqualToString:@""])) {
        _btnShowOrder.hidden = true;
        
    }else{
        _lbName.text = _CouponsName;
        _lbAddress.text = _Address;
        _lbPhone.text = _Phone;
        _btnShowOrder.hidden = false;
    }
    
    [self.btnShowOrder primaryStyle];
    [self.btnShowOrder addAwesomeIcon:FAIconTags beforeTitle:NO];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//回到订单明细
- (IBAction)btnShowOrder:(id)sender {
    if ((_orderID == nil)||([_orderID isEqualToString:@""])) {
        NSLog(@"消费券：无法找到订单明细");
    }else{
        /*//带订单号，支持退款操作
        NSLog(@"消费券：转到订单明细");
        OrderDetailViewController *itemOrder = [[OrderDetailViewController alloc] init];
        
        [self.navigationController pushViewController:itemOrder animated:NO];

        
        itemOrder.itemid = self.orderID;
        itemOrder.itemname = self.lbName.text;
        itemOrder.itemdetail = self.lbAddress.text;
        
        itemOrder.OrderAction= @"已付款";
        itemOrder.PayStatus = @"2";
        itemOrder.OrderStatus= @"1";
         */
    }
    
}

//定位地图
- (IBAction)btntoMap:(id)sender {
    if ((_orderID == nil)||([_orderID isEqualToString:@""])) {
        NSLog(@"消费券：无法定位商家位置");
    }else{
        //带订单号
        NSLog(@"消费券：转到地图定位");
        
        self.tabBarController.selectedIndex = 1;
        [self performSelector:@selector(LocationDelay) withObject:nil afterDelay:0.5f];

        return;
    }
}

/*
- (void)LocationDelay{
    //以下代码需要延迟执行，如果是地图没有初始化
    NSString *strName = _lbName.text;
    NSString *strlatitude = [[NSString alloc]initWithFormat:@"%f", _Locationpt.latitude];
    NSString *strlongitude = [[NSString alloc]initWithFormat:@"%f", _Locationpt.longitude];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:strName, @"name", strlatitude,@"latitude",strlongitude,@"longitude", nil];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"LocationPointNotification"
     object:nil
     userInfo:dataDict];
    
}*/

- (void)LocationDelay{
    
    
    //取导航列表直接推视图
    NSArray *arrControllers = self.tabBarController.viewControllers;
    for(UIViewController *viewController in arrControllers)
    {
        if([viewController isKindOfClass:[navMapsViewController class]])
        {
            //NavigationController
            UINavigationController *navCtrl = (UINavigationController *)viewController;
            
            //NSLog(@"%@",navCtrl.viewControllers);
            NSLog(@"服务列表标注到地图");
            
            PoiSearchViewController *poimapview;
            
            //如果已有初始化过的 PoiSearchViewController 则不再创建新实例
            for (UIViewController *mapviewController in navCtrl.viewControllers) {
                
                if([mapviewController isKindOfClass:[PoiSearchViewController class]]){
                    //存在,强制转换为地图的View
                    poimapview = (PoiSearchViewController *)mapviewController;
                    //传递参数
                    poimapview.listData = nil;
                    poimapview.itemname = _lbName.text;
                    poimapview.Locationpt = _Locationpt;
                    poimapview.iZoomLevel = 14;
                    
                    //最后跳转页面
                    self.tabBarController.selectedIndex = 1;
                    
                    [poimapview LocationRefresh];
                    
                    return;
                    
                    NSString *strName = _lbName.text;
                    NSString *strlatitude = [[NSString alloc]initWithFormat:@"%f", _Locationpt.latitude];
                    NSString *strlongitude = [[NSString alloc]initWithFormat:@"%f", _Locationpt.longitude];
                    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:strName, @"name", strlatitude,@"latitude",strlongitude,@"longitude", nil];
                    
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"LocationPointNotification"
                     object:nil
                     userInfo:dataDict];
                    
                    [poimapview LocationRefresh];
                    return;//防止重复推同一个视图
                }
                
            }
            
            if (poimapview == nil) {
                //创建新实例
                poimapview = [[PoiSearchViewController alloc] init];
            }
            
            //推送地图的视图
            [navCtrl pushViewController:poimapview animated:NO];
            //PoiSearchViewController 太多实例
            
            //传递参数
            poimapview.listData = nil;
            poimapview.itemname = _lbName.text;
            poimapview.Locationpt = _Locationpt;
            poimapview.iZoomLevel = 14;
            
            //最后跳转页面
            self.tabBarController.selectedIndex = 1;
            
            return;
        }
        else
        {
            // view controller
        }
    }
    
    //以下代码需要延迟执行，如果是地图没有初始化
    NSString *strName = _lbName.text;
    NSString *strlatitude = [[NSString alloc]initWithFormat:@"%f", _Locationpt.latitude];
    NSString *strlongitude = [[NSString alloc]initWithFormat:@"%f", _Locationpt.longitude];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:strName, @"name", strlatitude,@"latitude",strlongitude,@"longitude", nil];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"LocationPointNotification"
     object:nil
     userInfo:dataDict];
    
}

//选择订单支付方式//选择取消订单
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"couponsorder"])
    {
        
        NSLog(@"从消费券到订单页面 %@",self.orderID);
        
        //方法有特殊之处，调试发现直接 实例化并push会导致 cell错误，所以只传值。
        //跳转到消费券列表(已付款)
        OrderDetailViewController *orderview =  [segue destinationViewController];
        orderview.OrderID = _orderID;
        orderview.OrderAction = @"已付款";
        orderview.PayStatus = @"2";
        //缺乏订单信息
        orderview.PageAction = @"1";    //强制刷新
        
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc]init];
        backItem.title=@"";
        backItem.tintColor=[UIColor colorWithRed:129/255.0 green:129/255.0  blue:129/255.0 alpha:1.0];
        self.navigationItem.backBarButtonItem = backItem;
    }
    
    
    //取消订单 or 申请退款
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
