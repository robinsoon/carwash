//
//  MapsLocationTableViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-5-13.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PoiSearchViewController.h"
#import "washcarsAppDelegate.h"
#import "NSString+URLEncoding.h"
#import "locationCell.h"

@interface MapsLocationTableViewController : UITableViewController

@property (nonatomic,strong) NSString *Province;//城市位置，省
@property (nonatomic,strong) NSString *City;    //市级
@property (nonatomic,strong) NSString *District;//具体的区县市
@property (nonatomic,strong) NSString *Address;

@property (nonatomic,strong) NSString *AreaID;

@property (nonatomic,strong) NSString *PostCity;    //市级
@property (nonatomic,strong) NSString *PostDistrict;//具体的区县市

@property (nonatomic,strong) NSString *isOpenCurrent;
@property (nonatomic,strong) NSString *defaultCode;
@property (nonatomic,strong) NSString *defaultArea;
@property (nonatomic,strong) NSString *CityFinded;//标记用户是否已选中了城市
@property (nonatomic) int iFindLevel;//标记用户城市层级:省、市、区
@property (nonatomic,strong) NSString *CurrentCity;//用户已选中的城市

@property (strong, nonatomic)UIColor *CellBgColor;  //单元格背景色
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnCityList;

@property (nonatomic) int selectedRow;         //选中的行

@property (nonatomic) int toMap;         //显示地图

//接收从服务器返回数据 Json包
@property (strong,nonatomic) NSMutableData *datas;

@property (nonatomic,strong) NSMutableArray* listData;  //商品列表
//重新加载表视图
-(void)reloadView:(NSDictionary*)res;

//开始请求 Web Service
-(void)startRequest;

//翻页
- (int)setPageNext;

@end
