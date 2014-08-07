//
//  myMenuTableViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-7-29.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "myMenuTableViewController.h"
#import "carswashOrderTableViewController.h"

@interface myMenuTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation myMenuTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //用户登录的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginCompletion:)
                                                 name:@"LoginCompletionNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OrderWithLogin:)
                                                 name:@"OrderWithLoginNotification"
                                               object:nil];
    
    //订单的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OrderCompletion:)
                                                 name:@"OrderCompletionNotification"
                                               object:nil];
    //用户注册消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registerCompletion:)
                                                 name:@"RegisterCompletionNotification"
                                               object:nil];

    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if (false==delegate.isLogin) {
        NSLog(@"转到登录页面");
        /*userLoginViewController *loginview = [[userLoginViewController alloc] init];
         [self.navigationController pushViewController:loginview animated:YES];
         */
        
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"userLoginViewController"];
        
        _lbUsername.text = @"查看账户信息，请先登录";

        _txtMoney.text = @"余额 0 元";
        _menuPoint.text = @"积分 0";
        _btnLogin.titleLabel.text = @"登录";
        
        loginViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:loginViewController animated:YES completion:^{
            NSLog(@"打开登录界面");
        }];
        
    }else if(![delegate.username isEqual:@""]){
        _userid = delegate.userid;
        _username = delegate.username;
        _usermoney = delegate.usermoney;
        _userpoints = delegate.userpoints;
        
        _lbUsername.text = _username;
        
        _txtMoney.text = [[NSString alloc]initWithFormat:@"余额 %1.2f 元", _usermoney];
        _menuPoint.text = [[NSString alloc]initWithFormat:@"积分 %1.0f", _userpoints];
        _btnLogin.titleLabel.text = @"退出";
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//页面即将展示
-(void) viewWillAppear:(BOOL)animated{
        
    //主动查一下积分、余额信息 （以后改为消息触发）
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //_username  = delegate.username;
    _usermoney = delegate.usermoney;
    _userpoints = delegate.userpoints;
    
    _txtMoney.text = [[NSString alloc]initWithFormat:@"余额 %1.2f 元", _usermoney];
    
    _menuPoint.text = [[NSString alloc]initWithFormat:@"积分 %1.0f", _userpoints];
    
    
    if ((delegate.userbonus > 0)&&(![delegate.userid isEqualToString:@""])){
        _menuBonus.text = [[NSString alloc] initWithFormat:@"红包 [ %1.0f ]",delegate.userbonus];
        
    }else{
        
        _menuBonus.text = @"红包";
    }
    
    if ([delegate.userid isEqualToString:@""]) {
        _btnLogin.titleLabel.text = @"登录";
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // 返回按钮
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]init];
    backItem.title=@"";
    backItem.tintColor=[UIColor colorWithRed:129/255.0 green:129/255.0  blue:129/255.0 alpha:1.0];
    self.navigationItem.backBarButtonItem = backItem;
    
    if([segue.identifier isEqualToString:@"menupayed"])
    {
        carswashOrderTableViewController *itemPage1 = segue.destinationViewController;
        
        itemPage1.filterType = @"1";
    }
    
    if([segue.identifier isEqualToString:@"menunopay"])
    {
        carswashOrderTableViewController *itemPage2 = segue.destinationViewController;
        itemPage2.filterType = @"0";
    }
    
    if([segue.identifier isEqualToString:@"menuCoupons"])
    {
        
    }

}


#pragma mark - Table view data source
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row == 8 ) {
        return 0;
        
    }else{
        return 44;
    }
}*/

