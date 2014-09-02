//
//  mycarTableViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-8-28.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+URLEncoding.h"
#import "washcarsAppDelegate.h"

@interface mycarTableViewController : UITableViewController<UIPickerViewDelegate, UIPickerViewDataSource>



@property (weak, nonatomic) IBOutlet UILabel *txtbrand;

@property (weak, nonatomic) IBOutlet UILabel *txtseries;

@property (weak, nonatomic) IBOutlet UILabel *txtmodel;

@property (weak, nonatomic) IBOutlet UITextField *txtbuytime;

@property (weak, nonatomic) IBOutlet UITextField *txtmileage;

@property (weak, nonatomic) IBOutlet UIPickerView *pickSelect;

@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

//保存数据列表[表现层所依赖的内部数据集合]
@property (nonatomic,strong) NSMutableArray* listData;  //品牌列表
@property (nonatomic,strong) NSMutableArray* listDataseries;  //系列列表
@property (nonatomic,strong) NSMutableArray* listDatamodel;  //型号列表

@property (nonatomic, strong)  NSDictionary  *pickerData; //保存全部数据

//接收从服务器返回数据 Json包
@property (strong,nonatomic) NSMutableData *datas;

@property (strong, nonatomic) NSString *itemid;           //传入参数id
@property (strong, nonatomic) NSString *itemcontent;           //传入的建议

@property (strong, nonatomic) NSString *inbrand;           //传入参数id
@property (strong, nonatomic) NSString *inseries;           //传入参数id
@property (strong, nonatomic) NSString *inmodel;           //传入参数id
@property (strong, nonatomic) NSString *inbuytime;           //传入参数id
@property (strong, nonatomic) NSString *inmileage;           //传入参数id

//重新加载表视图
-(void)reloadView:(NSDictionary*)res;

//开始请求 Web Service
-(void)startRequest;


@end
