//
//  carswashOrderTableViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-13.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "carswashOrderTableViewController.h"
#import "MJRefresh.h"

@interface carswashOrderTableViewController (){
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
@property (strong, nonatomic) NSString *iPs_POSTAction; //请求数据POST参数Action
@property (strong, nonatomic) NSString *iPs_POSTAction2; //请求数据POST参数Action2
//传入变化的参数组,参数数目根据接口需要而变化
@property (strong, nonatomic) NSString *iPs_POSTID; //请求数据POST参数ID1
@property (strong, nonatomic) NSString *iPs_POSTQueryOption; //请求数据POST参数ID2
@property (strong, nonatomic) NSString *iPs_POSTQueryRegion; //请求数据POST参数ID3

//页面内部变量(由程序控制实际值)
@property (nonatomic) int iPageIndex;
@property (nonatomic) Boolean isConnected;
@end

@implementation carswashOrderTableViewController
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
    
    if (![_iPs_POSTQueryOption isEqualToString:_filterType]) {
        _iPs_POSTQueryOption = _filterType;
        //重新加载数据
        [self startRequest];
    }
    
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
    // 3.集成刷新控件
    // 3.1.下拉刷新
    
    // 3.2.上拉加载更多
    [self addFooter];
    [self addHeader];
    
    //用户登录的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginCompletion:)
                                                 name:@"LoginCompletionNotification"
                                               object:nil];
    
    //刷新列表的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OrderRefresh:)
                                                 name:@"OrderRefreshNotification"
                                               object:nil];
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
    _iPs_PageName=@"订单列表"; //页面名称(用于标记页面参数配置)
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _iPs_URL=delegate.iPs_URL; //请求数据接口模板--地址
    _iPs_PAGE=@"user_app.php"; //请求数据接口模板--页面1
    _iPs_POST=@"act=%@&user_id=%@"; //请求数据POST参数模板
    _iPs_POSTAction =@"order_unpay_list";   //未付款订单
    _iPs_POSTAction2 =@"order_pay_list";    //已付款订单
    //_iPs_POSTID=@"2692"; //请求数据POST参数ID1
    _iPs_POSTID=delegate.userid;
    
    _userid =_iPs_POSTID;
    
    // 0 未付款; 1 已付款
    _iPs_POSTQueryOption=@"1"; //请求数据POST参数ID2
    _iPs_POSTQueryRegion=@""; //请求数据POST参数ID3
    if (([_filterType isEqualToString:@""])||(_filterType ==nil)) {
        _filterType=@"1"; // 0 未付款; 1 已付款
    }
    
    //不随页面类型改变的部分
    _iPageIndex = 1;//初始化页面序号
    _CellBgColor =[UIColor colorWithRed:49/255.0 green:155/255.0 blue:205/255.0 alpha:0.15];
}

//登录返回
-(void)loginCompletion:(NSNotification*)notification {
    
    NSDictionary *theData = [notification userInfo];
    _userid = [theData objectForKey:@"ID"];
    NSString *lsLogin = [theData objectForKey:@"isLogin"];

    //页面显示用户登录信息
    //washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    if ([lsLogin isEqual:@"0"]) {
        _iPs_POSTID=@"";
        //未登录
        //重新请求数据
        NSLog(@"用户未登录，重新获取数据");
        
        _listData = nil;
        [self.tableView reloadData];
        
    }else{
        if ([_userid isEqual:_iPs_POSTID]) {
            //用户没有变化，不做刷新
            return;
            
        }else{
        _iPs_POSTID = _userid;
        
        _iPageIndex = 1;
        //重新请求数据
        NSLog(@"用户登录状态变更，重新获取数据");
        
        [self startRequest];
        }
    }
    
    
    
}

//刷新订单列表
-(void)OrderRefresh:(NSNotification*)notification {
    
    //
    NSLog(@"刷新订单列表通知,%@", _iPs_POSTID );
    [self startRequest];
}

