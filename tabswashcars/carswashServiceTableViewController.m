//
//  carswashServiceTableViewController.m
//  tabswashcars
//
//  Created by Robinpad on 14-5-13.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import "carswashServiceTableViewController.h"
#import "carswashDetailViewController.h"
#import "MJRefresh.h"
#import "navMapsViewController.h"
#import "PoiSearchViewController.h"
#import "AMWaveTransition.h"

@interface carswashServiceTableViewController ()<UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate>{
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;

}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet AMWaveTransition *interactive;
//重点说明
//2014-5-25  Created By Robin
//定义可配置的数据参数（对于简单查询只需1组配置）
//命名规则： i 表示实例变量；P 表示 页面变量； s 表示 数据类型为String；
//初始化统一调用方法：initPage
@property (strong, nonatomic) NSString *iPs_PageName; //页面名称(用于标记参数组)
@property (strong, nonatomic) NSString *iPs_URL; //请求数据接口模板--地址
@property (strong, nonatomic) NSString *iPs_PAGE; //请求数据接口模板--页面
@property (strong, nonatomic) NSString *iPs_PAGE2;//页面请求
@property (strong, nonatomic) NSString *iPs_POST; //请求数据POST参数模板
@property (strong, nonatomic) NSString *iPs_POST2; //请求数据POST参数模板
@property (strong, nonatomic) NSString *iPs_POSTAction; //请求数据POST参数Action

//传入变化的参数组,参数数目根据接口需要而变化
@property (strong, nonatomic) NSString *iPs_POSTID; //请求数据POST参数ID1
@property (strong, nonatomic) NSString *iPs_POSTQueryOption; //请求数据POST参数ID2
@property (strong, nonatomic) NSString *iPs_POSTQueryRegion; //请求数据POST参数ID3

//页面内部变量(由程序控制实际值)
@property (nonatomic) int iPageIndex;
@property (nonatomic) Boolean isConnected;

@end

//页面控制流程说明：
//1.初始化 viewWillAppear,initPage,viewDidLoad
//2.请求数据 startRequest
//3.数据返回解析 connectionDidFinishLoading , reloadView , tableView.reloadData
//4.数据展示 cellForRowAtIndexPath
//5.页面跳转 prepareForSegue


@implementation carswashServiceTableViewController

#pragma mark - initial View
//底层的初始化
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
    
    ////[self setServiceTitle];
    
    //地区变更，刷新
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    if ((delegate.userAreaID != nil)&&(![delegate.userAreaID isEqualToString:@""])) {
        _iPs_POSTQueryRegion = delegate.userAreaID;
    }

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setDelegate:self];
    
    [self.interactive attachInteractiveGestureToNavigationController:self.navigationController];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.interactive detachInteractiveGesture];
}

//页面基本元素已载入,开始增添个性化的功能
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // 1.手动注册cell
    //[self.tableView registerClass:[serviceViewCell class] forCellReuseIdentifier:@"serviceCell"];
    //[self.navigationController.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    [self.navigationController.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 78;//68;
    
    //_isplayAnimation = true;
    //self.tableView.allowsSelection = NO; // We essentially implement our own selection
    //self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0); // Makes the horizontal row seperator stretch the entire length of the table view
    _interactive = [[AMWaveTransition alloc] init];
    //刷新列表的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ServiceRefresh:)
                                                 name:@"ServiceRefreshNotification"
                                               object:nil];
    //加载数据
    //[self startRequest];
    
    // 3.集成刷新控件
    // 3.1.下拉刷新
    //[self addHeader];
    
    // 3.2.上拉加载更多
    [self addFooter];
    [self addHeader];
}

//释放内存占用,比如数据表格，缓存的图片等
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [_listData removeAllObjects ];
    [self startRequest];
}

