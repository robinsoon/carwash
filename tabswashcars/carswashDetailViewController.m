//
//  carswashDetailViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-14.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "carswashDetailViewController.h"
#import "UIButton+Bootstrap.h"
#import "navMapsViewController.h"
#import "PoiSearchViewController.h"
#import "OrderDetailViewController.h"
//#import "OrderSubmitViewController.h"
#import "moreInforTableViewController.h"
#import "sellRecordTableViewController.h"

@interface carswashDetailViewController ()
//定义可配置的数据参数（对于简单查询只需1组配置）
//命名规则： i 表示实例变量；P 表示 页面变量； s 表示 数据类型为String；
//初始化统一调用方法：initPage
@property (strong, nonatomic) NSString *iPs_PageName; //页面名称(用于标记参数组)
@property (strong, nonatomic) NSString *iPs_PAGE; //请求数据接口模板--页面
@property (strong, nonatomic) NSString *iPs_POST; //请求数据POST参数模板
@property (strong, nonatomic) NSString *iPs_POSTAction; //请求数据POST参数Action

@property (strong, nonatomic) NSString *iPs_POSTAction2; //请求数据POST参数Action

@property (strong, nonatomic) NSString *iPs_POSTAction3; //请求数据POST参数Action
//传入变化的参数组,参数数目根据接口需要而变化
@property (strong, nonatomic) NSString *iPs_POSTID; //请求数据POST参数ID1
@property (strong, nonatomic) NSString *iPs_POSTQueryOption; //请求数据POST参数ID2
@property (strong, nonatomic) NSString *iPs_POSTQueryRegion; //请求数据POST参数ID3
@property (strong, nonatomic) NSString *iPs_WebPAGE;
@property (strong, nonatomic) NSString *iPs_WebGet;

@end

@implementation carswashDetailViewController
@synthesize starView =_starView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if (_iPs_PageName==nil) {
            [self initPage];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *strID = [[NSString alloc] initWithFormat:@"ID: %@",self.itemid];
    self.lbID.text = strID;

    //销量
    self.lbNumber.text = _iSellNumber;
    
    [self.btnBuy dangerStyle];
    
    [self.btnBuy addAwesomeIcon:FAIconCheck beforeTitle:YES];

    [self.btnAddCart successStyle];
    
    //[self.btnAddCart addAwesomeIcon:FAIconStar beforeTitle:NO];
    [self.btnAddCart addAwesomeIcon:FAIconShoppingCart beforeTitle:NO];
    
    self.detailscrollview.contentSize = CGSizeMake(320,1050);
    [self.detailscrollview addSubview:self.subViewPrice];
    
    [self.detailscrollview addSubview:self.subWebContent];
    
    [self.detailscrollview addSubview:self.subViewComment];
    
    [self.detailscrollview addSubview:self.subViewDescribe];
    
    [_starView setImagesDeselected:@"Star0.png" partlySelected:@"Star1.png" fullSelected:@"Star2.png" andDelegate:self];
	[_starView displayRating:4.5];
    
    //self.detailscrollview.delegate = self;
    if (_iPs_PageName==nil) {
        [self initPage];
    }
    
    //加载数据
    _iPs_POSTQueryOption = @"0";
    [self startRequestItem];
    
    [self loadWebContent];
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
        [self startRequestItem];
        
    }
    
    
    //未避免跳转页面(定位到地图)返回后，按钮消失，特别增加以下代码，重新设定按钮风格
    //销毁按钮(不需要销毁，否则创建按钮需要代码完成)
    //[self.btnBuy removeFromSuperview];
    //[btn release];
    
    //重绘按钮
    [self.btnBuy dangerStyle];
    [self.btnAddCart successStyle];
    
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
    _iPs_PageName=@"服务明细"; //页面名称(用于标记页面参数配置)
    //请求数据接口模板--地址
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _iPs_URL=delegate.iPs_URL; //请求数据接口模板--地址
    
    _iPs_PAGE=@"goods_app.php"; //请求数据接口模板--页面
    _iPs_POST=@"act=%@&goods_id=%@"; //请求数据POST参数模板
    _iPs_POSTAction =@"goods_item";
    
    _iPs_POSTID= _itemid ; //请求数据POST参数ID1
    
    //_iPs_POSTAction2 =@"goods_comment"; //用户评论
    _iPs_POSTAction2 =@"goods_new_comment"; //用户评论
    
    _iPs_POSTAction3 =@"goods_record"; //销售记录
    
    _iPs_POSTQueryOption=@"0"; //请求数据POST参数ID2：0 详情 1评论 2销售记录
    _iPs_POSTQueryRegion=@""; //请求数据POST参数ID3
    //http://www.2345mall.com/description_app.php?act=goodsdesc&goods_id=",参数传商品ID
    _iPs_WebPAGE = @"description_app.php";
    _iPs_WebGet = @"act=goodsdesc&goods_id=";
    
    _subWebContent.delegate = self;
}

