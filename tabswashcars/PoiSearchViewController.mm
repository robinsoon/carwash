//
//  PoiSearchViewController.m
//  BaiduMapApi
//
//  百度地图搜索定位应用模块
//  注意：商家位置视图使用了独立的 xib 文件
//

#import "PoiSearchViewController.h"


@implementation PoiSearchViewController


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}

//CMCC-001:tk33366678
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //必须将地图委托指向自己，否则不会触发添加标注的viewForAnnotation
    _mapView.delegate = self;
    
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
//        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
	_poisearch = [[BMKPoiSearch alloc]init];

	_cityText.text = @"滕州";
	_keyText.text  = @"洗车";
    curPage = 1;
    _isShowPoiLabel = true;
    // 设置地图级别 // 地图比例尺级别，在手机上当前可使用的级别为3-19级
    if (_iZoomLevel<=1||_iZoomLevel>19) {
        _iZoomLevel = 14;
    }
    [_mapView setZoomLevel:_iZoomLevel];
    _nextPageButton.titleLabel.text = @"搜索";
    _nextPageButton.enabled = true;
    _mapView.isSelectedAnnotationViewFront = YES;
    
    //初始定位[模拟器]
    CLLocationCoordinate2D pt;
    
    if ([_itemname isEqual:nil]|[_itemname  isEqual: @""]) {
        pt.latitude = 35.087341;
        pt.longitude = 117.175142;
    }else{
        _showMsgLabel.text = @"定位商家位置";
        pt.latitude = _Locationpt.latitude*1E6;
        pt.longitude = _Locationpt.longitude*1E6;
        
        pt = _Locationpt;
        
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = pt;
        item.title = _itemname;
        
        //添加新标记
        [_mapView addAnnotation:item];

    }
    
    _mapView.centerCoordinate = pt;
}


-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _poisearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _poisearch.delegate = nil; // 不用时，置nil
}

-(IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}

- (void)dealloc {

}

-(IBAction)onClickOk
{
    curPage = 1;
    BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc]init];
    citySearchOption.pageIndex = curPage;
    citySearchOption.pageCapacity = 10;
    citySearchOption.city= _cityText.text;
    citySearchOption.keyword = _keyText.text;
    BOOL flag = [_poisearch poiSearchInCity:citySearchOption];
    //[citySearchOption release];
    if(flag)
    {
        _nextPageButton.enabled = true;
        NSLog(@"搜索%@ 第%d页",_keyText.text,curPage);
    }
    else
    {
        _nextPageButton.enabled = false;
        NSLog(@"城市内检索发送失败");
    }


}


-(IBAction)onClickNextPage
{
    curPage++;
    /*
    //法一：城市内检索，请求发送成功返回YES，请求发送失败返回NO
    BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc]init];
    citySearchOption.pageIndex = curPage;
    citySearchOption.pageCapacity = 10;
    citySearchOption.keyword = _keyText.text;
    
    citySearchOption.city= _cityText.text;              //城市是BMKCitySearchOption的属性
    BOOL flag = [_poisearch poiSearchInCity:citySearchOption];
    //[citySearchOption release];
    */
    //法二：搜索周边
    BMKNearbySearchOption *nearSearchOption = [[BMKNearbySearchOption alloc]init];
    nearSearchOption.pageIndex = curPage;
    nearSearchOption.pageCapacity = 12;
    nearSearchOption.keyword = _keyText.text;
    nearSearchOption.location = _mapView.centerCoordinate; //中心点坐标
    nearSearchOption.radius = 6000;    //搜索距离半径 m 单位:米
    BOOL flag = [_poisearch poiSearchNearBy:nearSearchOption];
    
    if(flag)
    {
        _nextPageButton.enabled = true;
        _nextPageButton.titleLabel.text = @"下一页";
        NSLog(@"搜索%@ 第%d页",_keyText.text,curPage);
    }
    else
    {
        _nextPageButton.enabled = false;
        NSLog(@"城市内检索发送失败");
    }

}
#pragma mark -
#pragma mark implement BMKMapViewDelegate

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"carwashMark";//@"xidanMark";
	
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
		//((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorGreen;
        
        //创建自定义的图标
        UIView *viewForImage=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 69, 80)];
        UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 49)];
        [imageview setImage:[UIImage imageNamed:@"Acarwash60.png"]];
        [viewForImage addSubview:imageview];
        
        //增加标注的文本名称
        if (_isShowPoiLabel) {
            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 45, 69, 31)];
            label.text=[annotationView.annotation title];
            label.textColor = [UIColor blueColor];
            label.backgroundColor=[UIColor clearColor];
            [viewForImage addSubview:label];
        }
        
        //标注视图替换图标
        annotationView.image=[self getImageFromView:viewForImage];
        
        
		// 设置重天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
        NSLog(@"%@ 已标记",[annotationView.annotation title]);
    }
	
    // 设置位置
	annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
	annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    
    return annotationView;
}
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
    NSLog(@"%@ 已选中",[view.annotation title]);
}
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{

    //NSLog(@"didAddAnnotationViews");
}