- (void)dealloc
{
    [self.navigationController setDelegate:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    if (operation != UINavigationControllerOperationNone) {
        AMWaveTransition *transition = [AMWaveTransition transitionWithOperation:operation];
        [transition setTransitionType:AMWaveTransitionTypeNervous];//AMWaveTransitionTypeSubtle
        return transition;

    }
    return nil;
}

- (NSArray*)visibleCells
{
    NSMutableArray *cells = [@[] mutableCopy];

    [cells addObjectsFromArray:[self.tableView visibleCells]];
    
    return cells;
    //return [self.tableView visibleCells];
}


//初始化页面变量组和参数
- (void)initPage
{
    //根据页面类型不同需要配置的部分
    _iPs_PageName=@"服务列表"; //页面名称(用于标记页面参数配置)
    //_iPs_URL=@"http://114.112.73.223:8080/"; //请求数据接口模板--地址
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    _iPs_URL=delegate.iPs_URL; //请求数据接口模板--地址

    _iPs_PAGE=@"category_app.php"; //请求数据接口模板--页面
    _iPs_PAGE2=@"distance.php";      //距离查询
    _iPs_POST=@"act=%@&cat_id=%@&page=%d&sel_attr=%@&region_id=%@"; //请求数据POST参数模板
    _iPs_POST2=@"act=%@&cat_id=%@&page=%d&sel_attr=%@&region_id=%@&latitude=%@&longitude=%@&meter=%@"; //请求数据POST参数模板
    _iPs_POSTAction =@"wash_list";
    
    _iPs_POSTID=@"139"; //请求数据POST参数ID1
    _iPs_POSTQueryOption=@"1"; //请求数据POST参数ID2
    _iPs_POSTQueryRegion=delegate.userAreaID ; //请求数据POST参数ID3
    
    _defaultCode = @"298";
    _defaultArea = @"枣庄市";
    _CityName = _defaultArea;
    
    _rowlimit = 60;
    _currentrowcount = 0;
    _isCategorychanged = false;
    if (_iPs_POSTQueryRegion==nil) {
        _iPs_POSTQueryRegion = _defaultCode;//枣庄
    }
    //设置分类
    if ((delegate.categorylist ==nil)||([delegate.categorylist isEqualToString:@""]))
    {
    }else{
        _iPs_POSTID = delegate.categorylist;
    
    }
    [self setServiceTitle];
    //不随页面类型改变的部分
    _iPageIndex = 1;//初始化页面序号
    _CellBgColor =[UIColor colorWithRed:49/255.0 green:155/255.0 blue:205/255.0 alpha:0.15];
}

//增加向下滑动刷新下页功能
- (void)addFooter
{
    __unsafe_unretained carswashServiceTableViewController *vc = self;
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.tableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        [self setPageNext];
        NSLog(@"下拉请求更多数据 %d",_iPageIndex);
        //加载数据
        [self startRequest];
        

        //[vc->_fakeData addObject:[NSString stringWithFormat:@"随机数据---%d", random]];

        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是footer
        [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:0.1];
        
        //NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    _footer = footer;
}

//滑动调用的刷新事件
- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    NSLog(@"滑动展示数据表格");
    // 刷新表格
    [self.tableView reloadData];
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}

//增加向上滑动返回上页功能
- (void)addHeader
{
    

    __unsafe_unretained carswashServiceTableViewController *vc = self;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self.tableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        NSLog(@"上拉请求翻页数据 %d",_iPageIndex);
        if (_iPageIndex<=1) {
            _iPageIndex = 1;
            NSLog(@"当前的数据列表没有历史缓存 %d",_iPageIndex);
            
        }else{
            //翻页控制逻辑这里后退1页
            _iPageIndex = _iPageIndex - 1;
            //加载数据
            [self startRequest];
        }
        //    if (_iPageIndex==0) {
        //        NSLog(@"页面初始化忽略上拉动作 %d",_iPageIndex);
        //        return;
        //    }
        
        // 这里的refreshView其实就是header
        [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:0.5];
        
        //NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
        //NSLog(@"%@----刷新完毕", refreshView.class);
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
            //NSLog(@"切换到：普通状态");
            break;
            
            case MJRefreshStatePulling:
            //NSLog(@"松开即可刷新的状态");
            break;
            
            case MJRefreshStateRefreshing:
            //NSLog(@"正在刷新状态");
            break;
            default:
            break;
        }
    };
    [header beginRefreshing];
    _header = header;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.listData.count;
}

