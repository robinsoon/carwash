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
#import "OrderDetailViewController.h"
#import "OrderSubmitViewController.h"
@interface carswashDetailViewController ()
//定义可配置的数据参数（对于简单查询只需1组配置）
//命名规则： i 表示实例变量；P 表示 页面变量； s 表示 数据类型为String；
//初始化统一调用方法：initPage
@property (strong, nonatomic) NSString *iPs_PageName; //页面名称(用于标记参数组)
@property (strong, nonatomic) NSString *iPs_PAGE; //请求数据接口模板--页面
@property (strong, nonatomic) NSString *iPs_POST; //请求数据POST参数模板
@property (strong, nonatomic) NSString *iPs_POSTAction; //请求数据POST参数Action

//传入变化的参数组,参数数目根据接口需要而变化
@property (strong, nonatomic) NSString *iPs_POSTID; //请求数据POST参数ID1
@property (strong, nonatomic) NSString *iPs_POSTQueryOption; //请求数据POST参数ID2
@property (strong, nonatomic) NSString *iPs_POSTQueryRegion; //请求数据POST参数ID3

@end

@implementation carswashDetailViewController

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
    
    self.detailscrollview.contentSize = CGSizeMake(320,650);
    [self.detailscrollview addSubview:self.subViewPrice];
    [self.detailscrollview addSubview:self.subViewComment];
    //self.detailscrollview.delegate = self;
    if (_iPs_PageName==nil) {
        [self initPage];
    }
    //加载数据
    [self startRequestItem];
    
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
    _iPs_POSTQueryOption=@"0"; //请求数据POST参数ID2
    _iPs_POSTQueryRegion=@""; //请求数据POST参数ID3
    
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
    NSLog(@"请求完成...");
    _isConnected = true;
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:_Requestdata options:NSJSONReadingAllowFragments error:nil];
    
    NSLog( @"Result: %@", [dict description] );
    [self reloadDetail:dict];
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

//小数位数据处理
-(NSString *) roundUp:(float)number afterPoint:(int)position{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:number];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    return [NSString stringWithFormat:@"%@",roundedOunces];
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
//                    poimapview.listData = nil;
//                    poimapview.itemname = _lbName.text;
//                    poimapview.Locationpt = _Locationpt;
//                    poimapview.iZoomLevel = 14;
                    
                    //最后跳转页面
                    self.tabBarController.selectedIndex = 1;
                    
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
//            poimapview.listData = nil;
//            poimapview.itemname = _lbName.text;
//            poimapview.Locationpt = _Locationpt;
//            poimapview.iZoomLevel = 14;
            
            //最后跳转页面
            self.tabBarController.selectedIndex = 1;
            
            
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