//增加向下滑动刷新下页功能
- (void)addFooter
{
    __unsafe_unretained carswashOrderTableViewController *vc = self;
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
    
    
    __unsafe_unretained carswashOrderTableViewController *vc = self;
    
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
    static NSString *CellIdentifier = @"OrderCell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier  forIndexPath:indexPath];
    //使用自定义的单元格
    OrderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier  forIndexPath:indexPath];
    
    if (cell == nil) {
        NSLog(@"表格初始化错误");
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"DiscountProductCell" owner:self options:nil] ;
        
        cell = [nib objectAtIndex:0];
    }
    //开始解析数据
    NSMutableDictionary*  dict = self.listData[indexPath.row];
    
    //    cell.imageView.image = [UIImage imageNamed:strImgName];
    //处理来自的网络图片
    //NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSLog(@"图片缓存路径:%@",documentsDirectoryPath);
    //Get Image From URL
    //UIImage * imageFromURL = [self getImageFromURL:strImgURL];
    //带有缓存机制的图片加载
    NSString *strImgName = [dict objectForKey:@"goods_thumb"];
    NSString *strImgURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,strImgName];
    //没有必要每次都从网络获取图片，应该建立图片缓存，优先查找本地缓存
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSURL *imgurl = [[NSURL alloc] initWithString: strImgURL];
    
    //异步加载图片
    
    [manager downloadWithURL:imgurl
                     options:0
                    progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
         //NSLog(@"%d.正在下载图片 %d / %d", indexPath.row , receivedSize , expectedSize);
         
     }
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             // do something with image
             cell.cellImg.image = image;
             //NSLog(@"异步载入图片 %@",strImgURL);
         }
     }];
    
    //修改单元格背景色
    UIView *bgColorView = [[UIView alloc] init];
    
    bgColorView.backgroundColor = _CellBgColor;
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    //填充单元格
    cell.cellOrderID.text =[dict objectForKey:@"order_id"];
    cell.cellOrdersn.text =[dict objectForKey:@"order_sn"];
    
    cell.cellTitle.text =[dict objectForKey:@"goods_name"];

    cell.cellMemo.text = [dict objectForKey:@"address_street"];
    
    cell.cellrow.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];

    //cell.cellAddDate.text = [dict objectForKey:@"add_time"];
    NSString *strDate = [dict objectForKey:@"add_time"];
    strDate = [strDate substringToIndex:11];

    cell.cellAddDate.text = strDate;
    //0 未付款
    //1 付款中
    //2 已付款
    NSString *strLeve = [dict objectForKey:@"pay_status"];
    if ([strLeve  isEqual: @"0"]) {
        cell.cellLeve.text = @"未付款";
    }else if([strLeve  isEqual: @"1"]) {
        cell.cellLeve.text = @"付款中";
    }else if([strLeve  isEqual: @"2"]) {
        cell.cellLeve.text = @"已付款";
    }else{
        cell.cellLeve.text = @"未付款";
    }
    
    //0 未确认
    //1 已确认
    //2 已取消
    //3 无效
    //4 退货
    //5 已分单
    //6 部分分单
    NSString *strStatus = [dict objectForKey:@"order_status"];
    if ([strStatus  isEqual: @"0"]) {
        cell.cellOrderDate.text = @"未确认";
        cell.cellOrderDate.textColor = [UIColor grayColor];
    }else if([strStatus  isEqual: @"1"]){
        cell.cellOrderDate.text = @"已确认";
        cell.cellOrderDate.textColor = [UIColor darkTextColor];
    }else if([strStatus  isEqual: @"2"]){
        cell.cellOrderDate.text = @"已取消";
        cell.cellOrderDate.textColor = [UIColor redColor];
    }else if([strStatus  isEqual: @"3"]){
        cell.cellOrderDate.text = @"无效";
        cell.cellOrderDate.textColor = [UIColor redColor];
    }else if([strStatus  isEqual: @"4"]){
        cell.cellOrderDate.text = @"退货";
        cell.cellOrderDate.textColor = [UIColor redColor];
    }else if([strStatus  isEqual: @"5"]){
        cell.cellOrderDate.text = @"已分单";
        cell.cellOrderDate.textColor = [UIColor darkTextColor];
    }else if([strStatus  isEqual: @"6"]){
        cell.cellOrderDate.text = @"部分分单";
    }else{
        cell.cellOrderDate.text = @"未知";
        cell.cellOrderDate.textColor = [UIColor redColor];
    }

    //填充价格字段

    NSString *nmPrice = [dict objectForKey:@"goods_price"];
    
    NSString *strPrice = [[NSString alloc] initWithFormat:@"%@",nmPrice];
        
    cell.cellPrice.text = strPrice;
    NSString *strAmount = [[NSString alloc] initWithFormat:@"%@",[dict objectForKey:@"goods_number"]];
    cell.cellAmount.text = strAmount;

    //NSString *strPrice = [[NSString alloc] initWithFormat:@"￥%@",[dict objectForKey:@"promote_price"]];
    //cell.cellPrice.text = strPrice;
    //cell.cellcmsPrice.text = [dict objectForKey:@"shop_price"];
    
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
//筛选
- (IBAction)btnFilterClicked:(id)sender {
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"未付款订单"
                                  otherButtonTitles:@"已支付订单",nil];
	actionSheet.actionSheetStyle =  UIActionSheetStyleAutomatic;
	[actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"过滤条件选择 = %i",buttonIndex);
    
    NSString *lsButtonTitle = @"";
    
    switch (buttonIndex) {
        case 0:
            _iPs_POSTQueryOption = @"0";
            lsButtonTitle = @"未付款订单";
            _filterType=@"0"; // 0 未付款; 1 已付款
            break;
        case 1:
            _iPs_POSTQueryOption = @"1";
            lsButtonTitle = @"已支付订单";
            _filterType=@"1"; // 0 未付款; 1 已付款
            break;
        case 2:
            return;
            break;
    }
    
    //[self setTitle:lsButtonTitle];
    //_barButtonItem = [[UIBarButtonItem alloc] initWithTitle:lsButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(btnFilter)];
    //self.navigationItem.leftBarButtonItem = _barButtonItem;
    
    
    //重新加载数据
    _iPageIndex = 1;
    [self startRequest];
    
    NSString *lsNotifyTitle = [[NSString alloc]initWithFormat:@"显示 %@" ,lsButtonTitle];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    [delegate showNotify:lsNotifyTitle HoldTimes:3];
}