#pragma mark - UITableView delegate methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rotationAngleDegrees = 0;
    CGFloat rotationAngleRadians = rotationAngleDegrees * (M_PI/180);
    //CGPoint offsetPositioning = CGPointMake(-200, -20);//左侧移入效果
    CGPoint offsetPositioning = CGPointMake(420, 20);//右侧移入效果
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform, rotationAngleRadians, 0.0, 0.0, 1.0);
    transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, 0.0);
    
    
    UIView *card = [cell contentView];
    card.layer.transform = transform;
    card.layer.opacity = 0.8;
    
    
    //控制滑入的速度 秒
    [UIView animateWithDuration:0.5f animations:^{
        card.layer.transform = CATransform3DIdentity;
        card.layer.opacity = 1;
    }];
}

//表格的定制化操作
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"serviceCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier  forIndexPath:indexPath];
    //使用自定义的单元格
    serviceViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier  forIndexPath:indexPath];
    
    if (cell == nil) {
        NSLog(@"表格初始化错误");
        NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"DiscountProductCell" owner:self options:nil] ;
        
        cell = [nib objectAtIndex:0];
    }
    //开始解析数据
    NSMutableDictionary*  dict = self.listData[indexPath.row];
    
    @try {
        
    
    //    cell.imageView.image = [UIImage imageNamed:strImgName];
    //处理来自的网络图片
    //NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSLog(@"图片缓存路径:%@",documentsDirectoryPath);
    //Get Image From URL
    //UIImage * imageFromURL = [self getImageFromURL:strImgURL];
    //带有缓存机制的图片加载
    NSString *strImgName = [dict objectForKey:@"goods_thumb"];
    NSString *strImgURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,strImgName];
    //没有必要每次都从网络获取图片，应该建立图片缓存，优先查找本地缓存
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSURL *imgurl = [[NSURL alloc] initWithString: strImgURL];
    
    //异步加载图片
    
    [manager downloadWithURL:imgurl
                     options:0
                    progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
         //NSLog(@"%d.正在下载图片 %d / %d", indexPath.row , receivedSize , expectedSize);
         
     }
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             // do something with image
             cell.cellImg.image = image;
             //NSLog(@"异步载入图片 %@",strImgURL);
         }
     }];
    
    //修改单元格背景色
    UIView *bgColorView = [[UIView alloc] init];
    
    bgColorView.backgroundColor = _CellBgColor;
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    //填充单元格
    NSString *lsTitle = @"";
    
    lsTitle = [dict objectForKey:@"goods_name"];
    if ([lsTitle length]>15) {
        lsTitle = [[dict objectForKey:@"goods_name"]substringToIndex:15];
    }
    cell.cellTitle.text =lsTitle;
    
    //cell.cellImg.image = [UIImage imageNamed:strImgURL];
    cell.cellMemo.text = [dict objectForKey:@"address_street"];
    //已售
    NSString *strLeve = [[NSString alloc] initWithFormat:@"已售 %@",[dict objectForKey:@"total"]];
        
    cell.cellLeve.text = strLeve;
    
    cell.cellOrder.text = [NSString stringWithFormat:@"%d", indexPath.row+1];
    
    //填充价格字段
    NSString *is_promote = [dict objectForKey:@"is_promote"];
    NSString *nmPrice = [dict objectForKey:@"promote_price"];
    NSString *nmSHPrice = [dict objectForKey:@"shop_price"];
    NSString *nmMKPrice = [dict objectForKey:@"market_price"];
    //NSString *strEndDate = [dict objectForKey:@"end_time"];
    //判断是否促销
    if (([is_promote isEqual:@"1"])&&(![nmPrice isEqual:@"0.00"])) {
        //执行促销活动价格
        NSString *strPrice = [[NSString alloc] initWithFormat:@"%@",nmPrice];
        //NSString *strEnd = @"";
        //截断末尾 0
//        strEnd=[strPrice substringFromIndex:[strPrice length]-1];
//        if ([strEnd isEqualToString:@"0"]) {
//            strPrice = [strPrice substringToIndex:[strPrice length]-1];
//        }
        cell.cellPrice.text = strPrice;
        cell.cellcmsPrice.text = [dict objectForKey:@"shop_price"];
    }else{
        //执行商城价格
        NSString *strPrice = [[NSString alloc] initWithFormat:@"%@",nmSHPrice];
        //NSString *strEnd = @"";
        //截断末尾 0
//        strEnd=[strPrice substringFromIndex:[strPrice length]-1];
//        if ([strEnd isEqualToString:@"0"]) {
//            strPrice = [strPrice substringToIndex:[strPrice length]-1];
//        }
        
        cell.cellPrice.text = strPrice;
        cell.cellcmsPrice.text = [[NSString alloc] initWithFormat:@"%1.0f元",[nmMKPrice doubleValue]];
        
        
    }
        

        cell.cellDistance.text = [dict objectForKey:@"distance"];
        if ([[dict objectForKey:@"distance"] isEqualToString:@"0"]){
            cell.cellDistance.text = @"";
        }
        
        if ([_iPs_POSTQueryOption isEqualToString:@"2"]) {
            NSString * clicked = [dict objectForKey:@"click_count"];
            
 
            NSString *strTips = clicked;
            if ([clicked length]>3) {
                double p = [clicked doubleValue]/1000.0;
                strTips = [[NSString alloc] initWithFormat:@"%1.1fK",p];
                
            }
            
            cell.cellDistance.text = [[NSString alloc] initWithFormat:@"人气%@",strTips];

            
        }
        
        //cell.cellDistance.text = @"<500m";
        
        //调整文本位置
        //位置向上偏移
        //CGPoint cellPricePoint = cell.cellPrice.center;
        
        //cellPricePoint.x = cellPricePoint.x - 20;
        
        //cell.cellPrice.center = cellPricePoint;
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
    }@catch (NSException *exception) {
        
    }
    @finally {
        
    }

    //NSString *strPrice = [[NSString alloc] initWithFormat:@"￥%@",[dict objectForKey:@"promote_price"]];
    //cell.cellPrice.text = strPrice;
    //cell.cellcmsPrice.text = [dict objectForKey:@"shop_price"];
    
    //以上已完成单元格修改
    return cell;
}

