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
    
    // UIImage -> RGBA
    [self getRGBAWithImage:self.testImage];
    
    // 获取一张图片中某个Pixel的RGBA值
    [self getRGBAFromImage:self.testImage atX:0 andY:0];

    // UIImage -> Gray
    [self getGrayWithImage:self.testImage];
    
    // UIImage -> BRG
    [self getBGRWithImage:self.testImage];
    
}
- (unsigned char *)getBGRWithImage:(UIImage *)image
{
    int RGBA = 4;
    int RGB  = 3;
    
    CGImageRef imageRef = [image CGImage];
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char *) malloc(width * height * sizeof(unsigned char) * RGBA);
    NSUInteger bytesPerPixel = RGBA;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    unsigned char * tempRawData = (unsigned char *)malloc(width * height * 3 * sizeof(unsigned char));
    
    for (int i = 0; i < width * height; i ++) {
        
        NSUInteger byteIndex = i * RGBA;
        NSUInteger newByteIndex = i * RGB;
        
        // Get RGB
        CGFloat red    = rawData[byteIndex + 0];
        CGFloat green  = rawData[byteIndex + 1];
        CGFloat blue   = rawData[byteIndex + 2];
        //CGFloat alpha  = rawData[byteIndex + 3];// 这里Alpha值是没有用的
        
        // Set RGB To New RawData
        tempRawData[newByteIndex + 0] = blue;   // B
        tempRawData[newByteIndex + 1] = green;  // G
        tempRawData[newByteIndex + 2] = red;    // R
    }
    
    return tempRawData;
}

#pragma mark - UIImage -> Gray
- (unsigned char *)getGrayWithImage:(UIImage *)image
{
    int GRAY = 1;
    
    // 获取灰度图
    CGImageRef imageRef = [image CGImage];
    
    int width = image.size.width;
    int height = image.size.height;
    unsigned char *rawData = (unsigned char *) malloc(width * height * sizeof(unsigned char));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    NSUInteger bytesPerPixel = GRAY;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, 0);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return rawData;
}


#pragma mark - 获取到一张图片中某个Pixel的RGBA值
- (void)getRGBAFromImage:(UIImage *)image atX:(int)xx andY:(int)yy {
    
    int RGBA = 4;
    
    CGImageRef imageRef = [image CGImage];
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // 从image的data buffer中取得影像，放入格式化后的rawData中
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char *)malloc(height * width * RGBA);
    NSUInteger bytesPerPixel = RGBA;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    /*
     创建一个BitMap的上下文:
        rawData -> 用来接收数据
        width,height -> 图片宽高
        bitsPerComponent -> 每个Pixel的空间，8 bit
        bytesPerRow -> 每行bitmap的字节数，8 bit * width
        colorSpace -> 颜色空间(3种：CMYK、RGB、Gray)
        CGBitmapInfo、CGImageAlphaInfo -> 最后一个参数：bitmap是否应该包含一个阿尔法通道和它是如何产生的,以及是否组件是浮点或整数
     */
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

#pragma mark - UIImage -> RGBA
- (unsigned char *)getRGBAWithImage:(UIImage *)image
{
    int RGBA = 4;
    
    CGImageRef imageRef = [image CGImage];
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char *) malloc(width * height * sizeof(unsigned char) * RGBA);
    NSUInteger bytesPerPixel = RGBA;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return rawData;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
