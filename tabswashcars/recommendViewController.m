//
//  recommendViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-7-30.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "recommendViewController.h"
#import "UIButton+Bootstrap.h"

@interface recommendViewController ()
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

@property (strong, nonatomic) NSString *iPs_PAGE3; //请求数据接口模板--页面
@property (strong, nonatomic) NSString *iPs_POST3; //请求数据POST参数模板
@property (strong, nonatomic) NSString *iPs_POSTAction3; //请求数据POST参数Action
//传入变化的参数组,参数数目根据接口需要而变化
@property (strong, nonatomic) NSString *iPs_POSTID; //请求数据POST参数ID1
@property (strong, nonatomic) NSString *iPs_POSTQueryOption; //请求数据POST参数ID2
@property (strong, nonatomic) NSString *iPs_POSTQueryRegion; //请求数据POST参数ID3

//页面内部变量(由程序控制实际值)
@property (nonatomic) int iPageIndex;
@property (nonatomic) Boolean isConnected;

@end

@implementation recommendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initPage];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnRecommend warningStyle];
    
    [self.btnRecommend addAwesomeIcon:FAIconThumbsUp beforeTitle:YES];
    
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
    
    _iPs_PAGE=@"activity_app.php"; //请求数据接口模板--页面
    
    _iPs_POST=@"act=%@&user_id=%@&phone=%@&activity_id=%@"; //请求数据POST参数模板
    
    _iPs_POSTAction = @"promote_bonus";
    
    _iPs_POSTID=delegate.userid;
    
    _iPs_POSTQueryOption=@"2"; //请求数据POST参数ID2
    _iPs_POSTQueryRegion=@""; //请求数据POST参数ID3
    _recommended = @"";
    _activityID = @"1";
    
    //验证手机号 2
    _iPs_PAGE3=@"user_app.php"; //请求数据接口模板--页面2
    _iPs_POST3=@"act=%@&phone=%@"; //请求数据POST参数模板
    _iPs_POSTAction3 =@"check_phone";//

    
    //不随页面类型改变的部分
    _iPageIndex = 1;//初始化页面序号
    
    _CellBgColor =[UIColor colorWithRed:49/255.0 green:155/255.0 blue:205/255.0 alpha:0.15];
    
    if (([_iPs_POSTID isEqualToString:@""])||(_iPs_POSTID == nil)) {
        [delegate showNotify:@"参与此活动，请您先登录！" HoldTimes:2];
    }
    
    _smsContent = @"我已经安装了这个去洗车手机应用，可能对你有用。近期举办各种惠及车主的活动，下载注册去洗车即可获得2元红包，查看详情：www.quxiche.com";
    
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
- (IBAction)txtPhoneBeginEdit:(id)sender {
    
    if ([_txtPhone.text isEqualToString:@"手机号"]) {
        _txtPhone.text = @"";
    }
    
    
}
- (IBAction)txtPhoneDidEnd:(id)sender {
    [sender resignFirstResponder];
}

//由于数字键盘没有Return键，当点击界面其它元素自动释放焦点以隐藏键盘
- (void)touchesBegan: (NSSet *)touches withEvent:(UIEvent *)event
{
    // do the following for all textfields in your current view
    [self.txtPhone resignFirstResponder];
    [self txtPhoneChanged:_txtPhone];
    
}

- (IBAction)txtPhoneChanged:(id)sender {

    if ([_phone isEqualToString:_txtPhone.text ]) {
        //没有变化
        return;
    }else{
        
        _phone = _txtPhone.text;
    }

    if ((_phone == nil)||([_phone isEqualToString:@""])) {
        return;
    }
    
    if ([_phone isEqualToString:@"手机号"]) {
        _txtPhone.text = @"";
        return;
    }

    //校验手机号
    if([self validateMobile:_phone]){
        
        
        NSLog(@"接受用户手机号:%@",_phone);
        
    }else{
        _phone = @"";
        //_txtPhone.text = @"";
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate showNotify:@"您的手机号不能通过校验。号码仅识别中国手机用户。" HoldTimes:2];
        
    }
    
}

- (IBAction)btnRecommendClicked:(id)sender {
    //推荐功能
    NSString *strCheckInfo = [self CheckUserInput];
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if (![strCheckInfo isEqualToString:@""]) {
        
        [delegate showNotify:strCheckInfo HoldTimes:2];
        return;
    }
    
    if([_recommended isEqualToString: _phone]){
        strCheckInfo = [[NSString alloc] initWithFormat:@"您已经推荐过 %@ ，每人最多可推荐10人，请换一个号码。",_phone];

        [delegate showNotify:strCheckInfo HoldTimes:3];
        return;
    
    }

    //应该先验证推荐号码是否是已注册号码
    strCheckInfo = [[NSString alloc] initWithFormat:@"正在验证您推荐的号码 %@ 是否已注册，请稍候...",_phone];
    [delegate showNotify:strCheckInfo HoldTimes:2];
    
    _iPs_POSTQueryOption=@"2";
    [self startRequest];
    
    //直接发短信测试
    //NSArray * recipientList = [NSArray arrayWithObjects:_phone,nil];
    
    //先发短信再作记录申请奖励
    //[self sendSMS:_smsContent recipientList:recipientList];

    /*
     可发送短信，但无法使用内容模板，故不适用
    NSURL * urlStr = [NSURL URLWithString:@"sms://10000"];//后面为参数
    
    [[UIApplication sharedApplication]openURL:urlStr];
    */
}