#pragma mark - Navigation
//页面发生跳转，进入明细
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"ShowOrderDetail"])
    {
        OrderDetailViewController *itemdetail = segue.destinationViewController;
        NSInteger selectedRow = [[self.tableView indexPathForSelectedRow] row];
        
        NSMutableDictionary*  dict = self.listData[selectedRow];
        
        
        
        itemdetail.itemname = [dict objectForKey:@"goods_name"];
        
        itemdetail.itemid = [dict objectForKey:@"goods_id"];
        itemdetail.OrderID = [dict objectForKey:@"order_id"];
        itemdetail.Ordersn = [dict objectForKey:@"order_sn"];
        itemdetail.UserID = _iPs_POSTID;
        
        itemdetail.itemprice = [dict objectForKey:@"goods_price"];
        
        itemdetail.itemdetail = [dict objectForKey:@"address_street"];
        itemdetail.itemAmount = [dict objectForKey:@"goods_number"];
        
        itemdetail.PayStatus = [dict objectForKey:@"pay_status"];
        itemdetail.OrderStatus = [dict objectForKey:@"order_status"];
        
        if ([itemdetail.PayStatus isEqualToString:@"0"]) {
            if ([itemdetail.OrderStatus isEqualToString:@"4"]) {
                //退款
                itemdetail.OrderAction = @"中止购买";
            }else if ([itemdetail.OrderStatus isEqualToString:@"1"]) {
                //购买过的订单但并未支付
                itemdetail.OrderAction = @"继续支付";
            }else{
                itemdetail.OrderAction = @"支付";
            
            }
        }else if([itemdetail.PayStatus isEqualToString:@"2"]){
            //已付款
            itemdetail.OrderAction = @"已付款";
        }else{
            itemdetail.OrderAction = @"支付";
            
        }
        
        itemdetail.OrderDate = [dict objectForKey:@"add_time"];
        
        
        //OrderAction
        NSLog(@"进入明细页面 %d",selectedRow);
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc]init];
        backItem.title=@"";
        backItem.tintColor=[UIColor colorWithRed:129/255.0 green:129/255.0  blue:129/255.0 alpha:1.0];
        self.navigationItem.backBarButtonItem = backItem;

    }
}

