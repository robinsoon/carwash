//
//  ViewController.m
//  MQPDemo
//
//  Created by ChaoGanYing on 13-5-6.
//  Copyright (c) 2013年 Alipay. All rights reserved.
//

#import "ViewController.h"
#import "PartnerConfig.h"
#import "DataSigner.h"
#import "AlixPayResult.h"
#import "DataVerifier.h"
#import "AlixPayOrder.h"

@implementation Product
@synthesize price = _price;
@synthesize subject = _subject;
@synthesize body = _body;
@synthesize orderId = _orderId;

@end

@interface ViewController ()
@end


@implementation ViewController
@synthesize result = _result;


-(void)dealloc
{
#if ! __has_feature(objc_arc)
    [_products release];
    [super dealloc];
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _result = @selector(paymentResult:);
    [self generateData];
	// Do any additional setup after loading the view, typically from a nib.
}

//wap回调函数
-(void)paymentResult:(NSString *)resultd
{
    //结果处理
#if ! __has_feature(objc_arc)
    AlixPayResult* result = [[[AlixPayResult alloc] initWithString:resultd] autorelease];
#else
    AlixPayResult* result = [[AlixPayResult alloc] initWithString:resultd];
#endif
	if (result)
    {
		
		if (result.statusCode == 9000)
        {
			/*
			 *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
			 */
            
            //交易成功
            NSString* key = AlipayPubKey;//签约帐户后获取到的支付宝公钥
			id<DataVerifier> verifier;
            verifier = CreateRSADataVerifier(key);
            
			if ([verifier verifyString:result.resultString withSign:result.signString])
            {
                //验证签名成功，交易结果无篡改
			}
        }
        else
        {
            //交易失败
        }
    }
    else
    {
        //失败
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 *产生商品列表数据
 */
- (void)generateData{
	NSArray *subjects = [[NSArray alloc] initWithObjects:@"话费充值",
						 @"魅力香水",@"珍珠项链",@"三星 原装移动硬盘",
						 @"发箍发带",@"台版N97I",@"苹果手机",
						 @"蝴蝶结",@"韩版雪纺",@"五皇纸箱",nil];
	NSArray *body = [[NSArray alloc] initWithObjects:@"[四钻信誉]北京移动30元 电脑全自动充值 1到10分钟内到账",
					 @"新年特惠 adidas 阿迪达斯走珠 香体止汗走珠 多种香型可选",
					 @"[2元包邮]韩版 韩国 流行饰品太阳花小巧雏菊 珍珠项链2M15",
					 @"三星 原装移动硬盘 S2 320G 带加密 三星S2 韩国原装 全国联保",
					 @"[肉来来]超热卖 百变小领巾 兔耳朵布艺发箍发带",
					 @"台版N97I 有迷你版 双卡双待手机 挂QQ JAVA 炒股 来电归属地 同款比价",
					 @"山寨国产红苹果手机 Hiphone I9 JAVA QQ后台 飞信 炒股 UC",
					 @"[饰品实物拍摄]满30包邮 三层绸缎粉色 蝴蝶结公主发箍多色入",
					 @"饰品批发价 韩版雪纺纱圆点布花朵 山茶玫瑰花 发圈胸针两用 6002",
					 @"加固纸箱 会员包快递拍好去运费冲纸箱首个五皇",nil];
	
	_products = [[NSMutableArray alloc] init];
    	
	for (int i = 0; i < [subjects count]; ++i) {
		Product *product = [[Product alloc] init];
		product.subject = [subjects objectAtIndex:i];
		product.body = [body objectAtIndex:i];
		if (1==i) {
			product.price = 1;
		}
		else if(2==i)
		{
			product.price = 10;
		}
		else if(3==i)
		{
			product.price = 100;
		}
		else if(4==i)
		{
			product.price = 1000;
		}
		else if(5==i)
		{
			product.price = 2000;
		}
		else if(6==i)
		{
			product.price = 6000;
		}
		else {
			product.price = 0.01;
		}
		
		[_products addObject:product];
#if ! __has_feature(objc_arc)
		[product release];
#endif
	}
	
#if ! __has_feature(objc_arc)
	[subjects release], subjects = nil;
	[body release], body = nil;
#endif
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 55.0f;
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if ! __has_feature(objc_arc)
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
													reuseIdentifier:@"Cell"] autorelease];
#else
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
													reuseIdentifier:@"Cell"];