#pragma mark - Event Processor
//订单完成后跳转
-(void)ServiceRefresh:(NSNotification*)notification {
    
    
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    //地区变更，刷新
    if ((delegate.userAreaID != nil)&&(![delegate.userAreaID isEqualToString:@""])) {
        _iPs_POSTQueryRegion = delegate.userAreaID;

    }
    
    if ((delegate.categorylist ==nil)||([delegate.categorylist isEqualToString:@""]))
    {
        _iPs_POSTID = @"139";
    }else{
        _iPs_POSTID = delegate.categorylist;
        
    }
    
    if ((delegate.userCitySupported ==nil)||([delegate.userCitySupported isEqualToString:@""]))
    {
        _iPs_POSTQueryRegion = _defaultCode;
    }
    
    NSLog(@"服务列表页面刷新通知,%@", _iPs_POSTID );
    
    [self setServiceTitle];
    
    _iPageIndex = 0;
    //[_listData removeAllObjects ];
    _isCategorychanged = true;
    [self startRequest];
}


//地图展示
- (IBAction)btntoMapClicked:(id)sender {
    
    if ([self.listData count] == 0) {
        return;
    }
    
    self.tabBarController.selectedIndex = 1;
    [self performSelector:@selector(LocationDelay) withObject:nil afterDelay:0.8f];
    
    
    //[self.navigationController pushViewController:poimapview animated:NO];

    
}

