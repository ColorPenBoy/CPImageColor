# CPImageColor

由于业务需求，Core 封装的 SDK是由C++ OpenCV编写的，需要图片转换成BGR格式。

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
	Gray = (R*19595 + G*38469 + B*7472) >> 16
```

计算机上所有的颜色都可以用这4个数值的组合来表示出来，RGB即为计算机的三原色。

####第一步：获取到一张图片中某个Pixel的RGBA值

