//
//  mycarTableViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-8-28.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "mycarTableViewController.h"

@interface mycarTableViewController ()
//重点说明
//2014-5-25  Created By Robin
//定义可配置的数据参数（对于简单查询只需1组配置）
//命名规则： i 表示实例变量；P 表示 页面变量； s 表示 数据类型为String；
#pragma mark- declare 声明变量
@property (strong, nonatomic) IBOutlet UITableView *tableView;
//初始化统一调用方法：initPage
@property (strong, nonatomic) NSString *iPs_PageName; //页面名称(用于标记参数组)
@property (strong, nonatomic) NSString *iPs_URL; //请求数据接口模板--地址
@property (strong, nonatomic) NSString *iPs_PAGE; //请求数据接口模板--页面
@property (strong, nonatomic) NSString *iPs_POST; //请求数据POST参数模板

@property (strong, nonatomic) NSString *iPs_POSTAction; //请求数据POST参数Action

@property (strong, nonatomic) NSString *iPs_POST2; //请求数据POST参数模板

@property (strong, nonatomic) NSString *iPs_POSTAction2; //请求数据POST参数Action

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

@implementation mycarTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self initPage];
    }
    return self;
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
        [self startRequest];
    }
}

//初始化页面变量组和参数
- (void)initPage
{
    //根据页面类型不同需要配置的部分
    _iPs_PageName=@"车主资料"; //页面名称(用于标记页面参数配置)
    //_iPs_URL=@"http://114.112.73.223:8080/"; //请求数据接口模板--地址
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _iPs_URL=delegate.iPs_URL; //请求数据接口模板--地址
    
    _iPs_PAGE=@"carinfo_app.php"; //请求数据接口模板--页面
    
    _iPs_POSTAction = @"show_info";  //获取信息
    _iPs_POST = @"act=%@&userid=%@"; //请求数据POST参数模板
    
    _iPs_POSTAction2 = @"carlist";  //获取品牌，系列，型号
    _iPs_POST2 = @"act=%@&car_brand=%@&car_category=%@"; //请求数据POST参数模板
    
    //提交
    _iPs_POSTAction3 = @"insert_usercar";  //提交我的汽车信息
    _iPs_POST3 = @"act=%@&userid=%@&car_brand=%@&car_category=%@&car_model=%@&time=%@&distance=%@"; //请求数据POST参数模板
    
    _iPs_POSTID=delegate.userid;
    
    _iPs_POSTQueryOption=@"0"; //请求数据POST参数ID2 0 查询，1 查品牌，2 查系列 ，3查型号，4 提交
    _iPs_POSTQueryRegion=@""; //请求数据POST参数ID3
    
    
    //不随页面类型改变的部分
    _iPageIndex = 1;//初始化页面序号
    if (([_iPs_POSTID isEqualToString:@""])||(_iPs_POSTID == nil)) {
        [delegate showNotify:@"感谢您的支持，请您先登录！" HoldTimes:2];
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.pickSelect.dataSource = self;
    self.pickSelect.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Action

- (IBAction)txtbuytimeChanged:(id)sender {
    _inbuytime = _txtbuytime.text;
    
}

- (IBAction)txtmileageChanged:(id)sender {
    _inmileage = _txtmileage.text;
}

- (IBAction)txtEditEnd:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)btnSubmitClicked:(id)sender {
    
    if ([_btnSubmit.titleLabel.text isEqualToString:@"修改"]) {
        [_btnSubmit setTitle:@"提交" forState:UIControlStateNormal];
        _iPs_POSTQueryOption = @"1";
        [self startRequest];
        
        return;
    }
    
    

    
    //提交数据
    //验证数据是否已填写完整
    
    _inbuytime = _txtbuytime.text;
    _inmileage = _txtmileage.text;
    

    NSString *strError = @"";
    if (([_inbrand isEqualToString:@""])||(_inbrand==nil) ){
        strError = @"请填写品牌";
    }
    if (([_inseries isEqualToString:@""])||(_inseries==nil) ){
        strError = @"请填写系列";
    }
    if (([_inmodel isEqualToString:@""])||(_inmodel==nil) ){
        strError = @"请填写汽车型号";
    }
    if (([_inbuytime isEqualToString:@""])||(_inbuytime==nil) ){
        strError = @"请填写购车时间";
    }
    if (([_inmileage isEqualToString:@""])||(_inmileage==nil) ){
        strError = @"请填写行车里程";
    }
    
    if (![strError isEqualToString:@""]) {
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate showNotify:strError HoldTimes:2];
        return;
    }
    NSLog(@"提交用户汽车信息");
    _iPs_POSTQueryOption=@"4";
    [self startRequest];
}


//由于数字键盘没有Return键，当点击界面其它元素自动释放焦点以隐藏键盘
- (void)touchesBegan: (NSSet *)touches withEvent:(UIEvent *)event
{
    // do the following for all textfields in your current view
    [self.txtmileage resignFirstResponder];
    [self.txtbuytime resignFirstResponder];
    //[self txtInputChanged:_txtuserinput];
    
}

