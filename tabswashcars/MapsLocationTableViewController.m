//
//  MapsLocationTableViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-13.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "MapsLocationTableViewController.h"
#import "MapsViewController.h"
#import "MJRefresh.h"

@interface MapsLocationTableViewController (){
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
//定义可配置的数据参数（对于简单查询只需1组配置）
//命名规则： i 表示实例变量；P 表示 页面变量； s 表示 数据类型为String；
//初始化统一调用方法：initPage
@property (strong, nonatomic) NSString *iPs_PageName; //页面名称(用于标记参数组)
@property (strong, nonatomic) NSString *iPs_URL; //请求数据接口模板--地址
@property (strong, nonatomic) NSString *iPs_PAGE; //请求数据接口模板--页面
@property (strong, nonatomic) NSString *iPs_POST; //请求数据POST参数模板
@property (strong, nonatomic) NSString *iPs_POSTAction; //请求数据POST参数Action

//传入变化的参数组,参数数目根据接口需要而变化
@property (strong, nonatomic) NSString *iPs_POSTID; //请求数据POST参数ID1
@property (strong, nonatomic) NSString *iPs_POSTQueryOption; //请求数据POST参数ID2
@property (strong, nonatomic) NSString *iPs_POSTQueryRegion; //请求数据POST参数ID3

@property (strong, nonatomic) PoiSearchViewController *poimapview;

//页面内部变量(由程序控制实际值)
@property (nonatomic) int iPageIndex;
@property (nonatomic) Boolean isConnected;
@end

@implementation MapsLocationTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self initPage];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //页面跳转至地图首页
    //MapsViewController *mapview = [[MapsViewController alloc] init];
    //[self.navigationController pushViewController:mapview animated:YES];
    if (_iPs_PageName==nil) {
        [self initPage];
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //订单的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DidLocationCompletion:)
                                                 name:@"DidLocationNotification"
                                               object:nil];
    //刷新列表的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LocationPoint:)
                                                 name:@"LocationPointNotification"
                                               object:nil];

    
    // 3.2.上拉加载更多
    [self addFooter];
    [self addHeader];
    _toMap = 0;
    PoiSearchViewController *poimapview = [[PoiSearchViewController alloc] init];
    [self.navigationController pushViewController:poimapview animated:YES];
    poimapview.title = @"位置";
    poimapview.itemname = @"";
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]init];
    backItem.title=@"";
    backItem.tintColor=[UIColor colorWithRed:129/255.0 green:129/255.0  blue:129/255.0 alpha:1.0];
    self.navigationItem.backBarButtonItem = backItem;

}

//页面即将展示
-(void) viewWillAppear:(BOOL)animated{
    //如果页面没有初始化则先用初始值
    if (_iPs_PageName==nil) {
        [self initPage];
    }
    if (_isConnected == false) {
        NSLog(@"尝试重新加载数据...");
        //重新加载数据
        [self startRequest];
    }
    
    
    //
    if (_toMap > 1) {
        
//        if(_poimapview == nil){
//            _poimapview = [[PoiSearchViewController alloc] init];
//        }
//        [self.navigationController pushViewController:_poimapview animated:YES];
        
        //需要转发通知

    }
    
    
}

- (void)viewWillDisappear:(BOOL)animated{
    //消失
    _toMap = 0;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//初始化页面变量组和参数
- (void)initPage
{
    //根据页面类型不同需要配置的部分
    _iPs_PageName=@"地区列表"; //页面名称(用于标记页面参数配置)
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _iPs_URL=delegate.iPs_URL; //请求数据接口模板--地址
    //_iPs_URL=@"http://192.168.1.43/mall/";
    
    _iPs_PAGE=@"getLocationList.php"; //请求数据接口模板--页面1
    _iPs_POST=@"act=%@&city=%@&district=%@"; //请求数据POST参数模板
    _iPs_POSTAction =@"region_list";
    
    //_iPs_PAGE=@"property_app.php"; //请求数据接口模板--页面1
    //_iPs_POST=@"act=%@&region_id=%@"; //请求数据POST参数模板
    //_iPs_POSTAction =@"region_list";
    _iPs_POSTID = @"298";//delegate.userid; //请求数据POST参数ID1
    
    _iPs_POSTQueryOption=@""; //请求数据POST参数ID2
    _iPs_POSTQueryRegion=@""; //请求数据POST参数ID3
    
    _defaultCode = @"298";
    _defaultArea = @"枣庄";
    
    _lbAddress.text = delegate.userAddress;
    _AreaID = delegate.userAreaID;
    
    //不随页面类型改变的部分
    _iPageIndex = 1;//初始化页面序号
    _selectedRow = -1;
    _CellBgColor =[UIColor colorWithRed:49/255.0 green:155/255.0 blue:205/255.0 alpha:0.15];
    
    if (delegate.isLimited) {
        _btnCityList.hidden = true;

        //将定位修正到服务区域下
        _City = @"枣庄";
        _District = @"滕州市";
        
        _PostCity = _City;
        _PostDistrict = _District;

    }
    
}

//增加向下滑动刷新下页功能
- (void)addFooter
{
    __unsafe_unretained MapsLocationTableViewController *vc = self;
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.tableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        NSLog(@"下拉请求更多数据 %d",_iPageIndex);
        [self setPageNext];
        //加载数据
        [self startRequest];
        
        
        //[vc->_fakeData addObject:[NSString stringWithFormat:@"随机数据---%d", random]];
        
        
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是footer
        [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:0.1];
        
        //NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    _footer = footer;
}

//滑动调用的刷新事件
- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    NSLog(@"滑动展示数据表格");
    // 刷新表格
    [self.tableView reloadData];
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}

