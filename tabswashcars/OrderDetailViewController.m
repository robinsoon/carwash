//
//  OrderDetailViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-16.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "AlipayViewController.h"
#import "UIButton+Bootstrap.h"
#import "couponsTableViewController.h"

@interface OrderDetailViewController ()
//重点说明
//订单明细(创建、查看详情)
//订单提交后刷新明细页面[功能：取消订单 or 申请退款]
//包含六种业务请求：0 提交订单; 1 支付订单; 2 删除订单; 3 申请退款; 4 再次购买; 5 再次购买的支付;
//2014-5-25  Created By Robin
//定义可配置的数据参数（对于简单查询只需1组配置）
//命名规则： i 表示实例变量；P 表示 页面变量； s 表示 数据类型为String；
//初始化统一调用方法：initPage
@property (strong, nonatomic) NSString *iPs_PageName; //页面名称(用于标记参数组)
@property (strong, nonatomic) NSString *iPs_URL; //请求数据接口模板--地址
@property (strong, nonatomic) NSString *iPs_PAGE; //请求数据接口模板--页面

@property (strong, nonatomic) NSString *iPs_POST; //请求数据POST参数模板
@property (strong, nonatomic) NSString *iPs_POST1; //请求数据POST参数1模板
@property (strong, nonatomic) NSString *iPs_POST2; //请求数据POST参数2模板
@property (strong, nonatomic) NSString *iPs_POST3; //请求数据POST参数3模板
@property (strong, nonatomic) NSString *iPs_POST4; //请求数据POST参数4模板
@property (strong, nonatomic) NSString *iPs_POST5; //请求数据POST参数5模板


@property (strong, nonatomic) NSString *iPs_POSTAction; //请求数据POST参数Action
@property (strong, nonatomic) NSString *iPs_POSTAction1; //请求数据POST参数Action1
@property (strong, nonatomic) NSString *iPs_POSTAction2; //请求数据POST参数Action2
@property (strong, nonatomic) NSString *iPs_POSTAction3; //请求数据POST参数Action3
@property (strong, nonatomic) NSString *iPs_POSTAction4; //请求数据POST参数Action4
@property (strong, nonatomic) NSString *iPs_POSTAction5; //请求数据POST参数Action5


//传入变化的参数组,参数数目根据接口需要而变化
@property (strong, nonatomic) NSString *iPs_POSTID; //请求数据POST参数ID1


//请求数据POST参数类型：0 提交订单; 1 支付订单; 2 删除订单; 3 申请退款; 4 再次购买; 5 再次购买的支付;
@property (strong, nonatomic) NSString *iPs_POSTQueryOption; //请求数据POST参数ID2

