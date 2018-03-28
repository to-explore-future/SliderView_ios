//
//  JCSliderShowVC.m
//  jcCloud
//  展示图片录播图 手动滑动的那种
//  Created by sharingmobile on 2018/3/26.
//  Copyright © 2018年 danqing. All rights reserved.
//

/**
 *  要求实现:尽量少的图片内存驻留,缓存起来,最多缓存三张,
 *  还要保证流畅性,当用户往左或者往右拖拽的时候,加载下一张图片
 */

#import "JCSliderShowVC.h"
#import <SDWebImage/UIImageView+WebCache.h>


#define kScreen_width [[UIScreen mainScreen] bounds].size.width
#define kScreen_height [[UIScreen mainScreen] bounds].size.height

@interface JCSliderShowVC ()<UIScrollViewDelegate>

@property(nonatomic,strong)UIScrollView * scrollView;
@property(nonatomic,strong)NSArray * picUrls;
@property NSInteger index;
@property(nonatomic,strong)NSMutableArray * imageViews;             //imageView 队列
@property(nonatomic,strong)NSMutableArray * imageViewsStatus;       //imageView 队列


@end

@implementation JCSliderShowVC

-(void)viewWillAppear:(BOOL)animated{
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initFrame];
    
}

-(void)initFrame{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.scrollView];
    [self.scrollView setContentSize:CGSizeMake(self.picUrls.count * kScreen_width, kScreen_height - 64)];
    [self.scrollView setContentOffset:CGPointMake(self.index * kScreen_width, 0)];
    
    UIImageView * iv = [self setImageViewWithIndex:self.index];
    [self.imageViews replaceObjectAtIndex:self.index withObject:iv];
    [self updateImageviewStatus:true withIndex:self.index];
    
    //进入页面当前选中的位置  前后位置 提前加载 图片
    //1.正常情况下 假设当前位置的前后都 位置
    if (self.index >0 && self.index < self.picUrls.count - 1) {
        //前后各加载一张图片
        UIImageView * iv1 = [self setImageViewWithIndex:(self.index - 1)];
        [self.imageViews replaceObjectAtIndex:self.index - 1 withObject:iv1];
        [self updateImageviewStatus:true withIndex:self.index - 1];
        
        UIImageView * iv2 = [self setImageViewWithIndex:self.index + 1];
        [self.imageViews replaceObjectAtIndex:self.index + 1 withObject:iv2];
        [self updateImageviewStatus:true withIndex:self.index + 1];
    }
    //2.当前位置位于起始位置 预加载下一张
    if (self.index == 0) {
        UIImageView * next = [self setImageViewWithIndex:1];
        [self.imageViews replaceObjectAtIndex:1 withObject:next];
        [self updateImageviewStatus:true withIndex:1];
    }
    //3.当前位置位于最后的位置 预加载最后位置的前一张
    if (self.index == self.picUrls.count - 1) {
        UIImageView * iv = [self setImageViewWithIndex:self.index - 1];
        [self.imageViews replaceObjectAtIndex:self.index - 1 withObject:iv];
        [self updateImageviewStatus:true withIndex:self.index - 1];
    }
    
}

#pragma mark - delegate scrollviewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"开始滑动 : %f",scrollView.contentOffset.x);
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    NSLog(@"手指离开了");
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
}

