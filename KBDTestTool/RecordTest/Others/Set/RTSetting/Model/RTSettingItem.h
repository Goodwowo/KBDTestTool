
#import <UIKit/UIKit.h>
@class RTIdentify;

typedef enum : NSInteger{
    ZFSettingItemTypeNone, // 什么也没有
    ZFSettingItemTypeArrow, // 箭头
    ZFSettingItemTypeSwitch // 开关
} ZFSettingItemType;

@interface RTSettingItem : NSObject

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subTitle;

@property (nonatomic, copy) NSString *detail;

@property (nonatomic, assign) ZFSettingItemType type;// Cell的样式
@property (nonatomic, assign) CGFloat titleFontSize;

@property (nonatomic, assign) CGFloat detailFontSize;

@property (nonatomic, assign) CGFloat subTitleFontSize;

@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) UIColor *detailColor;

@property (nonatomic, strong) UIColor *subTitleColor;

@property (nonatomic,assign)BOOL on;

@property (nonatomic,assign)BOOL isEdit;
@property (nonatomic,assign)BOOL isSelect;

@property (nonatomic,strong)RTIdentify *identify;
@property (nonatomic,copy)NSString *stamp;
/** cell上开关的操作事件 */
@property (nonatomic, copy) void (^switchBlock)(BOOL on) ;

@property (nonatomic, copy) void (^operation)() ; // 点击cell后要执行的操作

+ (id)itemWithIcon:(NSString *)icon title:(NSString *)title type:(ZFSettingItemType)type;

+ (id)itemWithIcon:(NSString *)icon title:(NSString *)title subTitle:(NSString *)subTitle type:(ZFSettingItemType)type;

+ (id)itemWithIcon:(NSString *)icon title:(NSString *)title detail:(NSString *)detail type:(ZFSettingItemType)type;

@end