//from_app = 0 商城, 1 安卓, 2 苹果
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
    if (_iPs_PageName==nil) {
        [self initPage];
    }
    
    //用户登录的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginCompletion:)
                                                 name:@"LoginCompletionNotification"
                                               object:nil];

    self.lbID.text = _Ordersn;
    
    self.lbName.text = self.itemname;
    self.lbPrice.text = self.itemprice;//商品单价
    self.lbDescription.text = self.itemdetail;
    self.lbAmount.text = self.itemAmount;//1
    self.lbTotalPrice.text = self.itemprice;//商品总价
    self.lbBuyCount.text = self.itemAmount;//1
    self.btnstep.value = 1;
    
    
    //0 未付款
    //1 付款中
    //2 已付款
    if ([_PayStatus  isEqual: @"0"]) {
        self.lbPayStatus.text = @"未付款";
    }else if([_PayStatus  isEqual: @"1"]) {
        self.lbPayStatus.text = @"付款中";
    }else if([_PayStatus  isEqual: @"2"]) {
        self.lbPayStatus.text = @"已付款";
        
    }else{
        self.lbPayStatus.text = @"未付款";
    }
    
    //0 未确认
    //1 已确认
    //2 已取消
    //3 无效
    //4 退货
    //5 已分单
    //6 部分分单

    if ([_OrderStatus  isEqual: @"0"]) {
        self.lbOrderStatus.text = @"未确认";
    }else if([_OrderStatus  isEqual: @"1"]){
        self.lbOrderStatus.text = @"已确认";
    }else if([_OrderStatus  isEqual: @"2"]){
        self.lbOrderStatus.text = @"已取消";
    }else if([_OrderStatus  isEqual: @"3"]){
        self.lbOrderStatus.text = @"无效";
    }else if([_OrderStatus  isEqual: @"4"]){
        self.lbOrderStatus.text = @"退货";
    }else if([_OrderStatus  isEqual: @"5"]){
        self.lbOrderStatus.text = @"已分单";
    }else if([_OrderStatus  isEqual: @"6"]){
        self.lbOrderStatus.text = @"部分分单";
    }else{
        self.lbOrderStatus.text = @"未知";
    }
    
    //支付
    [self.btnSubmit primaryStyle];
    [self.btnSubmit addAwesomeIcon:FAIconLegal beforeTitle:NO];
    //提交订单
    [self.btnCreate primaryStyle];
    [self.btnCreate addAwesomeIcon:FAIconCircleArrowUp beforeTitle:YES];
    //删除
    [self.btnDeleteOrder dangerStyle];
    [self.btnDeleteOrder addAwesomeIcon:FAIconMinusSign beforeTitle:YES];
    //退款
    [self.btnRebackOrder dangerStyle];
    [self.btnRebackOrder addAwesomeIcon:FAIconWarningSign beforeTitle:YES];
    //再次购买
    [self.btnBuyAgain primaryStyle];
    [self.btnBuyAgain addAwesomeIcon:FAIconBolt beforeTitle:NO];
    
    [self.btncoupons warningStyle];
    [self.btncoupons addAwesomeIcon:FAIconAsterisk beforeTitle:YES];
    
    //刷新按钮
    self.btnRefresh.titleLabel.text = @"";
    [self.btnRefresh successStyle];
    [self.btnRefresh addAwesomeIcon:FAIconRepeat beforeTitle:YES];
    
    //几个功能按钮重绘一次，主要控制同时显示的两个按钮
    [self ReDrawButtons];
    
    ///////////////////////////////////
    //从订单明细中获取更多数据，为支付做准备
    //如果进入支付状态的订单，自动刷新订单明细 支付和已付款
    if (([_OrderAction isEqualToString:@"支付"])&&( _OrderID !=nil))
    {
        [self getOrderDetails:_OrderID];
    }
    
    //从外部页面跳转过来参数传递不全，只包含orderID,需要刷新
    if ([_PageAction isEqualToString:@"1"])
    {
        [self getOrderDetails:_OrderID];
    }
    
}