- (void)LocationDelay{
    NSMutableDictionary*  dict = self.listData[0];

    //取导航列表直接推视图
    NSArray *arrControllers = self.tabBarController.viewControllers;
    self.tabBarController.selectedIndex = 1;
    
    for(UIViewController *viewController in arrControllers)
    {
        if([viewController isKindOfClass:[navMapsViewController class]])
        {
            //NavigationController
            UINavigationController *navCtrl = (UINavigationController *)viewController;
            
            //NSLog(@"%@",navCtrl.viewControllers);
            NSLog(@"服务列表标注到地图");
            
            PoiSearchViewController *poimapview;
            
            //如果已有初始化过的 PoiSearchViewController 则不再创建新实例
            for (UIViewController *mapviewController in navCtrl.viewControllers) {
                
                if([mapviewController isKindOfClass:[PoiSearchViewController class]]){
                    //存在,强制转换为地图的View
                    poimapview = (PoiSearchViewController *)mapviewController;
                    //传递参数
                    poimapview.listData = _listData;
                    poimapview.itemname = [dict objectForKey:@"goods_name"];
                    _Locationpt.latitude = [[dict objectForKey:@"Latitude"] doubleValue];
                    _Locationpt.longitude = [[dict objectForKey:@"Longitude"] doubleValue];
                    poimapview.Locationpt = _Locationpt;
                    poimapview.iZoomLevel = 14;
                    
                    //最后跳转页面
                    self.tabBarController.selectedIndex = 1;
                    
                    [poimapview LocationRefresh];
                    return;//防止重复推同一个视图
                }
                
            }
            
            if (poimapview == nil) {
                //创建新实例
                poimapview = [[PoiSearchViewController alloc] init];
            }
            
            //推送地图的视图
            [navCtrl pushViewController:poimapview animated:NO];
            //PoiSearchViewController 太多实例
            
            //传递参数
            poimapview.listData = _listData;
            poimapview.itemname = [dict objectForKey:@"goods_name"];
            _Locationpt.latitude = [[dict objectForKey:@"Latitude"] doubleValue];
            _Locationpt.longitude = [[dict objectForKey:@"Longitude"] doubleValue];
            poimapview.Locationpt = _Locationpt;
            poimapview.iZoomLevel = 14;
            
            //最后跳转页面
            self.tabBarController.selectedIndex = 1;
            
            return;
        }
        else
        {
            // view controller
        }
    }
}