- (IBAction)btnCloseClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"用户取消推荐");
        //传递消息
        /*[[NSNotificationCenter defaultCenter]
         postNotificationName:@"RegisterCompletionNotification"
         object:nil
         userInfo:dataDict];*/
    }];

    
}



- (BOOL)validateMobile:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


//校验用户的输入
- (NSString *)CheckUserInput{
    
    _phone = _txtPhone.text;
    
    
    //_phoneCheckNum

    NSString *strError = @"";
    
    if (([_phone isEqualToString:@""])||(_phone==nil)) {
        //手机号错误
        strError = @"手机号错误";
        
        return strError;
    }

    if(![self validateMobile:_phone]){
        strError = @"您的手机号不能通过校验。号码仅识别中国手机用户。";
        
        return strError;
    }
    
    return  @"";
    
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
    
    
    
    NSString *post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID,_phone,_activityID];
    
    if([_iPs_POSTQueryOption isEqualToString:@"0"]){
        //发送推荐人
        strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
        post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID,_phone,_activityID];
    }else if([_iPs_POSTQueryOption isEqualToString:@"2"]){
        //验证是否注册
        strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE3];
        post = [NSString stringWithFormat:_iPs_POST3,_iPs_POSTAction3,_phone];
    }else{
        
    }

    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
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
        
        if([_iPs_POSTQueryOption isEqualToString:@"2"]){
            //验证是否注册
            //验证手机号

            if ([ isError intValue]==0) {
                //成功！
                NSLog(@"推荐手机通过校验 %@ ,打开推荐短信",_phone);
                
                
                NSArray * recipientList = [NSArray arrayWithObjects:_phone,nil];
                
                //先发短信再作记录申请奖励
                [self sendSMS:_smsContent recipientList:recipientList];
                
                
                return;
            }else{
                //提示已注册
                NSLog(@"手机校验失败 %@ 已注册",_phone);
                NSString *strPageMsg = [res objectForKey:@"msg"];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您推荐的手机号码无法注册"
                                                                    message:strPageMsg
                                                                   delegate:self
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
                _txtPhone.text = @"手机号";
                return;
            }

        }else if([_iPs_POSTQueryOption isEqualToString:@"0"]){
            //发送推荐人的号码到后台，参加活动
            
            
        }else{
            
        }

        if ([isError integerValue]==0) {
            //有效
            _recommended = _phone;
            NSString * RESMsg = [res objectForKey:@"result"];
            NSLog(@" 有效：%@" , RESMsg);
            //[delegate showNotify:@"您已成功推荐一位好友，该好友注册后您将得到奖励！红包可用于抵扣订单付款。" HoldTimes:2];
            [self alertWithTitle:@"推荐好友提示" msg:@"您已成功推荐一位好友，该好友注册后您将得到奖励！红包可用于抵扣订单付款。"];
            _txtPhone.text = @"手机号";
            /*
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
            }*/
            
        }else if ([isError integerValue]==1){
            //无效
            
            NSString * ErrorMsg = [res objectForKey:@"err_msg"];
            NSLog(@"无效： %@" , ErrorMsg);
            [delegate showNotify:ErrorMsg HoldTimes:3];

        }
        
        
        
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

#pragma mark - Send SMS
//内容，收件人列表
- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
    if([MFMessageComposeViewController canSendText])
        
    {
        NSLog(@"向手机好友%@，发送推荐短信。", _phone);
        /*
        controller.recipients = [NSArray arrayWithObject:@"15988888888"];
        controller.body = @"请直接将此条认证短信发送给我们，以完成手机安全绑定。(9qzkd27953ma)";
        controller.messageComposeDelegate = self;
        */
        
        controller.recipients = recipients; //收信人<列表，支持群发>
        
        controller.body = bodyOfMessage;

        controller.messageComposeDelegate = self; //代理，处理发送结果
        
        //[self presentModalViewController:controller animated:NO];//警告已过时的方式

        [self presentViewController: controller animated:YES completion:^(void) {
            NSLog(@"短信界面：%@ 内容：%@",_phone,bodyOfMessage);
            }];
        
        //[[[[controller viewControllers] lastObject] navigationItem] setTitle:@"推荐短信"];//修改短信界面标题
        
    }else{
        [self alertWithTitle:@"提示信息" msg:@"设备没有短信功能"];
    }
    
}

// 处理发送完的响应结果
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    
    

    switch ( result ) {
            
        case MessageComposeResultCancelled:
            NSLog(@"发送短信取消");
            [self alertWithTitle:@"提示信息" msg:@"发送已取消"];
            break;
        case MessageComposeResultFailed:// send failed
            [self alertWithTitle:@"提示信息" msg:@"发送推荐短信失败"];
            
            break;
        case MessageComposeResultSent:
            //[self alertWithTitle:@"提示信息" msg:@"发送推荐短信成功"];
            [self sendSMSCompletion];
            break;
        default:
            break;
    }
    //[controller dismissModalViewControllerAnimated:NO];
    
    [controller dismissViewControllerAnimated:NO
     completion:^(void){
     // Code
     }];
}

- (void) sendSMSCompletion{
    //发送短信成功,提交后台记录推荐人
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    [delegate showNotify:@"短信已发送成功！每人可推荐10个好友注册，推荐的好友注册后您可得到3元红包奖励。" HoldTimes:2];
    
    _iPs_POSTQueryOption = @"0";
    [self startRequest];
    
}

- (void) alertWithTitle:(NSString *)title msg:(NSString *)msg {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];

    [alert show];
}

@end