//页面即将展示
-(void) viewWillAppear:(BOOL)animated{
    //如果页面没有初始化则先用初始值
    if (_iPs_PageName==nil) {
        [self initPage];
    }
    
    if(([_Ordersn isEqualToString:@""])||(_Ordersn == nil)){
        _lbID.hidden = true;
        _lbidtext.hidden = true;
    }else{
        _lbID.hidden = false;
        _lbidtext.hidden = false;
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
    
    //注意：这里重用了订单页面，分为提交订单和查询订单明细
    //订单的支付在另外一个页面
    
    _iPs_PageName=@"订单详情"; //页面名称(用于标记页面参数配置)
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _iPs_URL=delegate.iPs_URL; //请求数据接口模板--地址
    _iPs_PAGE=@"flow_app.php"; //请求数据接口模板--页面1
    
    
    //请求数据POST参数类型：0 提交订单; 1 订单详情; 2 删除订单; 3 申请退款; 4 再次购买; 5 再次购买的支付;
    
    
    _iPs_POST=@"act=%@&user_id=%@&goods_id=%@&number=%@&amount=%@&from_app=%@";
    _iPs_POST1=@"act=%@&user_id=%@&order_id=%@";
    _iPs_POST2=@"act=%@&user_id=%@&order_id=%@";
    _iPs_POST3=@"act=%@&user_id=%@&order_id=%@";
    _iPs_POST4=@"act=%@&user_id=%@&order_id=%@";
    _iPs_POST5=@"act=%@&user_id=%@&order_id=%@&pay_id=%@&pay_name=%@";
    
    _iPs_POSTAction =@"insert_order";   //提交订单
    _iPs_POSTAction1 =@"buy_order";     //查询订单详情
    _iPs_POSTAction2 =@"remove_order";     //删除订单
    _iPs_POSTAction3 =@"reback";     //申请退款
    _iPs_POSTAction4 =@"buy_again_order";     //再次购买
    _iPs_POSTAction5 =@"done_again_order";     //再次购买的支付
    
    _iPs_POSTID=delegate.userid;
    _UserID =_iPs_POSTID;

    //下面这个参数非常重要，他对应订单页面的业务请求序号
    _iPs_POSTQueryOption=@"0";
    
    //from_app = 0 商城, 1 安卓, 2 苹果
    _iPs_POSTQueryRegion=@"2"; //请求数据POST参数ID3
    
    //不随页面类型改变的部分
    _iPageIndex = 1;//初始化页面序号
}

//按钮隐藏以后再显示需要重绘，应用主题风格，否则不会显示
- (void) ReDrawButtons{
    if ([_OrderAction  isEqual: @"新建"]) {

        self.btnSubmit.hidden = true;
        self.btnCreate.hidden = false;//只显示提交订单
        self.btnDeleteOrder.hidden = true;
        self.btnRebackOrder.hidden = true;
        self.btnBuyAgain.hidden = true;
        self.btncoupons.hidden = true;
        self.btnRefresh.hidden = true;
        
        self.lbBuyCount.enabled = true;
        self.btnstep.enabled = true;
        
        
    }else if ([_OrderAction  isEqual: @"支付"]){
        //默认
        self.btnSubmit.hidden = false;//支付
        self.btnCreate.hidden = true;
        self.btnDeleteOrder.hidden = false;//删除
        self.btnRebackOrder.hidden = true;
        self.btnBuyAgain.hidden = true;
        self.btncoupons.hidden = true;
        self.btnRefresh.hidden = false;
        
        self.lbBuyCount.enabled = false;
        self.btnstep.enabled = false;
    }else if ([_OrderAction  isEqual: @"继续支付"]){
        //订单状态已确认，支付状态未支付
        self.btnSubmit.hidden = true;
        self.btnCreate.hidden = true;
        self.btnDeleteOrder.hidden = false;//删除
        self.btnRebackOrder.hidden = true;//退款
        self.btnBuyAgain.hidden = false;//再买
        self.btncoupons.hidden = true;
        self.btnRefresh.hidden = false;
        
        self.lbBuyCount.enabled = false;
        self.btnstep.enabled = false;

    }else if ([_OrderAction  isEqual: @"已付款"]){

        self.btnSubmit.hidden = true;
        self.btnCreate.hidden = true;
        self.btnDeleteOrder.hidden = true;
        self.btnRebackOrder.hidden = false;//退款
        self.btnBuyAgain.hidden = true;//再买
        self.btncoupons.hidden = false;
        self.btnRefresh.hidden = false;
        
        self.lbBuyCount.enabled = false;
        self.btnstep.enabled = false;
    }else  if ([_OrderAction  isEqual: @"中止购买"]){
        self.btnSubmit.hidden = true;//支付
        self.btnCreate.hidden = true;
        self.btnDeleteOrder.hidden = false;//删除
        self.btnRebackOrder.hidden = true;//退款
        self.btnBuyAgain.hidden = true;//再买
        self.btncoupons.hidden = true;
        self.btnRefresh.hidden = false;
        
        self.lbBuyCount.enabled = false;
        self.btnstep.enabled = false;
    }

    //支付
    [self.btnSubmit primaryStyle];
    //[self.btnSubmit addAwesomeIcon:FAIconLegal beforeTitle:NO];
    //提交订单
    [self.btnCreate primaryStyle];
    //[self.btnCreate addAwesomeIcon:FAIconCircleArrowUp beforeTitle:YES];
    //删除
    [self.btnDeleteOrder dangerStyle];
    //[self.btnDeleteOrder addAwesomeIcon:FAIconMinusSign beforeTitle:YES];
    //退款
    [self.btnRebackOrder dangerStyle];
    //[self.btnRebackOrder addAwesomeIcon:FAIconWarningSign beforeTitle:YES];
    //再次购买
    [self.btnBuyAgain primaryStyle];
    //[self.btnBuyAgain addAwesomeIcon:FAIconBolt beforeTitle:NO];
    
    [self.btncoupons warningStyle];
    
    [self.btnRefresh successStyle];
    
    
    if(([_Ordersn isEqualToString:@""])||(_Ordersn == nil)){
        _lbID.hidden = true;
        _lbidtext.hidden = true;
    }else{
        _lbID.hidden = false;
        _lbidtext.hidden = false;
    }

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

- (IBAction)btnStepChanged:(id)sender
{
    
    NSString *strBuy = [[NSString alloc] initWithFormat:@"%1.0f",self.btnstep.value ];

    self.lbBuyCount.text=strBuy;
    [self byCountChanged:_lbBuyCount];
}

//修改数量
- (IBAction)buyCountDidEnd:(id)sender {
    
    [sender resignFirstResponder];
}

//修改数量更新价格
- (IBAction)byCountChanged:(id)sender {
    double icount = 0;
    double iPrice = 0;
    double iTotal = 0;
    icount = [_lbBuyCount.text doubleValue];
    _itemAmount = _lbBuyCount.text;
    
    if (icount>0) {
        
        self.btnstep.value = icount;
        iPrice = [_lbPrice.text doubleValue];//商品单价
        
        iTotal = icount * iPrice;
        //商品总价
        _lbTotalPrice.text = [[NSString alloc] initWithFormat:@"%1.2f",iTotal];
    }else{
    //重置为1
        _itemAmount = @"1";
        self.btnstep.value = 1;
        self.lbBuyCount.text = @"1";
        _lbTotalPrice.text = _lbPrice.text;
    }
    
    
    
}

//由于数字键盘没有Return键，当点击界面其它元素自动释放焦点以隐藏键盘
- (void)touchesBegan: (NSSet *)touches withEvent:(UIEvent *)event
{
    // do the following for all textfields in your current view
    [self.lbBuyCount resignFirstResponder];
    [self byCountChanged:_lbBuyCount];

}


/////////////////////////////////////////////////////////////////

//提交订单
- (IBAction)btnSubmitOrder:(id)sender {
    //请求数据POST参数类型：0 提交订单; 1 支付订单; 2 删除订单; 3 申请退款; 4 再次购买; 5 再次购买的支付;
    //使用新的订单价格
    _itemAmount = _lbBuyCount.text; //数量
    _itemTotal = _lbTotalPrice.text;//订单价格
    
    _iPs_POSTQueryOption=@"0";
    [self startRequest];
    
}

//支付按钮
- (IBAction)btnpayclicked:(id)sender {
}


- (IBAction)btnDeleteOrderClicked:(id)sender {
    [self deleteOrder:_OrderID];
}

- (IBAction)btnRebackOrderClicked:(id)sender {
    [self rebackOrder:_OrderID];
}

- (IBAction)btnBuyAgainClicked:(id)sender {
    [self buyAgainOrder:_OrderID];
}

//刷新订单
- (IBAction)btnRefreshClicked:(id)sender {
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    [delegate showNotify:@"正在刷新订单,请稍候" HoldTimes:1.5];
    [self getOrderDetails:_OrderID];
}

//跳转到优惠券
- (IBAction)btnCouponsClicked:(id)sender {
    
    
    //传递消息
    /*UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *couponsViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"couponslistView"];
    
    couponsViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:couponsViewController animated:YES completion:^{
        NSLog(@"打开消费券界面");
    }];*/

}


//刷新订单明细
- (void)getOrderDetails:(NSString *)lsOrderID{
    _iPs_POSTQueryOption=@"1";
    [self startRequest];

}

//处理其它业务： 删除订单
- (void)deleteOrder:(NSString *)lsOrderID{
    _iPs_POSTQueryOption=@"2";
    [self startRequest];
}
//处理其它业务： 申请退款
- (void)rebackOrder:(NSString *)lsOrderID{
    _iPs_POSTQueryOption=@"3";
    [self startRequest];
}
//处理其它业务： 再次购买
- (void)buyAgainOrder:(NSString *)lsOrderID{
    _iPs_POSTQueryOption=@"4";
    [self startRequest];
}
//处理其它业务： 再次购买的支付
- (void)buyAgainPay:(NSString *)lsOrderID{
    _iPs_POSTQueryOption=@"5";
    [self startRequest];
}

//登录返回
-(void)loginCompletion:(NSNotification*)notification {
    
    NSDictionary *theData = [notification userInfo];
    _UserID = [theData objectForKey:@"ID"];
    NSString *lsLogin = [theData objectForKey:@"isLogin"];
    
    //页面显示用户登录信息
    //washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    if ([lsLogin isEqual:@"0"]) {
        _iPs_POSTID=@"";
        //未登录
        //重新请求数据
        NSLog(@"用户未登录，重新获取数据");
    }else{
        if ([_UserID isEqual:_iPs_POSTID]) {
            //用户没有变化，不做刷新
            return;
            
        }else{
            _iPs_POSTID = _UserID;
            
            _iPageIndex = 1;
            //重新请求数据
            NSLog(@"用户登录状态变更，重新获取数据");
        }
    }
    
    [self startRequest];
    
}


//选择订单支付方式//选择取消订单
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"ShowPay"])
    {
        AliPayViewController *itemPay = segue.destinationViewController;
        
        itemPay.itemid = self.itemid;
        itemPay.OrderID = self.OrderID;
        itemPay.OrderSn = self.Ordersn;
        
        itemPay.dict_orderdetails = self.dict_orderdetails;
        
        itemPay.itemname = self.lbName.text;
        itemPay.itemprice = self.itemprice;
        itemPay.itemAmount = self.itemAmount;
        itemPay.itemTotal = self.itemTotal;
        itemPay.itemdetail = self.lbDescription.text;

        
        NSLog(@"进入支付页面 %@",self.Ordersn);
        
    }
    
    if([segue.identifier isEqualToString:@"ordercoupons"])
    {
        
        NSLog(@"进入消费券页面 %@",self.Ordersn);
        
        //方法有特殊之处，调试发现直接 实例化并push会导致 cell错误，所以只传值。
        //跳转到消费券列表(已付款)
        couponsTableViewController *couponsview =  [segue destinationViewController];
        couponsview.orderID = _OrderID;
        couponsview.orderName = _itemname;
        couponsview.Address = _itemdetail;
        couponsview.Phone = @"";
        couponsview.Locationpt = _Locationpt;
        couponsview.FromOrder = @"1"; // 标记来自订单的消费券
        //不要再push了，已经执行了push，否则会错误。
        //[self.navigationController pushViewController:couponsview animated:YES];


    }
    
    
    //取消订单 or 申请退款
    
}


