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
@property (weak, nonatomic) IBOutlet UIView *subview1;
@property (weak, nonatomic) IBOutlet UIView *subview2;
@property (weak, nonatomic) IBOutlet UIView *subview3;
@property (weak, nonatomic) IBOutlet UIView *subview4;
@property (weak, nonatomic) IBOutlet UIImageView *homebkg;
@property (weak, nonatomic) IBOutlet UIImageView *homebkgmode;

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

//小分类
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem1;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem2;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem3;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem4;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem5;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem6;

@property (weak, nonatomic) IBOutlet UIButton *btnsubitem21;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem22;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem23;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem24;

@property (weak, nonatomic) IBOutlet UIButton *btnsubitem31;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem32;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem33;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem34;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem35;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem36;

@property (weak, nonatomic) IBOutlet UIButton *btnsubitem41;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem42;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem43;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem44;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem45;
@property (weak, nonatomic) IBOutlet UIButton *btnsubitem46;

@property (weak, nonatomic) IBOutlet UILabel *txtItem1;
@property (weak, nonatomic) IBOutlet UILabel *txtItem2;
@property (weak, nonatomic) IBOutlet UILabel *txtItem3;
@property (weak, nonatomic) IBOutlet UILabel *txtItem4;


@property (nonatomic) int iSelectedIndex;//选中序号

@property (nonatomic,strong) NSString * lsNotifyTitle;

@end