#pragma mark - Table view data source

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
}*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}*/

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
#pragma mark 实现协议UIPickerViewDataSource方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 3;//拨盘包含3列
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    int icount = 0;
	if (component == 0) {
        //个数
		icount = [self.listData count];
    }else if (component == 1) {
        //个数
        icount = [self.listDataseries count];
	} else {
        //个数
		icount = [self.listDatamodel count];
	}
	return icount;
}

#pragma mark 实现协议UIPickerViewDelegate方法
-(NSString *)pickerView:(UIPickerView *)pickerView
			titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *strName = @"1";
	if (component == 0) {
        //选择品牌
        strName = [[self.listData objectAtIndex:row] objectForKey:@"description"];
		
	} else if(component == 1) {
        //选择系列
        strName = [[self.listDataseries objectAtIndex:row]objectForKey:@"description"];

	}else{
        //选择型号
        strName = [[self.listDatamodel objectAtIndex:row] objectForKey:@"description"];
    }
    return strName;
}

- (void)pickerView:(UIPickerView *)pickerView
	  didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *seletedName = @"";
	if (component == 0) {
        //品牌
		seletedName = [[self.listData objectAtIndex:row] objectForKey:@"description"];
        
        _inbrand = seletedName;
        _txtbrand.text = _inbrand;
        
        _iPs_POSTQueryOption = @"2";
        [self startRequest];
        
    } else if(component == 1) {
        //选择系列
        seletedName = [[self.listDataseries objectAtIndex:row] objectForKey:@"description"];
        
        _inseries = seletedName;
        _txtseries.text = _inseries;
        _iPs_POSTQueryOption = @"3";
        [self startRequest];
        
	}else{
        //选择型号
        seletedName = [[self.listDatamodel objectAtIndex:row] objectForKey:@"description"];
        _inmodel = seletedName;
        _txtmodel.text = _inmodel;
        
    }

		//NSArray *array = [self.pickerData objectForKey:seletedProvince];
		//self.pickerCitiesData = array;
		//[self.pickSelect reloadComponent:1];
        NSLog(@"%@", seletedName);
	
}

//返回指定列的宽度
- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if (component==0) {
        //第0列，宽为100
        return  90;
    } else if(component==1){
        //第1列，宽为100
        return  90;
    }
    else{
        //第三列宽为120
        return 140;
    }
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return  45;
}


#pragma mark- POST Data 页面请求数据
/*
 * 开始请求Web Service
 */
