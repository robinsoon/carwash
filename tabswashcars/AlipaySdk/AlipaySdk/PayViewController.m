//
//  PayViewController.m
//  MQPDemo
//
//  Created by ChaoGanYing on 13-7-3.
//  Copyright (c) 2013年 Alipay. All rights reserved.
//

#import "PayViewController.h"
#import "PartnerConfig.h"
#import "DataSigner.h"
#import "AlixPayResult.h"
#import "DataVerifier.h"

@interface PayViewController ()

@end

@implementation PayViewController
@synthesize result = _result;
@synthesize name = _name;
@synthesize info = _info;
@synthesize price = _price;

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
    // Do any additional setup after loading the view from its nib./Users/zhumengcen/Desktop/workroom/ymx/MQPDemo/MQPDemo/PayViewController.h
    _result = @selector(paymentResult:);
    self.name.text = @"《暗黑破坏神3:凯恩之书》";
    self.info.text = @"暴雪唯一官方授权中文版!玩家必藏！附赠暗黑精致手绘地图!绝不仅仅是一本暗黑的故事或画册，而是一个栩栩如生的游戏再现。是游戏玩家珍藏的首选。";
    self.price.text = @"0.01";
//    [[NSNotificationCenterdefaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenterdefaultCenter] addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPay:(id)sender
{
    /*
	 *生成订单信息及签名
	 *由于demo的局限性，采用了将私钥放在本地签名的方法，商户可以根据自身情况选择签名方法
	 */
    
    NSString *appScheme = @"AlipaySdkDemo";
    NSString* orderInfo = [self getOrderInfo];
    NSString* signedStr = [self doRsa:orderInfo];
    
    NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                             orderInfo, signedStr, @"RSA"];

    [AlixLibService payOrder:orderString AndScheme:appScheme seletor:_result target:self];
    
}

-(NSString*)getOrderInfo
{
    /*
	 *点击获取prodcut实例并初始化订单信息
	 */
    
    NSMutableString * discription = [NSMutableString string] ;
	[discription appendFormat:@"partner=\"%@\"", PartnerID];
	[discription appendFormat:@"&seller_id=\"%@\"", SellerID];
	[discription appendFormat:@"&out_trade_no=\"%@\"", [self generateTradeNO]];
	[discription appendFormat:@"&subject=\"%@\"", self.name.text];
	[discription appendFormat:@"&body=\"%@\"", self.info.text];
	[discription appendFormat:@"&total_fee=\"%@\"", self.price.text];
	[discription appendFormat:@"&notify_url=\"%@\"", @"m.alipay.com"];
    [discription appendFormat:@"&service=\"%@\"", @"mobile.securitypay.pay"];
    [discription appendFormat:@"&payment_type=\"%@\"",@"1"];
	[discription appendFormat:@"&_input_charset=\"%@\"", @"utf-8"];
    [discription appendFormat:@"&it_b_pay=\"%@\"", @"30m"];
	[discription appendFormat:@"&show_url=\"%@\"",@"m.alipay.com"];
    [discription appendFormat:@"&return_url=\"%@\"", @"m.alipay.com"];

	return discription;
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

//wap回调函数
-(void)paymentResult:(NSString *)resultd
{
    //结果处理
#if __has_feature(objc_arc)
    AlixPayResult* result = [[AlixPayResult alloc] initWithString:resultd];
#else
    AlixPayResult* result = [[[AlixPayResult alloc] initWithString:resultd] autorelease];
#endif
	if (result)
    {
		
		if (result.statusCode == 9000)
        {
			/*
			 *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
			 */
            
            //交易成功
            NSString* key = @"签约帐户后获取到的支付宝公钥";
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder]; return NO;
    }
    return YES; 
}


@end
