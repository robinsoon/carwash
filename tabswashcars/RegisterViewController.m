//
//  RegisterViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-6-10.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()
//重点说明
//2014-5-25  Created By Robin
//定义可配置的数据参数（对于简单查询只需1组配置）
//命名规则： i 表示实例变量；P 表示 页面变量； s 表示 数据类型为String；
//初始化统一调用方法：initPage
@property (strong, nonatomic) NSString *iPs_PageName; //页面名称(用于标记参数组)
@property (strong, nonatomic) NSString *iPs_URL; //请求数据接口模板--地址
@property (strong, nonatomic) NSString *iPs_PAGE; //请求数据接口模板--页面
@property (strong, nonatomic) NSString *iPs_PAGE2; //请求数据接口模板--页面
@property (strong, nonatomic) NSString *iPs_PAGE3; //请求数据接口模板--页面
@property (strong, nonatomic) NSString *iPs_POST; //请求数据POST参数模板
@property (strong, nonatomic) NSString *iPs_POST2; //请求数据POST参数模板
@property (strong, nonatomic) NSString *iPs_POST3; //请求数据POST参数模板
@property (strong, nonatomic) NSString *iPs_POSTAction; //请求数据POST参数Action
@property (strong, nonatomic) NSString *iPs_POSTAction2; //请求数据POST参数Action2
@property (strong, nonatomic) NSString *iPs_POSTAction3; //请求数据POST参数Action3
//传入变化的参数组,参数数目根据接口需要而变化
@property (strong, nonatomic) NSString *iPs_POSTID; //请求数据POST参数ID1
@property (strong, nonatomic) NSString *iPs_POSTQueryOption; //请求数据POST参数ID2
@property (strong, nonatomic) NSString *iPs_POSTQueryRegion; //请求数据POST参数ID3
@end

@implementation RegisterViewController

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
    
    [self.btnSubmit successStyle];
    
    [self.btnSubmit addAwesomeIcon:FAIconKey beforeTitle:YES];
    
    self.scrollMain.contentSize = CGSizeMake(320,450);
    [self.scrollMain addSubview:self.subView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }
    
    //预设参数，自动填写用户名和密码，节省测试时间
    if(_isDebug){
        //_txtUserName.text = @"syb_ceshi";
        //_txtPassword.text = @"sunyubin";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

}

- (void) viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)keyboardWillShow:(NSNotification *)notification {}

//初始化页面变量组和参数
- (void)initPage
{
    //根据页面类型不同需要配置的部分
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _iPs_URL=delegate.iPs_URL; //请求数据接口模板--地址
    
    _iPs_PageName=@"用户注册"; //页面名称(用于标记页面参数配置)
    
    //注册请求 0
    _iPs_PAGE=@"user_app.php"; //请求数据接口模板--页面1
    _iPs_POST=@"act=%@&username=%@&password=%@&phone=%@&from_app=2"; //请求数据POST参数模板
    _iPs_POSTAction =@"register";   //注册
    
    //短信  1
    _iPs_PAGE2=@"messageAuthentication.php"; //请求数据接口模板--页面2
    _iPs_POST2=@"action=%@&phone=%@"; //请求数据POST参数模板
    _iPs_POSTAction2 =@"regist";//
    
    //验证手机号 2
    _iPs_PAGE3=@"user_app.php"; //请求数据接口模板--页面2
    _iPs_POST3=@"act=%@&phone=%@"; //请求数据POST参数模板
    _iPs_POSTAction3 =@"check_phone";//

    _iPs_POSTID=@"0"; //请求数据POST参数ID1
    _iPs_POSTQueryOption=@"0"; //请求数据POST参数ID2
    _iPs_POSTQueryRegion=@""; //请求数据POST参数ID3

    _RegAction = @"0";
    _btnSendCheckNum.enabled = false;
    _isDebug = false;
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
#pragma mark- button Event

- (IBAction)txtPhoneEdited:(id)sender {
    [sender resignFirstResponder];
    //验证用户手机
    
    _phone = _txtPhone.text;
    _txtUserName.text = _txtPhone.text;
    [_txtCheckNum becomeFirstResponder];
    
}
- (IBAction)txtPhoneChanged:(id)sender {
    _phone = _txtPhone.text;
    
    if ((_phone == nil)||([_phone isEqualToString:@""])) {
        return;
    }
    //校验手机号
    if([self validateMobile:_phone]){
        
        
        NSLog(@"接受用户手机号:%@",_phone);
        
        //请求服务器验证手机
        _RegAction = @"2";
        [self startRequest];
        
    }else{
        _phone = @"";
        //_txtPhone.text = @"";
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate showNotify:@"您的手机号不能通过校验。号码仅识别中国手机用户。" HoldTimes:2];
        _btnSendCheckNum.enabled = false;
        
    }
    
}

