//
//  signinTableViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-8-1.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//
#import <QuartzCore/CoreAnimation.h>

#import "signinTableViewController.h"
#import "MJRefresh.h"
#import "UIButton+Bootstrap.h"

@interface signinTableViewController (){
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

@implementation signinTableViewController

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
    
    self.btnSignin.titleLabel.text = @"签到";
    
    [self.btnSignin primaryStyle];
    
    [self.btnSignin addAwesomeIcon:FAIconCheck beforeTitle:YES];
    
    _essaylimit = 140;
    _txtuserinput.layer.cornerRadius = 6;
    _txtuserinput.layer.masksToBounds = YES;
    _txtuserinput.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _txtuserinput.layer.borderWidth = 1;
    _txtuserinput.delegate = self ;
    
    [self Randessay];
    
    
    _txtuserinput.text = _myessay;
    _txtlength.titleLabel.text = [[NSString alloc]initWithFormat:@"%d/%d",[_myessay length], _essaylimit];
    
    [_progressbar setProgress:(_signincount/10.0) animated:YES];
    _btnSignin.enabled = false;
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
    _iPs_PageName=@"签到记录"; //页面名称(用于标记页面参数配置)
    //_iPs_URL=@"http://114.112.73.223:8080/"; //请求数据接口模板--地址
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _iPs_URL=delegate.iPs_URL; //请求数据接口模板--地址
    
    _iPs_PAGE=@"sign_in_app.php"; //请求数据接口模板--页面
    
    
    _iPs_POST = @"act=%@&user_id=%@"; //请求数据POST参数模板2
    _iPs_POST2=@"act=%@&user_id=%@&content=%@"; //请求数据POST参数模板
    
    _iPs_POSTAction = @"sign_record";  //获取签到记录 0
    
    _iPs_POSTID=delegate.userid;
    
    _iPs_POSTQueryOption=@"0"; //请求数据POST参数ID2
    _iPs_POSTQueryRegion=@""; //请求数据POST参数ID3
    
    _iPs_POSTAction2 = @"add_sign";  //写说说 1
    _iPs_POSTAction3 = @"sign_bonus";   //获取红包 2

    
    //不随页面类型改变的部分
    _iPageIndex = 1;//初始化页面序号
    
    _CellBgColor =[UIColor colorWithRed:49/255.0 green:155/255.0 blue:205/255.0 alpha:0.15];
    
    if (([_iPs_POSTID isEqualToString:@""])||(_iPs_POSTID == nil)) {
        //[delegate showNotify:@"参与此活动，请您先登录！" HoldTimes:2];
    }
    
}