/*
- (CGFloat)tableView:(UITableView *)tableView heightForSelectionAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row == 5 ) {
        return 0;
        
    }else{
        return 44;
    }

}*/

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 0;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//登录返回
-(void)loginCompletion:(NSNotification*)notification {
    
    NSDictionary *theData = [notification userInfo];
    _userid = [theData objectForKey:@"ID"];
    _username = [theData objectForKey:@"name"];
    
    _usermoney = [[theData objectForKey:@"user_money"]doubleValue];
    _userpoints = [[theData objectForKey:@"pay_points"]doubleValue];
    
    NSLog(@"登录页面返回,username = %@", _username);
    NSString *lsLogin = [theData objectForKey:@"isLogin"];
    
    
    //页面显示用户登录信息
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //if (false==delegate.isLogin) {
    if ([lsLogin isEqual:@"0"]) {
        _lbUsername.text = @"查看账户信息，请先登录";//_username;
        _btnLogin.titleLabel.text = @"登录";
        _withnoLogin = @"1";
        _txtMoney.text = [[NSString alloc]initWithFormat:@"余额 0.00 元"];
        _menuPoint.text = [[NSString alloc]initWithFormat:@"积分 0"];
        _menuBonus.text = @"红包";
        //[self.tableView reloadData];
        
    }else{
        
        delegate.userid = _userid;
        delegate.username = _username;
        delegate.usermoney = _usermoney;
        delegate.userpoints = _userpoints;
        
        _btnLogin.titleLabel.text = @"退出";
        _lbUsername.text = _username;

        _txtMoney.text = [[NSString alloc]initWithFormat:@"余额 %1.2f 元", _usermoney];
        _menuPoint.text = [[NSString alloc]initWithFormat:@"积分 %1.0f", _userpoints];
        _menuBonus.text = @"红包";
        _withnoLogin = @"";
        
    }

    
}


//订单无法提交的跳转,需要登录
-(void)OrderWithLogin:(NSNotification*)notification {
    
    //
    _withnoLogin = @"";
    NSLog(@"订单无法提交的跳转，缺少用户登录信息。");
    [self btnLogin:_btnLogin];
}

//订单完成后跳转
-(void)OrderCompletion:(NSNotification*)notification {

    [self performSegueWithIdentifier:@"menuCoupons" sender:self];
    /*
    NSDictionary *theData = [notification userInfo];
    _orderName = [theData objectForKey:@"name"];
    _orderID = [theData objectForKey:@"ID"];
    _FromOrder = @"1";
    _iPageIndex = 0;
    //
    NSLog(@"订单完成后跳转,%@",_orderID);
    _btnmyCoupons.titleLabel.text = @"订单消费券";
    [self startRequest];
     */
}

//注册返回
-(void)registerCompletion:(NSNotification*)notification {
    
    NSDictionary *theData = [notification userInfo];
    
    NSString *isRegist = [theData objectForKey:@"isRegist"];
    if ([isRegist isEqualToString:@"0"]) {
        //注册失败
        NSLog(@"注册无效！");
        return;
    }else if ([isRegist isEqualToString:@"1"]){
        NSLog(@"注册成功！");
    }
    
    _userid = [theData objectForKey:@"ID"];
    
    _username = [theData objectForKey:@"name"];
    _password = [theData objectForKey:@"password"];
    
    _userphone = [theData objectForKey:@"phone"];
    
    NSLog(@"注册用户返回,username = %@",_username);
    
    if (([_userid isEqualToString:@""])||(_userid==nil)) {
        NSLog(@"注册用户ID无效");
        return;
    }
    
    //更新用户信息
    

}



//登录退出
- (IBAction)btnLogin:(id)sender {
    if ([_btnLogin.titleLabel.text isEqualToString:@"退出"]) {
        //退出
        //订单创建失败
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"退出账户"
                                                            message:@"您确实要退出当前账户吗？"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"退出",nil];
        [alertView show];
        
        
    }else{
        //登录
        [self performSegueWithIdentifier:@"useractlogin" sender:self];
        
    }
    
}

//退出 询问操作结果
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //退出
        _isQuitCurrent = true;
        
        
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        
        delegate.isLogin= false;
        delegate.userid = @"";
        
        delegate.password = @"";
        delegate.isAutoLogin = false;
        
        delegate.usermoney = 0;
        delegate.userpoints = 0;
        
        //存档配置
        [delegate SaveConfig];
        
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"isLogin",@"", @"ID",@"", @"name", nil];
        
        //传递消息
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"LoginCompletionNotification"
         object:nil
         userInfo:dataDict];
        _btnLogin.titleLabel.text = @"登录";
        //重要：主动调用 Segue 呈现页面
        NSLog(@"退出登录");
        [self performSegueWithIdentifier:@"useractlogin" sender:self];
        
        
    }else{
        _isQuitCurrent = false;
        //
        _btnLogin.titleLabel.text = @"退出";
        
        NSLog(@"取消退出");
    }
    
}

@end
