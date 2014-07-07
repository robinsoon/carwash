//
//  PoiSearchViewController.h
//  BaiduMapApi
//
//  百度地图搜索定位应用模块
//  注意：商家位置视图使用了独立的 xib 文件


#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import "BMKTypes.h"
#import "washcarsAppDelegate.h"
@interface PoiSearchViewController : UIViewController<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKPoiSearchDelegate,BMKGeocodeSearchDelegate> {
	IBOutlet BMKMapView* _mapView;
	IBOutlet UITextField* _cityText;
	IBOutlet UITextField* _keyText;
    IBOutlet UIButton* _nextPageButton;
    IBOutlet UILabel* _showMsgLabel;
    BMKPoiSearch* _poisearch;
    BMKLocationService* _locService;
    BMKGeocodeSearch* _geocodesearch;
    int curPage;

}

@property (weak, nonatomic) IBOutlet UIView *HeadView;
-(IBAction)onClickOk;
-(IBAction)onClickNextPage;
- (IBAction)textFiledReturnEditing:(id)sender;

@property (nonatomic,strong) NSMutableArray* listData;  //商品列表(传入参数)
@property (nonatomic,strong) NSString *itemname;         //名称[为空表示无需定位商家位置]
@property (nonatomic) CLLocationCoordinate2D Locationpt; //初始坐标位置
@property (nonatomic) CLLocationCoordinate2D myLocationpt; //我的坐标位置

@property (nonatomic) int iZoomLevel;                    //地图缩放级别(3-19级,默认14)
@property (nonatomic) bool isShowPoiLabel;                //是否显示标记名称
@property (nonatomic,strong) NSMutableArray* detailData;  //POI详情数据

@property (weak, nonatomic) IBOutlet UIButton *btnSearch;

@property (nonatomic) bool isLocation;                //是否启用定位
@property (nonatomic) bool isDidLocation;             //是否完成定位
@property (nonatomic) bool isDidGeocode;             //是否完成城市编码

@property (nonatomic,strong) NSString *geoProvince;
@property (nonatomic,strong) NSString *geoCity;
@property (nonatomic,strong) NSString *geoDistrict;
@property (nonatomic,strong) NSString *geoAddress;

- (void)LocationRefresh;

//定位
-(void)startLocation;
//跟随态
-(void)startFollowing;
//罗盘态
-(void)startFollowHeading;
//停止定位
-(void)stopLocation;


@end
