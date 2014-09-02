//
//  MyPickerView.m
//  HaoBao
//  QQ:297184181
//  Created by haobao on 13-11-26.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import "MyPickerView.h"

@interface MyPickerView()

@property (nonatomic, retain)NSMutableArray *tables;


- (void)addContent;
- (void)removeContent;

//返回当前是第几组
- (NSInteger)componentFromWheelView:(WheelView*)wheelView;

@end

@implementation MyPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        
        if(loop == nil){
            loop = [[MagnifierView alloc] init];
            loop.viewToMagnify = self;

        }
        // Initialization code
    }
    return self;
}

- (void)addloop
{
    [self.superview addSubview:loop];
    
}

- (void)update{
    
    [self removeContent];
    [self addContent];
    
    [self performSelector:@selector(addloop) withObject:nil afterDelay:0.2];
    loop.touchPoint=CGPointMake(160, 108);
    [loop setNeedsDisplay];
}

#pragma mark - Content

- (void)addContent{
    
    const NSInteger components = [self numberOfComponents];
    
    _tables=[[NSMutableArray alloc] init];
    
    CGRect tableFrame = CGRectMake(0, 0, 0, self.bounds.size.height);
    for (NSInteger i = 0; i<components; ++i) {
        
        tableFrame.size.width = self.frame.size.width/components;
        
        WheelView *wheelview=[[WheelView alloc] initWithFrame: tableFrame];
        wheelview.delegate = self;
        [wheelview reloadData];
        wheelview.idleDuration = 0;
        [self addSubview:wheelview];
        [self.tables addObject:wheelview];
        
        tableFrame.origin.x += tableFrame.size.width;
    }
    
    //上边的渐变阴影
    UIImageView *image=[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height*1/2-17.5)];
    image.image=[[UIImage imageNamed:@"upshadow.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:30];
    [self addSubview:image];
    //[image release];
    
    
    //下边的渐变阴影
    UIImageView *image1=[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, self.bounds.size.height-self.bounds.size.height*1/2+17.5, self.bounds.size.width, self.bounds.size.height*1/2-17.5)];
    image1.image=[[UIImage imageNamed:@"downshadow.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:30];
    [self addSubview:image1];
    //[image1 release];
    
}

- (void)removeContent
{
    for (WheelView *table in self.tables) {
        [table removeFromSuperview];
    }
    self.tables = nil;
    
}

-(void) reloadData{
    
    for (WheelView *table in self.tables) {
        [table reloadData];
    }
}


-(void) reloadDataInComponent:(NSInteger)component{
    
    [[self.tables objectAtIndex:component] reloadData];
}

#pragma mark WheelViewDelegate

- (NSInteger)numberOfRowsOfWheelView:(WheelView *)wheelView{
    NSInteger component = [self componentFromWheelView:wheelView];
    return [self numberOfRowsInComponent:component];
}

- (UIView *)wheelView:(WheelView *)wheelView viewForRowAtIndex:(int)index{
    NSInteger component = [self componentFromWheelView:wheelView];
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    label.text=[self setDataForRow:index inComponent:component];
    
    label.backgroundColor=[UIColor clearColor];
    label.textAlignment=NSTextAlignmentCenter;
    return label;
}

- (float)rowWidthInWheelView:(WheelView *)wheelView{
    
    return 300;
}

- (float)rowHeightInWheelView:(WheelView *)wheelView{
    
    return 30;
}

- (void)wheelView:(WheelView *)wheelView didSelectedRowAtIndex:(NSInteger)index
{
    NSInteger component = [self componentFromWheelView:wheelView];
    if([self.delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]){
         [self.delegate pickerView:self didSelectRow:index inComponent:component];
    }
}

#pragma mark 滚动，调用该方法
- (void)wheelViewDidScroller:(WheelView *)wheelView
{
    loop.touchPoint=CGPointMake(160, 108);
    [loop setNeedsDisplay];
}


#pragma mark - get dataSourse;
//组数
- (NSInteger) numberOfComponents
{
    if ([self.dataSource respondsToSelector:@selector(numberOfComponentsInPickerView:)]) {
        return [self.dataSource numberOfComponentsInPickerView:self];
    }
    return 1;
}
//行数
- (NSInteger) numberOfRowsInComponent:(NSInteger)component
{
    if ([self.dataSource respondsToSelector:@selector(pickerView:numberOfRowsInComponent:)]) {
        return [self.dataSource pickerView:self numberOfRowsInComponent:component];
    }
    return 0;
}
//每行数据
- (NSString *)setDataForRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if ([self.delegate respondsToSelector:@selector(pickerView:titleForRow:forComponent:)]) {
        return [self.delegate pickerView:self titleForRow:row forComponent:component];
    }
    return @"";
}

#pragma mark - Other methods

//或得当前组数
- (NSInteger)componentFromWheelView:(WheelView *)wheelView
{
    return [self.tables indexOfObject:wheelView];
}

- (void) dealloc{
    
    self.tables = nil;
    //[super dealloc];
}


@end