//增加向上滑动返回上页功能
- (void)addHeader
{
    
    
    __unsafe_unretained MapsLocationTableViewController *vc = self;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self.tableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        NSLog(@"上拉请求翻页数据 %d",_iPageIndex);
        if (_iPageIndex<=1) {
            _iPageIndex = 1;
            NSLog(@"当前的数据列表没有历史缓存 %d",_iPageIndex);
            
        }else{
            //翻页控制逻辑这里后退1页
            _iPageIndex = _iPageIndex - 1;
            //加载数据
            [self startRequest];
        }
        //    if (_iPageIndex==0) {
        //        NSLog(@"页面初始化忽略上拉动作 %d",_iPageIndex);
        //        return;
        //    }
        
        
        // 这里的refreshView其实就是header
        [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:0.5];
        
        //NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
        //NSLog(@"%@----刷新完毕", refreshView.class);
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                //NSLog(@"切换到：普通状态");
                break;
                
            case MJRefreshStatePulling:
                //NSLog(@"松开即可刷新的状态");
                break;
                
            case MJRefreshStateRefreshing:
                //NSLog(@"正在刷新状态");
                break;
            default:
                break;
        }
    };
    [header beginRefreshing];
    _header = header;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.listData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"locatcell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier  forIndexPath:indexPath];
    locationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier  forIndexPath:indexPath];

    //使用自定义的单元格
    
    if (cell == nil) {
        NSLog(@"表格初始化错误");
        

        [[NSBundle mainBundle] loadNibNamed:@"locationCell" owner:self options:nil];

    }
    //开始解析数据

    NSMutableDictionary*  dict = self.listData[indexPath.row];
    
    //修改单元格背景色
    UIView *bgColorView = [[UIView alloc] init];
    
    bgColorView.backgroundColor = _CellBgColor;
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    
    //填充单元格
    NSString * strID;
    NSString * strName;
    NSString * strisopen;
    NSString * strNamePlus1;
    NSString * strNamePlus2;
    cell.lbNo.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
    
    strID =[dict objectForKey:@"region_id"];
    strName =[dict objectForKey:@"region_name"];
    strisopen =[dict objectForKey:@"isopen"]; //0 未开通  1 已开通
    
    //适当扩展，增加识别概率
    strNamePlus1 = [[NSString alloc]initWithFormat:@"%@省",strName];
    strNamePlus2 = [[NSString alloc]initWithFormat:@"%@市",strName];
    
    cell.lbName.text =  strName;
    cell.lbID.text = strID;
    
    if ([strisopen isEqualToString:@"1"]) {
        //
        //@"已开通";
        cell.lbisOpen.text = @"已开通";
        cell.lbName.textColor = [UIColor darkTextColor];
    }else{
        cell.lbisOpen.text = @"  ×";
        cell.lbName.textColor = [UIColor grayColor];
    }

    
    
    if(_selectedRow == indexPath.row){
        if([strisopen isEqualToString:@"1"]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.selected = YES;
        }else{
            _selectedRow = -1;
        }
        _CurrentCity = strName;
        _AreaID = strID;
        _isOpenCurrent = strisopen;
    }else if(_selectedRow == -1){
        if (([strName isEqualToString:_District])||([strNamePlus2 isEqualToString:_District])) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.selected = YES;
            _CurrentCity = strName;
            _AreaID = strID;
            _isOpenCurrent = strisopen;
        }else if(([strName isEqualToString:_City])||([strNamePlus1 isEqualToString:_City])||([strNamePlus2 isEqualToString:_City])){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.selected = YES;
            _CurrentCity = strName;
            _AreaID = strID;
            _isOpenCurrent = strisopen;
        }else if(([strName isEqualToString:_Province])||([strNamePlus1 isEqualToString:_Province])||([strNamePlus2 isEqualToString:_Province])){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.selected = YES;
            _CurrentCity = strName;
            _AreaID = strID;
            _isOpenCurrent = strisopen;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    //以上已完成单元格修改
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //响应开关
    ////方法之一：设置一个外部变量，选中的时候传值，然后通过重新加载数据，使得在选中这行打勾，其他行无样式,此方法加载的时候第一行默认打勾了
    if (_selectedRow == indexPath.row) {
        //相同则取消，并将标记归零(不选)
        _selectedRow = -1;
    }else{
        _selectedRow = indexPath.row;
    }
    
    [self.tableView reloadData];

    //延迟执行
    [self performSelector:@selector(usedAreaID) withObject:nil afterDelay:0.3f];
}

