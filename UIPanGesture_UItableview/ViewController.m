//
//  ViewController.m
//  UIPanGesture_UItableview
//
//  Created by 唐蒙波 on 2019/11/29.
//  Copyright © 2019 Meng. All rights reserved.
//

#import "ViewController.h"
#import "HJGestureTable.h"

#define Nav_TopHeight ([UIScreen mainScreen].bounds.size.height >= 812.0 ? 35 : 20)
#define Kuan_Width [UIScreen mainScreen].bounds.size.width
#define Gao_HEIGHT [UIScreen mainScreen].bounds.size.height
#define BL_Kuan [UIScreen mainScreen].bounds.size.width/375

typedef enum{
    Top = 0,
    Bottom,
}TopOrBottom;//从顶部开始拖动还是从底部开始拖动

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL alsoPanGesture;
}

@property(nonatomic,assign)TopOrBottom  topOrBottom;

@property(nonatomic,strong)HJGestureTable * trendsTableView;

@property(nonatomic,assign)float topOriginY;//trendsTableView可以拖动到的最顶部

@property(nonatomic,assign)float bottomOriginY;//trendsTableView可以拖动到的最底部



@end

@implementation ViewController

-(HJGestureTable *)trendsTableView
{
    if (!_trendsTableView) {
        
        _trendsTableView = [[HJGestureTable alloc] initWithFrame:CGRectMake(0, self.bottomOriginY, Kuan_Width, Gao_HEIGHT-self.topOriginY)];
        _trendsTableView.delegate = self;
        _trendsTableView.dataSource = self;
        [self.view addSubview:_trendsTableView];
    }
    return _trendsTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topOrBottom = Bottom;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.topOriginY = Nav_TopHeight+50*BL_Kuan;
    self.bottomOriginY = Nav_TopHeight+400*BL_Kuan;
    
    self.trendsTableView.separatorStyle = NO;
    [self.trendsTableView setContentSize:CGSizeMake(Kuan_Width, self.trendsTableView.frame.size.height+300)];
    
    
    //添加拖动手势
    UIPanGestureRecognizer * pan =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.trendsTableView addGestureRecognizer:pan];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   
    //让手势拖动监听先执行,防止手势拖动还没有监听到,tableview自身已经滚动了,从而self.trendsTableView.contentOffset.y!=0
    if(!alsoPanGesture)
    {
        [self.trendsTableView setContentOffset:CGPointMake(0, 0)];
    }
    //当self.trendsTableView的位置在最顶部和最底部之间时让self.trendsTableView只可以拖动,让self.trendsTableView自身滑动无效
    if (self.trendsTableView.frame.origin.y>self.topOriginY&&self.trendsTableView.frame.origin.y<self.bottomOriginY)
    {
        NSLog(@"当self.trendsTableView手势拖动时,self.trendsTableViewn自身滑动事件禁止");
        [self.trendsTableView setContentOffset:CGPointMake(0, 0)];
    }
    
    //当self.trendsTableView拖动到顶部 self.trendsTableView的内部还要向下滚动时让self.trendsTableView可以拖动
    if(self.trendsTableView.frame.origin.y==self.topOriginY && self.trendsTableView.contentOffset.y<0)
    {
        [self.trendsTableView setContentOffset:CGPointMake(0, 0)];
    }
    //当self.trendsTableView拖动到底部 self.trendsTableView的内部还要向上滚动时让self.trendsTableView可以拖动
    if(self.trendsTableView.frame.origin.y==self.bottomOriginY && self.trendsTableView.contentOffset.y>0)
    {
        [self.trendsTableView setContentOffset:CGPointMake(0, 0)];
    }
}

