//
//  carswashOrderTableViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-13.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "couponsTableViewController.h"
#import "MJRefresh.h"
#import "UIButton+Bootstrap.h"
#import "bonusTableViewController.h"

@interface couponsTableViewController (){
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

//重点说明
//2014-5-25  Created By Robin
//定义可配置的数据参数（对于简单查询只需1组配置）
//命名规则： i 表示实例变量；P 表示 页面变量； s 表示 数据类型为String；
//初始化统一调用方法：initPage
@property (strong, nonatomic) NSString *iPs_PageName; //页面名称(用于标记参数组)
@property (strong, nonatomic) NSString *iPs_URL; //请求数据接口模板--地址
@property (strong, nonatomic) NSString *iPs_PAGE; //请求数据接口模板--页面
@property (strong, nonatomic) NSString *iPs_POST; //请求数据POST参数模板
@property (strong, nonatomic) NSString *iPs_POST2; //请求数据POST参数模板2
@property (strong, nonatomic) NSString *iPs_POSTAction; //请求数据POST参数Action
@property (strong, nonatomic) NSString *iPs_POSTAction2; //请求数据POST参数Action2
//传入变化的参数组,参数数目根据接口需要而变化
@property (strong, nonatomic) NSString *iPs_POSTID; //请求数据POST参数ID1
@property (strong, nonatomic) NSString *iPs_POSTQueryOption; //请求数据POST参数ID2
@property (strong, nonatomic) NSString *iPs_POSTQueryRegion; //请求数据POST参数ID3

@property (strong, nonatomic) NSString *iPs_PAGE3; //请求数据接口模板--页面
@property (strong, nonatomic) NSString *iPs_POST3; //请求数据POST参数模板
@property (strong, nonatomic) NSString *iPs_POSTAction3; //请求数据POST参数Action
//页面内部变量(由程序控制实际值)
@property (nonatomic) int iPageIndex;
@property (nonatomic) Boolean isConnected;
@end

@implementation couponsTableViewController
//底层的初始化
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self initPage];
        
    }
    return self;
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
    
    //主动查一下积分、余额信息 （以后改为消息触发）
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _usermoney = delegate.usermoney;
    _userpoints = delegate.userpoints;
    
    _txtMoney.text = [[NSString alloc]initWithFormat:@"余额 %1.2f 元", _usermoney];
    _txtPoint.text = [[NSString alloc]initWithFormat:@"积分 %1.0f", _userpoints];
    
    
}
//页面基本元素已载入,开始增添个性化的功能
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.btnAbout defaultStyle];
    [self.btnAbout addAwesomeIcon:FAIconTrophy beforeTitle:YES];
    
    //[self.btnmyCoupons successStyle];
    //[self.btnmyCoupons addAwesomeIcon:FAIconAsterisk beforeTitle:YES];
    //用户登录的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginCompletion:)
                                                 name:@"LoginCompletionNotification"
                                               object:nil];
    
    //订单的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OrderCompletion:)
                                                 name:@"OrderCompletionNotification"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OrderWithLogin:)
                                                 name:@"OrderWithLoginNotification"
                                               object:nil];
    //刷新列表的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(couponsRefresh:)
                                                 name:@"couponsRefreshNotification"
                                               object:nil];

    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if (false==delegate.isLogin) {
        NSLog(@"转到登录页面");
        /*userLoginViewController *loginview = [[userLoginViewController alloc] init];
        [self.navigationController pushViewController:loginview animated:YES];
        */
        
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"userLoginViewController"];
        
        _lbUsername.text = @"查看账户信息，请先登录";
        _lbUserInfo.text = @"";
        _txtMoney.text = @"余额 0 元";
        _txtPoint.text = @"积分 0";
        _btnLogin.titleLabel.text = @"登录";
        
        loginViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:loginViewController animated:YES completion:^{
            NSLog(@"打开登录界面");
        }];

    }else if(![delegate.username isEqual:@""]){
        _userid = delegate.userid;
        _username = delegate.username;
        _usermoney = delegate.usermoney;
        _userpoints = delegate.userpoints;
        
        //NSString * userinfo = [[NSString alloc]initWithFormat:@"   余额：%1.2f   积分：%1.0f", _usermoney,_userpoints];
        _lbUserInfo.text = @"";//userinfo;
        _lbUsername.text = _username;
        
        _txtMoney.text = [[NSString alloc]initWithFormat:@"余额 %1.2f 元", _usermoney];
        _txtPoint.text = [[NSString alloc]initWithFormat:@"积分 %1.0f", _userpoints];
        _btnLogin.titleLabel.text = @"退出";
        
    }

    // 3.集成刷新控件
    // 3.1.下拉刷新
    
    // 3.2.上拉加载更多
    [self addFooter];
    [self addHeader];
    
}