/////////////////////////////////////////////////////////////////

/*
 * 开始请求Web Service
 */
-(void)startRequest
{
    _isConnected = false;
    
    if ([_iPs_POSTID isEqualToString:@""]) {
        //传递消息
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"OrderWithLoginNotification"
         object:nil
         userInfo:nil];


        self.tabBarController.selectedIndex = 4;
        return;
    }
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    NSString *post = @"";
    //请求数据POST参数类型：0 提交订单; 1 支付订单; 2 删除订单; 3 申请退款; 4 再次购买; 5 再次购买的支付;
    
    if([_iPs_POSTQueryOption isEqualToString:@"0"]){
        //0 提交订单;
        post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID,_itemid,_itemAmount,_itemTotal,_iPs_POSTQueryRegion];

    }else if([_iPs_POSTQueryOption isEqualToString:@"1"]){
        //1 获取订单详情
        post = [NSString stringWithFormat:_iPs_POST1,_iPs_POSTAction1,_iPs_POSTID,_OrderID];

    }else if([_iPs_POSTQueryOption isEqualToString:@"2"]){
        //删除订单
        //act = remove_order&user_id=?&order_id=?
        post = [NSString stringWithFormat:_iPs_POST2,_iPs_POSTAction2,_iPs_POSTID,_OrderID];
    }else if([_iPs_POSTQueryOption isEqualToString:@"3"]){
        //申请退款
        //act = reback&user_id=?&order_id=?
        post = [NSString stringWithFormat:_iPs_POST3,_iPs_POSTAction3,_iPs_POSTID,_OrderID];
    }else if([_iPs_POSTQueryOption isEqualToString:@"4"]){
        //再次购买
        //act = buy_again_order&user_id=?&order_id=?
        post = [NSString stringWithFormat:_iPs_POST4,_iPs_POSTAction4,_iPs_POSTID,_OrderID];
    }else if([_iPs_POSTQueryOption isEqualToString:@"5"]){
        //再次购买的支付
        //act = done_again_order&user_id=?&order_id=?&pay_id=?&pay_name=?
        //用户再次购买支付接口
        post = [NSString stringWithFormat:_iPs_POST5,_iPs_POSTAction5,_iPs_POSTID,_OrderID,_PayID,_PayName];
    }else{
        //其它
        return;
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
    
    NSLog( @"Result: %@", [dict description] );

    ///////////////////////////////////////////////////////
    
    //数据页面请求结果的解析
    if([_iPs_POSTQueryOption isEqualToString:@"0"]){
        //0 提交订单;
        [self resolveOrderSubmit:dict];
        
    }else if([_iPs_POSTQueryOption isEqualToString:@"1"]){
        //1 获取订单详情
        [self resolveOrderDetail:dict];
    }else if([_iPs_POSTQueryOption isEqualToString:@"2"]){
        //删除订单
        //act = remove_order&user_id=?&order_id=?
        [self resolvedeleteOrder:dict];
    }else if([_iPs_POSTQueryOption isEqualToString:@"3"]){
        //申请退款
        //act = reback&user_id=?&order_id=?
        [self resolverebackOrder:dict];
        
    }else if([_iPs_POSTQueryOption isEqualToString:@"4"]){
        //再次购买
        //act = buy_again_order&user_id=?&order_id=?
        [self resolvebuyAgain:dict];
    }else if([_iPs_POSTQueryOption isEqualToString:@"5"]){
        //再次购买的支付
        //act = done_again_order&user_id=?&order_id=?&pay_id=?&pay_name=?
        //用户再次购买支付接口
        //[self resolvebuyAgain:dict];
        
    }else{
        //其它
        return;
    }
    
    //激活数据列表的刷新
    //[self reloadView:dict];
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


/////////////////////////////////////////////////////////////
//以下是数据结果的解析

//提交订单的返回
-(void)resolveOrderSubmit:(NSDictionary*)res
{
    NSNumber *resultCodeObj = [res objectForKey:@"is_error"];
    if (resultCodeObj==nil) {
        //无法处理的结果
        
        resultCodeObj = [[NSNumber alloc] initWithInt:1];
    }
    if ([resultCodeObj integerValue] ==0){
        
        NSNumber *isOrderID = [res objectForKey:@"order_id"];
        
        _OrderID = [isOrderID stringValue];
        _Ordersn = [res objectForKey:@"order_sn"];
        _itemid = _OrderID;
        
        _OrderAction=@"支付";
        [self ReDrawButtons];
        
        _PayStatus=@"0";
        _lbID.text = _Ordersn;
        
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
        
        NSString *lsNotifyTitle = [[NSString alloc]initWithFormat:@"提交完成！订单编号为:%@,稍候将自动转到支付页面",_Ordersn ];
        
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate showNotify:lsNotifyTitle HoldTimes:3];

        //等待获取到支付信息后直接进入支付页面
        //需要刷新订单页面
        _PageAction = @"2";//支付跳转
        [self getOrderDetails:_OrderID];
        
        
    }else if ([resultCodeObj integerValue] ==1)
    {
        NSString *strError = [res objectForKey:@"err_msg"];
        NSString *strTotalPrice= [res objectForKey:@"amount_check"];
        //自动纠正价格
        _lbTotalPrice.text = strTotalPrice;
        _itemTotal = strTotalPrice;
        //单价换算
        _itemprice = [[NSString alloc] initWithFormat:@"%1.2f", [strTotalPrice doubleValue]/[_itemAmount doubleValue]];
        _lbPrice.text = _itemprice;
        _OrderAction = @"新建";
        [self ReDrawButtons];
        //订单创建失败
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提交订单错误"
                                                            message:strError
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
}

//刷新订单明细的返回
-(void)resolveOrderDetail:(NSDictionary*)res
{
    NSNumber *resultCodeObj = [res objectForKey:@"is_error"];
    if (resultCodeObj==nil) {
        //无法处理的结果
        
        resultCodeObj = [[NSNumber alloc] initWithInt:1];
    }
    if ([resultCodeObj integerValue] ==0){
        
        _dict_orderdetails = res;
        //解析订单明细：
        NSDictionary* dict_goods = [res objectForKey:@"order_goods"];
        NSDictionary* dict_order = [res objectForKey:@"order_info"];
        //NSDictionary* dict_paylist = [res objectForKey:@"order_select"]; //支付方式选择
        //NSDictionary* dict_payname = [res objectForKey:@"order_pay"];    //支付方式类型
        
        
        NSNumber *isOrderID = [dict_order objectForKey:@"order_id"];
        
        _OrderID = [[NSString alloc]initWithFormat:@"%@", isOrderID ];
        _Ordersn = [dict_order objectForKey:@"order_sn"];
        _OrderStatus=[dict_order objectForKey:@"order_status"];
        _PayStatus=[dict_order objectForKey:@"pay_status"];
    
        _itemTotal =[dict_order objectForKey:@"order_amount"];

        _lbID.text = _Ordersn;
        
        

        //订单信息的解析
        _itemname = [dict_goods objectForKey:@"goods_name"];
        _itemprice = [dict_goods objectForKey:@"goods_price"];
        //_itemTotal = [dict_goods objectForKey:@"subtotal"];
        _itemAmount = [dict_goods objectForKey:@"goods_number"];
        
        _itemdetail = [dict_goods objectForKey:@"address_street"];
        
        self.lbID.text = _Ordersn;
        
        self.lbName.text = self.itemname;
        self.lbPrice.text = self.itemprice;
        
        self.lbTotalPrice.text = self.itemTotal;
        
        self.lbBuyCount.text = self.itemAmount;
        
        self.lbDescription.text = self.itemdetail;
        //self.lbAmount.text = self.itemAmount;
        //0 未付款
        //1 付款中
        //2 已付款
        if ([_PayStatus  isEqual: @"0"]) {
            self.lbPayStatus.text = @"未付款";
            _OrderAction=@"支付";
        }else if([_PayStatus  isEqual: @"1"]) {
            self.lbPayStatus.text = @"付款中";
            _OrderAction=@"支付";
        }else if([_PayStatus  isEqual: @"2"]) {
            self.lbPayStatus.text = @"已付款";
            _OrderAction=@"已付款";
        }else{
            self.lbPayStatus.text = @"未付款";
            _OrderAction=@"支付";
        }
        
        //0 未确认
        //1 已确认
        //2 已取消
        //3 无效
        //4 退货
        //5 已分单
        //6 部分分单
        
        if ([_OrderStatus  isEqual: @"0"]) {
            self.lbOrderStatus.text = @"未确认";
        }else if([_OrderStatus  isEqual: @"1"]){
            
            self.lbOrderStatus.text = @"已确认";
            self.lbOrderStatus.textColor = [UIColor darkTextColor];
        }else if([_OrderStatus  isEqual: @"2"]){
            self.lbOrderStatus.text = @"已取消";
            self.lbOrderStatus.textColor = [UIColor redColor];
        }else if([_OrderStatus  isEqual: @"3"]){
            self.lbOrderStatus.text = @"无效";
            self.lbOrderStatus.textColor = [UIColor redColor];
        }else if([_OrderStatus  isEqual: @"4"]){
            
            self.lbOrderStatus.text = @"退货";
            self.lbOrderStatus.textColor = [UIColor redColor];
        }else if([_OrderStatus  isEqual: @"5"]){
            self.lbOrderStatus.text = @"已分单";
            self.lbOrderStatus.textColor = [UIColor darkTextColor];
        }else if([_OrderStatus  isEqual: @"6"]){
            self.lbOrderStatus.text = @"部分分单";
            self.lbOrderStatus.textColor = [UIColor darkTextColor];
        }else{
            self.lbOrderStatus.text = @"未知";
            self.lbOrderStatus.textColor = [UIColor redColor];
        }
        
        
        //根据订单状态决定动作
        
        [self ReDrawButtons];
        
        ////自动跳转到支付页面
        if([_PageAction isEqualToString:@"2"]){
            NSLog(@"已经取得支付数据，转到支付页面");
            //[self btnpayclicked:_btnSubmit];
            //重要：主动调用 Segue 呈现页面
            [self performSegueWithIdentifier:@"ShowPay" sender:self];
        }
        
        
        
        
    }else if ([resultCodeObj integerValue] ==1)
    {
        NSString *strError = [res objectForKey:@"err_msg"];
        //[res objectForKey:@"amount_check"];

        //订单创建失败
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"获取订单错误"
                                                            message:strError
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
}

//删除订单的返回
-(void)resolvedeleteOrder:(NSDictionary*)res
{
    NSNumber *resultCodeObj = [res objectForKey:@"is_error"];
    if (resultCodeObj==nil) {
        //无法处理的结果
        
        resultCodeObj = [[NSNumber alloc] initWithInt:1];
    }
    if ([resultCodeObj integerValue] ==0){
        
        
        NSString *lsNotifyTitle = [[NSString alloc]initWithFormat:@"您已删除1个订单,订单号:%@",_Ordersn ];
        
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate showNotify:lsNotifyTitle HoldTimes:3];
        
        
        //传递消息
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"OrderRefreshNotification"
         object:nil
         userInfo:nil];
        
        //返回到前一个界面
        //[self dismissViewControllerAnimated:YES completion:nil]; //模态
        [self.navigationController popViewControllerAnimated:YES]; //PUSH
    }else if ([resultCodeObj integerValue] ==1)
    {
        NSString *strError = [res objectForKey:@"err_msg"];

        _OrderAction = @"支付";
        [self ReDrawButtons];
        //订单创建失败
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"删除订单错误"
                                                            message:strError
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
}

//申请退款的返回
-(void)resolverebackOrder:(NSDictionary*)res
{
    NSNumber *resultCodeObj = [res objectForKey:@"is_error"];
    if (resultCodeObj==nil) {
        //无法处理的结果
        
        resultCodeObj = [[NSNumber alloc] initWithInt:1];
    }
    if ([resultCodeObj integerValue] ==0){
        
        NSNumber *isOrderID = [res objectForKey:@"order_id"];
        
        _OrderID = [isOrderID stringValue];
        _Ordersn = [res objectForKey:@"order_sn"];
        
        _OrderAction=@"支付";
        [self ReDrawButtons];
        
        _PayStatus=@"0";
        _lbID.text = _OrderID;
        
        NSString *lsNotifyTitle;
        if (_Ordersn!=nil) {
            lsNotifyTitle = [[NSString alloc]initWithFormat:@"您的退款申请已受理！订单编号为:%@",_Ordersn ];
        }else{
            lsNotifyTitle = [[NSString alloc]initWithFormat:@"您的退款申请已受理！" ];
        }
        
        
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate showNotify:lsNotifyTitle HoldTimes:3];
        
        //传递消息
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"OrderRefreshNotification"
         object:nil
         userInfo:nil];

        //传递消息
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"couponsRefreshNotification"
         object:nil
         userInfo:nil];
        //返回到前一个界面
        //[self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES]; //PUSH
    }else if ([resultCodeObj integerValue] ==1)
    {
        NSString *strError = [res objectForKey:@"err_msg"];
        //[res objectForKey:@"amount_check"];
        _OrderAction = @"已付款";
        [self ReDrawButtons];
        //订单创建失败
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"申请退款错误"
                                                            message:strError
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
}

