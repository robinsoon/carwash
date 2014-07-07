//
//  AliPayViewController.m
//  AlipaySdkDemo
//
//  Created by Robinpad on 14-5-20.
//  Copyright (c) 2014年 Alipay. All rights reserved.
//

#import "AliPayViewController.h"
#import "PartnerConfig.h"
#import "DataSigner.h"
#import "AlixPayResult.h"
#import "DataVerifier.h"
#import "AlixPayOrder.h"
#import "UIButton+Bootstrap.h"
#import "bonusViewCell.h"
#import "couponsTableViewController.h"

@implementation Product
@synthesize price = _price;
@synthesize subject = _subject;
@synthesize body = _body;
@synthesize orderId = _orderId;

@end

//为了让滚动视图能够接收触摸事件，以隐藏键盘，做如下扩展
@implementation UIScrollView (UITouchEvent)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

@end


@interface AliPayViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
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

@implementation AliPayViewController
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
    [self.btnPay warningStyle];
    [self.btnPay addAwesomeIcon:FAIconMoney beforeTitle:YES];
    if (_iPs_PageName==nil) {
        [self initPage];
    }

    _result = @selector(paymentResult:);
    //[self generateData];
	// Do any additional setup after loading the view, typically from a nib.
    _selectedbonus = -1;
    _usedbonus = 0;
    _usedbonusid = @"";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.detailscrollview.contentSize = CGSizeMake(320,600);//如需变长可设定800
    
    [self.detailscrollview addSubview:self.subViewPrice];
    [self.detailscrollview addSubview:self.subViewPay];
    

    self.lbID.text = _OrderSn;//self.itemid;
    self.lbName.text = self.itemname;
    self.lbPrice.text = self.itemTotal;
    self.lbDescription.text = self.itemdetail;

    if ([_PayAction isEqualToString:@"继续支付"]) {
        //继续付款逻辑
        NSLog(@"付款进入继续支付流程");
        
        _lbPayContinue.text = [[NSString alloc]initWithFormat:@"订单总金额：%@元",_itemTotal];
        
        //将应付金额修改为剩余金额
        _itemTotal = _itemPay;
        self.lbPrice.text = self.itemTotal;
        
    }


    //用户登录的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginCompletion:)
                                                 name:@"LoginCompletionNotification"
                                               object:nil];
    
    //支付回调完成的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(payCompletion:)
                                                 name:@"UserPayCompletionNotification"
                                               object:nil];

    
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    if (false==delegate.isLogin) {
        NSLog(@"转到登录页面");
        
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"userLoginViewController"];
        
        _lbUsername.text = @"";
        _lbUserInfo.text = @"查看账户信息，请先登录";
        _usermoney = 0;
        _userpoints = 0;
        _txtMoney.text = [[NSString alloc]initWithFormat:@"余额 %1.2f 元", _usermoney];
        _txtPoints.text = [[NSString alloc]initWithFormat:@"积分 %1.0f", _userpoints];
        
        loginViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:loginViewController animated:YES completion:^{
            NSLog(@"打开登录界面");
        }];
        
    }else if(![delegate.username isEqual:@""]){
        _userid = delegate.userid;
        _username = delegate.username;
        _usermoney = delegate.usermoney;
        _userpoints = delegate.userpoints;
        
        NSString * userinfo = [[NSString alloc]initWithFormat:@"   余额：%1.2f 元   积分：%1.0f", _usermoney,_userpoints];
        _lbUserInfo.text = userinfo;
        _lbUsername.text = _username;
        
        _txtMoney.text = [[NSString alloc]initWithFormat:@"余额 %1.2f 元", _usermoney];
        _txtPoints.text = [[NSString alloc]initWithFormat:@"积分 %1.0f", _userpoints];

    }
    

    
    //初始化付款额
    [self initpay];
    _products = _listData;
    //载入红包
    [self.tableView reloadData];
    
    
    /*
    //NSDictionary* dict_goods = [_dict_orderdetails objectForKey:@"order_goods"];
    NSDictionary* dict_order = [_dict_orderdetails objectForKey:@"order_info"];
    NSDictionary* dict_paylist = [_dict_orderdetails objectForKey:@"order_select"]; //支付方式选择
    NSDictionary* dict_payname = [_dict_orderdetails objectForKey:@"order_pay"];    //支付方式类型
    
    
    NSNumber *isOrderID = [dict_order objectForKey:@"order_id"];
    _OrderSn = [dict_order objectForKey:@"order_sn"];
    
    */
    
    /*
    _OrderID = [[NSString alloc]initWithFormat:@"%@", isOrderID ];
    _Ordersn = [dict_order objectForKey:@"order_sn"];
    _OrderStatus=[dict_order objectForKey:@"order_status"];
    _PayStatus=[dict_order objectForKey:@"pay_status"];
    
    _itemAmount =[dict_order objectForKey:@"order_amount"];
    */
    
}

