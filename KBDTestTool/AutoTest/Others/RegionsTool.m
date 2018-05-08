
#import "RegionsTool.h"

const int MaxN=10001;

int x_arr[MaxN];//记录所有矩形的x
int y_arr[MaxN];//记录所有矩形的y
int x_w_arr[MaxN];//记录所有矩形的width
int y_h_arr[MaxN];//记录所有矩形的height
int bg_w;//window的width
int bg_h;//window的height
int viewCount;//所有控件的个数(不包括window)
int viewArr[MaxN];//所有控件
int area[MaxN];//所有控件计算剩余的没有被遮挡的矩形面积总和
int curView;//当前第几个矩形(用于数组下标)

void regionClip(int x,int x_w,int y,int y_h,int z){
    //当与上一层比较时,发现没有交集(重叠),继续上游
    while(z<=viewCount && (x>=x_w_arr[z] || x_w<=x_arr[z] || y>=y_h_arr[z] || y_h<=y_arr[z]))z++;
    
    if(z>viewCount){//没有重叠
        area[curView]+=(x_w-x)*(y_h-y);//计算面积并保存
        return;
    }
    
    if(x<x_arr[z]){//右边重叠
        regionClip(x,x_arr[z],y,y_h,z+1);
        x=x_arr[z];//裁掉左边没重叠的矩形,剩下右边除了重叠之外的矩形,这样就不会有重复的计算面积
    }
    
    if(x_w>x_w_arr[z]){//左边重叠
        regionClip(x_w_arr[z],x_w,y,y_h,z+1);
        x_w=x_w_arr[z];
    }
    
    if(y<y_arr[z]){//下面重叠
        regionClip(x,x_w,y,y_arr[z],z+1);
    }
    
    if(y_h>y_h_arr[z]){//上面重叠
        regionClip(x,x_w,y_h_arr[z],y_h,z+1);
    }
}

NSMutableArray * filter_c(NSMutableArray *events){
    memset(x_arr,0,sizeof(x_arr));
    memset(y_arr,0,sizeof(y_arr));
    memset(x_w_arr,0,sizeof(x_w_arr));
    memset(y_h_arr,0,sizeof(y_h_arr));
    memset(viewArr,0,sizeof(viewArr));
    memset(area,0,sizeof(area));
    
    CGRect mainScreen=[UIScreen mainScreen].bounds;
    bg_w=mainScreen.size.width;
    bg_h=mainScreen.size.height;
    viewCount=(int)events.count;
    
    x_arr[0]=y_arr[0]=0;x_w_arr[0]=bg_w;y_h_arr[0]=bg_h;viewArr[0]=1;
    
    for (NSInteger i=0,count=events.count; i<count; i++) {
        id event=events[i];
        CGRect frame=[event rect];
        
        x_arr[i+1]=(int)frame.origin.x;
        y_arr[i+1]=(int)frame.origin.y;
        x_w_arr[i+1]=(int)frame.origin.x+(int)frame.size.width;
        y_h_arr[i+1]=(int)frame.origin.y+(int)frame.size.height;
        viewArr[i+1]=(int)i+2;
    }
    
    int i;
    
    for(i=viewCount;i>=0;i--){
        curView=viewArr[i];
        regionClip(x_arr[i],x_w_arr[i],y_arr[i],y_h_arr[i],i+1);
    }
    
    NSMutableArray *filterArrM=[NSMutableArray array];
    for(i=1;i<MaxN;i++){
        if(area[i]>0){
            if (i>1&&((i-2)<events.count)) {
                [filterArrM addObject:events[i-2]];
            }
        }
    }
    return filterArrM;
}

@implementation RegionsTool

+ (NSMutableArray *)filterEvents:(NSMutableArray *)events{
    return filter_c(events);
}

+ (NSMutableArray *)removesEvent:(NSMutableArray *)events{
    NSMutableArray *temp = [NSMutableArray arrayWithArray:events];
    [temp removeObjectsInArray:filter_c(events)];
    return temp;
}

@end