//是否减速了
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"当滑动到下一个页的时候,没有速度的时候,就会回调这个方法");
    //这时候判断是 滑动了第几页
    CGFloat x = scrollView.contentOffset.x;
    NSInteger currentPage = x / kScreen_width;
    //如果当前位置 没有图片 那么就加载
    NSNumber * status = self.imageViewsStatus[currentPage];
    if ([status boolValue]) {
        
    }else{
        UIImageView * iv = [self setImageViewWithIndex:currentPage];
        [self.imageViews replaceObjectAtIndex:currentPage withObject:iv];
        [self updateImageviewStatus:true withIndex:currentPage];
    }
    NSLog(@"当前在第    %ld    页",currentPage);
    //当当前页发生改变的时候呢 那些页需要加载 那些页需要释放呢
    //当往后滑动的时候呢 手指向左滑动 展示下一个界面的时候
    //这时候也该加载 currentPage的下一页 释放 currentPage的上上一页==self.index - 1
    if (currentPage > self.index) {
        //预加载注意:如果currentPage 是最后一个 那么就没有预加载 但是有释放
        //如果有预加载的位置 我就预加载
        NSInteger nextPage = currentPage + 1;
        if (nextPage <= self.picUrls.count - 1) {
            //1.预加载currentPage的下一页
            UIImageView * iv = [self setImageViewWithIndex:nextPage];
            [self.imageViews replaceObjectAtIndex:nextPage withObject:iv];
            [self updateImageviewStatus:true withIndex:nextPage];
        }
        //2.释放 以及注意
        //1.从集合中找到要释放的 imageview
        NSInteger releasePage = self.index - 1;
        if (releasePage >= 0) {
            UIImageView * iv1 = self.imageViews[releasePage];
            [iv1 removeFromSuperview];
            UIImageView * temp = [[UIImageView alloc] init];
            [self.imageViews replaceObjectAtIndex:releasePage withObject:temp];
            [self updateImageviewStatus:false withIndex:releasePage];
        }
        
        //3.所有都做完了,更新当前的页 索引
        self.index = currentPage;
    }else if(currentPage < self.index){ //要展示前面的页
        //注意:如果currentpage是最前面的一个 那么没有预加载 但是有释放
        //1.预加载currentPage的前一页
        NSInteger prePage = currentPage -1;
        if (prePage >= 0) {
            UIImageView * iv = [self setImageViewWithIndex:currentPage - 1];
            [self.imageViews replaceObjectAtIndex:prePage withObject:iv];
            [self updateImageviewStatus:true withIndex:prePage];
        }
        
        //2.释放
        //1.从集合中找到要释放的 imageview 先简单点 只要能滑动 就一定要释放
        NSInteger realsePage = self.index + 1;
        if (realsePage <= self.picUrls.count - 1) {
            UIImageView * iv1 = self.imageViews[realsePage];
            [iv1 removeFromSuperview];
            UIImageView * temp = [[UIImageView alloc] init];
            [self.imageViews replaceObjectAtIndex:realsePage withObject:temp];
            [self updateImageviewStatus:false withIndex:realsePage];
        }
        //3.所有都做完了,更新当前的页 索引
        self.index = currentPage;
    }
    
    //展示status
    NSInteger count = self.imageViewsStatus.count;
    for (int i = 0; i < count; i++) {
        NSNumber * status = self.imageViewsStatus[i];
        if ([status boolValue]) {
            NSLog(@"有图片 = %d",i);
        }
    }
}

#pragma mark - method

-(UIImageView*)setImageViewWithIndex:(NSInteger )index{
    //拿到这个图片的宽高
    NSInteger w = [@"5400" integerValue];
    NSInteger h = [@"4150" integerValue];
    //说明 由于需求中暂时没有 图片的放大缩小 要求
    NSString * picPath = self.picUrls[index];
    NSString * picPathUTF8 = [picPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * picURL = [NSURL URLWithString:picPathUTF8];
    //确定根据图片的宽高 确定imageview 的宽高
    CGFloat imageViewHeight = kScreen_width * h / w;
    //根据图片的高度 保证图片在屏幕垂直居中 计算 y
    CGFloat y = (kScreen_height - 64 - imageViewHeight) / 2;
    NSLog(@"height = %f",kScreen_height);
    //设置图片
    //展示当前index 的 图片 确定frame
    UIImageView * currentIndexImageview = [[UIImageView alloc] initWithFrame:CGRectMake(index * kScreen_width, y, kScreen_width, imageViewHeight)];
    //把这个添加到 scrollView中
    [currentIndexImageview setBackgroundColor:[UIColor redColor]];
    [currentIndexImageview sd_setImageWithURL:picURL];
    [self.scrollView addSubview:currentIndexImageview];
    return currentIndexImageview;
}

-(void)releaseImageViewWithIndex:(NSInteger )index{
    
}

-(void)updateImageviewStatus:(Boolean)status withIndex:(NSInteger)index{
    NSNumber * imageViewStatus = [[NSNumber alloc] initWithBool:status];
    [self.imageViewsStatus replaceObjectAtIndex:index withObject:imageViewStatus];
}

-(void)setUrls:(NSArray *)urls{
   //用这个类里面的 数组指向外边的 urls数组
    self.picUrls = urls;
//    self.imageViews;
}

-(void)setSelectedIndex:(NSInteger )selectedIndex{
    self.index = selectedIndex;
//    NSLog(@"currentindex = %ld",self.index);
}

-(UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        [_scrollView setPagingEnabled:YES];//按页展示
//        [_scrollView setBounces:NO];
        [_scrollView setScrollEnabled:YES];
//        [_scrollView setShowsHorizontalScrollIndicator:YES];
//        [_scrollView setShowsVerticalScrollIndicator:NO];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

//虽然声明了一个 指定长度的 但是这个里面最多放 三个对象 会随用随销毁, 这样生命知识简化 代码的逻辑难度
-(NSMutableArray *)imageViews{
    if (_imageViews == nil) {
        NSInteger count = self.picUrls.count;
        _imageViews = [[NSMutableArray alloc] init];
        for (int i = 0; i < count; i++) {
            UIImageView * view = [[UIImageView alloc] init];
            [_imageViews addObject:view];
        }
    }
    return _imageViews;
}

-(NSMutableArray *)imageViewsStatus{
    if (_imageViewsStatus == nil) {
        _imageViewsStatus = [[NSMutableArray alloc] init];
        NSInteger count = self.picUrls.count;
        //生成imageViewStatus
        for (int i = 0; i < count; i++) {
            NSNumber * status = [[NSNumber alloc] initWithBool:false];
            [self.imageViewsStatus addObject:status];
        }
    }
    return _imageViewsStatus;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