//释放内存占用,比如数据表格，缓存的图片等
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//初始化页面变量组和参数
- (void)initPage
{
    //根据页面类型不同需要配置的部分
    _iPs_PageName=@"消费券列表"; //页面名称(用于标记页面参数配置)
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _iPs_URL=delegate.iPs_URL; //请求数据接口模板--地址
    _iPs_PAGE=@"flow_app.php"; //请求数据接口模板--页面1
    _iPs_POST=@"act=%@&user_id=%@"; //请求数据POST参数模板
    _iPs_POST2=@"act=%@&user_id=%@&order_id=%@"; //请求数据POST参数模板
    _iPs_POSTAction =@"user_code";   //消费券
    _iPs_POSTAction2 =@"order_code";//订单下的消费券
    _iPs_POSTID = delegate.userid; //请求数据POST参数ID1
    
    _iPs_POSTQueryOption=@""; //请求数据POST参数ID2
    _iPs_POSTQueryRegion=@""; //请求数据POST参数ID3
    
    //短信验证的接口
    _iPs_PAGE3=@"messageAuthentication.php"; //请求数据接口模板--页面1
    _iPs_POST3=@"action=%@&phone=%@&invitationCode=%@&username=%@&bussinessname=%@"; //请求数据POST参数模板
    _iPs_POSTAction3 =@"order";   //订单完成后发送消费券密码
    

    //不随页面类型改变的部分
    _iPageIndex = 1;//初始化页面序号
    
    if (delegate.isLogin) {
        _btnLogin.titleLabel.text = @"退出";
    }else{
        _btnLogin.titleLabel.text = @"登录";
    }
    
    if(delegate.userbonus > 0){
        _txtBonus.text = [[NSString alloc] initWithFormat:@"红包 [ %1.0f ]",delegate.userbonus];
        
    }else{
    
        _txtBonus.text = @"红包";
    }
    _withnoLogin = @"";
    _CellBgColor =[UIColor colorWithRed:49/255.0 green:155/255.0 blue:205/255.0 alpha:0.15];

}

//登录返回
-(void)loginCompletion:(NSNotification*)notification {
    
    NSDictionary *theData = [notification userInfo];
    _userid = [theData objectForKey:@"ID"];
    _username = [theData objectForKey:@"name"];
    
    _usermoney = [[theData objectForKey:@"user_money"]doubleValue];
    _userpoints = [[theData objectForKey:@"pay_points"]doubleValue];
    
    NSLog(@"登录页面返回,username = %@", _username);
    NSString *lsLogin = [theData objectForKey:@"isLogin"];
    

    //页面显示用户登录信息
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //if (false==delegate.isLogin) {
    if ([lsLogin isEqual:@"0"]) {
        _lbUsername.text = @"查看账户信息，请先登录";//_username;
        _lbUserInfo.text = @"    未登录，无法使用订单和交易功能";
        _btnLogin.titleLabel.text = @"登录";
        _withnoLogin = @"1";
        _txtMoney.text = [[NSString alloc]initWithFormat:@"余额 0 元"];
        _txtPoint.text = [[NSString alloc]initWithFormat:@"积分 0"];
        
        _listData = nil;
        
        [self.tableView reloadData];
        
    }else{
    
    delegate.userid = _userid;
    delegate.username = _username;
    delegate.usermoney = _usermoney;
    delegate.userpoints = _userpoints;
    
    _btnLogin.titleLabel.text = @"退出";
    _lbUsername.text = _username;
    NSString * userinfo = [[NSString alloc]initWithFormat:@"   余额：%1.2f   积分：%1.0f", _usermoney,_userpoints];
    _txtMoney.text = [[NSString alloc]initWithFormat:@"余额 %1.2f 元", _usermoney];
    _txtPoint.text = [[NSString alloc]initWithFormat:@"积分 %1.0f", _userpoints];
    _lbUserInfo.text = userinfo;
    _withnoLogin = @"";
        
    }
    
    //变更用户身份
    _iPs_POSTID = delegate.userid;
    
    //返回
    //[self.navigationController popViewControllerAnimated:YES];
    _listData = nil;
    //重新请求加载数据
    [self startRequest];
    
}

