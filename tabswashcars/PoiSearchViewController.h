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
@interface PoiSearchViewController : UIViewController<BMKMapViewDelegate, BMKPoiSearchDelegate> {
	IBOutlet BMKMapView* _mapView;
	IBOutlet UITextField* _cityText;
	IBOutlet UITextField* _keyText;
    IBOutlet UIButton* _nextPageButton;
    IBOutlet UILabel* _showMsgLabel;
    BMKPoiSearch* _poisearch;
    int curPage;

}

-(IBAction)onClickOk;
-(IBAction)onClickNextPage;
- (IBAction)textFiledReturnEditing:(id)sender;

@property (nonatomic,strong) NSMutableArray* listData;  //商品列表(传入参数)
@property (nonatomic,strong) NSString *itemname;         //名称[为空表示无需定位商家位置]
@property (nonatomic) CLLocationCoordinate2D Locationpt; //初始坐标位置
@property (nonatomic) int iZoomLevel;                    //地图缩放级别(3-19级,默认14)
@property (nonatomic) bool isShowPoiLabel;                //是否显示标记名称
@property (nonatomic,strong) NSMutableArray* detailData;  //POI详情数据

@property (weak, nonatomic) IBOutlet UIButton *btnSearch;


- (void)LocationRefresh;

@end
