//
//  WheelView.h
//  HaoBao
//  QQ:297184181
//  Created by haobao on 13-12-2.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WheelViewDelegate;

@interface WheelView : UIView <UIGestureRecognizerDelegate>{
    
    NSMutableArray *_views;                      //存放当前的view的顺序；
    NSMutableArray *_viewsAngles;                //这里存放view的倾斜角度；
    NSMutableArray *_originalPositionedViews;    //原始的view放在这个数组里边；方便后面做选择的时候找到对应的值；
    NSInteger viewsNum;                       //view的个数；
        
    BOOL toDescelerate;
    
    BOOL toRearrange;
    
    NSInteger currentIndex;
}

@property (nonatomic,assign) NSObject<WheelViewDelegate> *delegate;
@property (nonatomic) int idleDuration;


- (void)reloadData;

@end

@protocol WheelViewDelegate

@required

- (NSInteger)numberOfRowsOfWheelView:(WheelView *)wheelView;
- (UIView *)wheelView:(WheelView *)wheelView viewForRowAtIndex:(int)index;
- (float)rowWidthInWheelView:(WheelView *)wheelView;
- (float)rowHeightInWheelView:(WheelView *)wheelView;

@optional

- (void)wheelViewDidScroller:(WheelView *)wheelView;
- (void)wheelView:(WheelView *)wheelView didSelectedRowAtIndex:(NSInteger)index;

@end