//订单完成后跳转
-(void)OrderCompletion:(NSNotification*)notification {

    NSDictionary *theData = [notification userInfo];
    _orderName = [theData objectForKey:@"name"];
    _orderID = [theData objectForKey:@"ID"];
    _FromOrder = @"1";
    _iPageIndex = 0;
    //
    NSLog(@"订单完成后跳转,%@",_orderID);
    _btnmyCoupons.titleLabel.text = @"订单消费券";
    [self startRequest];
}

//订单无法提交的跳转,需要登录
-(void)OrderWithLogin:(NSNotification*)notification {
    
    //
    _withnoLogin = @"";
    NSLog(@"订单无法提交的跳转，缺少用户登录信息。");
    [self btnLogin:_btnLogin];
}

//刷新优惠券列表
-(void)couponsRefresh:(NSNotification*)notification {
    
    //
    NSLog(@"刷新优惠券列表通知,%@", _iPs_POSTID );
    [self startRequest];
}



//增加向下滑动刷新下页功能
- (void)addFooter
{
    __unsafe_unretained couponsTableViewController *vc = self;
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
    
    
    __unsafe_unretained couponsTableViewController *vc = self;
    
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


//表格的定制化操作
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CouponsCell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier  forIndexPath:indexPath];
    CouponsViewCell *cell;
    if ((_orderID==nil)||([_orderID isEqualToString:@""])) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    //使用自定义的单元格
    
    if (cell == nil) {
        NSLog(@"表格初始化错误");
        
        //cell = [[CouponsViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [[NSBundle mainBundle] loadNibNamed:@"CouponsViewCell" owner:self options:nil];
        

        //NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"couponsTableViewController" owner:self options:nil] ;
        
        //cell = [nib objectAtIndex:0];
    }
    //开始解析数据
    
    

    NSMutableDictionary*  dict = self.listData[indexPath.row];
    
    //修改单元格背景色
    UIView *bgColorView = [[UIView alloc] init];

    bgColorView.backgroundColor = _CellBgColor;
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    
    //填充单元格
    cell.lbNumber.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
    cell.lbCouponsCode.text =[dict objectForKey:@"code"];
    //cell.lbBuyDate.text =[dict objectForKey:@"use_time"];
    
    NSString *strStatus = [dict objectForKey:@"status"];
    //0 未消费；1 已消费； 2 密码券过期失效； 3 密码券无效；4 退款，密码券无效；
    if ([strStatus isEqual: @"0"]) {
        cell.lbStatus.text = @"有效,未消费";
        cell.lbCouponsCode.textColor = [UIColor redColor];
    }else if([strStatus isEqual: @"1"]){
        cell.lbStatus.text = @"已消费";
        cell.lbCouponsCode.textColor = [UIColor darkGrayColor];
    }else if([strStatus isEqual: @"2"]){
        cell.lbStatus.text = @"已过期";
        cell.lbCouponsCode.textColor = [UIColor lightGrayColor];
    }else if([strStatus isEqual: @"3"]){
        cell.lbStatus.text = @"无效";
        cell.lbCouponsCode.textColor = [UIColor lightGrayColor];
    }else if([strStatus isEqual: @"4"]){
        cell.lbStatus.text = @"无效，已申请退款";
        cell.lbCouponsCode.textColor = [UIColor darkTextColor];
    }else{
        cell.lbStatus.text = @"无效";
        cell.lbCouponsCode.textColor = [UIColor lightGrayColor];
    }
    
    if ([_FromOrder isEqualToString:@"1"]) {
        //来自订单的消费券
        _orderID = [dict objectForKey:@"order_id"];
        //服务器返回了完整的信息
        _orderName = [dict objectForKey:@"goods_name"];
        _Phone = [dict objectForKey:@"phone"];
        _Address = [dict objectForKey:@"address_street"];
        
        _Locationpt.latitude = [[dict objectForKey:@"Latitude"] doubleValue];
        _Locationpt.longitude = [[dict objectForKey:@"Longitude"] doubleValue];
        //带订单号过滤
        cell.orderSn = [dict objectForKey:@"order_sn"];

        
    }else{
        _orderID = [dict objectForKey:@"order_id"];
        //服务器返回了完整的信息
        _orderName = [dict objectForKey:@"goods_name"];
        _Phone = [dict objectForKey:@"phone"];
        _Address = [dict objectForKey:@"address_street"];
        
        _Locationpt.latitude = [[dict objectForKey:@"Latitude"] doubleValue];
        _Locationpt.longitude = [[dict objectForKey:@"Longitude"] doubleValue];
        //带订单号过滤
        cell.orderSn = [dict objectForKey:@"order_sn"];
        
    }
    //解析其它数据存入变量 CELL
    

    if ((_orderID == nil)||([_orderID isEqualToString:@""])) {
        //查找用户的密码券
        cell.lbName.text = @"";
    }else{

        cell.lbName.text = _orderName;
        cell.orderID = _orderID;
        
        cell.orderName = _orderName;
        cell.Phone = _Phone;
        cell.Address = _Address;
        cell.Locationpt = _Locationpt;

    }

    //以上已完成单元格修改
    return cell;

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