-(void)ratingChanged:(float)newRating {
	_ratingLabel.text = [NSString stringWithFormat:@"%1.1f", newRating];
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

#pragma mark - Navigation
//页面发生跳转，进入明细
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"ShowOrder"])
    {
        OrderDetailViewController *itemOrder = segue.destinationViewController;
        
        
        itemOrder.itemid = self.itemid;
        itemOrder.itemname = self.lbName.text;
        itemOrder.itemprice = self.itemprice;
        itemOrder.itemdetail = self.lbAddress.text;
        itemOrder.itemAmount = @"1";
        itemOrder.itemTotal = self.itemprice;
        itemOrder.OrderAction= @"新建";
        itemOrder.PayStatus = @"0";
        itemOrder.OrderStatus= @"0";
        
        NSLog(@"进入订单页面 %@",self.itemid);
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc]init];
        backItem.title=@"";
        backItem.tintColor=[UIColor colorWithRed:129/255.0 green:129/255.0  blue:129/255.0 alpha:1.0];
        self.navigationItem.backBarButtonItem = backItem;

    }
    
    //OrderSubmitViewController *ordersubmit = [];
    
    if([segue.identifier isEqualToString:@"morelist"])
    {
        moreInforTableViewController *itemlist = segue.destinationViewController;
        
        itemlist.listData = self.listcommit;
        itemlist.itemid = self.itemid;
        
        NSLog(@"进入扩展信息列表 %d",self.listcommit.count );
        
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc]init];
        backItem.title=@"";
        backItem.tintColor=[UIColor colorWithRed:129/255.0 green:129/255.0  blue:129/255.0 alpha:1.0];
        self.navigationItem.backBarButtonItem = backItem;
        
    }
    
    if([segue.identifier isEqualToString:@"sellrecordlist"])
    {
        sellRecordTableViewController *itemlist = segue.destinationViewController;
        
        itemlist.listData = self.listSell;
        itemlist.itemid = self.itemid;
        
        NSLog(@"进入销售记录列表 %d",self.listSell.count );
        
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc]init];
        backItem.title=@"";
        backItem.tintColor=[UIColor colorWithRed:129/255.0 green:129/255.0  blue:129/255.0 alpha:1.0];
        self.navigationItem.backBarButtonItem = backItem;
        
    }

    
    
}



/*
 * 开始请求Web Service
 */

-(void)startRequestItem
{
    _isConnected = false;
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _iPs_URL=delegate.iPs_URL; //请求数据接口模板--地址
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];

    NSString *post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_itemid];
    
    if ([_iPs_POSTQueryOption isEqualToString:@"0"]) {
        post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_itemid];
        
    }else if ([_iPs_POSTQueryOption isEqualToString:@"1"]) {
        //评论的请求
        post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction2,_itemid];
        
    }else if ([_iPs_POSTQueryOption isEqualToString:@"2"]) {
        //评论的请求
        post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction3,_itemid];
        
    }

    
    
    
    
    
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
	
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request delegate:self];
	
    if (connection) {
        NSLog(@"%@ POST=%@", strURL , post);
        _isConnected = true;
        _Requestdata = [NSMutableData new];
    }else{
        NSLog(@"无法建立数据连接！%@ POST=%@", strURL , post);
        _isConnected = false;
    }
}