//再次购买的返回
//对于支付中的订单(部分完成)
-(void)resolvebuyAgain:(NSDictionary*)res
{
    NSNumber *resultCodeObj = [res objectForKey:@"is_error"];
    if (resultCodeObj==nil) {
        //无法处理的结果
        
        resultCodeObj = [[NSNumber alloc] initWithInt:1];
    }
    if ([resultCodeObj integerValue] ==0){
        
        NSNumber *isOrderID = [res objectForKey:@"order_id"];
        
        _OrderID = [isOrderID stringValue];
        _Ordersn = [res objectForKey:@"order_sn"];
        
        _OrderAction=@"支付";
        [self ReDrawButtons];
        
        _PayStatus=@"0";
        _lbID.text = _OrderID;
        
        NSString *lsNotifyTitle = [[NSString alloc]initWithFormat:@"感谢您的支持！新的订单号:%@",_Ordersn ];
        
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate showNotify:lsNotifyTitle HoldTimes:3];
        
        //需要刷新订单页面
        [self getOrderDetails:_OrderID];
        
    }else if ([resultCodeObj integerValue] ==1)
    {
        NSString *strError = [res objectForKey:@"err_msg"];
        //[res objectForKey:@"amount_check"];
        _OrderAction = @"已付款";
        [self ReDrawButtons];
        //订单创建失败
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提交订单错误"
                                                            message:strError
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
}


