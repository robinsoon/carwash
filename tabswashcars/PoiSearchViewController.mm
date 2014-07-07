//
//  PoiSearchViewController.m
//  BaiduMapApi
//
//  百度地图搜索定位应用模块
//  注意：商家位置视图使用了独立的 xib 文件
//

#import "PoiSearchViewController.h"
#import "UIButton+Bootstrap.h"

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
    
    _isDidLocation = false;
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
//        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    
	_poisearch = [[BMKPoiSearch alloc]init];
    _locService = [[BMKLocationService alloc]init];
    _geocodesearch = [[BMKGeocodeSearch alloc]init];
    //刷新列表的消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LocationPoint:)
                                                 name:@"LocationPointNotification"
                                               object:nil];
    
	_cityText.text = @"滕州";
	_keyText.text  = @"洗车";
    curPage = 1;
    _isShowPoiLabel = true;
    _HeadView.hidden = true;
    // 设置地图级别 // 地图比例尺级别，在手机上当前可使用的级别为3-19级
    if (_iZoomLevel<=1||_iZoomLevel>19) {
        _iZoomLevel = 14;
    }
    [_mapView setZoomLevel:_iZoomLevel];
    _nextPageButton.titleLabel.text = @"搜索";
    _nextPageButton.enabled = true;
    
    //提交订单
    [self.btnSearch primaryStyle];
    [self.btnSearch addAwesomeIcon:FAIconMapMarker beforeTitle:YES];

    
    _mapView.isSelectedAnnotationViewFront = YES;
    
    //初始定位[模拟器]
    CLLocationCoordinate2D pt;
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];

    if(!delegate.isFixedPosition){
        _isDidLocation = false;
        _isDidGeocode = false;
        [self startFollowing];
    }else{
        _geoProvince = delegate.userProvince;
        _geoCity = delegate.userCity;
        _geoDistrict = delegate.userDistrict;
        _geoAddress = delegate.userAddress;
        
        _myLocationpt = delegate.Userpt;
        
        _isDidLocation = true;
        _isDidGeocode = true;
        
        _cityText.text =[[NSString alloc]initWithFormat:@"%@" ,_geoDistrict];
        
        //加位置标记
        BMKPointAnnotation* myitem = [[BMKPointAnnotation alloc]init];
        myitem.coordinate = _myLocationpt;
        myitem.title = @"我的位置";
        myitem.subtitle = _geoAddress;
        //添加新标记
        [_mapView addAnnotation:myitem];
    }
    
    //_mapView.showsUserLocation = YES;//开启定位服务
    
    if ([_itemname isEqual:nil]|[_itemname  isEqual: @""]) {
        pt.latitude = 35.087341;
        pt.longitude = 117.175142;
    }else{
        _showMsgLabel.text = @"定位商家位置";
        if ([_listData count]>0)
        {
            //数据不止一条，来自服务列表的定位信息
            _showMsgLabel.text = @"定位商家位置";
            for (int i=0; i<[_listData count]; i++) {
                _Locationpt.latitude = [[[_listData objectAtIndex:i ]objectForKey:@"Latitude"]doubleValue ];
                _Locationpt.longitude = [[[_listData objectAtIndex:i ]objectForKey:@"Longitude"]doubleValue ];
                _itemname = [[_listData objectAtIndex:i ]objectForKey:@"goods_name"];
                
                //pt.latitude = _Locationpt.latitude*1E6;
                //pt.longitude = _Locationpt.longitude*1E6;
                
                pt = _Locationpt;
                
                BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
                item.coordinate = pt;
                item.title = _itemname;
                
                //添加新标记
                [_mapView addAnnotation:item];

            }
            
        }else
        {
        
        //只有一条
        
        //pt.latitude = _Locationpt.latitude*1E6;
        //pt.longitude = _Locationpt.longitude*1E6;
        
        pt = _Locationpt;
        
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = pt;
        item.title = _itemname;
        
        //添加新标记
        [_mapView addAnnotation:item];
        }

    }
    
    _mapView.centerCoordinate = pt;
}


-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _poisearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated {
    [self stopLocation];
    _isLocation = false;
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _poisearch.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geocodesearch.delegate = nil; // 不用时，置nil

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
    
    //法一：城市内检索，请求发送成功返回YES，请求发送失败返回NO
    BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc]init];
    citySearchOption.pageIndex = curPage;
    citySearchOption.pageCapacity = 10;
    citySearchOption.keyword = _keyText.text;
    
    citySearchOption.city= _cityText.text;              //城市是BMKCitySearchOption的属性
    BOOL flag = [_poisearch poiSearchInCity:citySearchOption];
    //[citySearchOption release];
    
    /*
    //法二：搜索周边
    BMKNearbySearchOption *nearSearchOption = [[BMKNearbySearchOption alloc]init];
    nearSearchOption.pageIndex = curPage;
    nearSearchOption.pageCapacity = 12;
    nearSearchOption.keyword = _keyText.text;
    nearSearchOption.location = _mapView.centerCoordinate; //中心点坐标
    nearSearchOption.radius = 6000;    //搜索距离半径 m 单位:米
    BOOL flag = [_poisearch poiSearchNearBy:nearSearchOption];
    */
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