//按照条件查找
- (IBAction)btnFilter:(id)sender {
    
    /*UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"默认等级排序"
                                  otherButtonTitles:@"按人气关注度",@"离我最近",@"近期销量高低",@"优惠价格最低",nil];
     */
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"默认销量排序"
                                  otherButtonTitles:@"按人气关注度",@"最新上架",@"优惠价格最高",@"优惠价格最低",@"离我最近",nil];
	actionSheet.actionSheetStyle =  UIActionSheetStyleAutomatic;
	[actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //NSLog(@"过滤条件选择 = %i",buttonIndex);
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString *lsButtonTitle = @"";

    switch (buttonIndex) {
        case 0:
            _iPs_POSTQueryOption = @"1";
            lsButtonTitle = @"销量排序";
            break;
        case 1:
            _iPs_POSTQueryOption = @"2";
            lsButtonTitle = @"人气关注度";
            break;
        case 2:
            _iPs_POSTQueryOption = @"3";
            lsButtonTitle = @"最新上架";
            break;
        case 3:
            _iPs_POSTQueryOption = @"4";
            lsButtonTitle = @"价格高优先";
            break;
        case 4:
            _iPs_POSTQueryOption = @"5";
            lsButtonTitle = @"优惠价最低";
            break;
        case 5:
            _iPs_POSTQueryOption = @"6";
            lsButtonTitle = @"距离最近";
            //如果位置不确定需要先推送到地图定位后再回来刷新
            if ((delegate.userlatitude==nil)||([delegate.userlatitude isEqualToString:@""])) {
                NSString *lsMsg = [[NSString alloc]initWithFormat:@" %@ 筛选需要开启 定位服务" ,lsButtonTitle];
                
                [delegate showNotify:lsMsg HoldTimes:2.5];
                self.tabBarController.selectedIndex = 1;
                _iPs_POSTQueryOption = @"0";
                return;
            }

            break;
        case 6:
            return;
            break;
    
        }
    
    //[self setTitle:lsButtonTitle];
    //_barButtonItem = [[UIBarButtonItem alloc] initWithTitle:lsButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(btnFilter)];
    //self.navigationItem.leftBarButtonItem = _barButtonItem;
    
    


    //重新加载数据
    _iPageIndex = 1;
    [_listData removeAllObjects ];
    [self startRequest];
    
    NSString *lsNotifyTitle = [[NSString alloc]initWithFormat:@"按照 %@ 筛选数据" ,lsButtonTitle];

    [delegate showNotify:lsNotifyTitle HoldTimes:2];
}

//更新服务列表标题
- (void) setServiceTitle{
    NSLog(@"页面标题：%@",_iPs_POSTID);
    if ([_iPs_POSTID isEqualToString:@"139" ]) {
        self.title = @"洗车服务";
    }else if ( [_iPs_POSTID isEqualToString:@"141" ]) {
        self.title = @"打蜡服务";
    }else if ( [_iPs_POSTID isEqualToString:@"176" ]) {
        self.title = @"贴膜服务";
    }else if ( [_iPs_POSTID isEqualToString:@"181" ]) {
        self.title = @"推荐套餐";
    }else{
        
        washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
        //NSString *strTips = [[NSString alloc] initWithFormat:@"%@ %@",delegate.userDistrict,delegate.userServiceName];
        NSString *strTips = delegate.userServiceName;
        self.title = strTips;
        
        //self.title = @"服务列表";
    }
}
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
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view 18963273133
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
 //选择了Table中的某一个Cell，跳转至明细页面
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
 
 //开始解析数据
 NSMutableDictionary*  dict = self.listData[indexPath.row];
 NSString *strID = [dict objectForKey:@"goods_id"];
 NSString *strName = [dict objectForKey:@"goods_name"];
 NSString *strPrice = [dict objectForKey:@"promote_price"];
 
 // 页面传值
 //self.serviceDetail;
 
 //        Note  *note = self.listData[indexPath.row];
 //        self.detailViewController.detailItem = note;
 }
 }
 */

#pragma mark - Navigation
//页面发生跳转，进入明细
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"ShowDetail"])
    {
        carswashDetailViewController *itemdetail = segue.destinationViewController;
        NSInteger selectedRow = [[self.tableView indexPathForSelectedRow] row];
        
        if (self.listData.count == 0){
            return;
        }
        
        NSMutableDictionary*  dict = self.listData[selectedRow];
        
        //NSString *strName = [dict objectForKey:@"goods_name"];
        itemdetail.title = [dict objectForKey:@"goods_name"];
        //已售
        itemdetail.iSellNumber = [dict objectForKey:@"total"];
        
        itemdetail.itemid = [dict objectForKey:@"goods_id"];
        NSLog(@"进入明细页面 %d", selectedRow );
        
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc]init];
        backItem.title=@"";
        backItem.tintColor=[UIColor colorWithRed:129/255.0 green:129/255.0  blue:129/255.0 alpha:1.0];
        self.navigationItem.backBarButtonItem = backItem;
        
    }
}



/*
 * 开始请求Web Service
 */
