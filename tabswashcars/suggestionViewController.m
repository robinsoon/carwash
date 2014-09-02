//
//  suggestionViewController.m
//  washcarsbusiness
//
//  Created by Robinpad on 14-8-22.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "suggestionViewController.h"

@interface suggestionViewController ()
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

//传入变化的参数组,参数数目根据接口需要而变化
@property (strong, nonatomic) NSString *iPs_POSTID; //请求数据POST参数ID1
@property (strong, nonatomic) NSString *iPs_POSTQueryOption; //请求数据POST参数ID2
@property (strong, nonatomic) NSString *iPs_POSTQueryRegion; //请求数据POST参数ID3

//页面内部变量(由程序控制实际值)
@property (nonatomic) int iPageIndex;
@property (nonatomic) Boolean isConnected;

@end

@implementation suggestionViewController

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
    _wordslimit = 320;
    
    _txtContent.layer.cornerRadius = 6;
    _txtContent.layer.masksToBounds = YES;
    _txtContent.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _txtContent.layer.borderWidth = 1;
    _txtContent.delegate = self ;
    _itemmode = @"改进建议：\n\n  衷心的感谢您对我们公司的信任和支持。为了不断提高我公司产品和服务质量，完善我们的工作，为了给您提供更加优质的产品及服务，在致以我们诚挚问候的同时，请您在百忙之中写下意见反馈。我们热切的期盼着您对我们的工作提出宝贵的意见和建议，我们将不胜感激，谢谢！\n\n产品服务热线：400 88 23450";
    _txtContent.text = _itemmode;
    _txtlength.text = [[NSString alloc]initWithFormat:@"%d/%d",[_itemmode length], _wordslimit];

    self.myscrollView.contentSize = CGSizeMake(320,580);
    //[self.myscrollView addSubview:self.subView];

    //标记出版本号
    self.title = [NSString stringWithFormat:@"去洗车 v%@ 改进建议", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]];
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
        //[self startRequest];
    }
}

//初始化页面变量组和参数
- (void)initPage
{
    //根据页面类型不同需要配置的部分
    _iPs_PageName=@"建议"; //页面名称(用于标记页面参数配置)
    //_iPs_URL=@"http://114.112.73.223:8080/"; //请求数据接口模板--地址
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _iPs_URL=delegate.iPs_URL; //请求数据接口模板--地址
    
    _iPs_PAGE=@"user_app.php"; //请求数据接口模板--页面

    _iPs_POST = @"act=%@&user_id=%@&content=%@&user_phone=%@&user_pos=%@&version=%@&from_app=2"; //请求数据POST参数模板
    
    _iPs_POSTAction = @"add_app_feedback";  //反馈建议
    
    _iPs_POSTID=delegate.userid;
    
    _iPs_POSTQueryOption=@"0"; //请求数据POST参数ID2
    _iPs_POSTQueryRegion=@""; //请求数据POST参数ID3
    
    
    //不随页面类型改变的部分
    _iPageIndex = 1;//初始化页面序号
    _wordslimit = 320;
    if (([_iPs_POSTID isEqualToString:@""])||(_iPs_POSTID == nil)) {
        [delegate showNotify:@"感谢您的支持，请您先登录再填写建议！" HoldTimes:2];
    }
    
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

- (IBAction)txtPhoneDidEnd:(id)sender {
    [sender resignFirstResponder];
    [_txtposition becomeFirstResponder];
}

- (IBAction)txtPhoneChanged:(id)sender {
    _isconnection = _txtconnection.text;
}

- (IBAction)txtPostionDidEnd:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)txtPostionChanged:(id)sender{
    _isposition = _txtposition.text;
}