//地图定位页面刷新
-(void)LocationPoint:(NSNotification*)notification {
    
    //解析数据
    NSDictionary *dataDict = notification.userInfo;
    if (dataDict==nil) {
        return;
    }
    
    _itemname = [dataDict objectForKey:@"name"];
    //title = @"位置";
    _Locationpt.latitude = [[dataDict objectForKey:@"latitude"] doubleValue];
    _Locationpt.longitude = [[dataDict objectForKey:@"longitude"] doubleValue];
    _iZoomLevel = 17;

    NSLog(@"地图定位页面刷新通知" );
    
    [_mapView setZoomLevel:_iZoomLevel];
    
    //
    CLLocationCoordinate2D pt;
    
    //pt.latitude = _Locationpt.latitude*1E6;
    //pt.longitude = _Locationpt.longitude*1E6;
    
    pt = _Locationpt;
    
    BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
    item.coordinate = pt;
    item.title = _itemname;
    
    //删除标记
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    //添加新标记
    [_mapView addAnnotation:item];

    _mapView.centerCoordinate = pt;
    
}

-(void)LocationRefresh
{
    //移除标记
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    
    CLLocationCoordinate2D pt;
    
    if ([_listData count]>0)
    {
        if (_isDidGeocode) {
            //加位置标记 一定要先加可重用标记
            BMKPointAnnotation* myitem = [[BMKPointAnnotation alloc]init];
            myitem.coordinate = _myLocationpt;
            myitem.title = @"我的位置";
            myitem.subtitle = _geoAddress;
            //添加新标记
            [_mapView addAnnotation:myitem];
        }

        //数据不止一条，来自服务列表的定位信息
        _showMsgLabel.text = @"定位商家位置";
        for (int i=0; i<[_listData count]; i++) {
            _Locationpt.latitude = [[[_listData objectAtIndex:i ]objectForKey:@"Latitude"]doubleValue ];
            _Locationpt.longitude = [[[_listData objectAtIndex:i ]objectForKey:@"Longitude"]doubleValue ];
            _itemname = [[_listData objectAtIndex:i ]objectForKey:@"goods_name"];
            
            //pt.latitude = _Locationpt.latitude*1E6;
            //pt.longitude = _Locationpt.longitude*1E6;
            
            pt = _Locationpt;
            
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = pt;
            item.title = _itemname;
            
            //添加新标记
            [_mapView addAnnotation:item];
            
        }
        
        _mapView.centerCoordinate = pt;
            
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
    NSString *myAnnotationViewID = @"carwashMarkMe";
    BMKAnnotationView* annotationView;
    if ([[annotation title]isEqualToString:@"我的位置"]) {
        annotationView = [view dequeueReusableAnnotationViewWithIdentifier:myAnnotationViewID];
    }else{
    
        // 检查是否有重用的缓存
        annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    }
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        
        if ([[annotation title]isEqualToString:@"我的位置"]) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:myAnnotationViewID];

            	((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
                annotationView.annotation = annotation;
                annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));

        }else{
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];

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
        }
        
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
            [self.btnSearch primaryStyle];
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
            [self.btnSearch primaryStyle];
        }
    }
}