#pragma mark- NSURLConnection 回调方法
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_Requestdata appendData:data];
}


-(void) connection:(NSURLConnection *)connection didFailWithError: (NSError *)error {
    
    _isConnected = false;
    NSLog(@"连接失败：%@",[error localizedDescription]);
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection {
    
    _isConnected = true;
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:_Requestdata options:NSJSONReadingAllowFragments error:nil];
    
    NSLog( @"Result: %@", [dict description] );
    
    if ([_iPs_POSTQueryOption isEqualToString:@"1"]){
        
        [self reloadCommit:dict];
        
        //请求购买记录
        if(_iSellNumber > 0){
            //暂不开启
            _iPs_POSTQueryOption = @"2";
            [self startRequestItem];
        }
    }else if([_iPs_POSTQueryOption isEqualToString:@"2"]){
        
        [self reloadSellRecord:dict];
        
    }else{
        
        [self reloadDetail:dict];
        
        //请求用户评论
        
        _iPs_POSTQueryOption = @"1";
        [self startRequestItem];
    }
    
}


//重新加载表视图
-(void)reloadDetail:(NSDictionary*)res
{
    NSString *goods_id = [res objectForKey:@"goods_id"];
    if ([goods_id isEmpty]) {
        NSString *errorStr = [[NSString alloc] initWithFormat:@"Service Error, ID:%@",goods_id];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误信息"
                                                            message:errorStr
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];

        return;
    }
    
    self.detailData[0] = res;

    //NSLog(@"1399276800  = %@",confromTimesp);
    //填充价格字段
    NSDictionary *is_promote = [res objectForKey:@"is_promote"];

    NSString *nmPrice = [res objectForKey:@"promote_price"];
    NSString *nmSHPrice = [res objectForKey:@"shop_price"];
    NSString *nmMKPrice = [res objectForKey:@"market_price"];
    
    self.lbShopPrice.text =nmMKPrice;//市场价格(原价)
    
    float discount = 0;
    float fPrice = 0;
    float fMKPrice = [nmMKPrice floatValue];
    //判断是否促销
    if ([is_promote isEqual:@"1"]) {
        //执行促销活动价格
        NSString *strPrice = [[NSString alloc] initWithFormat:@"%@",nmPrice];
        self.lbPrice.text =strPrice;
        fPrice = [nmPrice floatValue];
        self.itemprice = nmPrice;
        
        //时间转换 promote_end_date
        NSNumber * promoteend= [res objectForKey:@"promote_end_date"];
        
        int nmEndDate = [promoteend intValue];
        if (nmEndDate>0) {
            NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:nmEndDate];
            
            //处理日期时间的格式
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSString *destDateString = [dateFormatter stringFromDate:confromTimesp];
            //输出
            _lbenddate.text = destDateString;
            _lbenddate.hidden = false;
            _lbenddatehead.hidden = false;
        }
    }else{
        //执行商城价格
        NSString *strPrice = [[NSString alloc] initWithFormat:@"%@",nmSHPrice];
        self.lbPrice.text =strPrice;
        fPrice = [nmSHPrice floatValue];
        self.itemprice = nmSHPrice;
        
        _lbenddate.text = @"";
        _lbenddate.hidden = true;
        _lbenddatehead.hidden = true;

    }
    
    
    //计算打折
    if (0 != fMKPrice && 0 != fPrice) {
        discount = 10*fPrice/fMKPrice;
        //[self.roundUp:discount afterPoint:2];
        if (discount>=1 && discount<10) {
            self.lbDiscount.text =[[NSString alloc] initWithFormat:@"%1.1f折",discount];
        }else if (discount<1){
            self.lbDiscount.text =@"低于1折";
        }else{
            self.lbDiscount.text =@"";
        }
        
    }else{
        discount = 0;
        self.lbDiscount.text =@"";
    }

    @try{
    //填充Detail数据字段
    self.lbName.text =[res objectForKey:@"goods_name"];

    self.lbClickcount.text =[res objectForKey:@"click_count"];
    self.lbgoodsn.text =[res objectForKey:@"goods_sn"];
    
    self.lbStyle.text =[res objectForKey:@"add_time"];
    
    
    self.lbAddress.text = [res objectForKey:@"address_street"];
    self.lbPhone.text = [res objectForKey:@"phone"];
    
    self.lbBusinessName.text =[res objectForKey:@"business_displayname"];
    
    self.lbgoodsvalidate.text =[res objectForKey:@"goods_valid"];
    self.lbgoodsusetime.text =[res objectForKey:@"use_time_range"];
    self.lbnotice.text =[res objectForKey:@"goods_remind"];
    self.lbuserole.text =[res objectForKey:@"use_role"];
    
    _Locationpt.latitude =[[res objectForKey:@"Latitude"] doubleValue];
    _Locationpt.longitude =[[res objectForKey:@"Longitude"] doubleValue];
    
    //销量
    self.lbNumber.text = _iSellNumber;//[res objectForKey:@"goods_number"];
        if((_iSellNumber == nil)||([_iSellNumber isEqualToString:@"0"])){
        }else{
            _lbNumber.textColor = [UIColor blueColor];
        }
    
    //库存
    NSInteger goodsnumber = [[res objectForKey:@"goods_number"] integerValue];
    if ((10>=goodsnumber)&&(0<goodsnumber)) {
        //货源紧张
        _lbsellout.text = [[NSString alloc] initWithFormat:@"限售%d个",(int)goodsnumber];

        _lbsellout.hidden = false;
        _btnBuy.hidden = false;
        [self.btnBuy dangerStyle];
    }else if(0>=goodsnumber) {
        //已售完
        _lbsellout.text = @"已售完";
        _lbsellout.hidden = false;
        _btnBuy.hidden = true;
    }else{
        _lbsellout.hidden = true;
        _btnBuy.hidden = false;
        [self.btnBuy dangerStyle];
    }
    
    //带有缓存机制的图片加载
    NSString *strImgName = [res objectForKey:@"goods_img"];
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
         NSLog(@" 正在下载图片 %d / %d", receivedSize , expectedSize);
         
     }
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             // do something with image
             self.imgServiceView.image = image;
             NSLog(@"异步载入图片 %@",strImgURL);
         }
     }];
        
    }@catch(NSException *exp1){
    
    }
    //加载完毕
    NSLog(@"商品&服务详情加载完毕。");
}