//页面即将展示
-(void) viewWillAppear:(BOOL)animated{
    //如果页面没有初始化则先用初始值
    if (_iPs_PageName==nil) {
        [self initPage];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

//初始化页面变量组和参数
- (void)initPage
{
    //根据页面类型不同需要配置的部分
    _iPs_PageName=@"支付"; //页面名称(用于标记页面参数配置)
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _iPs_URL=delegate.iPs_URL; //请求数据接口模板--地址
    _iPs_PAGE=@"flow_app.php"; //请求数据接口模板--页面1
    _iPs_POST=@"act=%@&user_id=%@&order_id=%@&pay_id=%@&pay_name=%@&surplus=%@&integral=%@&bonus=%@"; //请求数据POST参数模板
    _iPs_POSTAction =@"done_order";   //支付订单
    //_iPs_POSTID=@"2692"; //请求数据POST参数ID1
    _iPs_POSTID=delegate.userid;
    
    _userid =_iPs_POSTID;
    
    _iPs_POSTQueryOption=@"0"; //请求数据POST参数// 0=支付宝, 1=财付通,2=银联支付
    _iPs_POSTQueryRegion=@""; //请求数据POST参数ID3
    

    //不随页面类型改变的部分
    _iPageIndex = 1;//初始化页面序号
    _CellBgColor =[UIColor colorWithRed:49/255.0 green:155/255.0 blue:205/255.0 alpha:0.15];
}


- (void)keyboardWillShow:(NSNotification *)notification {
    // create custom buttom
    /*
     UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
     doneButton.frame = CGRectMake(0, 163, 106, 53);
     doneButton.adjustsImageWhenHighlighted = NO;
     [doneButton setImage:[UIImage imageNamed:@"DoneUp.png"] forState:UIControlStateNormal];
     [doneButton setImage:[UIImage imageNamed:@"DoneDown.png"] forState:UIControlStateHighlighted];
     [doneButton addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventTouchUpInside];
     
     // locate keyboard view
     UIWindow *tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
     UIView *keyboard;
     for (int i = 0; i < [tempWindow.subviews count]; i++) {
     keyboard = [tempWindow.subviews objectAtIndex:i];
     // keyboard view found; add the custom button to it
     if ([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES) {
     [keyboard addSubview:doneButton];
     }
     }
     */
}

//登录返回
-(void)loginCompletion:(NSNotification*)notification {
    
    NSDictionary *theData = [notification userInfo];
    _username = [theData objectForKey:@"name"];
    _userid = [theData objectForKey:@"ID"];
    NSLog(@"登录页面返回,username = %@", _username);
    NSString *lsLogin = [theData objectForKey:@"isLogin"];
    
    
    //页面显示用户登录信息
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //if (false==delegate.isLogin) {
    if ([lsLogin isEqual:@"0"]) {
        _lbUsername.text = _username;
        _lbUserInfo.text = @"    未登录，部分功能不可用";
        
    }else{
        _userid = delegate.userid;
        _username = delegate.username;
        _usermoney = delegate.usermoney;
        _userpoints = delegate.userpoints;
        
        _lbUsername.text = _username;
        NSString * userinfo = [[NSString alloc]initWithFormat:@"   余额：%1.2f   积分：%1.0f", _usermoney,_userpoints];
        _lbUserInfo.text = userinfo;
        
    }
    
    
}

//支付完成
-(void)payCompletion:(NSNotification*)notification {
    
    NSDictionary *theData = [notification userInfo];
    //_username = [theData objectForKey:@"name"];
    //_userid = [theData objectForKey:@"ID"];
    
    NSString *lsPayCompletion = [theData objectForKey:@"isPayCompletion"];

    //页面显示用户登录信息
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];

    if ([lsPayCompletion isEqual:@"1"]) {
        //成功
        NSLog(@"支付页面返回。交易成功");
        //提示付款成功，并跳转到密码券
        NSString *lsNotifyTitle = [[NSString alloc]initWithFormat:@"您已成功支付1个订单,订单号:%@",_OrderSn ];
        
        [delegate showNotify:lsNotifyTitle HoldTimes:3];
        
        //返回到前一个界面
        //[self.navigationController popViewControllerAnimated:YES]; //PUSH
        
        //传递消息
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"OrderRefreshNotification"
         object:nil
         userInfo:nil];
        
        //跳转到消费券列表(已付款)
        
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:_itemname, @"name", _OrderID,@"ID", nil];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"OrderCompletionNotification"
         object:nil
         userInfo:dataDict];
        
        //重要：主动调用 Segue 呈现页面
        [self performSegueWithIdentifier:@"couponslist" sender:self];
        
    }else{
        //失败
        NSLog(@"支付页面返回。支付未成功");
        NSString *lsNotifyTitle = [[NSString alloc]initWithFormat:@"支付未完成,请尝试其它支付方式,订单号:%@",_OrderSn ];
        
        [delegate showNotify:lsNotifyTitle HoldTimes:5];
    }
}