//地理位置翻查
-(void) onGetReverseGeocodeResult:(BMKGeocodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    if (error == 0) {
        BMKAddressComponent *ptdetail=result.addressDetail;
        //取得地址的详细信息
        _geoProvince = ptdetail.province;
        _geoCity = ptdetail.city;
        _geoDistrict = ptdetail.district;
        _geoAddress = result.address;
        if ((_geoCity == nil)||([_geoCity isEqual:@""])) {
            
        }else{
            _cityText.text =[[NSString alloc]initWithFormat:@"%@" ,_geoDistrict];
            
            
            //存储
            
            delegate.userProvince = _geoProvince;
            delegate.userCity = _geoCity;
            delegate.userDistrict = _geoDistrict;
            delegate.userAddress = _geoAddress;
            _isDidGeocode = true;
            delegate.isFixedPosition = _isDidGeocode;
            
            //存储
            [delegate SetUserLocation:_myLocationpt ];
            //加位置标记
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = _myLocationpt;
            item.title = @"我的位置";
            item.subtitle = _geoAddress;
            //添加新标记
            [_mapView addAnnotation:item];
            
            //发送消息通知城市位置已找到
            NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:_geoAddress, @"address",_geoProvince, @"province",_geoCity, @"city",_geoDistrict, @"district", nil];
            
            //传递消息
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"DidLocationNotification"
             object:nil
             userInfo:dataDict];
            
            NSString *lsNofify =[[NSString alloc]initWithFormat:@"已找到您的位置：%@ 。",result.address];
            
            [delegate showNotify:lsNofify HoldTimes:2.5];
            
            [self stopLocation];
        }
    }else{
        NSString *lsNofify =[[NSString alloc]initWithFormat:@"无法定位用户当前的位置。"];
        _isDidGeocode = false;
        delegate.isFixedPosition = _isDidGeocode;
        [delegate showNotify:lsNofify HoldTimes:2];
        
    }
    
    //NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
	//[_mapView removeAnnotations:array];
	//array = [NSArray arrayWithArray:_mapView.overlays];
	//[_mapView removeOverlays:array];
    /*
	if (error == 0) {
		BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
		item.coordinate = result.location;
		item.title = result.address;
        item.subtitle = @"我的位置";
        BMKAddressComponent *ptdetail=result.addressDetail;
        //取得地址的详细信息
        _geoProvince = ptdetail.province;
        _geoCity = ptdetail.city;
        _geoDistrict = ptdetail.district;
        
        if ((_geoCity == nil)||([_geoCity isEqual:@""])) {
            
        }else{
            _cityText.text =[[NSString alloc]initWithFormat:@"%@" ,_geoDistrict];
        }
        
		[_mapView addAnnotation:item];
        //_mapView.centerCoordinate = result.location;
     
        NSString* titleStr;
        NSString* showmeg;
        titleStr = @"反向地理编码";
        showmeg = [NSString stringWithFormat:@"%@",item.title];
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:titleStr message:showmeg delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        [myAlertView show];
     
	}*/
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

    _HeadView.hidden = !_HeadView.hidden;

    
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
    _HeadView.hidden = true;
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
    _HeadView.hidden = false;
}
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSString* showmeg = [NSString stringWithFormat:@"区域变化(x=%d,y=%d,\r\nwidth=%d,height=%d).\r\nZoomLevel=%d;RotateAngle=%d;OverlookAngle=%d",(int)_mapView.visibleMapRect.origin.x,(int)_mapView.visibleMapRect.origin.y,(int)_mapView.visibleMapRect.size.width,(int)_mapView.visibleMapRect.size.height,(int)_mapView.zoomLevel,_mapView.rotation,_mapView.overlooking];
    
    _showMsgLabel.text = showmeg;
    
}


/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewWillStartLocatingUser:(BMKMapView *)mapView
{
	NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    //NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    //    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
    //地图位置居中
    //_mapView.centerCoordinate = userLocation.location.coordinate;
    
    if (!_isDidLocation) {
        [self saveUserLocation:userLocation];
    }
}

- (void)saveUserLocation:(BMKUserLocation *)userLocation
{
    NSString *lsNofify =[[NSString alloc]initWithFormat:@"完成定位：lat= %f,long= %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude];
    NSLog(@"%@",lsNofify);
    
    //地图位置居中
    _mapView.centerCoordinate = userLocation.location.coordinate;
    _myLocationpt= userLocation.location.coordinate;
    washcarsAppDelegate *delegate=(washcarsAppDelegate*)[[UIApplication sharedApplication]delegate];
    //存储
    [delegate SetUserLocation:userLocation.location.coordinate ];
    //[delegate showNotify:@"已找到当前的位置，您可以关闭定位以节省电量。" HoldTimes:2];
    
    
    //停止定位
    _isDidLocation = true;
    
    //触发城市编码查询
    if (!_isDidGeocode) {
        [self GetReverseGeocode];
    }

    //[self stopLocation];
}




/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(BMKMapView *)mapView
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

#pragma mark -
#pragma mark 获取定位信息

//根据位置获取地址编码
- (void)GetReverseGeocode
{
    if (_isDidGeocode) {
        return;
    }
    
    BMKReverseGeocodeOption *reverseGeocodeSearchOption = [[BMKReverseGeocodeOption alloc]init];
    
    reverseGeocodeSearchOption.reverseGeoPoint = _mapView.centerCoordinate;
    BOOL flag = [_geocodesearch reverseGeocode:reverseGeocodeSearchOption];
    
    if(flag)
    {
        //NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }

}

-(IBAction)onClickReverseGeocode
{
    
    BMKReverseGeocodeOption *reverseGeocodeSearchOption = [[BMKReverseGeocodeOption alloc]init];
    
    reverseGeocodeSearchOption.reverseGeoPoint = _mapView.centerCoordinate;
    BOOL flag = [_geocodesearch reverseGeocode:reverseGeocodeSearchOption];

    if(flag)
    {
        //NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
}


- (IBAction)btnLocationClicked:(id)sender {
    //定位
    if (_isLocation) {
        [self stopLocation];
        _isLocation = false;
    }else{
        //[self startLocation];
        [self startFollowing];
        //[self startFollowHeading];
        
        _isLocation = true;
    }
}

//普通态
-(void)startLocation
{
    NSLog(@"进入普通定位态");
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}

//罗盘态
-(void)startFollowHeading
{
    NSLog(@"进入罗盘态");
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
    _mapView.showsUserLocation = YES;
    
}
//跟随态
-(void)startFollowing
{
    NSLog(@"进入跟随态");
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;
    
}
//停止定位
-(void)stopLocation
{
    NSLog(@"退出定位");
    [_locService stopUserLocationService];
    _mapView.showsUserLocation = NO;
}


@end