//重新加载表视图--用户评论
-(void)reloadCommit:(NSDictionary*)res
{
    NSString *commit_id = @"";
    NSString *lsName = @"";
    NSString *lsCommit = @"";
    NSString *lsRank = @"";
    NSString *lsDate = @"";
    NSString *lsEmail = @"";
    
    @try{
        NSEnumerator *enumerator = [res objectEnumerator];

        NSArray *results = [enumerator allObjects];
        
        NSDictionary* dict;
        double ldRank = 0;
        double ldRankSum = 0;
        
        _listcommit = [[NSMutableArray alloc] initWithArray:results];
        [enumerator allObjects];
        if (results.count > 0)
        {
            for (int i=0; i<results.count; i++) {
                dict = [results objectAtIndex:i];
                commit_id = [dict objectForKey:@"id"];
                if ([commit_id isEmpty]) {
                    continue;
                }
                //填充Detail数据字段
                lsDate =[dict objectForKey:@"add_time"];
                lsEmail =[dict objectForKey:@"email"];
                lsRank =[dict objectForKey:@"rank"];
                lsName = [dict objectForKey:@"username"];
                lsCommit =[dict objectForKey:@"content"];
                //[@"user_id"];
                
                ldRank = [lsRank doubleValue];
                ldRankSum += ldRank;
            }
            
            _lbCommitCount.text = [[NSString alloc]initWithFormat:@"%d人评价",results.count];
            ldRank = ldRankSum/results.count;
            if (ldRank<=0.5) {
                ldRank = 1;
            }
            _lbCommitCount.textColor = [UIColor blueColor];
            [_starView displayRating:ldRank];
            NSLog(@"加载评论数据...共 %d 条",results.count);

        } else {
            NSLog(@"暂无评论");
            _lbCommitCount.text = @"暂无评论";
            [_starView displayRating:5.0];
        }
        
    }@catch(NSException *exp1){
        
    }

}