-(void)startRequest
{
    _isConnected = false;

    NSString *strURL = [[NSString alloc] initWithFormat:@"%@%@",_iPs_URL,_iPs_PAGE];
    
    NSURL *url = [NSURL URLWithString:[strURL URLEncodedString]];
    
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //设置分类
    if ((delegate.categorylist ==nil)||([delegate.categorylist isEqualToString:@""]))
    {
        _iPs_POSTID = @"139";
    }else{
        _iPs_POSTID = delegate.categorylist;
    }
    
    if ((delegate.userCitySupported ==nil)||([delegate.userCitySupported isEqualToString:@""]))
    {
        _iPs_POSTQueryRegion = _defaultCode;
    }

    //NSString *post = [NSString stringWithFormat:@"act=wash_list&cat_id=139&page=%d&sel_attr=0&region_id=%@",_iPageIndex,@"298"];
    NSString *post = [NSString stringWithFormat:_iPs_POST,_iPs_POSTAction,_iPs_POSTID,_iPageIndex,_iPs_POSTQueryOption,_iPs_POSTQueryRegion];
    
    if ([_iPs_POSTQueryOption isEqualToString:@"6"]) {
        //距离最近        pt.latitude = 35.087341;pt.longitude = 117.175142;
        //////////////////////////////////////////////////////////////////
        strURL = [[NSString alloc] initWithFormat:@"%@%@", _iPs_URL,_iPs_PAGE2];
        
        url = [NSURL URLWithString:[strURL URLEncodedString]];
        @try{
        post = [NSString stringWithFormat:_iPs_POST2,_iPs_POSTAction,_iPs_POSTID,_iPageIndex,_iPs_POSTQueryOption,_iPs_POSTQueryRegion,delegate.userlatitude,delegate.userlongitude,@"10000"];
        }@catch(NSException *excp1){
            NSLog(@"最近距离查询数据错误");
        }
        
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
    NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:_datas options:NSJSONReadingAllowFragments error:nil];
    
    //NSLog( @"Result: %@", [dict description] );
    //激活数据列表的刷新
    [self reloadView:dict];
}

#pragma mark - Page Data