#pragma mark - Event Processor

//响应定位事件，直接推送
-(void)LocationPoint:(NSNotification*)notification {
    
    //如果已经打开地图则不需要再推送地图
    _toMap = 1;

}

//定位获取位置后的跳转标记
-(void)DidLocationCompletion:(NSNotification*)notification {
    
    NSDictionary *theData = [notification userInfo];
    _Address = [theData objectForKey:@"address"];
    _Province = [theData objectForKey:@"province"];
    _City = [theData objectForKey:@"city"];
    _District = [theData objectForKey:@"district"];

    _iPageIndex = 0;
    _lbAddress.text =_Address;
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if (delegate.isLimited) {
        //将定位修正到服务区域下
        _City = @"枣庄";
        _District = @"滕州市";
    }
    //
    NSLog(@"定位完成后识别位置,%@",_Address);
    
    
    _selectedRow = -1;
    _iFindLevel = 1;

    //去掉“市”
    NSString *strEnd = @"";
    //截断末尾 0
    strEnd=[_City substringFromIndex:[_City length]-1];
    if ([strEnd isEqualToString:@"市"]) {
        _City = [_City substringToIndex:[_City length]-1];
    }
    
    _PostCity = _City;
    _PostDistrict = _District;
    
    
    [self startRequest];
}



- (IBAction)btnCityListClicked:(id)sender {
    //城市列表
    _PostCity = @"中国";
    _PostDistrict = @"";
    _selectedRow = -1;
    _iFindLevel = 1;
    //发出请求
    [self startRequest];
    
    //在用户修改城市前不变更原自动定位
}

//询问用户位置变更，同时包含了服务支持信息
- (void)RequestAutoChanged:(NSString *)strMsg isOpen:(NSString *)lsOpened {
    
    //询问变更定位信息
    //NSString *strMsg = [[NSString alloc ] initWithFormat:@"当前城市定位至:%@", _CurrentCity];
    if([lsOpened isEqualToString:@"1"]){
        
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        
        if([delegate.userDistrict isEqualToString:_District]){
            //没有变化不需要提示
            [self findedAreaID];
            return;
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"位置服务提醒"
                                                            message:strMsg
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定",nil];

        alertView.tag = 1;
        [alertView show];
    }else{
        //未开通的地区
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未开通的地区提醒"
                                                            message:strMsg
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定",nil];

        alertView.tag = 2;
        [alertView show];
    }

    
}

//退出 询问操作结果
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            NSLog(@"确认使用当前城市");
            [self findedAreaID];
        }else{

            _CurrentCity = _defaultArea;
            _AreaID = _defaultCode;
            NSLog(@"取消当前定位采用默认位置 %@",_CurrentCity);
            [self findedAreaID];
        }
    }else if(alertView.tag == 2){
        //无论选择什么都使用默认地区
        
        _CurrentCity = _defaultArea;
        _AreaID = _defaultCode;
        NSLog(@"未开通地区，采用默认位置 %@",_CurrentCity);
        [self findedAreaID];
    }
    
}

