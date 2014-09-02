//
//  carswashServiceTableViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-5-13.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+URLEncoding.h"
#import "UIImageView+WebCache.h"
#import "washcarsAppDelegate.h"
#import "serviceViewCell.h"

@class carswashDetailViewController;

@interface carswashServiceTableViewController : UITableViewController<UIActionSheetDelegate>

//保存数据列表[表现层所依赖的内部数据集合]
@property (nonatomic,strong) NSMutableArray* listData;  //商品列表

@property (nonatomic,strong) NSMutableArray* listSort;  //排序列表

@property (nonatomic,strong) NSMutableArray* listArea;  //地区列表

//接收从服务器返回数据 Json包
@property (strong,nonatomic) NSMutableData *datas;

//自定义风格的单元格
@property (strong,nonatomic) carswashDetailViewController *serviceDetail;

@property (weak, nonatomic) IBOutlet UIButton *btnToMap;
@property (weak, nonatomic) IBOutlet UIButton *btnFilter;

@property (nonatomic, retain) UIBarButtonItem *barButtonItem; //定义一个条件按钮
@property (nonatomic) CLLocationCoordinate2D Locationpt; //初始坐标位置
@property (strong, nonatomic)UIColor *CellBgColor;  //单元格背景色

@property (nonatomic,strong) NSString *CityName;

@property (nonatomic,strong) NSString *defaultCode;
@property (nonatomic,strong) NSString *defaultArea;

@property (nonatomic) int rowlimit;
@property (nonatomic) int currentrowcount;

@property (nonatomic) BOOL isplayAnimation;

@property (nonatomic) BOOL isCategorychanged;

//重新加载表视图
-(void)reloadView:(NSDictionary*)res;

//开始请求Web Service
-(void)startRequest;

//翻页
- (int)setPageNext;
@end