#pragma mark - Navigation
//页面发生跳转，进入明细
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showbonus"])
    {
        //红包列表
        //bonusTableViewController *itemlist = segue.destinationViewController;
        
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc]init];
        backItem.title=@"";
        backItem.tintColor=[UIColor colorWithRed:129/255.0 green:129/255.0  blue:129/255.0 alpha:1.0];
        self.navigationItem.backBarButtonItem = backItem;
        
    }
    
    if([segue.identifier isEqualToString:@"showcoupons"])
    {
        couponsDetailViewController *itemdetail = segue.destinationViewController;
        
        NSInteger selectedRow = [[self.tableView indexPathForSelectedRow] row];
        
        
        
        NSMutableDictionary*  dict = self.listData[selectedRow];
        itemdetail.CouponsCode = [dict objectForKey:@"code"];
        itemdetail.CouponsStatus = [dict objectForKey:@"status"];
        
        //来自订单的消费券
        _orderID = [dict objectForKey:@"order_id"];
        //服务器返回了完整的信息
        _orderName = [dict objectForKey:@"goods_name"];
        _Phone = [dict objectForKey:@"phone"];
        _Address = [dict objectForKey:@"address_street"];
        
        _Locationpt.latitude = [[dict objectForKey:@"Latitude"] doubleValue];
        _Locationpt.longitude = [[dict objectForKey:@"Longitude"] doubleValue];
        
        itemdetail.orderID = _orderID;
        itemdetail.CouponsName = _orderName;
        itemdetail.Address = _Address;
        itemdetail.Phone = _Phone;
        itemdetail.Locationpt = _Locationpt;

        UIBarButtonItem *backItem=[[UIBarButtonItem alloc]init];
        backItem.title=@"";
        backItem.tintColor=[UIColor colorWithRed:129/255.0 green:129/255.0  blue:129/255.0 alpha:1.0];
        self.navigationItem.backBarButtonItem = backItem;

        /*
         //点击消费券会重置cell导致信息丢失,由于Cell被释放
        static NSString *CellIdentifier = @"CouponsCell";
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //使用自定义的单元格
        CouponsViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier  forIndexPath:indexPath];
        
        if (cell != nil) {
            //取表格中的数据
            itemdetail.orderID = cell.orderID;
            itemdetail.CouponsName = cell.orderName;
            itemdetail.Address = cell.Address;
            itemdetail.Phone = cell.Phone;
            itemdetail.Locationpt = cell.Locationpt;
            
        }

        
        
        if ((_orderID == nil)||([_orderID isEqualToString:@""])) {
            
        }else{
            //带订单号过滤
            itemdetail.orderID = _orderID;
            itemdetail.CouponsName = _orderName;
            itemdetail.Address = _Address;
            itemdetail.Phone = _Phone;
            itemdetail.Locationpt = _Locationpt;
        }

        */
        
        
        //itemdetail.CouponsNote = [dict objectForKey:@"note"];
        //itemdetail.CouponsUsedtime = [dict objectForKey:@"use_time"];
        
        
        
    }
    if([segue.identifier isEqualToString:@"userlogin"])
    {
    }
}


