//
//  OrderDetailViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-16.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "UIButton+Bootstrap.h"

@interface OrderDetailViewController ()
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

//订单明细的状态有：已付款订单(显示消费码)、未付款订单(显示支付)、新建 订单草稿(显示提交订单)
@implementation OrderDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSString *lsUserID = @"2692";
        self.UserID = lsUserID;
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lbID.text = _OrderID;//self.itemid;
    self.lbName.text = self.itemname;
    self.lbPrice.text = self.itemprice;
    self.lbDescription.text = self.itemdetail;
    self.lbAmount.text = self.itemAmount;
    
    if ([_OrderStatus isEqual:@"0"]) {
        self.lbOrderStatus.text = @"新建";
    }else
    {
        self.lbOrderStatus.text = @"有效";
    }
    
    if ([_PayStatus isEqual:@"0"]) {
        self.lbPayStatus.text = @"未支付";
    }else
    {
        self.lbPayStatus.text = @"已支付";
    }
    
    if ([_OrderAction  isEqual: @"新建"]) {
        self.btnSubmit.titleLabel.text = @"提交订单";
    }else if ([_OrderAction  isEqual: @"支付"]){
        self.btnSubmit.titleLabel.text = @"支付";
    }else if ([_OrderAction  isEqual: @"已付款"]){
        self.btnSubmit.titleLabel.text = @"申请退款";
    }else{
        self.btnSubmit.hidden = true;
    }
    [self.btnSubmit primaryStyle];
    [self.btnSubmit addAwesomeIcon:FAIconCircleArrowUp beforeTitle:YES];
    

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
    _iPs_PageName=@"订单列表"; //页面名称(用于标记页面参数配置)
    _iPs_URL=@"http://114.112.73.223:8080/"; //请求数据接口模板--地址
    _iPs_PAGE=@"flow_app.php"; //请求数据接口模板--页面1
    _iPs_POST=@"act=%@&user_id=%@&goods_id=%@&number=%@&amount=%@"; //请求数据POST参数模板
    _iPs_POSTAction =@"insert_order";   //已付款订单
    _iPs_POSTAction2 =@"";//未付款订单
    _iPs_POSTID=@"2692"; //请求数据POST参数ID1
    _iPs_POSTQueryOption=@""; //请求数据POST参数ID2
    _iPs_POSTQueryRegion=@""; //请求数据POST参数ID3
    
    //不随页面类型改变的部分
    _iPageIndex = 1;//初始化页面序号
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"ShowPay"])
    {
        OrderDetailViewController *itemPay = segue.destinationViewController;
        
        itemPay.itemid = self.OrderID;
        itemPay.itemname = self.lbName.text;
        itemPay.itemprice = self.lbPrice.text;
        itemPay.itemdetail = self.lbDescription.text;
        
        NSLog(@"进入订单页面 %@",self.OrderID);
        
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
    NSString *post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID,_itemid,_itemAmount,_itemprice];
    
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
    
    //NSLog( @"Result: %@", [dict description] );
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
    NSArray *results = [res objectForKey:@"order_id"];
    if (results.count > 0)
    {
        self.listData = [res objectForKey:@"order_id"];
        
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
            [self startRequest];
            return;
        }
        //[self.tableView reloadData];
    } else {
        //{"state":0}
        NSNumber *resultStateObj = [res objectForKey:@"is_error"];
        if ([resultStateObj integerValue] ==0){
            self.iPageIndex = 1;
            NSLog(@"列表视图页面下次滚动将返回首行...");
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
