//
//  MapsViewController.h
//  tabswashcars
//
//  Created by Robinpad on 14-5-13.
//  Copyright (c) 2014年 Robinpad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import "washcarsAppDelegate.h"
@interface MapsViewController : UIViewController<BMKMapViewDelegate, BMKPoiSearchDelegate>{
    BMKPoiSearch* _poisearch;
    IBOutlet BMKMapView* _mapView;
    int curPage;
    
}

@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UITextField *txtCity;
@property (weak, nonatomic) IBOutlet UITextField *txtTarget;
- (IBAction)textFiledReturnEditing:(id)sender;
@end