-(UIImage *)getImageFromView:(UIView *)view{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//获取百度地图搜索结果
#pragma mark -
#pragma mark implement BMKSearchDelegate
//搜索结果展示(重要)
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    // 清除屏幕中所有的annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
	[_mapView removeAnnotations:array];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        
        //_detailData =result.poiInfoList;  //记录POI详情信息，包含地址、电话
		for (int i = 0; i < result.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = poi.pt;
            item.title = poi.name;
            
            //解读BMKPoiInfo(uid,name,adress,phone,city,pt,postcode,epoitype:POI类型，0:普通点 1:公交站 2:公交线路 3:地铁站 4:地铁线路)
            
            
            //添加新标记
            [_mapView addAnnotation:item];
            //NSLog(@"添加标记 %@ .",[item title]);
            
            if(i == 0)
            {
                //将第一个点的坐标移到屏幕中央[定位方法]
                _mapView.centerCoordinate = poi.pt;
            }

            //NSString* showmeg = [NSString stringWithFormat:@"1.%@ 经度:%f,纬度:%f", poi.name, item.coordinate.latitude,item.coordinate.longitude ];
            //NSLog(@"%@",showmeg) ;
        }
        if (result.poiInfoList.count == 0) {
            curPage = 0;
            
            NSLog(@"未发现新标记,搜索将返回首页");
            _showMsgLabel.text = @"未发现新标记,搜索将返回首页";
            _nextPageButton.titleLabel.text = @"搜索";
        }else{
            NSLog(@"已添加%d个标记",result.poiInfoList.count);
        }
	} else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"起始点有歧义");
    } else {
        // 各种情况的判断。。。
        NSLog(@"数据结果未预测");
        if (result.poiInfoList.count == 0) {
            curPage = 0;
            
            NSLog(@"未发现新标记,搜索将返回首页");
            _showMsgLabel.text = @"未发现新标记,搜索将返回首页";
            _nextPageButton.titleLabel.text = @"搜索";
        }

    }
}


//响应地图自带的事件
#pragma mark 底图手势操作
/**
 *点中底图标注后会回调此接口
 *@param mapview 地图View
 *@param mapPoi 标注点信息
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi*)mapPoi
{
    NSLog(@"onClickedMapPoi-%@",mapPoi.text);
    NSString* showmeg = [NSString stringWithFormat:@"标注:%@,\r\n当前经度:%f,当前纬度:%f,\r\nZoomLevel=%d;RotateAngle=%d;OverlookAngle=%d", mapPoi.text,mapPoi.pt.longitude,mapPoi.pt.latitude, (int)_mapView.zoomLevel,_mapView.rotation,_mapView.overlooking];
    _showMsgLabel.text = showmeg;
}
/**
 *点中底图空白处会回调此接口
 *@param mapview 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"onClickedMapBlank-latitude==%f,longitude==%f",coordinate.latitude,coordinate.longitude);
    NSString* showmeg = [NSString stringWithFormat:@"空白处(blank click).\r\n当前经度:%f,当前纬度:%f,\r\nZoomLevel=%d;RotateAngle=%d;OverlookAngle=%d", coordinate.longitude,coordinate.latitude,
                         (int)_mapView.zoomLevel,_mapView.rotation,_mapView.overlooking];
    _showMsgLabel.text = showmeg;
}

/**
 *双击地图时会回调此接口
 *@param mapview 地图View
 *@param coordinate 返回双击处坐标点的经纬度
 */
- (void)mapview:(BMKMapView *)mapView onDoubleClick:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"onDoubleClick-latitude==%f,longitude==%f",coordinate.latitude,coordinate.longitude);
    NSString* showmeg = [NSString stringWithFormat:@"双击地图(double click).\r\n当前经度:%f,当前纬度:%f,\r\nZoomLevel=%d;RotateAngle=%d;OverlookAngle=%d", coordinate.longitude,coordinate.latitude,
                         (int)_mapView.zoomLevel,_mapView.rotation,_mapView.overlooking];
    _showMsgLabel.text = showmeg;
}

/**
 *长按地图时会回调此接口
 *@param mapview 地图View
 *@param coordinate 返回长按事件坐标点的经纬度
 */
- (void)mapview:(BMKMapView *)mapView onLongClick:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"onLongClick-latitude==%f,longitude==%f",coordinate.latitude,coordinate.longitude);
    NSString* showmeg = [NSString stringWithFormat:@"长按地图(long pressed).\r\n当前经度:%f,当前纬度:%f,\r\nZoomLevel=%d;RotateAngle=%d;OverlookAngle=%d", coordinate.longitude,coordinate.latitude,
                         (int)_mapView.zoomLevel,_mapView.rotation,_mapView.overlooking];
    _showMsgLabel.text = showmeg;
    
}
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSString* showmeg = [NSString stringWithFormat:@"区域变化(x=%d,y=%d,\r\nwidth=%d,height=%d).\r\nZoomLevel=%d;RotateAngle=%d;OverlookAngle=%d",(int)_mapView.visibleMapRect.origin.x,(int)_mapView.visibleMapRect.origin.y,(int)_mapView.visibleMapRect.size.width,(int)_mapView.visibleMapRect.size.height,(int)_mapView.zoomLevel,_mapView.rotation,_mapView.overlooking];
    
    _showMsgLabel.text = showmeg;
    
}

@end
