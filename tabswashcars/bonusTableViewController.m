//
//  bonusTableViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-7-11.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "bonusTableViewController.h"
#import "MJRefresh.h"



@interface bonusTableViewController (){
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

//传入变化的参数组,参数数目根据接口需要而变化
@property (strong, nonatomic) NSString *iPs_POSTID; //请求数据POST参数ID1
@property (strong, nonatomic) NSString *iPs_POSTQueryOption; //请求数据POST参数ID2
@property (strong, nonatomic) NSString *iPs_POSTQueryRegion; //请求数据POST参数ID3

//页面内部变量(由程序控制实际值)
@property (nonatomic) int iPageIndex;
@property (nonatomic) Boolean isConnected;

@end

@implementation bonusTableViewController

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
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(BonusCompletion:)
                                                 name:@"BonusRefreshNotification"
                                               object:nil];
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
    _iPs_PageName=@"服务列表"; //页面名称(用于标记页面参数配置)
    //_iPs_URL=@"http://114.112.73.223:8080/"; //请求数据接口模板--地址
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _iPs_URL=delegate.iPs_URL; //请求数据接口模板--地址
    
    _iPs_PAGE=@"user_app.php"; //请求数据接口模板--页面

    _iPs_POST=@"act=%@&user_id=%@"; //请求数据POST参数模板

    _iPs_POSTAction = @"user_bonus";
    
    _iPs_POSTID=delegate.userid;

    _iPs_POSTQueryOption=@"0"; //请求数据POST参数ID2
    _iPs_POSTQueryRegion=@""; //请求数据POST参数ID3

    //不随页面类型改变的部分
    _iPageIndex = 1;//初始化页面序号
    
    _CellBgColor =[UIColor colorWithRed:49/255.0 green:155/255.0 blue:205/255.0 alpha:0.15];

}

//增加向下滑动刷新下页功能
- (void)addFooter
{
    __unsafe_unretained bonusTableViewController *vc = self;
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
    
    
    __unsafe_unretained bonusTableViewController *vc = self;
    
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
    static NSString *CellIdentifier = @"bonusCell";

    bonuslistViewCell *cell;

    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    //使用自定义的单元格
    
    if (cell == nil) {
        NSLog(@"表格初始化错误");
        
        [[NSBundle mainBundle] loadNibNamed:@"bonusCell" owner:self options:nil];
        
        
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
    cell.lbName.text =[dict objectForKey:@"type_name"];
    cell.lbValues.text = [dict objectForKey:@"type_money"];
    
    NSString *strDate = [dict objectForKey:@"use_end_date"];
    cell.lbValidate.text =[[NSString alloc] initWithFormat:@"有效期至：%@" ,strDate];
    
    NSString *strStatus = [dict objectForKey:@"status"];
    
    cell.lbStatus.text = strStatus;
    
    //0 未使用；1 已使用； 2 已过期；
    if ([strStatus isEqual: @"未使用"]) {
        cell.lbName.textColor = [UIColor redColor];
        cell.lbValues.textColor = [UIColor redColor];
        
        cell.lbStatus.textColor = [UIColor darkTextColor];
    }else if([strStatus isEqual: @"已使用"]){
        cell.lbName.textColor = [UIColor darkTextColor];
        cell.lbValues.textColor = [UIColor darkTextColor];
        cell.lbStatus.textColor = [UIColor lightGrayColor];
        
    }else if([strStatus isEqual: @"已过期"]){
        cell.lbName.textColor = [UIColor lightGrayColor];
        cell.lbValues.textColor = [UIColor lightGrayColor];

        cell.lbStatus.textColor = [UIColor redColor];
    }else{
        cell.lbName.textColor = [UIColor redColor];
        cell.lbValues.textColor = [UIColor redColor];
        cell.lbStatus.textColor = [UIColor darkTextColor];
    }

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


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

//红包刷新事件
-(void)BonusCompletion:(NSNotification*)notification {

    [self startRequest];
}


/*
 * 开始请求Web Service
 */
-(void)startRequest
{
    _isConnected = false;
    
    if (([_iPs_POSTID isEqualToString:@""])||(_iPs_POSTID == nil)) {
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate showNotify:@"无法查看账户数据，请您先登录！" HoldTimes:2];
        return;
    }
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    NSString *post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID];
    
    
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

#pragma mark - Page Data


//重新加载表视图
-(void)reloadView:(NSDictionary*)res
{

        NSArray *results = [res objectForKey:@"bonus_list"];
        
        self.listData = [res objectForKey:@"bonus_list"];
        
        NSLog(@"列表视图加载数据...共 %d 条",results.count);
        if (results.count == 0) {
            if (_iPageIndex != 1){
                _iPageIndex = 1;
                NSLog(@"列表视图将循环到首行记录");
                [self startRequest];
                return;
            }
        }else{
            washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
            
            NSString *lsCount = [[NSString alloc]initWithFormat:@"%d" ,results.count];
            delegate.userbonus = results.count;
            [delegate saveUserDefaults:@"userbonus" setValue:lsCount];
            
        }
        
        [self.tableView reloadData];
        
        if (_iPageIndex>1) {
            //移动到首行
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionMiddle];
            
        }
        
    
    
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


@end