//修改数量更新价格
- (IBAction)lbUsedMoneyChanged:(id)sender {
    //界面的TextField取消键盘事件传递影响了 余额变更，需要特别处理。
    if (_usedmoney == [self.lbUsedMoney.text doubleValue]) {
        return;
    }
    
    double icount = 0;
    double iPrice = 0;
    double iTotal = 0;
    icount = [_lbUsedMoney.text doubleValue];
    if (icount>0) {
        
        self.btnSkipUserMoney.value = icount;
        iPrice = [_lbPrice.text doubleValue];
        
        iTotal =  iPrice - icount;
        if ((iTotal >= 0)&&(icount<= _usedmoneylimit)) {
            _lbPayMoney.text = [[NSString alloc] initWithFormat:@"%1.2f",iTotal];
            _usedmoney = icount;
        }else{
            //用户输入了错误的数字
            self.btnSkipUserMoney.value = 0;
            self.lbUsedMoney.text = @"0";
            _lbPayMoney.text = _lbPrice.text; ///减余额
            _usedmoney = 0;
        }
        
    }else{
        //重置为0
        
        self.btnSkipUserMoney.value = 0;
        self.lbUsedMoney.text = @"0";
        _lbPayMoney.text = _lbPrice.text; ///减余额
        _usedmoney = 0;
    }
    
    //触发计算总的付款金额事件
    [self calculatepay];
    
    
}

- (IBAction)btnSkipUserMoneyChanged:(id)sender
{
    
    NSString *strBuy = [[NSString alloc] initWithFormat:@"%1.2f",self.btnSkipUserMoney.value ];
    
    self.lbUsedMoney.text=strBuy;
    [self lbUsedMoneyChanged:_lbUsedMoney];
}

//修改数量
- (IBAction)lbUsedMoneyDidEnd:(id)sender {
    
    [sender resignFirstResponder];
}

//由于数字键盘没有Return键，当点击界面其它元素自动释放焦点以隐藏键盘
- (void)touchesBegan: (NSSet *)touches withEvent:(UIEvent *)event
{
    // do the following for all textfields in your current view
    [self.lbUsedMoney resignFirstResponder];
    [self lbUsedMoneyChanged:_lbUsedMoney];
    
}



- (IBAction)selectPointChanged:(id)sender {
    if (_selectPoints.isOn) {
        //使用积分
        //_usedpoints = _pointsinorder;
        if(_userpoints < _usedpointslimit){
            _usedpointslimit = _userpoints;
        }
            
        _usedpoints = _usedpointslimit;
        
    }else{
        //关闭积分
        _usedpoints = 0;
        
    }
    //触发修改
    [self calculatepay];
}

//是否使用余额支付
- (IBAction)selectMoneyChanged:(id)sender {
    if (_selectUserMoney.isOn) {
        //使用余额
        
        
        _usedmoney = _totalpaylimit - _totalpay - _usedpoints/100 - _usedbonus;
        
        //取值并校验
        //double 类型精度问题，不用 0
        if (_usedmoney>0.001) {
            _lbUsedMoney.text = [[NSString alloc]initWithFormat:@"%1.2f",_usedmoney];
            _btnSkipUserMoney.value = _usedmoney;
            
        }else{
            _usedmoney = 0;
            _lbUsedMoney.text = @"0";
            _btnSkipUserMoney.value = 0;
        }

        
        _lbUsedMoney.enabled = true;
        _btnSkipUserMoney.enabled = true;
        
        

        
    }else{
        //关闭余额调节
        _lbUsedMoney.text = @"0";
        _btnSkipUserMoney.value = 0;
        _lbUsedMoney.enabled = false;
        _btnSkipUserMoney.enabled = false;
    
        _usedmoney = 0;
    }
    //触发修改
    [self calculatepay];
}


- (IBAction)selectPayChanged:(id)sender {
    
    if (_selectAlipay.isOn) {
        //使用支付宝
        
        
    }else{
        //关闭支付宝支付
        //_totalpay = 0;
        
    }
    //触发修改
    [self calculatepay];
}