//重新加载表视图
-(void)reloadView:(NSMutableDictionary*)res
{
    @try{
        NSNumber *resultCodeObj = [res objectForKey:@"count"];
        if ([resultCodeObj integerValue] >=0)
        {
            NSMutableArray *results = [res objectForKey:@"goods_list"];

            //[self.listSort addObjectsFromArray:self.listData ];
            //self.listSort = [res objectForKey:@"goods_list"];
            //for (id item in self.listSort){
            //    [self.listData insertObject:item ];
            //}
            //NSNumber *nIndex = [[NSNumber alloc] initWithInt:0];
            
            if (results && results.count > 0)
            {
                //如果是更换了查询过滤条件则不应保留数据
                
                NSMutableArray* ComboData = [NSMutableArray arrayWithCapacity:30];

                //NSLog(@"-:%@",ComboData.description);
                //处理数据的合并
                NSMutableDictionary * objRow;
                //1.要避免重复的数据
                //2.要限制每页最多显示的数据行 _rowlimit
                //3.向前翻页的控制需要重写
                int postion = 0;
                if (_isCategorychanged) {
                    [_listData removeAllObjects ];
                    _isCategorychanged = false;
                }
                //

                _currentrowcount = _listData.count;
                if ( _currentrowcount + results.count <= _rowlimit ){
                    postion = 0;
                }else{
                    postion = _rowlimit - results.count;
                    if(postion<0){postion = 0;}
                }
                
                    
                for (int i = postion; i< _listData.count;  i++) {
                    
                    objRow = [[_listData objectAtIndex:i] mutableCopy];
                    if(![ ComboData containsObject:objRow]){
                    [ComboData addObject:objRow ];
                    }
                    //[ComboData insertObject:objRow atIndex:ComboData.count];
                    
                }

                for (int i = 0; i< results.count;  i++) {
                    
                    objRow = [[results objectAtIndex:i] mutableCopy];
                    if(![ ComboData containsObject:objRow]){
                    [ComboData addObject:objRow ];
                    }
                    //[ComboData insertObject:objRow atIndex:ComboData.count];
                    
                }
                
                //NSLog(@"+:%@",ComboData.description);

                
                _currentrowcount = ComboData.count;
                //self.listData = [res objectForKey:@"goods_list"];
                self.listData = ComboData;
                //刷新Table重新加载Cell表格
                
                [self.tableView reloadData];
                _isCategorychanged = false;
                //[self.view setNeedsDisplay];
                
                NSLog(@"列表视图加载数据...共 %d 条",results.count);
                if (_iPageIndex>1 && _listData.count>0) {
                    int scrollpos = _listData.count - 10;
                    if (scrollpos<1) {
                        scrollpos = 1;
                    }
                    //移动到首行
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:scrollpos inSection:0]
                                                animated:YES
                                          scrollPosition:UITableViewScrollPositionMiddle];
                    
                    /*
                    //移动到首行
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                                                animated:YES
                                          scrollPosition:UITableViewScrollPositionMiddle];
                    */
                    
                    //最末行自动归位
                    if (results.count < 10){
                        NSLog(@"列表视图将循环到首行记录,共 %d 条 Page= %d",results.count, _iPageIndex);
                        _iPageIndex = 0;
                        /*washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
                        NSString *strTips = [[NSString alloc] initWithFormat:@"%@ 没有更多 %@ 了，\n总计：%d 。请试试其它分类吧",delegate.userDistrict,delegate.userServiceName,_listData.count];
                        [delegate showNotify:strTips HoldTimes:1];*/
                    }
                    
                }
            }

            if (results.count == 0) {
                if (_iPageIndex != 1){
                    NSLog(@"列表视图将循环到首行记录 Page= %d" ,_iPageIndex);
                    _iPageIndex = 1;
                    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
                    NSString *strTips = [[NSString alloc] initWithFormat:@"%@ 没有更多 %@ 了，\n总计：%d 。请试试其它分类吧",delegate.userDistrict,delegate.userServiceName,_listData.count];
                    [delegate showNotify:strTips HoldTimes:1];
                    //[self startRequest];
                    return;
                }else if (_iPageIndex <=1){
                    NSLog(@"当前列表下无数据");
 
                    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
                    if (delegate.isLimited) {
                        return;
                    }
                    NSString *strTips = [[NSString alloc] initWithFormat:@"%@ 没有发现开通 %@ 的商户，请试试其它分类",delegate.userDistrict,delegate.userServiceName];
                    
                    if ([_iPs_POSTQueryOption isEqualToString:@"6" ]) {
                        strTips = [[NSString alloc] initWithFormat:@"根据我的位置没有找到最近的 %@，请试试其它排序方式",delegate.userServiceName];
                        _iPs_POSTQueryOption = @"0";
                    }
                    
                    [delegate showNotify:strTips HoldTimes:1];
                }
            }
        }else {
            //{"state":0}
            NSNumber *resultStateObj = [res objectForKey:@"state"];
            if ([resultStateObj integerValue] ==0){
                self.iPageIndex = 1;
                NSLog(@"列表视图页面下次滚动将返回首行...");
                return;
            }
            NSString *errorStr = @"Service Error";
            self.iPageIndex = 1;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误信息"
                                                                message:errorStr
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
            [alertView show];
        }
    }@catch( NSException *ec1){
        NSLog(@"Exception: %@", [ec1 description]);
    }
    
}

//控制Page页面数据翻页
- (int)setPageNext
{
	const int N = 15;
	int nextPage = 0;
    nextPage = _iPageIndex + 1;
    if ((nextPage>N)||(_listData.count<10)) {
        nextPage = 1;
    }
    _iPageIndex = nextPage;
    NSLog(@"NextPage=%d",_iPageIndex);
    return nextPage;
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