#endif
	Product *product = [_products objectAtIndex:indexPath.row];
	UIView *adaptV = [[UIView alloc] initWithFrame:CGRectMake(10, 0,
															  cell.bounds.size.width-10, cell.bounds.size.height)];
	
	UILabel *subjectLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, adaptV.bounds.size.width, 20)];
	subjectLb.text = product.subject;
	[subjectLb setFont:[UIFont boldSystemFontOfSize:14]];
	subjectLb.backgroundColor = [UIColor clearColor];
	[adaptV addSubview:subjectLb];
#if ! __has_feature(objc_arc)
	[subjectLb release];
#endif
	UILabel *bodyLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 25,
																adaptV.bounds.size.width, 20)];
	bodyLb.text = product.body;
	[bodyLb setFont:[UIFont systemFontOfSize:12]];
	[adaptV addSubview:bodyLb];
#if ! __has_feature(objc_arc)
	[bodyLb release];
#endif
	UILabel *priceLb = [[UILabel alloc] initWithFrame:CGRectMake(220, 5, 100, 20)];
	priceLb.text = [NSString stringWithFormat:@"一口价：%.2f",product.price];
	[priceLb setFont:[UIFont systemFontOfSize:12]];
	[adaptV addSubview:priceLb];
#if ! __has_feature(objc_arc)
	[priceLb release];
#endif
	[cell.contentView addSubview:adaptV];
#if ! __has_feature(objc_arc)
	[adaptV release];
#endif
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
	 *生成订单信息及签名
	 *由于demo的局限性，采用了将私钥放在本地签名的方法，商户可以根据自身情况选择签名方法(为安全起见，在条件允许的前提下，我们推荐从商户服务器获取完整的订单信息)
	 */
    
    NSString *appScheme = @"AlipaySdkDemo";
    NSString* orderInfo = [self getOrderInfo:indexPath.row];
    NSString* signedStr = [self doRsa:orderInfo];
    
    NSLog(@"%@",signedStr);
    
    NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                             orderInfo, signedStr, @"RSA"];
	
    [AlixLibService payOrder:orderString AndScheme:appScheme seletor:_result target:self];

}

-(NSString*)getOrderInfo:(NSInteger)index
{
    /*
	 *点击获取prodcut实例并初始化订单信息
	 */
	Product *product = [_products objectAtIndex:index];    
    AlixPayOrder *order = [[AlixPayOrder alloc] init];
    order.partner = PartnerID;
    order.seller = SellerID;

    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
	order.productName = product.subject; //商品标题
	order.productDescription = product.body; //商品描述
	order.amount = [NSString stringWithFormat:@"%.2f",product.price]; //商品价格
	//order.notifyURL =  @"http%3A%2F%2Fwwww.xxx.com"; //回调URL
	order.notifyURL =  @"http%3A%2F%2F2345mall.com%2Fnotify_url.php"; //回调URL
    
	return [order description];
}

- (NSString *)generateTradeNO
{
	const int N = 15;
	
	NSString *sourceString = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	NSMutableString *result = [[NSMutableString alloc] init] ;
	srand(time(0));
	for (int i = 0; i < N; i++)
	{
		unsigned index = rand() % [sourceString length];
		NSString *s = [sourceString substringWithRange:NSMakeRange(index, 1)];
		[result appendString:s];
	}
	return result;
}

-(NSString*)doRsa:(NSString*)orderInfo
{
    id<DataSigner> signer;
    signer = CreateRSADataSigner(PartnerPrivKey);
    NSString *signedString = [signer signString:orderInfo];
    return signedString;
}

//回调支付的结果
-(void)paymentResultDelegate:(NSString *)result
{
    NSLog(@"%@",result);
}

@end