//计算金额的逻辑
- (void)calculatepay{
    
    
    _totalpay = _totalpaylimit - _usedmoney - _usedpoints/100 - _usedbonus;
    
    if((_totalpay<0)&&(_usedmoney>0)){
        //如果是余额超付，则改回原值
        _usedmoney = _totalpaylimit - _usedpoints/100 - _usedbonus;
        _lbUsedMoney.text = [[NSString alloc]initWithFormat:@"%1.2f",_usedmoney];
        _btnSkipUserMoney.value = _usedmoney;
    }
    
    //取值并校验
    //double 类型精度问题，不用 0
    if (_totalpay>0.001) {
        _lbPayMoney.text = [[NSString alloc]initWithFormat:@"%1.2f",_totalpay];
        _selectAlipay.on = true;
    }else{
        _totalpay = 0;
        _lbPayMoney.text = @"0";
        _selectAlipay.on = false;
    }
    
    
}

//计算金额的逻辑 - 红包有增加抵扣金额，单独处理
- (void)calculatepay_bonus{
    

    _totalpay = _totalpaylimit - _usedmoney - _usedpoints/100 - _usedbonus;
    
    //红包足够支付的情况
    if(_usedbonus >= _totalpaylimit){
        //抵扣整单
        _selectPoints.on = false;
        _selectUserMoney.on = false;
        _usedmoney = 0;
        _usedpoints = 0;
        _usedbonus = _totalpaylimit;
    }else if((_usedbonus  > 0 )&&(_totalpay<=0))
    {
        //红包部分能够支付则优先抵扣支付和余额
        if ((_usedmoney>0)&&(_selectUserMoney.isOn)) {
            //抵消余额
            _usedmoney = _totalpaylimit - _usedbonus - _usedpoints/100;
            _lbUsedMoney.text = [[NSString alloc]initWithFormat:@"%1.2f",_usedmoney];
        }else if((_usedpoints>0)&&(_selectPoints.isOn)){
            //抵消积分
            _usedpoints = (_totalpaylimit - _usedbonus)*100;
            _lbUserPoints.text = [[NSString alloc]initWithFormat:@"可用%1.0f积分抵用%1.2f元",_usedpoints, _usedpoints/100];
        }
        
    }else if(( _usedbonus == 0)&&(_usedmoney < _usedmoneylimit)&&(_selectUserMoney.isOn))
    {
        //如果是用户调节余额，则不必重算覆盖用户的修改

        
        //用户取消了红包，应该先增加余额再增加支付金额
        _usedmoney = _totalpaylimit - _usedpoints/100 - _usedbonus;
        if(_usedmoney>_usedmoneylimit){_usedmoney=_usedmoneylimit;}
        
        _lbUsedMoney.text =[[NSString alloc]initWithFormat:@"%1.2f",_usedmoney];
        _totalpay = _totalpaylimit - _usedmoney - _usedpoints/100 - _usedbonus;
        
    
    }
    //取值并校验
    //double 类型精度问题，不用 0
    if (_totalpay>0.001) {
        _lbPayMoney.text = [[NSString alloc]initWithFormat:@"%1.2f",_totalpay];
        _selectAlipay.on = true;
    }else{
        _totalpay = 0;
        _lbPayMoney.text = @"0";
        _selectAlipay.on = false;
    }


}

