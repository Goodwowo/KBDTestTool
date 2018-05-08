
#import "ReactiveObjC.h"
#import "UIView+RT.h"
#import "UIView+KVO.h"
#import "KVOAllView.h"
#import "KBDTestTool.h"
#import "Aspects.h"
#import "UIView+RTLayerIndex.h"
#import "RTOperationQueue.h"
#import "RTCommandList.h"
#import "JohnAlertManager.h"
#import "RTInteraction.h"
#import "UIViewController+RT.h"
#import "RTTopVC.h"
#import "ZHStatusBarNotification.h"
#import "RTGetTargetView.h"
#import "RTDisPlayAllView.h"
#import "UIScrollView+RT.h"
#import "UIView+Frame.h"
#import "RTViewHierarchy.h"
#import "RTOperationImage.h"
#import "RTAutoRun.h"
#import "RTPlayBack.h"
#import "RTConfigManager.h"
#import "SimulationView.h"
#import "RTScreenRecorder.h"
#import "RTRecordVideo.h"
#import "RTOpenDataBase.h"
#import "RTSearchVCPath.h"
#import "RTLoginViewController.h"
#import "RTRegistViewController.h"
#import "RTForgetPasswordViewController.h"
#import "RTSystemClass.h"
#import "RTVCLearn.h"
#import "RTAutoJump.h"
#import "RTDeviceInfo.h"
#import "RTCrashLag.h"
#import "DateTools.h"
#import "ZHSaveDataToFMDB.h"
#import "TabBarAndNavagation.h"
#import "NSArray+ZH.h"
#import "NSDictionary+ZH.h"
#import "UIColor+SDColor.h"
#import "SuspendBall.h"

//获取屏幕 宽度、高度
#define CurrentScreen_Width ([UIScreen mainScreen].bounds.size.width)
#define CurrentScreen_Height ([UIScreen mainScreen].bounds.size.height)

// 获取RGB颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)
#define RGBOnly(color) RGB(color,color,color)

#define Run 1

#define IsRecord 1
#define IsRunRecord !IsRecord

#define KVO_Tap 1
#define KVO_Event 1
#define KVO_Scroll 1
#define KVO_TextView 1
#define KVO_TextField 1
#define KVO_tableView_didSelectRowAtIndexPath 1
#define KVO_collectionView_didSelectRowAtIndexPath 1

#define KVO_Super 1
#define NeedSimilationView 0

#define CurrentAppThemeColor RGB(257,127,0)
#define KBD_VERSION (@"1.0.0")