//展开地区,找到并更换地区ID ,用户选择城市时触发
-(void)usedAreaID{

    if ((_AreaID != nil)&&(![_AreaID isEqualToString:@""])) {
        NSLog(@"地区变更为 %@ ",_AreaID);
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];

        //每次选中展开后增加层级
        if([_isOpenCurrent isEqualToString:@"1"]){
            _iFindLevel = _iFindLevel + 1;
            if (_iFindLevel!=2) {//只选择省无法选定服务
            delegate.userAreaID = _AreaID;
            delegate.userDistrict = _CurrentCity;
            delegate.userCitySupported = _isOpenCurrent;
            [delegate saveUserDefaults:@"userareaid" setValue:_AreaID];
            [delegate saveUserDefaults:@"userdistrict" setValue:_CurrentCity];
            [delegate saveUserDefaults:@"usercitysupported" setValue:_isOpenCurrent];
            }
        }
        
        if (_iFindLevel>=4) {
            //已经进入到具体区域，不需要再展开
            if([_isOpenCurrent isEqualToString:@"1"]){
                NSString *strMsg = [[NSString alloc ] initWithFormat:@"当前城市定位至:%@", _CurrentCity];
                [delegate showNotify:strMsg HoldTimes:2];
                NSLog(@"当前城市: %@ , %@",_CurrentCity ,_AreaID);
            }else{
                //未开通
                NSString *strMsg = [[NSString alloc ] initWithFormat:@"您选择的城市: %@ ,目前尚未开通服务支持。我们将在服务列表中展示默认的服务项目。", _CurrentCity];

                [self RequestAutoChanged:strMsg isOpen:_isOpenCurrent];
                //修改默认城市
            }

            //刷新服务列表
            self.tabBarController.selectedIndex = 2;
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ServiceRefreshNotification"
             object:nil
             userInfo:nil];

        }else{
            //展开区域
            NSLog(@"展开下一级: %@ , %@",_CurrentCity ,_AreaID);

            _selectedRow = -1;
            //发出请求
            if([_isOpenCurrent isEqualToString:@"1"]){
                _PostCity = _CurrentCity;
                _PostDistrict = @"";
                //只能展开已开通地区
                [self startRequest];
            }else{
                _PostCity = @"";
            }
        }
    }
    
}


-(void)findedAreaID{
    
    if ((_AreaID != nil)&&(![_AreaID isEqualToString:@""])) {
        NSLog(@"地区变更为 %@ ,%@ ", _CurrentCity,_AreaID);
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        if([_isOpenCurrent isEqualToString:@"1"]){
            delegate.userAreaID = _AreaID;
            delegate.userDistrict = _CurrentCity;
            delegate.userCitySupported = _isOpenCurrent;
            
            if (_iFindLevel>=4) {
                //已经进入到具体区域，不需要再展开
                //NSString *strMsg = [[NSString alloc ] initWithFormat:@"当前城市定位至:%@", _CurrentCity];
                //[delegate showNotify:strMsg HoldTimes:2];
                [delegate saveUserDefaults:@"userareaid" setValue:_AreaID];
                [delegate saveUserDefaults:@"userdistrict" setValue:_CurrentCity];
                [delegate saveUserDefaults:@"usercitysupported" setValue:_isOpenCurrent];
                //刷新服务列表
                //self.tabBarController.selectedIndex = 2;
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"ServiceRefreshNotification"
                 object:nil
                 userInfo:nil];
                
            
            }
        }
    }
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//城市数据列表
- (void)LocationtoArea{
    
    if ([_CityFinded isEqualToString:@"1"]) {
        //已选择城市
        
    }
    
    //存在定位信息
    if ((_District!=nil)&&(![_District isEqualToString:@""])) {
        //去掉“市”
        NSString *strEnd = @"";
        //截断末尾 0
        strEnd=[_City substringFromIndex:[_City length]-1];
        if ([strEnd isEqualToString:@"市"]) {
            _City = [_City substringToIndex:[_City length]-1];
        }

        _PostCity = _City;
        _PostDistrict = _District;
    }else{
        //默认城市、可以是中国，然后选择省，再选则市，区县
        
        
        _PostCity = @"中国";
        _PostDistrict = @"";
        
    }
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if (delegate.isLimited) {
        //将定位修正到服务区域下
        _City = @"枣庄";
        _District = @"滕州市";
        
        _PostCity = _City;
        _PostDistrict = _District;
        
    }
    
}



/*
 * 开始请求Web Service
 */