#pragma mark - 手势执行的方法
-(void)handlePan:(UIPanGestureRecognizer *)rec{
    
    alsoPanGesture = YES;
    //返回在横坐标上、纵坐标上拖动了多少像素
    CGPoint point=[rec translationInView:self.view];
    
    //当self.trendsTableView内部没有滚动到顶部时 不允许拖动
    if (self.trendsTableView.contentOffset.y!=0)
    {
        NSLog(@"%f",self.trendsTableView.contentOffset.y);
        return;
    }
    
    if (self.trendsTableView.frame.origin.y+point.y<=self.topOriginY ) {
        
        //当self.trendsTableView拖动到最顶部时可以滑动  且self.trendsTableView的位置不再随拖动改变
        self.trendsTableView.frame = CGRectMake(self.trendsTableView.frame.origin.x, self.topOriginY, self.trendsTableView.frame.size.width, self.trendsTableView.frame.size.height);
        
        self.trendsTableView.scrollEnabled = YES;

    }
    else if (self.trendsTableView.frame.origin.y+point.y>=self.bottomOriginY)
    {
        //当self.trendsTableView拖动到最底部时可以滑动  且self.trendsTableView的位置不再随拖动改变
        self.trendsTableView.frame = CGRectMake(self.trendsTableView.frame.origin.x, self.bottomOriginY, self.trendsTableView.frame.size.width, self.trendsTableView.frame.size.height);
        
        self.trendsTableView.scrollEnabled = YES;
        
    }
    else
    {
        self.trendsTableView.frame = CGRectMake(self.trendsTableView.frame.origin.x, self.trendsTableView.frame.origin.y+point.y, self.trendsTableView.frame.size.width, self.trendsTableView.frame.size.height);
        
        self.trendsTableView.scrollEnabled = NO;//防止在拖动的同时 self.trendsTableView内部滚动
    }
    
    [rec setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if(rec.state == UIGestureRecognizerStateEnded || rec.state == UIGestureRecognizerStateCancelled)//拖动结束
    {
        //当self.trendsTableView拖动结束时  让self.trendsTableView的位置滚动到最顶部或者最底部
            
        if (self.topOrBottom == Bottom) {
            
            if (self.trendsTableView.frame.origin.y<self.bottomOriginY-30*BL_Kuan) {
                
                self.topOrBottom = Top;
                
                [UIView animateWithDuration:0.5 animations:^{
                    
                    self.trendsTableView.frame = CGRectMake(self.trendsTableView.frame.origin.x, self.topOriginY, self.trendsTableView.frame.size.width, self.trendsTableView.frame.size.height);
                    
                } completion:^(BOOL finished) {
                    
                    self.trendsTableView.scrollEnabled = YES;
                }] ;
            }
            else
            {
                [UIView animateWithDuration:0.5 animations:^{
                    
                    self.trendsTableView.frame = CGRectMake(self.trendsTableView.frame.origin.x, self.bottomOriginY, self.trendsTableView.frame.size.width, self.trendsTableView.frame.size.height);
                    
                } completion:^(BOOL finished) {
                    
                    self.trendsTableView.scrollEnabled = YES;
                }] ;

            }
        }
        else
        {
            if (self.trendsTableView.frame.origin.y>self.topOriginY+30*BL_Kuan) {
                
                self.topOrBottom = Bottom;
                
                [UIView animateWithDuration:0.5 animations:^{
                    
                    self.trendsTableView.frame = CGRectMake(self.trendsTableView.frame.origin.x, self.bottomOriginY, self.trendsTableView.frame.size.width, self.trendsTableView.frame.size.height);
                    
                } completion:^(BOOL finished) {
                    
                    self.trendsTableView.scrollEnabled = YES;
                }] ;

              
            }
            else
            {
                [UIView animateWithDuration:0.5 animations:^{
                                  
                                  self.trendsTableView.frame = CGRectMake(self.trendsTableView.frame.origin.x, self.topOriginY, self.trendsTableView.frame.size.width, self.trendsTableView.frame.size.height);
                                  
                              } completion:^(BOOL finished) {
                                  
                                  self.trendsTableView.scrollEnabled = YES;
                              }] ;
            }
        }
    }
    
}
#pragma mark---UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 10;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    return  207*BL_Kuan;
    
    
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSString *tableIdentifier = [NSString stringWithFormat:@"RoomTableViewCell"] ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row%2==0) {
        
        cell.backgroundColor = [UIColor purpleColor];
    }
    else
    {
        cell.backgroundColor = [UIColor yellowColor];
    }
    return cell;
    
    
}

@end