- (IBAction)btnmycouponsClicked:(id)sender {
    [self performSelector:@selector(couponsDelay) withObject:nil afterDelay:0.2f];
}

- (void)couponsDelay{
    //以下代码需要延迟执行，如果没有初始化
    if ([_FromOrder isEqualToString: @"1"]) {
        _FromOrder = @"0";
        _btnmyCoupons.titleLabel.text = @"我的消费券";
        [self startRequest];
        
    }else if((_orderID != nil)&&(![_orderID isEqualToString:@""])){
        //_FromOrder = @"1";
        //_btnmyCoupons.titleLabel.text = @"订单消费券";
        //[self startRequest];
        _iPageIndex = 0;
    }

}

//点击红包
- (IBAction)btnShowBonusClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"showbonus" sender:self];
    
}

- (IBAction)btnShowBonusArea:(id)sender {
    [self performSegueWithIdentifier:@"showbonus" sender:self];
}


//登录退出
- (IBAction)btnLogin:(id)sender {
    if ([_btnLogin.titleLabel.text isEqualToString:@"退出"]) {
        //退出
        //订单创建失败
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"退出账户"
                                                            message:@"您确实要退出当前账户吗？"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"退出",nil];
        [alertView show];
        
        
    }else{
        //登录
        [self performSegueWithIdentifier:@"userlogin" sender:self];
        
    }
    
}

//退出 询问操作结果
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //退出
        _isQuitCurrent = true;
        

        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        
        delegate.isLogin= false;
        delegate.userid = @"";

        delegate.password = @"";
        delegate.isAutoLogin = false;
        
        delegate.usermoney = 0;
        delegate.userpoints = 0;
        
        //存档配置
        [delegate SaveConfig];
        
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"isLogin",@"", @"ID",@"", @"name", nil];
        
            //传递消息
        [[NSNotificationCenter defaultCenter]
             postNotificationName:@"LoginCompletionNotification"
             object:nil
             userInfo:dataDict];

        //重要：主动调用 Segue 呈现页面
        NSLog(@"退出登录");
        [self performSegueWithIdentifier:@"userlogin" sender:self];

        
    }else{
        _isQuitCurrent = false;
        //
        _btnLogin.titleLabel.text = @"退出";

        NSLog(@"取消退出");
    }

}

/*
 * 开始请求Web Service
 */
-(void)startRequest
{
    _isConnected = false;
    //跳转到登录页面
    if ([_iPs_POSTID isEqualToString:@""]) {
        
        
        if (([_withnoLogin isEqualToString:@""])) {
            _withnoLogin = @"1";//避免用户循环进入登录页面
            //重要：主动调用 Segue 呈现页面
            [self performSegueWithIdentifier:@"userlogin" sender:self];
        }
        
        return;
    }
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    
    
    //NSString *post = [NSString stringWithFormat:@"act=wash_list&cat_id=139&page=%d&sel_attr=0&region_id=%@",_iPageIndex,@"298"];
    NSString *post = @"";
    
    
    if ((_orderID == nil)||([_orderID isEqualToString:@""])) {
        //查找用户的密码券
        post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID];
        _iPageIndex = 0;
    }else{
        //带订单号过滤[防止使用过OrderID后，过滤不全]
        if ([_FromOrder isEqualToString:@"1"]) {
            _iPageIndex = _iPageIndex + 1;
            if (_iPageIndex > 3) {
                //滑动3次显示全部
                _FromOrder=@"0";
                _btnmyCoupons.titleLabel.text = @"我的消费券";
                post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID];
            }else{
            post = [NSString stringWithFormat:_iPs_POST2,_iPs_POSTAction2,_iPs_POSTID,_orderID];
            }
        }else{
            post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID];
            _iPageIndex = 0;
        }
    }
    
    
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
	
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request delegate:self];
	
    if (connection) {
        _isConnected = true;    //由于请求异步，并不能确定本次连接成功，但要防止重复请求
        _datas = [NSMutableData new];
        NSLog(@"发出数据请求:%@  POST=%@",strURL,post);
        //[self setPageNext];//下次请求换页
        if(_iPageIndex <= 0)
        {_iPageIndex = 1;}
        
    }else{
        NSLog(@"无法建立数据连接！%@ POST=%@", strURL , post);
        _isConnected = false;
    }
}

