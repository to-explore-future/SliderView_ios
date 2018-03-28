//
//  ViewController.m
//  SliderView
//
//  Created by sharingmobile on 2018/3/28.
//  Copyright © 2018年 869518570@qq.com. All rights reserved.
//

#import "ViewController.h"
#import "JCSliderShowVC.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ViewController ()

@property(nonatomic,strong)NSArray * urls;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化 网址
    NSString * url = @"http://pic.qjimage.com/culturarm002/high/is09aa5xq.jpg,http://pic.qjimage.com/cultura_rm001/high/is09ae37v.jpg,http://pic.qjimage.com/culturarm003/high/is09am2rg.jpg,http://pic.qjimage.com/culturarm003/high/is09ar6b3.jpg,http://pic.qjimage.com/culturarm003/high/is09ak4p8.jpg,http://pic.qjimage.com/culturarm003/high/is09ak4p0.jpg,http://pic.qjimage.com/culturarm003/high/is09ak4pi.jpg,http://pic.qjimage.com/culturarm003/high/is09ak4p0.jpg,http://pic.qjimage.com/culturarm003/high/is09ak4p9.jpg,http://pic.qjimage.com/culturarm003/high/is09ak4o8.jpg,http://pic.qjimage.com/culturarm003/high/is09ak4p3.jpg,http://pic.qjimage.com/culturarm003/high/is09ak4oy.jpg,http://pic.qjimage.com/culturarm003/high/is09ak4oh.jpg,http://pic.qjimage.com/culturarm003/high/is09ak4o8.jpg,http://pic.qjimage.com/culturarm003/high/is09ak4o3.jpg";
    self.urls = [url componentsSeparatedByString:@","];
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 200, 50)];
    [btn setTitle:@"点击这里" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor greenColor]];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIImageView * imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0,200 , 200, 180)];
    
    [imageview setBackgroundColor:[UIColor whiteColor]];
    NSURL * aaa = [NSURL URLWithString:@"http://pic.qjimage.com/culturarm002/high/is09aa5xq.jpg"];
    [imageview sd_setImageWithURL:aaa];
    [self.view addSubview:imageview];
    
}

-(void)btnAction{
    JCSliderShowVC * sliderView = [[JCSliderShowVC alloc] init];
    //设置网址的集合
    [sliderView setUrls:self.urls];
    //设置当前的索引
    [sliderView setSelectedIndex:0];
    [self.navigationController pushViewController:sliderView animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