-(void)startRequest
{
    _isConnected = false;

    NSString *strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    //NSString *post = [NSString stringWithFormat:@"act=wash_list&cat_id=139&page=%d&sel_attr=0&region_id=%@",_iPageIndex,@"298"];
    //NSString *post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID];
    
    if ((_PostCity==nil)||([_PostCity isEqualToString:@""])||([_PostCity isEqualToString:@"中国"])) {
        _PostCity = @"中国";
        _iFindLevel = 1;
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];

        if (delegate.isLimited) {
            //将定位修正到服务区域下
            _PostCity = @"枣庄";
            _PostDistrict = @"滕州市";
            
        }
    }
    
    NSString * strCity = _PostCity;
    NSString * strDistrict= _PostDistrict;
    NSString *encodeUrl2 = @"";
    NSString *encodeUrl1 = [strCity stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (strDistrict!=nil) {
        encodeUrl2 = [strDistrict stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString *post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,encodeUrl1,encodeUrl2 ];
    
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
	
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request delegate:self];
	
    if (connection) {
        _isConnected = true;    //由于请求异步，并不能确定本次连接成功，但要防止重复请求
        _datas = [NSMutableData new];
        NSLog(@"发出数据请求:%@  POST=%@ || city=%@, district=%@",strURL,post,_PostCity,_PostDistrict);
        //[self setPageNext];//下次请求换页
        if(_iPageIndex <= 0)
        {_iPageIndex = 1;}
        
    }else{
        NSLog(@"无法建立数据连接！%@ POST=%@", strURL , post);
        _isConnected = false;
    }
}

#pragma mark- NSURLConnection 回调方法
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_datas appendData:data];
}


-(void) connection:(NSURLConnection *)connection didFailWithError: (NSError *)error {
    
    _isConnected = false;
    NSLog(@"连接失败：%@",[error localizedDescription]);
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection {
    NSLog(@"请求数据完成接收,准备解析");
    _isConnected = true;
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:_datas options:NSJSONReadingAllowFragments error:nil];
    
    NSLog( @"Result: %@", [dict description] );
    //激活数据列表的刷新
    [self reloadView:dict];
}


//控制Page页面数据翻页
- (int)setPageNext
{
	const int N = 15;
	int nextPage = 0;
    nextPage = _iPageIndex + 1;
    if (nextPage>N) {
        nextPage = 1;
    }
    _iPageIndex = nextPage;
    NSLog(@"NextPage=%d",_iPageIndex);
    return nextPage;
}

- (IBAction)btnSearch:(id)sender {
    
    PoiSearchViewController *poimapview = [[PoiSearchViewController alloc] init];
    [self.navigationController pushViewController:poimapview animated:YES];
    poimapview.title = @"搜索";
    poimapview.itemname = @"";
}

- (void)getLocation
{
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _Address = delegate.userAddress;
    _Province = delegate.userProvince;
    _City = delegate.userCity;
    _District = delegate.userDistrict;
    
    if (_Address!=nil) {
        _lbAddress.text = _Address;
    }
    
}



//重新加载表视图
-(void)reloadView:(NSDictionary*)res
{
    
    @try{
        NSEnumerator *enumerator = [res objectEnumerator];
        
        NSArray *results = [enumerator allObjects];
        
        if (results.count > 0)
        {
            _listData = [NSMutableArray arrayWithArray:results];
            
            NSLog(@"列表视图加载数据...共 %d 条",results.count);
            //取得定位信息
            _iPageIndex = 1;
            
            if (results.count == 1) {
                //找到唯一结果
                _iFindLevel = 4;
                _CityFinded = @"1";
                NSMutableDictionary*  dict = self.listData[0];
                _AreaID =[dict objectForKey:@"region_id"];
                _CurrentCity =[dict objectForKey:@"region_name"];
                NSString *strisOpen =[dict objectForKey:@"isopen"];
                NSString *strMsg = @"";
                if ([strisOpen isEqualToString:@"1"]) {
                    //已开通
                    strMsg = [[NSString alloc ] initWithFormat:@"是否接受将我的位置定位到: %@ %@ ,该城市已开通服务。", _City,_District];
                }else{
                    //未开通地区
                    strMsg = [[NSString alloc ] initWithFormat:@"您所在的城市: %@ %@ ,目前尚未开通服务支持。我们将在服务列表中展示默认的服务项目。", _City,_District];
                }
                
                [self RequestAutoChanged:strMsg isOpen:strisOpen];
                
                //调用位置后的动作
                //[self findedAreaID];
                
            }else{
                _CityFinded = @"0";
            }

            [self getLocation];
            
            [self.tableView reloadData];

            
        } else {
            //{}无数据返回
            NSLog(@"请求数据返回空");
            
            _iPageIndex = _iPageIndex + 1;
            
            _listData = nil;
            
            //回到默认的顶层 ,防止请求为空 连续请求 3次后终止尝试
            if ((_iFindLevel<3)&&(_iPageIndex<3)){

                [self btnCityListClicked:_btnCityList];
                
            }
            //[self.tableView reloadData];
        }
    }@catch(NSException * e){
        
        //有异常说明 is_error 不存在
    }
    
}

@end
