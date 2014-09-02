//
//  commitListViewController.m
//  washcarsbusiness
//
//  Created by Robinpad on 14-8-13.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "commitListViewController.h"
#import "MJRefresh.h"
//#import "contentEditViewController.h"

@interface commitListViewController (){
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
}

//定义可配置的数据参数（对于简单查询只需1组配置）
//命名规则： i 表示实例变量；P 表示 页面变量； s 表示 数据类型为String；
#pragma mark- declare 声明变量
@property (strong, nonatomic) IBOutlet UITableView *tableView;
//初始化统一调用方法：initPage
@property (strong, nonatomic) NSString *iPs_PageName; //页面名称(用于标记参数组)
@property (nonatomic,strong) NSString * iPs_URL;
@property (strong, nonatomic) NSString *iPs_PAGE; //请求数据接口模板--页面
@property (strong, nonatomic) NSString *iPs_POST; //请求数据POST参数模板
@property (strong, nonatomic) NSString *iPs_POST2; //请求数据POST参数模板
@property (strong, nonatomic) NSString *iPs_POST3; //请求数据POST参数模板
@property (strong, nonatomic) NSString *iPs_POSTAction; //请求数据POST参数Action

@property (strong, nonatomic) NSString *iPs_POSTAction2; //请求数据POST参数Action

@property (strong, nonatomic) NSString *iPs_POSTAction3; //请求数据POST参数Action
//传入变化的参数组,参数数目根据接口需要而变化
@property (strong, nonatomic) NSString *iPs_POSTID; //请求数据POST参数ID1
@property (strong, nonatomic) NSString *iPs_POSTQueryOption; //请求数据POST参数ID2
@property (strong, nonatomic) NSString *iPs_POSTQueryRegion; //请求数据POST参数ID3

//页面内部变量(由程序控制实际值)
@property (nonatomic) int iPageIndex;
@property (nonatomic) Boolean isConnected;

@end

@implementation commitListViewController

@synthesize starView =_starView;
#pragma mark- ShowEvent 页面显示方法
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
    //用户注册消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(replyCompletion:)
                                                 name:@"ReplyCompletionNotification"
                                               object:nil];
    
    [self ResetLayoutMain];
    
    if (_iPs_PageName==nil) {
        [self initPage];
    }
    if (_isConnected == false) {
        NSLog(@"尝试重新加载数据...");
        //重新加载数据
        //[self startRequest];
    }
    // 3.2.上拉加载更多
    [self addFooter];
    [self addHeader];

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
    
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    _iPs_POSTID= delegate.userid ; //请求数据POST参数ID1
    
    
    
}