/*
 * 开始请求Web Service
 */
-(void)startRequest
{
    _isConnected = false;
    
    if ([_iPs_POSTID isEqualToString:@""]) {
        //传递消息
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"OrderWithLoginNotification"
         object:nil
         userInfo:nil];

        self.tabBarController.selectedIndex = 4;
        return;
    }
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    
    
    //NSString *post = [NSString stringWithFormat:@"act=wash_list&cat_id=139&page=%d&sel_attr=0&region_id=%@",_iPageIndex,@"298"];
    NSString *post = @"";
    
    //_filterType   //_iPs_POSTQueryOption
    if ([_filterType isEqual:@"0"]) {
        //默认显示未付款订单
        post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID];
        
    }else{
        //显示已付款订单
        post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction2,_iPs_POSTID];
    }
    
    _iPs_POSTQueryOption = _filterType;
    
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
    NSArray *results = [res objectForKey:@"pay_list"];
    if (results.count > 0)
    {
        self.listData = [res objectForKey:@"pay_list"];
        
        //NSNumber *nIndex = [[NSNumber alloc] initWithInt:0];
        /*
         if (results && results.count > 0)
         {
         int nIndex;
         for(nIndex = 0;nIndex <results.count; nIndex++)
         {
         NSDictionary *goods_id = [[results objectAtIndex:nIndex] objectForKey:@"goods_id"];
         NSDictionary *goods_name = [[results objectAtIndex:nIndex]objectForKey:@"goods_name"];
         NSDictionary *address = [[results objectAtIndex:nIndex]objectForKey:@"address_street"];
         NSLog(@"id = %@, name = %@, address = %@",goods_id.description,goods_name.description, address.description);
         }
         
         }*/
        NSLog(@"列表视图加载数据...共 %d 条",results.count);
        if (results.count == 0) {
            _iPageIndex = 0;
            NSLog(@"列表视图将循环到首行记录");
            _listData = nil;
            
        }
        [self.tableView reloadData];
    } else {
        //{"state":0}
        NSNumber *resultStateObj = [res objectForKey:@"state"];
        if ([resultStateObj integerValue] ==0){
            self.iPageIndex = 1;
            NSLog(@"列表视图页面下次滚动将返回首行...");
            
            self.iPageIndex = 1;
            washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
            
            if (![_iPs_POSTID isEqualToString:@""]) {
                //只有登录后才会提示
            
                if ([_iPs_POSTQueryOption isEqualToString:@"1"]) {
                    [delegate showNotify:@"当前用户没有找到已付款的订单，请尝试切换分类查找" HoldTimes:2];
                    
                }else{
                    [delegate showNotify:@"当前用户没有找到未付款的订单，请尝试切换分类查找" HoldTimes:2];
                }
            }
            _listData = nil;
            [self.tableView reloadData];
            return;
        }
        NSString *errorStr = @"Service Error";
        self.iPageIndex = 1;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误信息"
                                                            message:errorStr
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
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
