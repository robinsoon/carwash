//
//  washcarsFirstViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-5-9.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "washcarsAppDelegate.h"
@interface washcarsFirstViewController : UIViewController

@property (nonatomic) BOOL isInital;           //初始化不能多次调用
@property (weak, nonatomic) IBOutlet UIScrollView *mainscrollview;
@property (weak, nonatomic) IBOutlet UIView *subviewitem;
@property (weak, nonatomic) IBOutlet UIView *subviewnext;

@property (weak, nonatomic) IBOutlet UIButton *btnItem1;

@property (weak, nonatomic) IBOutlet UIButton *btnItem2;

@property (weak, nonatomic) IBOutlet UIButton *btnItem3;


@property (weak, nonatomic) IBOutlet UIButton *btnItem4;


@property (weak, nonatomic) IBOutlet UIButton *btnItem5;

@property (weak, nonatomic) IBOutlet UIButton *btnItem6;

@property (weak, nonatomic) IBOutlet UIButton *btnItem7;

@property (weak, nonatomic) IBOutlet UIButton *btnItem8;

@property (weak, nonatomic) IBOutlet UIButton *btnItem9;

@property (weak, nonatomic) IBOutlet UIButton *btnItem10;

@property (nonatomic,strong) NSString * lsNotifyTitle;

@end