//增加向下滑动刷新下页功能
- (void)addFooter
{
    __unsafe_unretained signinTableViewController *vc = self;
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
    __unsafe_unretained signinTableViewController *vc = self;
    
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


- (void)Randessay
{
    // Get random number between 0 and 9
    int xrandom = arc4random() % 10;
    _signincount = xrandom;////////
    switch (xrandom) {
        case 0:
            _myessay = @"生命的意义，在于倾听自己心灵的声音，做最精彩的自己。";
            break;
        case 1:
            _myessay = @"用漫不经心的态度，过随遇而安的生活。";
            break;
        case 2:
            _myessay = @"如果你看到面前的阴影，别怕，那是因为你的背后有阳光。";
            break;
        case 3:
            _myessay = @"感情再深，恩义再浓的朋友，天涯远隔，情义，终也慢慢疏淡。不是说彼此的心变了，也不是说不再当对方是朋友，只是，远在天涯，喜怒哀乐不能共享。原来，我们已是遥远得只剩下问候，问候还是好的，至少我们不曾把彼此忘记。";
            break;
        case 4:
            _myessay = @"因为爱过，所以慈悲；因为懂得，所以宽容。";
            break;
        case 5:
            _myessay = @"有些伤口，时间久了就会慢慢长好；有些委屈，受过了想通了也就释然了；有些伤痛，忍过了疼久了也成习惯了……然而却在很多孤独的瞬间，又重新涌上心头。其实，有些藏在心底的话，并不是故意要去隐瞒，只是，并不是所有的疼痛，都可以呐喊。";
            break;
        case 6:
            _myessay = @"一个人总要走陌生的路，看陌生的风景，听陌生的歌。最后你会发现，原本费尽心机想要忘记的事情真的就那么忘记了。";
            break;
        case 7:
            _myessay = @"生命中总有那么一段时光，充满不安，可是除了勇敢面对，我们别无选择。";
            break;
        case 8:
            _myessay = @"有时候，你原谅别人，只是因为你还想把他们留在你的生活里。";
            break;
        case 9:
            _myessay = @"假如爱情可以解释，誓言可以修改。假如，你我的相遇，可以重新安排。那么，生活就会比较容易。假如有一天，我终于能将你忘记。然而，这不是随便传说的故事。也不是明天才要上演的戏剧。我无法找出原稿，然后，将你一笔抹去。";
            break;
        default:
            break;
    }
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
    static NSString *CellIdentifier = @"notecell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier  forIndexPath:indexPath];
    //使用自定义的单元格
    signinTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier  forIndexPath:indexPath];
    
    if (cell == nil) {
        NSLog(@"表格初始化错误");
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"notecell" owner:self options:nil] ;
        
        cell = [nib objectAtIndex:0];
    }
    //开始解析数据
    NSMutableDictionary*  dict = self.listData[indexPath.row];
    
    @try {
        
        
        //修改单元格背景色
        UIView *bgColorView = [[UIView alloc] init];
        
        bgColorView.backgroundColor = _CellBgColor;
        bgColorView.layer.masksToBounds = YES;
        cell.selectedBackgroundView = bgColorView;

        
        cell.txtNumber.text = [NSString stringWithFormat:@"%d", indexPath.row+1];
        

        NSString *is_date = [dict objectForKey:@"add_time"];
        NSString *is_content = [dict objectForKey:@"content"];
        
        cell.txtDate.text = is_date;
        cell.txtContent.text = is_content;
        

        //调整文本位置
        //位置向上偏移
        //CGPoint cellPricePoint = cell.cellPrice.center;
        
        //cellPricePoint.x = cellPricePoint.x - 20;
        
        //cell.cellPrice.center = cellPricePoint;

    }@catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    //NSString *strPrice = [[NSString alloc] initWithFormat:@"￥%@",[dict objectForKey:@"promote_price"]];
    //cell.cellPrice.text = strPrice;
    //cell.cellcmsPrice.text = [dict objectForKey:@"shop_price"];
    
    //以上已完成单元格修改
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 10;
    
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

//由于数字键盘没有Return键，当点击界面其它元素自动释放焦点以隐藏键盘
- (void)touchesBegan: (NSSet *)touches withEvent:(UIEvent *)event
{
    // do the following for all textfields in your current view
    [self.txtuserinput resignFirstResponder];
    //[self txtInputChanged:_txtuserinput];
    
}

- (IBAction)btnSinginClicked:(id)sender {
    if ([_txtuserinput.text isEqualToString:@""]) {
        [self Randessay];
        _txtuserinput.text = _myessay;
        _txtlength.titleLabel.text = [[NSString alloc]initWithFormat:@"%d/%d",[_myessay length], _essaylimit];
        //[_progressbar setProgress:(_signincount/10.0) animated:YES];
    }else{
        //发表说说
        _myinputs = _txtuserinput.text;
        _iPs_POSTQueryOption = @"1";
        [self startRequest];
    
    }

}