//由于数字键盘没有Return键，当点击界面其它元素自动释放焦点以隐藏键盘
- (void)touchesBegan: (NSSet *)touches withEvent:(UIEvent *)event
{
    // do the following for all textfields in your current view
    [self.txtPhone resignFirstResponder];
    [self txtPhoneChanged:_txtPhone];
    
}

- (IBAction)txtCheckedNum:(id)sender {
    [sender resignFirstResponder];
    
    NSString *strCheckNum = _txtCheckNum.text;
    NSString *strError;
    if (([strCheckNum isEqualToString:@""])||(strCheckNum==nil)) {
        //手机验证错误
        strError = @"手机未经过验证";
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate showNotify:strError HoldTimes:1];
        return;
    }
    
    if (![strCheckNum isEqualToString:_phoneCheckNum]) {
        //手机验证码错误
        strError = @"手机验证码错误";
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate showNotify:strError HoldTimes:2];

        return;
    }

    
    [_txtUserName becomeFirstResponder];
}


- (IBAction)txtUsernameEdited:(id)sender {
    [sender resignFirstResponder];
    [_txtPassword becomeFirstResponder];
}
- (IBAction)txtPasswordEdited:(id)sender {
    [sender resignFirstResponder];
    [_txtRepPass becomeFirstResponder];
}

- (IBAction)txtRepPasswordEdited:(id)sender {
    [sender resignFirstResponder];
    //[_btnSubmit becomeFirstResponder];
    //验证用户数据输人
    
    //提交注册
    [self btnSubmitClicked:_btnSubmit];
}


- (IBAction)btnSendCheckPhoneClicked:(id)sender {
    
    _RegAction = @"1";
    [self startRequest];
    
    _btnSendCheckNum.enabled = false;
    _txtCheckNum.enabled = true;
}

//用户注册信息
- (IBAction)btnSubmitClicked:(id)sender {

    NSString *strCheckInfo = [self CheckUserInput];
    if (![strCheckInfo isEqualToString:@""]) {
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate showNotify:strCheckInfo HoldTimes:2];
        return;
    }

    _RegAction = @"0"; //注册
    [self startRequest];
    
    //[self RegDone:_btnSubmit];
    
}

#pragma mark- Page Function and Event

- (IBAction)RegDone:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"用户取消注册");
        //构造消息
        _userID = @"";
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"isRegist",_userID, @"ID",_txtUserName.text, @"name",_txtPassword.text, @"password",_txtPhone.text, @"phone", nil];

        //传递消息
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"RegisterCompletionNotification"
         object:nil
         userInfo:dataDict];
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
    _username = _txtUserName.text;
    _password = _txtPassword.text;
    
    
    //_phoneCheckNum
    NSString *strCheckNum = _txtCheckNum.text;
    NSString *strError = @"";
    
    if (([_phone isEqualToString:@""])||(_phone==nil)) {
        //手机号错误
        strError = @"手机号错误";
        
        return strError;
    }
    
    if (![_password isEqualToString:_txtRepPass.text]) {
        //两次输入密码不一致
        strError = @"两次输入密码不一致";
        
        return strError;
    }


    if (([strCheckNum isEqualToString:@""])||(strCheckNum==nil)) {
        //手机验证错误
        strError = @"手机未经过验证";
        
        return strError;
    }
    
    if (![strCheckNum isEqualToString:_phoneCheckNum]) {
        //手机验证码错误
        strError = @"手机验证码错误";
        
        return strError;
    }
    
    
    if (([_username isEqualToString:@""])||(_username==nil)) {
        //用户名验证错误
        strError = @"用户名错误";
        
        return strError;
    }

    
    
    return  @"";

}

#pragma mark- Web Request Function
/*
 * 开始请求Web Service
 */
