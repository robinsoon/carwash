//
//  expirydateTableViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-8-1.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "expirydateTableViewController.h"
#import "UIButton+Bootstrap.h"

@interface expirydateTableViewController ()
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

@implementation expirydateTableViewController

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
    [self.btnDone dangerStyle];
    
    [self.btnDone addAwesomeIcon:FAIconListOl beforeTitle:YES];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
        //[self startRequest];
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
    _iPs_PageName=@"兑奖活动"; //页面名称(用于标记页面参数配置)
    //_iPs_URL=@"http://114.112.73.223:8080/"; //请求数据接口模板--地址
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _iPs_URL=delegate.iPs_URL; //请求数据接口模板--地址
    
    _iPs_PAGE=@"common_app.php"; //请求数据接口模板--页面
    
    _iPs_POST=@"act=%@&user_id=%@&bonus_sn=%@"; //请求数据POST参数模板
    
    _iPs_POSTAction = @"check_bonus";
    
    _iPs_POSTID=delegate.userid;
    
    _iPs_POSTQueryOption=@"0"; //请求数据POST参数ID2
    _iPs_POSTQueryRegion=@""; //请求数据POST参数ID3
    
    //不随页面类型改变的部分
    _iPageIndex = 1;//初始化页面序号
    
    _CellBgColor =[UIColor colorWithRed:49/255.0 green:155/255.0 blue:205/255.0 alpha:0.15];
    
    if (([_iPs_POSTID isEqualToString:@""])||(_iPs_POSTID == nil)) {
        [delegate showNotify:@"参与此活动，请您先登录！" HoldTimes:2];
    }
    
    
}


#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

- (IBAction)txtNumberBeginEdit:(id)sender {
    
    if ([_txtExpiryNumber.text isEqualToString:@"请输入奖区内号码"]) {
        _txtExpiryNumber.text = @"";
    }
    
    
}


//由于数字键盘没有Return键，当点击界面其它元素自动释放焦点以隐藏键盘
- (void)touchesBegan: (NSSet *)touches withEvent:(UIEvent *)event
{
    // do the following for all textfields in your current view
    [self.txtExpiryNumber resignFirstResponder];
    [self txtNumberChanged:_txtExpiryNumber];
    
}

- (IBAction)btnDoneClicked:(id)sender {
    [self.txtExpiryNumber resignFirstResponder];
    [self txtNumberChanged:_txtExpiryNumber];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //
    if ([_txtExpiryNumber.text isEqualToString:@"请输入奖区内号码"]) {
        _number = @"";
    }
    
    if([_number length]<7){
        
        [delegate showNotify:@"您的兑奖码无效，请重新输入！" HoldTimes:2];
    }else{
        //兑奖
        [delegate showNotify:@"正在验证兑奖码，请稍候..." HoldTimes:2];
        [self startRequest];
    }
}


- (IBAction)txtNumberDidEnd:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)txtNumberChanged:(id)sender {
    
    _number = _txtExpiryNumber.text;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"openGift"])
    {
        opengiftViewController *itemBonus = segue.destinationViewController;
        itemBonus.bonusInfo = _bonusInfo;
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
    
    NSString *post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID,_number];
    
    
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
    @try{

        NSNumber * isError = [res objectForKey:@"is_error"];
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        
        if ([isError integerValue]==0) {
            //有效
            NSString * RESMsg = [res objectForKey:@"result"];
            NSLog(@"兑奖号 %@ 有效：%@", _number , RESMsg);
            [delegate showNotify:@"发现有惊喜！请打开红包 ^_^" HoldTimes:2];

            NSRange range = [RESMsg rangeOfString:@"元"];
            int location = range.location;
            //int leight = range.length;
            
            _bonusInfo = [RESMsg substringToIndex:location ];
            //进入红包页面
            if ([_bonusInfo length]>0) {
                //发送消息通知红包刷新
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"BonusRefreshNotification"
                 object:nil
                 userInfo:nil];
                
                
                [self performSegueWithIdentifier:@"openGift" sender:self];
            }
            
        }else if ([isError integerValue]==1){
            //无效
            
            NSString * ErrorMsg = [res objectForKey:@"err_msg"];
            NSLog(@"兑奖号 %@ 无效： %@", _number , ErrorMsg);
            [delegate showNotify:ErrorMsg HoldTimes:3];
            /*
            //进入红包页面(测试)
            NSString * RESMsg = @"5.00元";
            NSRange range = [RESMsg rangeOfString:@"元"];
            int location = range.location;
            //int leight = range.length;
            
            _bonusInfo = [RESMsg substringToIndex:location ];
             
            [self performSegueWithIdentifier:@"openGift" sender:self];
             */
        }
        
        _txtExpiryNumber.text = @"请输入奖区内号码";
    
    }@catch(NSException *exp2){
    
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
