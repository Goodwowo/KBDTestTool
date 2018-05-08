//
//  Header.h
//  MaiXiang
//
//  Created by mac on 2017/10/24.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisPlayAllView.h"
#import "UIGestureRecognizer+Ext.h"
#import "UIScrollView+AutoScroll.h"
#import "UIView+AutoTestExt.h"
#import "SimulationView.h"
#import "ZHGestureRecognizerTargetAndAction.h"
#import "UIView+Event.h"
#import "UIView+Frame.h"
#import "ViewHolder.h"
#import "NSArray+ZH.h"
#import "UIView+AutoScroll.h"

#define ShouldLogAllView 0 //是否需要打印window上所有控件到控制台

#define AutoTest YES //是否自动运行

#define AutoTest_Interval 1.5 //每一次重复间隔

#define DebugTap YES //是否执行点击事件
#define DebugScroll YES //是否执行滚动事件

#define AutoTest_CornerRadius 0 //标记可以点击的范围和可以滑动的区域的切圆角,默认为0
#define AutoTest_CornerBorderWidth 1 //标记可以点击的范围和可以滑动的区域的边框宽度,默认为0

#define AutoTest_Ges_Tap_Color [UIColor redColor] //标记可以点击的范围的边框颜色
#define AutoTest_UIControl_Action_Color [UIColor redColor] //标记可以点击的范围的边框颜色
#define AutoTest_ScollSwipe_Color [UIColor greenColor] //标记可以滑动的区域的边框颜色

//是否是随机乱点,如果是,那么自动测试过程会是-中间随机生成一个屏幕中的坐标点,无论这个坐标点点击下去,会不会有控件接收它的事件,但是这样会导致重复点击tableViewCell的概率变大,还有就是空白区域较多时很难点击返回按钮,总体所有页面的访问率不大
#define AutoTest_Random_Touch NO //建议为NO
#define AutoTest_RandomClickCount 5000 //当随机乱点的次数超过这个数值时,就会清空所有点击记录,代表重新开始记录

#define AutoTest_Happen_Click_UIControl 2 //UIControl最多点击次数限制
#define AutoTest_Happen_Click_Cell 1 //TableViewCell或者CollectionView的最多点击次数限制
#define AutoTest_Happen_Click_ChangeTopViewController AutoTest_Happen_Click_UIControl+2 //当发生事件时会有页面切换,就给这些事件多几次点击机会
#define AutoTest_WebView_AutoLink 5 //webView自动跳转网页次数

#define Push_Pop_Present_Dismiss_Animation YES //是否需要页面过渡动画

#define AutoTest_CrashAutoReStart 1 //崩溃后是否需要重新打开此APP,这样的话就可以整晚测试了,不过注意的是,需要另外一个APP相互配合,利用两个APP相互跳转的原理
//需要如下配置才能实现崩溃后重新打开
//1.确定不是连着Xcode运行该软件,需要安装后用户打开,不然崩溃后Xcode因为需要定位崩溃点而占用该软件使其不会退出,导致另外一个APP(名字叫做)不能跳转到该APP
//2.需要在info.plist文件中添加LSApplicationQueriesSchemes字段(数组)(如果没有的话),再在里面加 testapp2(如果里面没有的话)
//3.需要在URL types添加一个URL_Schemes为testapp1
//4.确保手机或者模拟器,除了这个APP的URL types的URL_Schemes存在testapp1,其它APP不存在,这样另外一个APP就一定是打开这个APP,不会出现找错的(一般可能是另外一个APP里也加了这个自动测试的文件)

#define AutoTest_WebViewAutoClickLink YES //WebView是否可以自动点击里面的超链接 这个功能还在琢磨中..........