//初始化时计算金额的逻辑
- (void)initpay{
    
    //取值并校验
    _totalpaylimit = [_itemTotal doubleValue];

    if (_dict_orderdetails == nil) {
        //没有正确取得订单信息，默认初始化
        if (_usermoney>_totalpaylimit){
            _usedmoneylimit = _totalpaylimit;
        }else{
            _usedmoneylimit = _usermoney;
        }
        
        _btnSkipUserMoney.maximumValue = _usedmoneylimit;
        
        return;
    }
    
    //解析订单明细：
    //NSDictionary* dict_order = [_dict_orderdetails objectForKey:@"order_info"];
    NSDictionary* dict_paylist = [_dict_orderdetails objectForKey:@"order_select"]; //支付方式选择
    //NSArray* arr_payname = [dict_paylist objectForKey:@"order_pay"];    //支付方式类型
    
    //余额、积分信息等
    NSNumber *lsValue = 0;
    _usedmoney = 0;
    _usedpoints = 0;
    _usedbonus = 0;
    
    lsValue = [dict_paylist objectForKey:@"allow_use_integral"];
    if ([lsValue intValue] == 1) {
        //积分
        _usedpointslimit = [[dict_paylist objectForKey:@"order_max_integral"]integerValue];
        
        double  your_integral= [[dict_paylist objectForKey:@"your_integral"]integerValue];
        
        _userpoints = your_integral;
        
        if (_usedpointslimit > your_integral) {
            _usedpointslimit = your_integral;
        }
        ////////
        _usedpoints = _usedpointslimit;
        _selectPoints.on = true;
        _selectPoints.enabled = true;
    }else{
        _usedpointslimit = 0;
        _usedpoints = 0;
        _selectPoints.on = false;
        _selectPoints.enabled = false;
    }
    
    //开关标记 0 不可用; 1 可用;
    lsValue = [dict_paylist objectForKey:@"allow_use_surplus"];
    if ([lsValue intValue] == 1) {
        //余额
        
        NSString *strMoney = [dict_paylist objectForKey:@"your_surplus"];
        _usedmoneylimit = [strMoney doubleValue];
        _usermoney = _usedmoneylimit;
        
        //对余额单独处理，去掉double过长的小数位
        
        _selectUserMoney.on = true;
        _selectUserMoney.enabled = true;
    }else{
        _usedmoneylimit = 0;
        _selectUserMoney.on = false;
        _selectUserMoney.enabled = false;
        _lbUsedMoney.text = @"0";
        _usedmoney = 0;
    }

    lsValue = [dict_paylist objectForKey:@"allow_use_bonus"];
    if ([lsValue intValue] == 1) {
        //红包--取决于列表
        //_usedbonuslimit = [[dict_paylist objectForKey:@"your_integral"]integerValue];
    }else{
        _usedbonuslimit = 0;
        //没有红包
    }

    //红包列表
    _listData = [dict_paylist objectForKey:@"bonus_list"];
    if (_listData.count >0){
        //存在红包
        
    }else{
        //没有红包
        _usedbonuslimit = 0;
        _usedbonus = 0;
        //添加一条数据
        //NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"bonus_id", @"0", @"type_id", @"0", @"type_money", @"没有红包", @"type_name",nil];
        //[_listData addObject:data];
        //没有红包不显示列表
        _tableView.hidden = true;
        //CGContextRef startPath = UIGraphicsGetCurrentContext();
        //CGRect  frame = _tableView.frame;
        
        //位置向上偏移
        CGPoint subviewPoint = _subViewPay.center;
        
        subviewPoint.y = subviewPoint.y - 117;
        
        _subViewPay.center = subviewPoint;
        

    }
    
    if ([_PayAction isEqualToString:@"继续支付"]) {
        //禁用积分、余额、红包
        _usedpointslimit = 0;
        _usedmoneylimit = 0;
        _usedbonuslimit = 0;
        
        _usedbonus = 0;
        _usedmoney = 0;
        _usedpoints = 0;
        
        _selectPoints.on = false;
        _selectUserMoney.on = false;
        _tableView.userInteractionEnabled = false;
        
    }
    
    //设置限制：可用积分、可用余额、支付上限
    _totalpaylimit = [_itemTotal doubleValue];
    
    //在用户 可用的数额 和 订单金额 之间取最小值
    if (_usedmoneylimit>_totalpaylimit) {
        _usedmoneylimit = _totalpaylimit;
    }
    
    //积分不可调节
    if (_usedpointslimit >_totalpaylimit*100) {
        _usedpointslimit = _totalpaylimit*100;
        _usedpoints =_usedpointslimit;
    }else{
    
    }
    
    //红包限制一个，但不限制金额
    if (_usedbonuslimit>_totalpaylimit) {
        _usedbonuslimit = _totalpaylimit;
    }
    
    _btnSkipUserMoney.maximumValue = _usedmoneylimit;
    
    if (_usedpointslimit > 0) {
        _lbUserPoints.text = [[NSString alloc]initWithFormat:@"可用%1.0f积分抵用%1.2f元",_usedpoints, _usedpoints/100];
    }else{
        _lbUserPoints.text = @"本单不可使用积分抵扣";
    }

    //控制余额初始值
    if (_usedmoneylimit > 0) {
        //考虑积分的抵扣
        _usedmoney = _totalpaylimit - _usedpoints/100;
        if (_usedmoney>_usedmoneylimit) {
            _usedmoney = _usedmoneylimit;
        }
        
        _lbUsedMoney.text = [[NSString alloc]initWithFormat:@"%1.2f",_usedmoney];
        
        _btnSkipUserMoney.value = _usedmoney;
    }else{
        _lbUsedMoney.text = @"0";
        _usedmoney = 0;
    }

    //计算金额(暂不考虑红包抵扣)
    _totalpay = _totalpaylimit - _usedmoney - _usedpoints/100;
    //double 类型精度问题，不用 0
    if (_totalpay>0.001) {
        _lbPayMoney.text = [[NSString alloc]initWithFormat:@"%1.2f",_totalpay];
        _selectAlipay.on = true;
    }else{
        _totalpay = 0;
        _lbPayMoney.text = @"0";
        _selectAlipay.on = false;
    }
    
    
}