#pragma mark- initial Event 初始化
//初始化页面变量组和参数
- (void)initPage
{
    //根据页面类型不同需要配置的部分
    _iPs_PageName=@"服务明细"; //页面名称(用于标记页面参数配置)
    //请求数据接口模板--地址
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _iPs_URL=delegate.iPs_URL; //请求数据接口模板--地址
    
    _iPs_PAGE=@"goods_app.php"; //请求数据接口模板--页面
    
    _iPs_POSTAction =@"search_goods_comment_count"; //用户评论汇总信息1~5星分布
    _iPs_POST=@"act=%@&goods_id=%@";
    
    _iPs_POSTAction2 =@"search_goods_comment_list";
    _iPs_POST2=@"act=%@&goods_id=%@&page=%d"; //请求数据POST参数模板
    
    
    _iPs_POSTID= delegate.userid; //请求数据POST参数ID1
    
    
    
    _iPs_POSTAction3 =@"set_unread_goods_comment"; //商家回复
    _iPs_POST3=@"act=%@&goods_id=%@";
    
    _iPs_POSTQueryOption=@"0"; //请求数据POST参数ID2：  评价 0获取评论汇总 1评论详情   2修改未读状态
    _iPs_POSTQueryRegion=@"0"; //请求数据POST参数ID3：  评论列表 0全部，1差评，2未读
    _unUnread = 0;
    _clearBeforeTag = @"";
    
    _CellBgColor =[UIColor colorWithRed:49/255.0 green:155/255.0 blue:205/255.0 alpha:0.15];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table Action 上下滑动Cell
//增加向下滑动刷新下页功能
- (void)addFooter
{
    __unsafe_unretained commitListViewController *vc = self;
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
    
    __unsafe_unretained commitListViewController *vc = self;
    
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

#pragma mark- Layout 显示布局

- (void)ResetLayoutMain{
    //调节进度条的高度，后面的系数是垂直放大
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 8.0f);
    _pgsLevel5.transform = transform;
    _pgsLevel4.transform = transform;
    _pgsLevel3.transform = transform;
    _pgsLevel2.transform = transform;
    _pgsLevel1.transform = transform;
    
    //星星评级
    [_starView setImagesDeselected:@"Star0.png" partlySelected:@"Star1.png" fullSelected:@"Star2.png" andDelegate:self];
    
    
	[_starView displayRating:[_itemRank floatValue]];
    
    //评分的背景 -- 圆角矩形
    _bgScore.layer.cornerRadius = 6;
    _bgScore.layer.masksToBounds = YES;
    _bgScore.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _bgScore.layer.borderWidth = 1;
    //_bgScore.delegate = self ;
    
    //Tab分页的背景1 -- 圆角矩形
    _bgCmAll.layer.cornerRadius = 12;
    _bgCmAll.layer.masksToBounds = YES;
    _bgCmAll.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _bgCmAll.layer.borderWidth = 1;
    _bgCmAll.hidden = false;
    //_btnShowAll.titleLabel.textColor = [UIColor whiteColor];
    [_btnShowAll setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[UIColor blueColor];
    
    //Tab分页的背景2 -- 圆角矩形
    _bgCmBad.layer.cornerRadius = 12;
    _bgCmBad.layer.masksToBounds = YES;
    _bgCmBad.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _bgCmBad.layer.borderWidth = 1;
    _bgCmBad.hidden = true;
    //_btnShowBad.titleLabel.textColor = [UIColor blueColor];
    [_btnShowBad setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    //Tab分页的背景3 -- 圆角矩形
    _bgCmUnRead.layer.cornerRadius = 12;
    _bgCmUnRead.layer.masksToBounds = YES;
    _bgCmUnRead.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _bgCmUnRead.layer.borderWidth = 1;
    _bgCmUnRead.hidden = true;
    //_btnShowunRead.titleLabel.textColor = [UIColor blueColor];
    [_btnShowunRead setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //下面的代码会让 HeaderView滚动消失
    //UIView *headerView = _subViewHeader;
    //[[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 180)];
    
    //self.tableView.tableHeaderView = _subViewHeader;

    /*
    self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(44, 0, 0, 0);
     */
}

#pragma mark- ActionEvent 触发控制逻辑
//登录返回
-(void)replyCompletion:(NSNotification*)notification {
    
    NSLog(@"回复页面返回");
    //内容被修改，为了维持一致，清空所有缓存重新请求
    ////请求数据POST参数ID3：  评论列表 0全部，1差评，2未读

    if ([_iPs_POSTQueryRegion isEqualToString:@"0"]) {

        [_listDataBad removeAllObjects];
    }else if ([_iPs_POSTQueryRegion isEqualToString:@"1"]) {

        [_listData removeAllObjects];
    }

    [self startRequest];
}

#pragma mark- ButtonClicked 按钮事件

- (IBAction)btnShowAllClicked:(id)sender {

    if (![_iPs_POSTQueryRegion isEqualToString:@"0"]) {
        _iPageIndex = 0;
        _iPs_POSTQueryRegion=@"0"; //请求数据POST参数ID3：  评论列表 0全部，1差评，2未读
    }
    
    
    _bgCmAll.hidden = false;
    //_btnShowAll.titleLabel.textColor = [UIColor whiteColor];
    [_btnShowAll setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[UIColor blueColor];
    
    //Tab分页的背景2
    _bgCmBad.hidden = true;
    //_btnShowBad.titleLabel.textColor = [UIColor blueColor];
    [_btnShowBad setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    //Tab分页的背景3
    _bgCmUnRead.hidden = true;
    //_btnShowunRead.titleLabel.textColor = [UIColor blueColor];
    [_btnShowunRead setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    if(_listData.count == 0){
        [self startRequest];
    }else{

        [self.tableView reloadData];
        //[self clearunread];
    }
}

- (IBAction)btnShowBadClicked:(id)sender {

    if (![_iPs_POSTQueryRegion isEqualToString:@"1"]) {
        _iPageIndex = 0;
        _iPs_POSTQueryRegion = @"1"; //请求数据POST参数ID3：  评论列表 0全部，1差评，2未读
    }
    
    _bgCmAll.hidden = true;
    //_btnShowAll.titleLabel.textColor = [UIColor blueColor];
    [_btnShowAll setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //[UIColor blueColor];
    
    //Tab分页的背景2
    _bgCmBad.hidden = false;
    //_btnShowBad.titleLabel.textColor = [UIColor whiteColor];
    [_btnShowBad setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //Tab分页的背景3
    _bgCmUnRead.hidden = true;
    //_btnShowunRead.titleLabel.textColor = [UIColor blueColor];
    [_btnShowunRead setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    if(_listDataBad.count == 0){

        [self startRequest];
    }else{
        [self.tableView reloadData];
        //[self clearunread];
    }
    
    
    
}

- (IBAction)btnShowUnReadClicked:(id)sender {
    if (![_iPs_POSTQueryRegion isEqualToString:@"2"]) {
        _iPageIndex = 0;
        _iPs_POSTQueryRegion=@"2"; //请求数据POST参数ID3：  评论列表 0全部，1差评，2未读
    }

    _bgCmAll.hidden = true;
    //_btnShowAll.titleLabel.textColor = [UIColor blueColor];
    [_btnShowAll setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //[UIColor blueColor];
    
    //Tab分页的背景2
    _bgCmBad.hidden = true;
    //_btnShowBad.titleLabel.textColor = [UIColor blueColor];
    [_btnShowBad setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    //Tab分页的背景3
    _bgCmUnRead.hidden = false;
    //_btnShowunRead.titleLabel.textColor = [UIColor whiteColor];
    [_btnShowunRead setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if(_listDatanoRead.count == 0){
        
        [self startRequest];
    }else{
        [self.tableView reloadData];
    }
}


#pragma mark- ActionEvent 触发控制逻辑

-(void)ratingChanged:(float)newRating {
	//_ratingLabel.text = [NSString stringWithFormat:@"%1.1f", newRating];
}


- (IBAction)btnReplyClicked:(id)sender {
    //NSString *lsTag = @"";
    
    UIButton *btn = (UIButton *)sender;
    _editRow = btn.tag;
    NSLog(@"回复：%d",_editRow);
    [self performSegueWithIdentifier:@"submitReply" sender:self];
}

- (IBAction)btnModifiedClicked:(id)sender {
    //NSString *lsTag = @"";
    UIButton *btn = (UIButton *)sender;
    _editRow = btn.tag;
    NSLog(@"修改：%d",_editRow);
    _editTag = @"";
    
    [self performSegueWithIdentifier:@"submitReply" sender:self];
}

#pragma mark- GotoPage 页面跳转方法
//页面发生跳转，进入明细
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    /*if([segue.identifier isEqualToString:@"submitReply"])
    {
        contentEditViewController *itemdetail = segue.destinationViewController;
        NSInteger selectedRow = [[self.tableView indexPathForSelectedRow] row];
        NSMutableDictionary*  dict = self.listData[selectedRow];
        //_editRow
        if ([_iPs_POSTQueryRegion isEqualToString:@"0"]) {
            //全部
            dict = self.listData[_editRow];
        }else if ([_iPs_POSTQueryRegion isEqualToString:@"1"]) {
            //差评
            dict = self.listDataBad[_editRow];
        }else if ([_iPs_POSTQueryRegion isEqualToString:@"2"]) {
            //未读
            dict = self.listDatanoRead[_editRow];
        }
        
        
        NSString *strContent = [dict objectForKey:@"user_content"];
        NSString *strReply = [dict objectForKey:@"buss_content"];
        
        //itemdetail.title = [dict objectForKey:@"goods_name"];
        itemdetail.itemid = [dict objectForKey:@"comment_id"];
        
        itemdetail.itemcontent = strReply;
        itemdetail.itemcommit = strContent;
        
        NSLog(@"进入商家回复编辑 %d ", _editRow);
        
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc]init];
        backItem.title=@"";
        backItem.tintColor=[UIColor colorWithRed:129/255.0 green:129/255.0  blue:129/255.0 alpha:1.0];
        self.navigationItem.backBarButtonItem = backItem;
        
    }*/
}



#pragma mark - Table view data source

//设置Header区在滑动时停留在页面顶部不消失
//注意：作为Header的View 如果放到tableHeaderView区就会滚动消失，必须移出
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 180.0)];
    //customView = _subViewHeader;
    [customView addSubview:_subViewHeader];
    return customView;
    //return _subViewHeader;
}

//设置Header高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 180.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if ([_iPs_POSTQueryRegion isEqualToString:@"0"]) {
        return _listData.count;
    }else if ([_iPs_POSTQueryRegion isEqualToString:@"1"]) {
        return _listDataBad.count;
    }else if ([_iPs_POSTQueryRegion isEqualToString:@"2"]) {
        return _listDatanoRead.count;
    }

    return _listData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    commitDetailListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commitdetail" forIndexPath:indexPath];
    //修改单元格背景色
    /*UIView *bgColorView = [[UIView alloc] init];
    
    bgColorView.backgroundColor = _CellBgColor;
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;*/
    

    
    /*UIView *backView = [[UIView alloc] initWithFrame:cell.frame];
    backView.layer.masksToBounds = YES;
    backView.layer.cornerRadius = 6;*/
    //开始解析数据
    NSMutableDictionary*  dict;
    if ([_iPs_POSTQueryRegion isEqualToString:@"0"]) {
        dict = self.listData[indexPath.row];
    }else if ([_iPs_POSTQueryRegion isEqualToString:@"1"]) {
        dict = self.listDataBad[indexPath.row];
    }else if ([_iPs_POSTQueryRegion isEqualToString:@"2"]) {
        dict = self.listDatanoRead[indexPath.row];
    }
    cell.iserial = indexPath.row;
    cell.btnSubmit.tag = indexPath.row;
    cell.btnModify.tag = indexPath.row;
    //内容展示
    cell.txtNumber.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
    
    //填充Detail数据字段
    cell.comment_id =[dict objectForKey:@"comment_id"];
    cell.txtName.text =[dict objectForKey:@"user_name"];
    cell.Rank =[dict objectForKey:@"comment_rank"];
    
    cell.txtAddDate.text =[dict objectForKey:@"user_datetime"];
    
    cell.txtContent.text =[dict objectForKey:@"user_content"];
    
    
    cell.txtReplyDate.text =[dict objectForKey:@"buss_datetime"];
    
    NSString *buss_content = [dict objectForKey:@"buss_content"];
    cell.txtReplyContent.text = buss_content;
    if (([buss_content isEqualToString:@""])||(buss_content == nil)) {
        //没有商家回复
        [cell setCellReplyStyle:false];
        /*CGRect cellFrame = [cell frame];
        cellFrame.size.height = 120;
        [cell setFrame:cellFrame];*/
    }else{
        [cell setCellReplyStyle:true];
    }
    
    
    
    //根据内容调整样式
    [cell initCell];
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //开始解析数据
    NSMutableDictionary*  dict;
    if ([_iPs_POSTQueryRegion isEqualToString:@"0"]) {
        dict = self.listData[indexPath.row];
    }else if ([_iPs_POSTQueryRegion isEqualToString:@"1"]) {
        dict = self.listDataBad[indexPath.row];
    }else if ([_iPs_POSTQueryRegion isEqualToString:@"2"]) {
        dict = self.listDatanoRead[indexPath.row];
    }
    
    
    NSString *buss_content = [dict objectForKey:@"buss_content"];
    if (([buss_content isEqualToString:@""])||(buss_content == nil)) {
        //没有商家回复
        return 122;
    }else{
        return 222;
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
- (void)clearunread{
    return;
    if (_unUnread>0) {
        //未读清零
        _unUnread = 0;
        [_listDatanoRead removeAllObjects];
        _countnormal = [[NSString alloc]initWithFormat:@"未读评论(%d)", _unUnread ];
        [_btnShowunRead setTitle:_countnormal forState:UIControlStateNormal];
    }else{
        return;
    }

    
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
    
    
    NSString *post = [NSString stringWithFormat:_iPs_POST3,_iPs_POSTAction3, _iPs_POSTID, _itemid ];
    _clearBeforeTag = _iPs_POSTQueryOption;
    _iPs_POSTQueryOption = @"2";
    [self startRequest:strURL POST:post];


}


#pragma mark- POST Request 发送网络请求方法
/*
 * 开始请求Web Service
 */
-(void)startRequest
{
    _isConnected = false;
    
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    NSString *post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction, _itemid];
    
    if ([_iPs_POSTQueryOption isEqualToString:@"0"]) {
        //评价汇总
        post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction, _itemid];
    }else if([_iPs_POSTQueryOption isEqualToString:@"1"]){
        //评价列表
        //_iPs_POST2=@"act=%@&business_id=%@&goods_id=%@&not_read=%@&is_bad=%@&page=%@";
        if (_iPageIndex <= 0) {
            _iPageIndex = 1;
        }
        
        post = [NSString stringWithFormat:_iPs_POST2,_iPs_POSTAction2, _itemid,_iPageIndex ];
        //_iPs_POSTQueryRegion//请求数据POST参数ID3：  评论列表 0全部，1差评，2未读
        //1为获取差评，0为获取好评，2为获取一般评论，不传值即获取全部评论
        if ([_iPs_POSTQueryRegion isEqualToString:@"0"]) {
            post = [post stringByAppendingString:@"&is_bad=0"];
        }else if ([_iPs_POSTQueryRegion isEqualToString:@"1"]) {
            
            post = [post stringByAppendingString:@"&is_bad=1"];
            
        }else if ([_iPs_POSTQueryRegion isEqualToString:@"2"]) {
            
            post = [post stringByAppendingString:@"&is_bad=2"];
        }
        
    }else if([_iPs_POSTQueryOption isEqualToString:@"2"]){
        //未读评价标记
        post = [NSString stringWithFormat:_iPs_POST3,_iPs_POSTAction3, _itemid ];
        
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
    NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:_datas options:NSJSONReadingAllowFragments error:nil];
    
    NSLog( @"Result: %@", [dict description] );
    //激活数据列表的刷新
    [self reloadView:dict];
}

#pragma mark - Page Data


//重新加载表视图
-(void)reloadView:(NSMutableDictionary*)res
{
    @try{
        NSNumber *resultCodeObj = [res objectForKey:@"is_err"];
        if (resultCodeObj==nil) {
            //无法处理的结果
            
            resultCodeObj = [[NSNumber alloc] initWithInt:1];
        }
        if ([resultCodeObj integerValue] ==0){
            //解析评论汇总：
            NSMutableDictionary* rank_info = [res objectForKey:@"result_list"];
            NSEnumerator *enumerator = [rank_info objectEnumerator];
            
            NSArray *results = [enumerator allObjects];
            
            //_listData = [NSMutableArray arrayWithArray:results];
            
            //_code  = [code_info objectForKey:@"goods_id"];
            //_userid  = [code_info objectForKey:@"goods_name"];
            if ([_iPs_POSTQueryOption isEqualToString:@"0"]) {
                //评价汇总
                NSLog(@"取得评价汇总");
                NSString *comment_rank;
                
                NSString *comment_count;

                int irank = 0;
                float total = 0.0;
                float totalscore = 0.0;
                
                //int resultcount = [[res objectForKey:@"count"]intValue];
                int resultbad = [[res objectForKey:@"bad_count"]intValue];
                int resultgood = [[res objectForKey:@"good_count"]intValue];
                int resultnormal = [[res objectForKey:@"common_count"]intValue];
                int resultcount = resultnormal + resultgood + resultbad;
                
                _countbad = [[NSString alloc]initWithFormat:@"差 评(%d)",resultbad];//resultbad
                //_btnShowBad.titleLabel.text = [[NSString alloc]initWithFormat:@"差评12%@",@""];
                //_btnShowBad.titleLabel.text = _countbad;
                [_btnShowBad setTitle:_countbad forState:UIControlStateNormal];
                //[_btnShowBad setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                
                _countnormal = [[NSString alloc]initWithFormat:@"中 评(%d)", resultnormal ];//resultunread
                //_btnShowunRead.titleLabel.text = _countnoread;
                [_btnShowunRead setTitle:_countnormal forState:UIControlStateNormal];
                //[_btnShowunRead setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                
                _countgood = [[NSString alloc]initWithFormat:@"好 评(%d)", resultgood ];
                [_btnShowAll setTitle:_countgood forState:UIControlStateNormal];
                
                _txtTotal.text = [[NSString alloc]initWithFormat:@"%d", resultcount ];
            
                
                for (int i = 0; i < results.count; i++) {
                    comment_rank = [[results objectAtIndex:i]objectForKey:@"comment_rank"];
                    comment_count = [[results objectAtIndex:i]objectForKey:@"count"];
                    
                    total += [comment_count floatValue];
                    
                    irank = [comment_rank intValue];
                    
                    totalscore = totalscore + irank*[comment_count floatValue];
                    
                    switch (irank) {
                        case 1:
                            _txtLevel1.text = comment_count;
                            
                            break;
                        case 2:
                            _txtLevel2.text = comment_count;
                            break;
                        case 3:
                            _txtLevel3.text = comment_count;
                            break;
                        case 4:
                            _txtLevel4.text = comment_count;
                            break;
                        case 5:
                            _txtLevel5.text = comment_count;
                            break;
                        default:
                            break;
                    }
                }
                if (total == 0) {
                    total = 1.0;
                }
                float lfValue = 0.0;
                lfValue = [_txtLevel1.text intValue]/total;
                [_pgsLevel1 setProgress:lfValue];
                
                lfValue = [_txtLevel2.text intValue]/total;
                [_pgsLevel2 setProgress:lfValue];
                
                lfValue = [_txtLevel3.text intValue]/total;
                [_pgsLevel3 setProgress:lfValue];
                
                lfValue = [_txtLevel4.text intValue]/total;
                [_pgsLevel4 setProgress:lfValue];
                
                lfValue = [_txtLevel5.text intValue]/total;
                [_pgsLevel5 setProgress:lfValue];
                
                if (([_itemRank floatValue]==0)||(totalscore==0)) {
                    _txtScore.text = @"3.0";
                    _txtScore.textColor = [UIColor lightGrayColor];
                }else{
                    _txtScore.text = [[NSString alloc]initWithFormat:@"%1.1f", totalscore/total ];
                }
                
                
                
                [_starView displayRating:[_txtScore.text floatValue]];
                
                //刷新后将Tab按钮默认选中全部评论
                //[self btnShowAllClicked:_btnShowAll];
                if(_listData.count == 0){
                    _iPs_POSTQueryOption = @"1";//取评论列表
                    [self startRequest];
                }
                return;
                
            }else if([_iPs_POSTQueryOption isEqualToString:@"1"]){
                //评价列表
                //解析评论汇总：
                NSMutableDictionary* rank_info = [res objectForKey:@"result_list"];
                NSEnumerator *enumerator = [rank_info objectEnumerator];
                
                NSArray *results = [enumerator allObjects];

                if ([_iPs_POSTQueryRegion isEqualToString:@"0"]) {
                    
                    //好评
                    _listData = [NSMutableArray arrayWithArray:results];

                    [self.tableView reloadData];
                    
                    if(_listDataBad.count == 0){
                        //_iPs_POSTQueryRegion = @"1";//取评论列表(差评)
                        //[self startRequest];
                    }
                    
                    //[self clearunread];
                    
                    
                }else if ([_iPs_POSTQueryRegion isEqualToString:@"1"]) {
                    //差评
                    _listDataBad = [NSMutableArray arrayWithArray:results];
                    
                    
                    [self.tableView reloadData];
                    
                    if(_listDatanoRead.count == 0){
                        //_iPs_POSTQueryRegion = @"2";//取评论列表(未读)
                        //[self startRequest];
                    }
                    
                    //[self clearunread];
                    
                }else if ([_iPs_POSTQueryRegion isEqualToString:@"2"]) {
                    //中评
                    _listDatanoRead = [NSMutableArray arrayWithArray:results];
                    _unUnread = [_listDatanoRead count];
                    [self.tableView reloadData];
                }
                
            }else if([_iPs_POSTQueryOption isEqualToString:@"2"]){
                //已读回复
                
                _iPs_POSTQueryOption = _clearBeforeTag;
                
                _clearBeforeTag = @"";
                
            }
            
            
            
            
            
            NSLog(@"列表视图加载数据...共 %d 条",results.count);
            
            [self.tableView reloadData];
        } else {
            //错误
            if([_iPs_POSTQueryOption isEqualToString:@"2"]){
                //已读回复
                
                _iPs_POSTQueryOption = _clearBeforeTag;
                
                _clearBeforeTag = @"";
                return;
            }

            NSString *Errormsg = [res objectForKey:@"err_msg"];
            NSLog(@"数据请求错误：%@",Errormsg);
            /*
            washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
            
            NSString *lsMsg = [[NSString alloc]initWithFormat:@"请努力提升销量以获取更多用户点评\n%@", Errormsg];
            if((Errormsg == nil)||([Errormsg isEqualToString:@""])){
                return;
            }
                
            if ([_iPs_POSTQueryRegion isEqualToString:@"0"]) {
                if (_iPageIndex<=1) {
                    
                    [delegate showNotify:lsMsg HoldTimes:1.5];
                }
                
            }else if ([_iPs_POSTQueryRegion isEqualToString:@"1"]) {
                if (_countbad>0) {
                    _iPageIndex = 0;
                    return;
                }
                lsMsg = [[NSString alloc]initWithFormat:@"恭喜您，目前没有差评记录。\n%@", Errormsg];
                [delegate showNotify:lsMsg HoldTimes:1.5];
            }else if ([_iPs_POSTQueryRegion isEqualToString:@"2"]) {
                lsMsg = [[NSString alloc]initWithFormat:@"今天没有新的用户评价。\n%@", Errormsg];
                [delegate showNotify:lsMsg HoldTimes:1.5];
            }

            */
            _iPageIndex = 0;
            [self.tableView reloadData];
        }
        
    }@catch(NSException *exp1){
        
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
