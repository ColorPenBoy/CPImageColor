//
//  ViewController.m
//  CPImageColorDemo
//
//  Created by 张强 on 16/4/22.
//  Copyright © 2016年 ColorPen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIImage * testImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.testImage = [UIImage imageNamed:@"1.jpg"];
    
    // 第一步：获取到一张图片中某个Pixel的RGBA值
    [self getRGBAFromImage:self.testImage atX:0 andY:0];

    
    
}

#pragma mark - 获取到一张图片中某个Pixel的RGBA值
- (void)getRGBAFromImage:(UIImage *)image atX:(int)xx andY:(int)yy {
    
    CGImageRef imageRef = [image CGImage];
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // 从image的data buffer中取得影像，放入格式化后的rawData中
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char *)malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    // 清空CGContextRef再绘制
    CGContextClearRect(context, CGRectMake(0.0, 0.0, width, height));
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // 将XY坐标转成一维数组
    unsigned long byteIndex = (bytesPerRow * yy) + (bytesPerPixel * xx);
    
    // 取得RGBA位的数据
    CGFloat red   = rawData[byteIndex];
    CGFloat green = rawData[byteIndex + 1];
    CGFloat blue  = rawData[byteIndex + 2];
    CGFloat alpha = rawData[byteIndex + 3];
    
    // 利用RGB计算灰阶的亮度值
    CGFloat gray = (red + green + blue)/3 ;
    
    // 输出
    NSLog(@"%@",[NSString stringWithFormat:@"%.2f", red]);
    NSLog(@"%@",[NSString stringWithFormat:@"%.2f", green]);
    NSLog(@"%@",[NSString stringWithFormat:@"%.2f", blue]);
    NSLog(@"%@",[NSString stringWithFormat:@"%.2f", alpha]);
    NSLog(@"%@",[NSString stringWithFormat:@"%.2f", gray]);
    
    free(rawData);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
