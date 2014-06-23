//
//  washcarsFirstViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-9.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "washcarsFirstViewController.h"

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
    self.mainscrollview.contentSize = CGSizeMake(306,185);
    [self.mainscrollview addSubview:self.subviewitem];
    [self.mainscrollview addSubview:self.subviewnext];
    
    
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





//首页按钮

- (IBAction)btnItem1Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"推荐" ];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    
    delegate.categorylist = @"182";
    self.tabBarController.selectedIndex = 2;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
}

- (IBAction)btnItem2Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"洗车" ];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    
    delegate.categorylist = @"139";
    self.tabBarController.selectedIndex = 2;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
}

- (IBAction)btnItem3Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"贴膜" ];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    delegate.categorylist = @"176";
    self.tabBarController.selectedIndex = 2;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
}

- (IBAction)btnItem4Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"打蜡" ];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    delegate.categorylist = @"141";
    self.tabBarController.selectedIndex = 2;

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
}

- (IBAction)btnItem5Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"美容" ];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    delegate.categorylist = @"181";
    self.tabBarController.selectedIndex = 2;

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

- (IBAction)btnItem8Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"改装" ];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    delegate.categorylist = @"185";
    self.tabBarController.selectedIndex = 2;

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
}

- (IBAction)btnItem9Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"汽车用品" ];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    delegate.categorylist = @"177";
    self.tabBarController.selectedIndex = 2;

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
}

- (IBAction)btnItem10Clicked:(id)sender {
    _lsNotifyTitle =
    [[NSString alloc]initWithFormat:@"展示页面:%@",@"其它" ];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //[delegate showNotify:_lsNotifyTitle HoldTimes:2];
    
    delegate.categorylist = @"189";
    self.tabBarController.selectedIndex = 2;

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ServiceRefreshNotification"
     object:nil
     userInfo:nil];
}





@end
