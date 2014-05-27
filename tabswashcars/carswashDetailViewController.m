//
//  carswashDetailViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-14.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "carswashDetailViewController.h"
#import "UIButton+Bootstrap.h"

#import "OrderDetailViewController.h"

@interface carswashDetailViewController ()

@end

@implementation carswashDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *strID = [[NSString alloc] initWithFormat:@"ID: %@",self.itemid];
    self.lbID.text = strID;

    [self.btnBuy dangerStyle];
    
    [self.btnBuy addAwesomeIcon:FAIconCheck beforeTitle:YES];
    
    
    [self.btnAddCart successStyle];
    
    //[self.btnAddCart addAwesomeIcon:FAIconStar beforeTitle:NO];
    [self.btnAddCart addAwesomeIcon:FAIconShoppingCart beforeTitle:NO];
    
    
    self.detailscrollview.contentSize = CGSizeMake(320,800);
    [self.detailscrollview addSubview:self.subViewPrice];
    [self.detailscrollview addSubview:self.subViewComment];
    //self.detailscrollview.delegate = self;
    
    //加载数据
    [self startRequestItem];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        itemOrder.itemdetail = self.lbPhone.text;
        
        NSLog(@"进入订单页面 %@",self.itemid);
        
    }
}



/*
 * 开始请求Web Service
 */

-(void)startRequestItem
{
    _isConnected = false;
    NSString *strURL = [[NSString alloc] initWithFormat:@"http://114.112.73.223:8080/goods_app.php"];
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    NSString *post = [NSString stringWithFormat:@"act=goods_item&goods_id=%@", _itemid ];
    
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
	
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request delegate:self];
	
    if (connection) {
        _isConnected = true;
        _Requestdata = [NSMutableData new];
    }else{
        NSLog(@"无法建立数据连接！%@ POST=%@", strURL , postData);
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
        NSString *strPrice = [[NSString alloc] initWithFormat:@"￥%@",nmPrice];
        self.lbPrice.text =strPrice;
        fPrice = [nmPrice floatValue];
        self.itemprice = nmPrice;
    }else{
        //执行商城价格
        NSString *strPrice = [[NSString alloc] initWithFormat:@"￥%@",nmSHPrice];
        self.lbPrice.text =strPrice;
        fPrice = [nmSHPrice floatValue];
        self.itemprice = nmSHPrice;
    }
    
    //计算打折
    if (0 != fMKPrice && 0 != fPrice) {
        discount = 10*fPrice/fMKPrice;
        //[self.roundUp:discount afterPoint:2];
        if (discount>=1 && discount<10) {
            self.lbDiscount.text =[[NSString alloc] initWithFormat:@"%g折",discount];
        }else if (discount<1){
            self.lbDiscount.text =@"低于1折";
        }else{
            self.lbDiscount.text =@"";
        }
        
    }else{
        discount = 0;
        self.lbDiscount.text =@"";
    }

    
    //填充Detail数据字段
    self.lbName.text =[res objectForKey:@"business_displayname"];

    self.lbClickcount.text =[res objectForKey:@"click_count"];
    self.lbgoodsn.text =[res objectForKey:@"goods_sn"];
    self.lbNumber.text =[res objectForKey:@"goods_number"];
    self.lbStyle.text =[res objectForKey:@"add_time"];
    
    
    self.lbAddress.text = [res objectForKey:@"address_street"];
    self.lbPhone.text = [res objectForKey:@"phone"];
    
    NSString *lsPostion = [[NSString alloc] initWithFormat:@"商铺地图定位Latitude:%@, Longitude:%@",[res objectForKey:@"Latitude"],[res objectForKey:@"Longitude"]];
    self.lbDetails.text = lsPostion;
    
    
    //带有缓存机制的图片加载
    NSString *strImgName = [res objectForKey:@"goods_img"];
    NSString *strImgURL = [[NSString alloc] initWithFormat:@"http://114.112.73.223:8080/%@",strImgName];
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

//页面即将展示
-(void) viewWillAppear:(BOOL)animated{
    if (_isConnected == false) {
        NSLog(@"尝试重新加载数据...");
        //重新加载数据
        [self startRequestItem];
    }
    
}

@end