- (IBAction)btnLengthClicked:(id)sender {
    _txtlength.titleLabel.text = [[NSString alloc]initWithFormat:@"%d/%d",[_txtuserinput.text length], _essaylimit];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if (1 == range.length) {//按下删除键
        _txtlength.titleLabel.text = [[NSString alloc]initWithFormat:@"%d/%d",[textView.text length], _essaylimit];
        return YES;
    }
    
    if ([text isEqualToString:@"\n"]) {//按下return键
        //这里隐藏键盘，不做任何处理
        [textView resignFirstResponder];
        return NO;
    }else {
        if ([textView.text length] <= _essaylimit) {//判断字符个数
            _txtlength.titleLabel.text = [[NSString alloc]initWithFormat:@"%d/%d",[textView.text length], _essaylimit];
            return YES;
        }else{
            
            textView.text = [textView.text substringToIndex:_essaylimit+1];
            _txtlength.titleLabel.text = [[NSString alloc]initWithFormat:@"%d/%d",[textView.text length], _essaylimit];
            //这里隐藏键盘，不做任何处理
            [textView resignFirstResponder];
            return NO;
        }
    }
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"inputChanged：%@", textView.text);
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([_txtuserinput.text isEqualToString:_myessay]) {
        _txtuserinput.text = @"";
        _txtlength.titleLabel.text = [[NSString alloc]initWithFormat:@"0/%d", _essaylimit];
    }
    
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
    
    if (([_iPs_POSTID isEqualToString:@""])||(_iPs_POSTID == nil)) {
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate showNotify:@"参与此活动，请您先登录！" HoldTimes:2];
        return;
    }
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];

    NSString *post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID];
    
    if([_iPs_POSTQueryOption isEqualToString:@"0"])
    {
        post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID];
        
    }else if([_iPs_POSTQueryOption isEqualToString:@"1"]){
        //签到
        post = [NSString stringWithFormat:_iPs_POST2,_iPs_POSTAction2,_iPs_POSTID,_myinputs];
    
    }else if([_iPs_POSTQueryOption isEqualToString:@"2"]){
        //获取红包
        post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction3,_iPs_POSTID];
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

#pragma mark - Page Data