//wap回调函数(支付)
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
        NSString *strResult =[[NSString alloc] initWithFormat:@"%@  (%d)",result.statusMessage,result.statusCode ];
		//UIAlertView *alertPay = [[UIAlertView alloc] initWithTitle:@"支付信息" message:strResult delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        //[alertPay show];
        
        
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        

        NSLog(@"支付宝回调结果：%@",result);
        
        //self.lbResult.text =  strResult;
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
            
            NSString *lsNotifyTitle = [[NSString alloc]initWithFormat:@"您已成功支付1个订单,支付结果:%@",strResult ];
            [delegate showNotify:lsNotifyTitle HoldTimes:3];
            //跳转到消费券列表(已付款)
            
            //重要：主动调用 Segue 呈现页面
            [self performSegueWithIdentifier:@"couponslist" sender:self];

        }
        else
        {
            //交易失败
            NSString *lsNotifyTitle = [[NSString alloc]initWithFormat:@"您的支付出现问题,支付结果:%@,订单(%@)将保留用于下次继续支付。",strResult ,_OrderSn];
            [delegate showNotify:lsNotifyTitle HoldTimes:3];
        }
    }
    else
    {
        //失败
    }
    
}

/*
 *产生商品列表数据
 */
- (void)generateData{
	
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 55.0f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listData.count;
}

////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"bonusCell";
    bonusViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier  forIndexPath:indexPath];
    
    if (cell == nil) {
        NSLog(@"表格初始化错误");
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"DiscountProductCell" owner:self options:nil] ;
        
        cell = [nib objectAtIndex:0];
    }
    //开始解析数据
    NSMutableDictionary*  dict = self.listData[indexPath.row];
    
    //填充单元格
    cell.lbname.text =[dict objectForKey:@"type_name"];
    cell.lbPrice.text =[dict objectForKey:@"type_money"];
    
    cell.lbbonusID.text =[dict objectForKey:@"bonus_id"];
    
    cell.lbTypeid.text = [dict objectForKey:@"type_id"];
    
    //修改单元格背景色
    UIView *bgColorView = [[UIView alloc] init];
    
    bgColorView.backgroundColor = _CellBgColor;
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    
    //保留前值已辨认变化
    double _usedbonuspri =_usedbonus;
    
    //不选
    if (-1==_selectedbonus) {
        _usedbonus = 0;
        _usedbonusid = @"";
    }
    if ( [[dict objectForKey:@"bonus_id"]isEqualToString:@"" ]) {
        //不可用
        cell.selectBonus.on = false;
        cell.selectBonus.enabled = false;
        _usedbonuspri = 0;
        _usedbonus=_usedbonuspri;
        _usedbonusid = @"";
    }else{
        if (indexPath.row==_selectedbonus) {
            //选中该单元Cell
            cell.selectBonus.on = true;
            //记住红包
            _usedbonus = [[dict objectForKey:@"type_money"]doubleValue];
            _usedbonusid = [dict objectForKey:@"bonus_id"];
            
        }else{
            
            cell.selectBonus.on = false;
        
        }
    }
    if (_usedbonus!=_usedbonuspri) {
        //触发修改
        [self calculatepay_bonus];
    }
    
    [cell.selectBonus addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventValueChanged];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //响应开关
    ////方法之一：设置一个外部变量，选中的时候传值，然后通过重新加载数据，使得在选中这行打勾，其他行无样式,此方法加载的时候第一行默认打勾了
    if (_selectedbonus == indexPath.row) {
        //相同则取消，并将标记归零(不选)
        _selectedbonus = -1;
    }else{
        _selectedbonus = indexPath.row;
    }
    
    [self.tableView reloadData];
    
    
    
    /*
    // 取消前一个选中的，单选
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:_selectedbonus inSection:1];
    bonusViewCell *lastCell = [self.tableView cellForRowAtIndexPath:lastIndex];
    lastCell.accessoryType = UITableViewCellAccessoryNone;
    lastCell.selectBonus.On = false;
    
    // 选中操作
    bonusViewCell *cell = [tableView  cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // 保存选中的
    _selectedbonus = indexPath.row;
    cell.selectBonus.On = true;
    
    [_tableView performSelector:@selector(deselectRowAtIndexPath:animated:) withObject:indexPath afterDelay:.5];
    */
    
    
    

    /*
	 *生成订单信息及签名
	 *由于demo的局限性，采用了将私钥放在本地签名的方法，商户可以根据自身情况选择签名方法(为安全起见，在条件允许的前提下，我们推荐从商户服务器获取完整的订单信息)
	 */
    /*
    NSString *appScheme = @"MQPAlipayCARWASH";
    NSString* orderInfo = [self getOrderInfo:indexPath.row];
    NSString* signedStr = [self doRsa:orderInfo];
    
    NSLog(@"%@",signedStr);
    
    NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                             orderInfo, signedStr, @"RSA"];
	
    [AlixLibService payOrder:orderString AndScheme:appScheme seletor:_result target:self];
    */
    
    
    
    
    
    
}