//重新加载表视图
-(void)reloadView:(NSDictionary*)res
{
    NSNumber *resultCodeObj = [res objectForKey:@"is_error"];
    if (resultCodeObj==nil) {
        //无法处理的结果
        
        resultCodeObj = [[NSNumber alloc] initWithInt:1];
    }
    if ([resultCodeObj integerValue] ==0){

        NSNumber *isOrderID = [res objectForKey:@"order_id"];
    
        _OrderID=[isOrderID stringValue];
        _OrderAction=@"支付";
        _PayStatus=@"0";
        _lbID.text = _OrderID;
        
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
            self.btnSubmit.hidden = true;
            self.btnCreate.hidden = false;
        }else if ([_OrderAction  isEqual: @"支付"]){
            self.btnSubmit.titleLabel.text = @"支付";
            self.btnSubmit.hidden = false;
            self.btnCreate.hidden = true;
        }else if ([_OrderAction  isEqual: @"已付款"]){
            self.btnCreate.titleLabel.text = @"申请退款";
            self.btnSubmit.hidden = true;
            self.btnCreate.hidden = false;
        }else{
            self.btnSubmit.hidden = true;
            self.btnCreate.hidden = false;
        }

    }else
    {
        //订单创建失败
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"创建订单错误"
                                                            message:@"无效的订单信息"
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