//重新加载表视图
-(void)reloadView:(NSDictionary*)res
{
    
    @try{
        
        NSNumber *isError = [res objectForKey:@"is_error"];
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        
        
        
        NSArray *results;

        
        if([_iPs_POSTQueryOption isEqualToString:@"0"])
        {
            if ([isError integerValue]==0){
            }else if ([isError integerValue]==1){
                //无效
                
                NSString * ErrorMsg = [res objectForKey:@"err_msg"];
                NSLog(@"%@", ErrorMsg);
                [delegate showNotify:ErrorMsg HoldTimes:2];
                return;
            }
            //显示列表
            res = [res objectForKey:@"result"];
            results = [res objectForKey:@"sign_list"];
            self.listData = [res objectForKey:@"sign_list"];
            
            NSString * has_bonus = [res objectForKey:@"has_bonus"];
            NSString * has_sign = [res objectForKey:@"has_sign"];
            NSString * need_sign = [res objectForKey:@"need_sign"];
            
            //签到状态：0为今日未签到，1为已签到，2为可领取红包
            NSNumber * signState = [res objectForKey:@"state"];
            NSString * total_sign = [res objectForKey:@"total_sign"];
            
            _signincount = [has_sign intValue];
            _signinneed = [need_sign doubleValue];
            [_progressbar setProgress:(_signincount/_signinneed) animated:YES];
            
            if ([signState integerValue]==0){
                _btnSignin.enabled = true;
                _txtuserinput.editable = true;
                
                NSString * RESMsg = [[NSString alloc] initWithFormat:@"今天您可以签到一次。\n 已完成进度：%@/%@ ，\n累计签到：%@次 ，已领取红包：%@个。", has_sign,need_sign,total_sign ,has_bonus];
                [delegate showNotify:RESMsg HoldTimes:3.5];
                
                [self.btnSignin primaryStyle];
            }else if([signState integerValue]==1){
                
                _btnSignin.enabled = false;
                _txtuserinput.editable = false;
                NSString * RESMsg = [[NSString alloc] initWithFormat:@"今天您已经签过了，明天再来吧。\n(已完成：%@/%@ ) 累计签到：%@次。", has_sign,need_sign,total_sign ];
                [delegate showNotify:RESMsg HoldTimes:2];
                
                //self.btnSignin.titleLabel.text = @"已签";
                
                [self.btnSignin infoStyle];
            }else if([signState integerValue]==2){
                _btnSignin.enabled = false;
                _txtuserinput.editable = false;
            }


            
            
            
        }else if([_iPs_POSTQueryOption isEqualToString:@"1"]){
            //签到

            if ([isError integerValue]==0){
                //有效
                
                _txtuserinput.text = @"";
                _txtlength.titleLabel.text = @"";
                
            }else if ([isError integerValue]==1){
                //无效
                
                NSString * ErrorMsg = [res objectForKey:@"err_msg"];
                NSLog(@"签到失败： %@", ErrorMsg);
                [delegate showNotify:ErrorMsg HoldTimes:3];
                return;
            }

            //更新签到信息，刷新列表
            res = [res objectForKey:@"result"];
            results = [res objectForKey:@"sign_list"];
            self.listData = [res objectForKey:@"sign_list"];
            
            NSString * has_bonus = [res objectForKey:@"has_bonus"];
            NSString * has_sign = [res objectForKey:@"has_sign"];
            NSString * need_sign = [res objectForKey:@"need_sign"];
            
            //签到状态：0为今日未签到，1为已签到，2为可领取红包
            NSNumber * signState = [res objectForKey:@"state"];
            NSString * total_sign = [res objectForKey:@"total_sign"];
            
            NSString * RESMsg = [[NSString alloc] initWithFormat:@"发送成功！任务已完成：%@/%@ ， 累计签到：%@次 ，已领取红包：%@次。", has_sign,need_sign,total_sign ,has_bonus];
            [delegate showNotify:RESMsg HoldTimes:3];
            
            _signincount = [has_sign intValue];
            _signinneed = [need_sign doubleValue];
            [_progressbar setProgress:(_signincount/_signinneed) animated:YES];
            
            //传递消息
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"SigninCompletionNotification"
             object:nil
             userInfo:nil];
            
            //判断是否需要查询红包
            if ([signState integerValue]==0){
                _btnSignin.enabled = true;
                _txtuserinput.editable = true;
            }else if([signState integerValue]==1){
                
                _btnSignin.enabled = false;
                _txtuserinput.editable = false;
                
            }else if([signState integerValue]==2){
                _iPs_POSTQueryOption = @"2";
                [self startRequest];
                
                _btnSignin.enabled = false;
                _txtuserinput.editable = false;
            }
            
        }else if([_iPs_POSTQueryOption isEqualToString:@"2"]){
            //获取红包
            if ([isError integerValue]==0){
            }else if ([isError integerValue]==1){
                //无效
                
                NSString * ErrorMsg = [res objectForKey:@"err_msg"];
                NSLog(@"%@", ErrorMsg);
                [delegate showNotify:ErrorMsg HoldTimes:2];
                return;
            }

            res = [res objectForKey:@"result"];
            _bonusInfo = [res objectForKey:@"bonus_money"];
            [delegate showNotify:@"恭喜您，得到了红包奖励！" HoldTimes:2];
            [self performSegueWithIdentifier:@"openGift" sender:self];
            return;
        }
        
        
        NSLog(@"列表视图加载数据...共 %d 条",results.count);
        if (results.count == 0) {
            if (_iPageIndex != 1){
                _iPageIndex = 1;
                return;
            }
        }else{
            
        }
        
        [self.tableView reloadData];
        
        if (_iPageIndex>1) {
            //移动到首行
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionMiddle];
            
        }
    
    }@catch(NSException *exp3){
        
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