/*
 * 开始请求Web Service 方法的参数改造(依赖参数传递)
 */
-(void)startRequest:(NSString *)paramURL POST:(NSString *)postString
{
    _isConnected = false;
    NSString *strURL = paramURL;
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    NSString *post = postString;
    
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
	
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request delegate:self];
	
    if (connection) {
        _isConnected = true;    //由于请求异步，并不能确定本次连接成功，但要防止重复请求
        _datas = [NSMutableData new];
        NSLog(@"发出数据请求:%@  POST=%@",strURL,post);
        //转到拖拉翻页[self setPageNext];//下次请求换页
        
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



//重新加载表视图
-(void)reloadView:(NSDictionary*)res
{
    if ((_orderID == nil)||([_orderID isEqualToString:@""])) {
        
    }else{
        /* //无法处理 is_error 异常
        //带订单号过滤
        if ([[res allKeys] containsObject:@"is_error"]) {
            NSNumber * Errors = [res objectForKey:@"is_error"];
            if ([Errors intValue] == 1 ) {
                //错误
                NSString * strMsg = [res objectForKey:@"err_msg"];
                washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
                [delegate showNotify:strMsg HoldTimes:3];
                
            }
        }*/
    }
    
    //以下代码需要重构，由于考虑兼容多种结果导致解析异常
    //需要规范请求返回数据格式
    
    @try{
        //尝试取 is_error
        
//        NSNumber *resultCodeObj = [res objectForKey:@"is_error"];
//            
//        if (resultCodeObj==nil) {
//            //无法处理的结果
//            
//            resultCodeObj = [[NSNumber alloc] initWithInt:0];
//        }
        int resultCodeObj = 2;
        if (resultCodeObj  ==1)
        {
            
            NSString *strError = [res objectForKey:@"err_msg"];
            //请求失败
            NSLog(@"请求数据返回 %@",strError);
            _listData = nil;
            [self.tableView reloadData];
            return;
            
        }else if (resultCodeObj  ==0){
            //正常
            NSString *strResult = [res objectForKey:@"result"];
            if (strResult == nil) {
                //{}无数据返回  ||([strResult isEqualToString:@""])
                NSLog(@"请求数据返回空");
                
                self.iPageIndex = 1;
                
                washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
                [delegate showNotify:@"当前用户没有找到可用的消费券" HoldTimes:3];
                
                _listData = nil;
                [self.tableView reloadData];
                return;
            }else{
                
            
            }
        }
        
    }@catch(NSException * e){
        
        //有异常说明 is_error 不存在
    }

    if ([_FromOrder isEqualToString:@"1"]) {
        
    }else{
    //正常逻辑解析列表
    res = [res objectForKey:@"result"];
    }
    @try{
        NSEnumerator *enumerator = [res objectEnumerator];
        NSString *lsCode = @"";
        
        NSArray *results = [enumerator allObjects];
        NSDictionary* dict;
        
        if (results.count > 0)
        {
            _listData = [NSMutableArray arrayWithArray:results];
            
            for (int i=0; i<results.count; i++) {
                dict = [results objectAtIndex:i];
                
                lsCode = [dict objectForKey:@"code"];
                
            }
            
            NSLog(@"列表视图加载数据...共 %d 条",results.count);
            
            [self.tableView reloadData];
        } else {
            //{}无数据返回
            NSLog(@"请求数据返回空");

            self.iPageIndex = 1;
            
            washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
            [delegate showNotify:@"当前用户没有找到可用的消费券" HoldTimes:3];
            _listData = nil;
            [self.tableView reloadData];
        }
    }@catch(NSException * e){
        
        //有异常说明 is_error 不存在
    }
    
}

//图片的处理
-(UIImage *) getImageFromURL:(NSString *)fileURL {
    NSLog(@"获取网络图片 %@",fileURL);
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}

//保存图片
-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        //ALog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
        NSLog(@"文件类型无法支持，请选择 jpeg，png格式");
    }
}

//文件路径，url/Image.png
-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    return result;
}


@end