-(void)startRequest
{
    _isConnected = false;
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
    NSString *post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_username,_password,_phone];
    
    //@"user_app.php"; //请求数据接口模板--页面
    //@"act=%@&username=%@&password=%@&phone=%@&from_app=2";
    //@"register";   //注册
    
    //短信
    //@"messageAuthentication.php"; //请求数据接口模板--页面2
    //@"action=%@&phone=%@"; //请求数据POST参数模板
    //@"regist";//
    
    //验证手机号
    //@"user_app.php"; //请求数据接口模板--页面3
    //@"act=%@&phone=%@"; //请求数据POST参数模板
    //@"check_phone";//

    
    if([_RegAction isEqualToString:@"0"]){
        strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
        post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_username,_password,_phone];
    }else if([_RegAction isEqualToString:@"1"]){
        strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE2];
        post = [NSString stringWithFormat:_iPs_POST2,_iPs_POSTAction2,_phone];
    }else if([_RegAction isEqualToString:@"2"]){
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
    NSString *strPageMsg = @"";
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    @try{
    if([_RegAction isEqualToString:@"0"]){
        //注册
        //_PageReturn = [dict objectForKey:@"is_register"];
        NSNumber *resultCodeObj = [dict objectForKey:@"is_register"];
        if ([resultCodeObj intValue]==1) {
            //成功注册！
            NSString *strTitleMsg = [[NSString alloc] initWithFormat:@"您已成功注册！欢迎您，%@",_username];
            [delegate showNotify:strTitleMsg HoldTimes:2];
            
            //发送消息，更新信息
            self.listData = [dict objectForKey:@"user_info"];
            NSMutableDictionary*  userinf = [dict objectForKey:@"user_info"];
            
            _userID = [userinf objectForKey:@"user_id"];
            _username = [userinf objectForKey:@"user_name"];
            _phone = [userinf objectForKey:@"mobile_phone"];
            _usermoney = [[userinf objectForKey:@"user_money"] doubleValue];
            _userpoints = [[userinf objectForKey:@"pay_points" ]doubleValue];
            
            //NSNumber * num =[userinf objectForKey:@"user_id"];
            //[userinf objectForKey:@"email"];
            _isRegisted = true;
            _btnSendCheckNum.enabled = false;
            //跳转
            NSLog(@"注册成功 %@",_userID);
            
            [self dismissViewControllerAnimated:YES completion:^{
                //构造消息
                NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"isRegist",_userID, @"ID",_username, @"name",_txtPassword.text, @"password",_phone, @"phone",_usermoney,@"user_money",_userpoints,@"pay_points", nil];
                
                //传递消息
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"RegisterCompletionNotification"
                 object:nil
                 userInfo:dataDict];
            }];

            
        }else{
            //注册失败
            _isRegisted = false;
            _btnSendCheckNum.enabled = true;
            //strPageMsg = [dict objectForKey:@"err_msg"];
            NSNumber *resultCodeMsg = [dict objectForKey:@"err_msg"];

            NSString *strTitleMsg = [[NSString alloc] initWithFormat:@"注册失败"];
            
            if ([resultCodeMsg intValue]==0) {
                strTitleMsg = [[NSString alloc] initWithFormat:@"注册失败：用户名 %@ 已经注册",_username];
                
            }else if([resultCodeMsg intValue]==1) {
                strTitleMsg = [[NSString alloc] initWithFormat:@"注册失败：无效的用户名 %@ ",_username];
                
            }else if([resultCodeMsg intValue]==2) {
                strTitleMsg = [[NSString alloc] initWithFormat:@"注册失败：用户名 %@ 不允许注册",_username];
                
            }else if([resultCodeMsg intValue]==3) {
                strTitleMsg = @"注册遇到不可知异常";
            }
            
            NSLog(@"%@",strTitleMsg);
            [delegate showNotify:strTitleMsg HoldTimes:3];
        
        }

    }else if([_RegAction isEqualToString:@"1"]){
        //验证码
        
        _phoneCheckNum = [dict objectForKey:@"code"];
        _PageReturn = [dict objectForKey:@"state"];
        
        //要求用户输入验证码
        if ((_phoneCheckNum==nil)||([_phoneCheckNum isEqualToString:@""])) {
            NSLog(@"获取短信验证码错误！");
            [delegate showNotify:@"没有获取短信验证码！" HoldTimes:2];
            _btnSendCheckNum.enabled = true;
            //_txtCheckNum.enabled = false;
        }else{
            NSLog(@"手机验证码 %@",_phoneCheckNum);
            _btnSendCheckNum.enabled = false;
            _txtCheckNum.enabled = true;
        }

    }else if([_RegAction isEqualToString:@"2"]){
        //验证手机号
        //_PageReturn = [dict objectForKey:@"is_error"];
        NSNumber *resultCodeObj = [dict objectForKey:@"is_error"];
        strPageMsg = [dict objectForKey:@"msg"];
        
        if ([ resultCodeObj intValue]==0) {
            //成功！
            NSLog(@"手机通过校验 %@",_phone);
            if ([_txtUserName.text isEqualToString:@""]) {
                _txtUserName.text = _txtPhone.text;
            }
            _btnSendCheckNum.enabled = true;
            
        }else{
            //提示已注册
            NSLog(@"手机校验失败 %@",_phone);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您的手机号码无法注册"
                                                                message:strPageMsg
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
            [alertView show];
            _btnSendCheckNum.enabled = false;
            _txtCheckNum.enabled = false;
        }
        
    }else{
        
    }
    }@catch(NSException *exp1){
    
    }
}

@end