//重新加载表视图--销售记录
-(void)reloadSellRecord:(NSDictionary*)res
{

    NSString *lsName = @"";
    NSString *lstatus = @"";
    NSString *lsBuyCount = @"";
    NSString *lsDate = @"";
    NSString *lsAmount = @"";
    NSString *lsuserid = @"";
    
    @try{
        NSEnumerator *enumerator = [res objectEnumerator];
        
        NSArray *results = [enumerator allObjects];
        NSDictionary* dict;
        double ldSellSum = 0;
        _listSell = [[NSMutableArray alloc] initWithArray:results];
        if (results.count > 0)
        {
            
            for (int i=0; i<results.count; i++) {
                dict = [results objectAtIndex:i];
                lsName = [dict objectForKey:@"user_name"];
                if ([lsName isEmpty]) {
                    continue;
                }
                //填充Detail数据字段
                lsDate =[dict objectForKey:@"add_time"];
                lsAmount =[dict objectForKey:@"goods_price"];
                lsBuyCount =[dict objectForKey:@"goods_number"];
                
                lstatus =[dict objectForKey:@"order_status"];
                lsuserid =[dict objectForKey:@"user_id"];
                ldSellSum+=[lsAmount doubleValue];
                
            }

            //_lbSellCount.text = [[NSString alloc]initWithFormat:@"平均售价 %d，最高",results.count];
            NSLog(@"加载购买记录...共 %d 条",results.count);
            
        } else {
            NSLog(@"暂无购买记录");
            _iSellNumber = @"0";

            _lbNumber.textColor = [UIColor blackColor];


        }
        
    }@catch(NSException *exp1){
        
    }
    
}

//小数位数据处理
-(NSString *) roundUp:(float)number afterPoint:(int)position{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:number];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    return [NSString stringWithFormat:@"%@",roundedOunces];
}

//加载基于Web页面的描述信息
- (void)loadWebContent{
    //http://www.2345mall.com/description_app.php?act=goodsdesc&goods_id=",参数传商品ID
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@%@?%@%@",_iPs_URL,_iPs_WebPAGE,_iPs_WebGet,_itemid];
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_subWebContent loadRequest:request];
    
    
}