//响应列表中的开关点击事件
- (IBAction)updateSwitchAtIndexPath:(id)sender {
    
    
    UISwitch *switchView = (UISwitch *)sender;
    
    if ([switchView isOn])
    {
        //do something..
        //bonusViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        //NSString *strName = cell.lbname.text;
        
        
    }
    else
    {
        //do something
        
        
    }
    
}



//按下付款按钮
- (IBAction)btnPayClicked:(id)sender {
    
    if (_totalpay>0.001) {
        
        //先使用余额、积分支付订单
        //完成后再发出支付宝请求
        //最后根据支付回调和后台校验跳转到消费券
        NSString *lsNotifyTitle = [[NSString alloc]initWithFormat:@"请稍候，正在处理支付，订单金额: %@ 元", _itemTotal ];
        
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate showNotify:lsNotifyTitle HoldTimes:3];
        
        [self startRequest];
        
        
        
    }else{
        //余额、积分足够支付订单
        //发出支付请求
        NSString *lsNotifyTitle = [[NSString alloc]initWithFormat:@"请稍候，正在处理支付，订单金额: %@ 元", _itemTotal ];
        
      washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate showNotify:lsNotifyTitle HoldTimes:3];

        [self startRequest];
        
    
    }
    
}


-(NSString*)getOrderInfo:(NSInteger)index
{
    /*
	 *初始化订单信息
	 */

    AlixPayOrder *order = [[AlixPayOrder alloc] init];
    order.partner = PartnerID;
    order.seller = SellerID;
   	//order.notifyURL =  @"http%3A%2F%2Fwwww.xxx.com"; //回调URL
	order.notifyURL =  @"http%3A%2F%2F2345mall.com%2Fnotify_url.php"; //回调URL
    
    order.tradeNO = self.OrderSn; //订单SN（由商家自行制定）
	order.productName = self.itemname; //商品标题
	order.productDescription = self.itemdetail; //商品描述
	//order.amount = self.itemTotal; //商品价格
    order.amount = self.lbPayMoney.text; //只计算需付款的金额
	return [order description];
}

//取得订单号
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
    UIAlertView *alertPay = [[UIAlertView alloc] initWithTitle:@"支付信息" message:result delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertPay show];
    NSLog(@"回调结果：%@",result);
    
    //向服务器发送确认支付请求
    
    
}


//选择订单支付方式//选择取消订单
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //重要：主动调用 Segue 呈现页面
    ////调用[self performSegueWithIdentifier:@"couponslist" sender:self];
    
    if([segue.identifier isEqualToString:@"couponslist"])
    {
        
        NSLog(@"进入消费券列表 %@",self.OrderSn);
        
        //方法有特殊之处，调试发现直接 实例化并push会导致 cell错误，所以只传值。
        //跳转到消费券列表(已付款)
        couponsTableViewController *couponsview =  [segue destinationViewController];
        couponsview.orderID = _OrderID;
        couponsview.orderName = _itemname;
        couponsview.Address = _itemdetail;
        //couponsview.Phone = @"";
        //couponsview.Locationpt = _Locationpt;
        
        //不要再push了，已经执行了push，否则会错误。
        //[self.navigationController pushViewController:couponsview animated:YES];
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc]init];
        backItem.title=@"";
        backItem.tintColor=[UIColor colorWithRed:129/255.0 green:129/255.0  blue:129/255.0 alpha:1.0];
        self.navigationItem.backBarButtonItem = backItem;

        
    }
    
    
    //取消订单 or 申请退款
    
}

/*
 * 开始请求Web Service
 */
