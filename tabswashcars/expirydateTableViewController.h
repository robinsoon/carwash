//
//  expirydateTableViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-8-1.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+URLEncoding.h"
#import "washcarsAppDelegate.h"
#import "opengiftViewController.h"

@interface expirydateTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *txtExpiryNumber;
@property (weak, nonatomic) IBOutlet UITextView *txtInfo;

@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@property (nonatomic, retain) NSString *number;

@property (nonatomic, retain) NSString *bonusInfo;

//保存数据列表[表现层所依赖的内部数据集合]
@property (nonatomic,strong) NSMutableArray* listData;  //商品列表

@property (nonatomic,strong) NSMutableArray* listSort;  //排序列表

@property (nonatomic,strong) NSMutableArray* listArea;  //地区列表

//接收从服务器返回数据 Json包
@property (strong,nonatomic) NSMutableData *datas;

@property (strong, nonatomic)UIColor *CellBgColor;  //单元格背景色

//重新加载表视图
-(void)reloadView:(NSDictionary*)res;

//开始请求 Web Service
-(void)startRequest;

//翻页
- (int)setPageNext;


@end