-(void)startRequest
{
    _isConnected = false;
    
    
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
    
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    NSString *post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID];
    
    if ([_iPs_POSTQueryOption isEqualToString:@"0" ]){
        //读取carinfo
        
    }else if ([_iPs_POSTQueryOption isEqualToString:@"1" ]){
        //获取品牌
        post = [NSString stringWithFormat:_iPs_POST2,_iPs_POSTAction2,@"",@""];
        
    }else if ([_iPs_POSTQueryOption isEqualToString:@"2" ]){
        //获取系列
        post = [NSString stringWithFormat:_iPs_POST2,_iPs_POSTAction2,_inbrand,@""];
    }else if ([_iPs_POSTQueryOption isEqualToString:@"3" ]){
        //获取型号
        post = [NSString stringWithFormat:_iPs_POST2,_iPs_POSTAction2,_inbrand,_inseries];
    }else if ([_iPs_POSTQueryOption isEqualToString:@"4" ]){
        //提交资料
        post = [NSString stringWithFormat:_iPs_POST3,_iPs_POSTAction3,_iPs_POSTID,_inbrand, _inseries, _inmodel, _inbuytime, _inmileage];
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
        
        NSNumber *resultCodeObj = [res objectForKey:@"is_error"];
        if (resultCodeObj==nil) {
            //无法处理的结果
            
            resultCodeObj = [[NSNumber alloc] initWithInt:1];
            
        }
        
        if ([resultCodeObj integerValue] ==0){
            //成功
            NSString *lsName = @"";
            int iPos = 0;
            if ([_iPs_POSTQueryOption isEqualToString:@"0" ]){
                //读取carinfo
                NSMutableDictionary* car_info = [res objectForKey:@"car_info"];
                NSEnumerator *enumerator = [car_info objectEnumerator];
                
                NSArray *results = [enumerator allObjects];
                
                NSMutableDictionary* car1 = [results objectAtIndex:0];

                _inbrand = [car1 objectForKey:@"brand_name"];
                _inseries = [car1 objectForKey:@"category_name"];
                _inmodel = [car1 objectForKey:@"model_name"];
                _inbuytime = [car1 objectForKey:@"times"];
                _inmileage = [car1 objectForKey:@"distance"];
                
                _txtbrand.text = _inbrand;
                _txtseries.text = _inseries;
                _txtmodel.text = _inmodel;
                
                _txtbuytime.text = _inbuytime;
                _txtmileage.text = _inmileage;
                
                
                //填充选择器数据
                [_btnSubmit setTitle:@"修改" forState:UIControlStateNormal];
                //_iPs_POSTQueryOption = @"1";
                //[self startRequest];
            }else if ([_iPs_POSTQueryOption isEqualToString:@"1" ]){
                //获取品牌
                NSMutableDictionary* car_info = [res objectForKey:@"carlist"];
                NSEnumerator *enumerator = [car_info objectEnumerator];
                
                NSArray *results = [enumerator allObjects];
                iPos = 0;
                
                for (int i = 0; i < results.count; i++) {
                    lsName = [[results objectAtIndex:i]objectForKey:@"description"];
                    
                    //[_listData addObject:[lsName copy]];
                    if ((iPos==0)&&([lsName isEqualToString:_inbrand])) {
                        iPos = i;
                    }
                }
                _listData = [NSMutableArray arrayWithArray:results];
                
                
                if (_listData.count > 0) {
                    [_pickSelect reloadComponent:0];
                    [_pickSelect selectRow:iPos inComponent:0 animated:YES];
                    _inbrand = [[_listData objectAtIndex:iPos]objectForKey:@"description"];
                    
                    _iPs_POSTQueryOption = @"2";
                    [self startRequest];
                }
            }else if ([_iPs_POSTQueryOption isEqualToString:@"2" ]){
                //获取系列
                NSMutableDictionary* car_info = [res objectForKey:@"carlist"];
                NSEnumerator *enumerator = [car_info objectEnumerator];
                
                NSArray *results = [enumerator allObjects];
                iPos = 0;
                
                for (int i = 0; i < results.count; i++) {
                    lsName = [[results objectAtIndex:i]objectForKey:@"description"];
                    //[_listDataseries addObject:[lsName copy]];
                    if ((iPos==0)&&([lsName isEqualToString:_inseries])) {
                        iPos = i;
                    }
                }
                _listDataseries = [NSMutableArray arrayWithArray:results];
                
                if (_listDataseries.count > 0) {
                    
                    [_pickSelect reloadComponent:1];
                    [_pickSelect selectRow:iPos inComponent:1 animated:YES];
                    _inseries = [[_listDataseries objectAtIndex:iPos]objectForKey:@"description"];
                    
                    _iPs_POSTQueryOption = @"3";
                    [self startRequest];
                }

            }else if ([_iPs_POSTQueryOption isEqualToString:@"3" ]){
                //获取型号
                NSMutableDictionary* car_info = [res objectForKey:@"carlist"];
                NSEnumerator *enumerator = [car_info objectEnumerator];
                
                NSArray *results = [enumerator allObjects];
                iPos = 0;
                for (int i = 0; i < results.count; i++) {
                    lsName = [[results objectAtIndex:i]objectForKey:@"description"];
                    //[_listDatamodel addObject:lsName ];
                    if ((iPos==0)&&([lsName isEqualToString:_inmodel])) {
                        iPos = i;
                    }
                }

                _listDatamodel = [NSMutableArray arrayWithArray:results];
                if (_listDatamodel.count > 0) {
                    
                    [_pickSelect reloadComponent:2];
                    [_pickSelect selectRow:iPos inComponent:2 animated:YES];

                    _inmodel = [[_listDatamodel objectAtIndex:iPos]objectForKey:@"description"];
                }
                
            }else if ([_iPs_POSTQueryOption isEqualToString:@"4" ]){
                //提交资料
                NSLog(@"车辆信息已提交完成！");
                washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
                [delegate showNotify:@"恭喜您，您的车辆信息已成功提交！" HoldTimes:3];
                
                [_btnSubmit setTitle:@"修改" forState:UIControlStateNormal];

            }
            
            _txtbrand.text = _inbrand;
            _txtseries.text = _inseries;
            _txtmodel.text = _inmodel;
            //_txtbuytime.text = @"";
            //_txtmileage.text = @"";
            
            
            
        } else {
            
            _iPageIndex = 0;
            NSString *Errormsg = [res objectForKey:@"err_msg"];
            //NSString *isMsg = [res objectForKey:@"is_login"];
            
            NSLog(@"数据请求错误：%@",Errormsg);
            
            //NSString *lsMsg = [[NSString alloc]initWithFormat:@"无法提交建议\n%@", Errormsg];
            
            //_txtbrand.text = @"";
            //_txtseries.text = @"";
            //_txtmodel.text = @"";
            //_txtbuytime.text = @"";
            //_txtmileage.text = @"";

            //[delegate showNotify:lsMsg HoldTimes:2.5];
            if ([_iPs_POSTQueryOption isEqualToString:@"0" ]){
                //读取carinfo
                [_btnSubmit setTitle:@"提交" forState:UIControlStateNormal];
                _iPs_POSTQueryOption = @"1";
                [self startRequest];
            }
            
        }
        
    }@catch(NSException *exp1){
        
    }
    
    
    
}

@end