-(void)startRequest
{
    _isConnected = false;
    //跳转到登录页面
    if ([_iPs_POSTID isEqualToString:@""]) {
        self.tabBarController.selectedIndex = 4;
        return;
    }
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    //NSString *post = [NSString stringWithFormat:@"act=wash_list&cat_id=139&page=%d&sel_attr=0&region_id=%@",_iPageIndex,@"298"];
    //_iPs_POST=@"act=%@&user_id=%@&order_id=%@&pay_id=%@&pay_name=%@&surplus=%@&integral=%@&bonus=%@"; //请求数据POST参数模板
    NSString *post = @"";
    
    
    if ([_iPs_POSTQueryOption isEqual:@"0"]) {
        NSString *str_surplus = [[NSString alloc]initWithFormat:@"%1.2f" ,_usedmoney];    //余额
        NSString *str_integral = [[NSString alloc]initWithFormat:@"%1.0f" ,_usedpoints];   //积分
        
        if (([_usedbonusid isEqualToString:@""])||(_usedbonusid == nil)) {
            _usedbonusid = @"0";
        }
        
        NSString *str_bonusid = _usedbonusid;    //红包
        
        if ((![_Payid isEqualToString:_iPs_POSTQueryOption])&&(_Payid!=nil)) {
            //可能是继续支付，需要pay_id
            _iPs_POSTQueryOption = _Payid;
        }
        
        //默认显示未付款订单
        post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID,_OrderID,_iPs_POSTQueryOption,@"支付宝支付",str_surplus,str_integral,str_bonusid];
    
    }
    
    if ([_PayAction isEqualToString:@"继续支付"]) {
        //禁用积分、余额、红包
        NSLog(@"继续支付：%@", _itemTotal);
        
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
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:_datas options:NSJSONReadingAllowFragments error:nil];
    
    NSLog( @"PayResult: %@", [dict description] );
    //支付结果的解析
    [self resolvePayOrder:dict];
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

// 付款流程：先支付商城余额接口，再支付支付宝等
//订单支付的返回
-(void)resolvePayOrder:(NSDictionary*)res
{
    NSNumber *resultCodeObj = [res objectForKey:@"is_error"];
    if (resultCodeObj==nil) {
        //无法处理的结果
        
        resultCodeObj = [[NSNumber alloc] initWithInt:1];
    }
    
    if ([resultCodeObj integerValue] ==0){
        if (_totalpay>0.001) {
        //需要网上支付 -- 支付宝
            NSString *lsNotifyTitle = [[NSString alloc]initWithFormat:@"正在处理支付,订单号:%@,应付金额:%1.2f元,将委托您选择的交易方式支付。",_OrderSn ,_totalpay];
            
            washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
            [delegate showNotify:lsNotifyTitle HoldTimes:3];
        
            //开启支付宝
            //走支付流程 MQPAlipayCARWASH
            NSString *appScheme = @"MQPAlipayCARWASH";//@"AlipaySdkDemo";
            NSString* orderInfo = [self getOrderInfo:1];
            NSString* signedStr = [self doRsa:orderInfo];
            
            NSLog(@"%@",signedStr);
            
            NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                                     orderInfo, signedStr, @"RSA"];
            ////////////////////////////////////////////////////////
            [AlixLibService payOrder:orderString AndScheme:appScheme seletor:_result target:self];
            
        }else{
        //提示付款成功，并跳转到密码券
            NSString *lsNotifyTitle = [[NSString alloc]initWithFormat:@"您已成功支付1个订单,订单号:%@",_OrderSn ];
            
            washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
            [delegate showNotify:lsNotifyTitle HoldTimes:3];
            
            //返回到前一个界面
            //[self.navigationController popViewControllerAnimated:YES]; //PUSH
            
            //传递消息
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"OrderRefreshNotification"
             object:nil
             userInfo:nil];
            
            //跳转到消费券列表(已付款)
            //传递消息
//            [[NSNotificationCenter defaultCenter]
//             postNotificationName:@"couponsRefreshNotification"
//             object:nil
//             userInfo:nil];
            
            NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:_itemname, @"name", _OrderID,@"ID", nil];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"OrderCompletionNotification"
             object:nil
             userInfo:dataDict];

            
            //重要：主动调用 Segue 呈现页面
            [self performSegueWithIdentifier:@"couponslist" sender:self];
            /*couponsTableViewController *couponsview = [[couponsTableViewController alloc] init];
             [self.navigationController pushViewController:couponsview animated:YES];*/

        }
        
        
    }else if ([resultCodeObj integerValue] ==1)
    {
        NSString *strError = [[NSString alloc]initWithFormat:@"未完成支付，订单号:%@ 价格:%@",_OrderSn ,[res objectForKey:@"order_price"]];
        
        
        //订单创建失败
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"订单支付错误"
                                                            message:strError
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
}

@end