- (IBAction)btnSubmitClicked:(id)sender {
    _itemcontent = _txtContent.text;
    _isconnection = _txtconnection.text;
    _isposition = _txtposition.text;
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];

    //校验输入
    if (([_itemcontent isEqualToString:@""])||(_itemcontent==nil)) {
        //内容错误
        NSString *lsMsg = [[NSString alloc]initWithFormat:@"请填写建议"];
        [delegate showNotify:lsMsg HoldTimes:2.0];
        return;
    }
    
    if ([_itemcontent isEqualToString: _itemmode]){
        //内容错误
        _txtContent.text = @"";
        NSString *lsMsg = [[NSString alloc]initWithFormat:@"请填写建议"];
        [delegate showNotify:lsMsg HoldTimes:2.0];
        return;
    }

    
    
    if (([_isconnection isEqualToString:@""])||(_isconnection==nil)) {
        //手机号错误
        NSString *lsMsg = [[NSString alloc]initWithFormat:@"请填写您的联系方式：电话或手机号码"];
        [delegate showNotify:lsMsg HoldTimes:2.0];
        return;
    }
    
    if (([_isposition isEqualToString:@""])||(_isposition==nil)) {
        //验证错误
        NSString *lsMsg = [[NSString alloc]initWithFormat:@"请填写您的称呼或姓名"];
        [delegate showNotify:lsMsg HoldTimes:2.0];
        return;
    }
    
    [self startRequest];
}

//由于数字键盘没有Return键，当点击界面其它元素自动释放焦点以隐藏键盘
- (void)touchesBegan: (NSSet *)touches withEvent:(UIEvent *)event
{
    // do the following for all textfields in your current view
    [self.txtContent resignFirstResponder];
    [self.txtconnection resignFirstResponder];
    [self.txtposition resignFirstResponder];
    //[self txtInputChanged:_txtuserinput];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ((1 == range.length)&&([textView.text length] >=1)){//按下删除键
        _txtlength.text = [[NSString alloc]initWithFormat:@"%d/%d",[textView.text length] - 1, _wordslimit];
        return YES;
    }
    
    if ([text isEqualToString:@"\n"]) {//按下return键
        //这里隐藏键盘，不做任何处理
        [textView resignFirstResponder];
        //[_txtconnection becomeFirstResponder];
        return YES;
    }else {
        if ([textView.text length] <= _wordslimit) {//判断字符个数
            _txtlength.text = [[NSString alloc]initWithFormat:@"%d/%d",[textView.text length], _wordslimit];
            return YES;
        }else{
            
            textView.text = [textView.text substringToIndex:_wordslimit+1];
            _txtlength.text = [[NSString alloc]initWithFormat:@"%d/%d",[textView.text length], _wordslimit];
            //这里隐藏键盘，不做任何处理
            [textView resignFirstResponder];
            return NO;
        }
    }
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"inputChanged：%@", textView.text);
    _itemcontent = textView.text;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:_itemmode]) {
        textView.text = @"";
        _itemcontent =  @"";
        _txtlength.text = [[NSString alloc]initWithFormat:@"%d/%d",0, _wordslimit];
    }
    
}

#pragma mark- POST Data 页面请求数据
/*
 * 开始请求Web Service
 */
-(void)startRequest
{
    _isConnected = false;
    
    
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
    
    //取得版本号
    //标记出版本号

    NSString *strVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    NSString *post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID, _itemcontent , _isconnection, _isposition,strVersion];

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
        //转到拖拉翻页[self setPageNext]; //下次请求换页
        
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
        
        NSNumber *resultCodeObj = [res objectForKey:@"is_err"];
        if (resultCodeObj==nil) {
            //无法处理的结果
            resultCodeObj = [[NSNumber alloc] initWithInt:1];
        }
        
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        
        if ([resultCodeObj integerValue] ==0){
            [delegate showNotify:@"提交建议成功！" HoldTimes:1.0];
            
            _txtContent.text = @"";
            _txtlength.text = @"";
            _txtposition.text = @"";
            _txtContent.text = @"";
            
            
            [self dismissViewControllerAnimated:NO completion:^{
                NSLog(@"提交建议成功");
                /*//传递消息
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"ReplyCompletionNotification"
                 object:nil
                 userInfo:nil];*/
            }];
        } else {
            _iPageIndex = 0;
            NSString *Errormsg = [res objectForKey:@"err_msg"];
            //NSString *isMsg = [res objectForKey:@"is_login"];
            
            NSLog(@"数据请求错误：%@",Errormsg);
            
            NSString *lsMsg = [[NSString alloc]initWithFormat:@"无法提交建议\n%@", Errormsg];
            
            
            [delegate showNotify:lsMsg HoldTimes:2.5];
            
            
        }
        
    }@catch(NSException *exp1){
        
    }
    
    
    
}


@end
