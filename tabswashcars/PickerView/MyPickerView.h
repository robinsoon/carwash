//
//  MyPickerView.h
//  HaoBao
//  QQ:297184181
//  Created by haobao on 13-11-26.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WheelView.h"           //滚轮
#import "MagnifierView.h"       //放大
@protocol MyPickerViewDataSource;
@protocol MyPickerViewDelegate;

@interface MyPickerView : UIView<WheelViewDelegate> {
    
    CGFloat centralRowOffset;
    
    MagnifierView *loop;

}

@property (nonatomic, assign) id<MyPickerViewDelegate> delegate;
@property (nonatomic, assign) id<MyPickerViewDataSource> dataSource;

@property (nonatomic, retain)UIColor *fontColor;

- (void)update;

- (void)reloadData;

- (void)reloadDataInComponent:(NSInteger)component;

@end

@protocol MyPickerViewDataSource <NSObject>
@required

- (NSInteger)numberOfComponentsInPickerView:(MyPickerView *)pickerView;

- (NSInteger)pickerView:(MyPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

@end

@protocol MyPickerViewDelegate <NSObject>

@optional

- (CGFloat)pickerView:(MyPickerView *)pickerView widthForComponent:(NSInteger)component;
//- (CGFloat)pickerView:(MyPickerView *)pickerView rowHeightForComponent:(NSInteger)component;

- (NSString *)pickerView:(MyPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;

//- (UIView *)pickerView:(MyPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;

- (void)pickerView:(MyPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;


@end


