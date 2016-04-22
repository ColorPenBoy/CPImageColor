# CPImageColor

由于业务需求，CoreDev 封装的 SDK是由C++ OpenCV编写的，需要图片转换成BGR格式。

Demo在[这里](https://github.com/ColorPenBoy/CPImageColor.git)

####格式类型：

* RBGA -  包含Alpha通道
* RGB
* BGR
* Gray - 灰度图

首先理解一张图片的组成，每张图片都是由无数个有序排列的带有颜色的像素点（Pixel）组成的，这些Pixel的排列都可以理解为一个二维数组，每个Pixel都是一个颜色点，即包含RGBA的Pixel。

####什么是RGBA呢
* R - Red
* G - Green
* B - Blue
* A - Alpha 透明度

####一个很重要的函数：从函数的命名可以看出，这是一个Bitmap上下文创建函数

```
	CGContextRef __nullable CGBitmapContextCreate(void * __nullable data,
    size_t width, size_t height, size_t bitsPerComponent, size_t bytesPerRow,
    CGColorSpaceRef __nullable space, uint32_t bitmapInfo)
```
下面来分别说一下这个函数几个参数的意思：

| 参数名称 | 作用、格式 |
|-----|------|
| data| 用来接收数据   |
| width|  图片宽度  |
| height|   图片高度 |
| bitsPerComponent| 每个Pixel的空间，一般为 8 bit   |
| bytesPerRow| 每行bitmap的字节数，一般为 bitsPerComponent * width  |
| space| 颜色空间(3种：CMYK、RGB、Gray)  |
|bitmapInfo|bitmap是否应该包含一个阿尔法通道和它是如何产生的,以及是否组件是浮点或整数|

我们主要利用这个函数，来进行下面的转换工作。

####将UIImage转为RGBA格式
```
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
```

####继续上面的工作，获取这张图片中某个Pixel的RGBA值

```
- (void)getRGBAFromImage:(UIImage *)image atX:(int)xx andY:(int)yy 
{
    
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

```
####将图片转为BGR格式
转换为BGR格式，顾名思义，BGR与RGBA，我们只需要把RGBA数据取到，去掉Alpha，再调换一下RGB的顺序就可以了，下面是具体调换代码：

```
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

```
####什么是Gray灰度
灰度（Gray scale）数字图像是每个像素只有一个采样颜色的图像。这类图像通常显示为从最暗黑色到最亮的白色的灰度

那么如何获取一个Pixel的Gray value呢：

```
心理学公式:
	Gray = R * 0.299 + G * 0.587 + B * 0.114

平均值方法:
    GRAY = (RED + BLUE + GREEN) / 3
   （GRAY,GRAY,GRAY ） 替代 （RED,GREEN,BLUE）
   
位移算法:
	Gray = (R * 19595 + G * 38469 + B * 7472) >> 16
```

计算机上所有的颜色都可以用这4个数值的组合来表示出来，RGB即为计算机的三原色。

####将一张图片转为灰度图

```
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
```

###参考资料(彦祖分享)
* 苹果官方Demo: [RosyWriter](https://developer.apple.com/library/ios/samplecode/RosyWriter/Introduction/Intro.html)
* [Shadertoy](https://www.shadertoy.com/)
* [A Beginner's Guide to Coding Graphics Shaders](http://gamedevelopment.tutsplus.com/tutorials/a-beginners-guide-to-coding-graphics-shaders--cms-23313)
* [Basic Threejs Scene](http://codepen.io)