#pragma mark ---- 数据加载完调用webView代理方法
- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    NSLog(@"加载基于Web页面的描述信息");

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    CGRect frame = aWebView.frame;
    //webView的宽度
    frame.size = CGSizeMake(300, 0);
    aWebView.frame = frame;
    float content_height = [[aWebView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    frame = aWebView.frame;
    //webView的宽度和高度
    frame.size = CGSizeMake(300, content_height+40);
    aWebView.frame = frame;
    
    //NSLog(@"-----%d",(int) frame.size.height);
    
    //移动下面两个View的位置
    int ypos = aWebView.frame.origin.y + frame.size.height + 20;
    
    _subViewComment.frame = CGRectMake( 0, ypos, _subViewComment.frame.size.width, _subViewComment.frame.size.height ); // set new position exactly
    
    ypos = ypos + _subViewComment.frame.size.height;
    
    _subViewDescribe.frame = CGRectMake( 0, ypos, _subViewDescribe.frame.size.width, _subViewDescribe.frame.size.height ); // set new position exactly
    
    self.detailscrollview.contentSize = CGSizeMake(320,ypos + _subViewDescribe.frame.size.height - 100);
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

- (IBAction)btnCommitClicked:(id)sender {
    if ( _listcommit.count>0) {
        [self performSegueWithIdentifier:@"morelist" sender:self];
    }else{
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];

        NSString *lsMsg = [[NSString alloc]initWithFormat:@"当前商品暂无评论"];
        
        [delegate showNotify:lsMsg HoldTimes:2.5];
    }

}
- (IBAction)btnSellRecordClicked:(id)sender {
    if((_iSellNumber == nil)||([_iSellNumber isEqualToString:@"0"])){
    }else{
        //暂不开启
        [self performSegueWithIdentifier:@"sellrecordlist" sender:self];
    }

    
}

//定位到地图
- (IBAction)btnLocation:(id)sender {
    
    
    self.tabBarController.selectedIndex = 1;
    [self performSelector:@selector(LocationDelay) withObject:nil afterDelay:0.5f];
    return;
    
    //[self LocationDelay];
    
    
    /*
     //不用下面的这个方法，切换地图后详情页面布局受到影响(顶部显示不全)
     PoiSearchViewController *poimapview = [[PoiSearchViewController alloc] init];
     [self.navigationController pushViewController:poimapview animated:NO];
     poimapview.itemname = _lbName.text;
     poimapview.title = @"位置";
     poimapview.Locationpt = _Locationpt;
     poimapview.iZoomLevel = 17;
     */
}

- (void)LocationDelay{
    
    
    //取导航列表直接推视图
    NSArray *arrControllers = self.tabBarController.viewControllers;
    for(UIViewController *viewController in arrControllers)
    {
        if([viewController isKindOfClass:[navMapsViewController class]])
        {
            //NavigationController
            UINavigationController *navCtrl = (UINavigationController *)viewController;
            
            //NSLog(@"%@",navCtrl.viewControllers);
            NSLog(@"服务列表标注到地图");
            
            PoiSearchViewController *poimapview;
            
            //如果已有初始化过的 PoiSearchViewController 则不再创建新实例
            for (UIViewController *mapviewController in navCtrl.viewControllers) {
                
                if([mapviewController isKindOfClass:[PoiSearchViewController class]]){
                    //存在,强制转换为地图的View
                    poimapview = (PoiSearchViewController *)mapviewController;
                    //传递参数
                    poimapview.listData = nil;
                    poimapview.itemname = _lbName.text;
                    poimapview.Locationpt = _Locationpt;
                    poimapview.iZoomLevel = 14;
                    
                    //最后跳转页面
                    self.tabBarController.selectedIndex = 1;
                    
                    [poimapview LocationRefresh];
                    
                    return;
                    
                    NSString *strName = _lbName.text;
                    NSString *strlatitude = [[NSString alloc]initWithFormat:@"%f", _Locationpt.latitude];
                    NSString *strlongitude = [[NSString alloc]initWithFormat:@"%f", _Locationpt.longitude];
                    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:strName, @"name", strlatitude,@"latitude",strlongitude,@"longitude", nil];
                    
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"LocationPointNotification"
                     object:nil
                     userInfo:dataDict];

                    [poimapview LocationRefresh];
                    return;//防止重复推同一个视图
                }
                
            }
            
            if (poimapview == nil) {
                //创建新实例
                poimapview = [[PoiSearchViewController alloc] init];
            }
            
            //推送地图的视图
            [navCtrl pushViewController:poimapview animated:NO];
            //PoiSearchViewController 太多实例
            
            //传递参数
            poimapview.listData = nil;
            poimapview.itemname = _lbName.text;
            poimapview.Locationpt = _Locationpt;
            poimapview.iZoomLevel = 14;
            
            //最后跳转页面
            self.tabBarController.selectedIndex = 1;
            
            return;
        }
        else
        {
            // view controller
        }
    }
    
    //以下代码需要延迟执行，如果是地图没有初始化
    NSString *strName = _lbName.text;
    NSString *strlatitude = [[NSString alloc]initWithFormat:@"%f", _Locationpt.latitude];
    NSString *strlongitude = [[NSString alloc]initWithFormat:@"%f", _Locationpt.longitude];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:strName, @"name", strlatitude,@"latitude",strlongitude,@"longitude", nil];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"LocationPointNotification"
     object:nil
     userInfo:dataDict];

}

@end
