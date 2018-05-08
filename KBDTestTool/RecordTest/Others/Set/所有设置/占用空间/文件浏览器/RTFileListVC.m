
#import "RTFileListVC.h"
#import <MessageUI/MessageUI.h>
#import "ZHFileManager.h"
#import "RTFilePreVC.h"
#import "RTFileInfo.h"
#import "AutoTestHeader.h"

#define HLNavigationBarHeight (self.navigationController ? 0 :64)

@interface RTFileListModel : NSObject
@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *subTitle;
@property (nonatomic,assign)BOOL isDirectory;
@property (nonatomic,strong)RTFileInfo *info;
@end

@implementation RTFileListModel
@end

@interface RTFileListVC ()<MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray    *fileList;
@property (nonatomic, strong) UIView            *headerView;
@property (nonatomic, strong) NSString *directoryStr;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation RTFileListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.activityIndicatorView];
    self.activityIndicatorView.center = self.view.center;
    self.activityIndicatorView.y-=64;
    [self.activityIndicatorView startAnimating];
    
    if (!self.directoryStr) self.directoryStr = NSHomeDirectory();
    
    UINavigationItem *navigationItem = self.navigationItem;
    if (![self.navigationController isKindOfClass:[UINavigationController class]]) {
        UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@""];
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HLNavigationBarHeight)];
        [navigationBar pushNavigationItem:navigationItem animated:NO];
        UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithTitle:@"<返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        navigationItem.leftBarButtonItem = backBarItem;
        self.headerView = navigationBar;
        [self.view addSubview:navigationBar];
    }
    if (self.directoryStr.length == NSHomeDirectory().length && [self.directoryStr isEqualToString:NSHomeDirectory()]) {
        navigationItem.title = @"沙盒目录";
    }else{
        navigationItem.title = [self.directoryStr lastPathComponent];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadData];
    });
}

- (void)loadData{
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directoryStr?:NSHomeDirectory() error:nil];
    NSMutableArray *directoryLists = [NSMutableArray array];
    NSMutableArray *fileLists = [NSMutableArray array];
    for (NSString *filePath in fileList) {
        NSString *tempfilePath = [self getSendBoxPath:filePath];
        RTFileListModel *model = [RTFileListModel new];
        model.title = filePath;
        model.subTitle = [ZHFileManager fileSizeString:tempfilePath];
        model.isDirectory = ([ZHFileManager getFileType:tempfilePath] == FileTypeDirectory);
        model.info = [[RTFileInfo alloc] initWithFileURL:[NSURL fileURLWithPath:tempfilePath]];
        if (model.isDirectory) {
            [directoryLists addObject:model];
        }else{
            [fileLists addObject:model];
        }
    }
    
    self.fileList = [NSMutableArray array];
    [self.fileList addObjectsFromArray:directoryLists];
    [self.fileList addObjectsFromArray:fileLists];
    
    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView stopAnimating];
        [self.tableView reloadData];
    });
}

- (NSString *)getSendBoxPath:(NSString *)path{
    NSString *directoryStr = nil;
    if (!self.directoryStr) directoryStr = self.directoryStr = NSHomeDirectory();
    if (path) directoryStr = [NSString stringWithFormat:@"%@/%@",self.directoryStr, path];
    return directoryStr;
}
- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HLNavigationBarHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* FileTableViewCell = @"FileTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FileTableViewCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:FileTableViewCell];
    }
    RTFileListModel *model = self.fileList[indexPath.row];
    cell.textLabel.text = model.title;
    cell.detailTextLabel.text = model.subTitle;
    cell.textLabel.textColor = (model.isDirectory)? [UIColor blueColor] : [UIColor grayColor];
    cell.imageView.image = [UIImage imageNamed:model.info.typeImageName];
    cell.accessoryType = (model.isDirectory)? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RTFileListModel *model = self.fileList[indexPath.row];
    NSString *filePath = [self getSendBoxPath:model.title];
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        if (isDirectory) {
            RTFileListVC *fileListVC = [[RTFileListVC alloc] init];
            fileListVC.directoryStr = filePath;
            if (self.navigationController) {
                [self.navigationController pushViewController:fileListVC animated:YES];
            }else {
                [self presentViewController:fileListVC animated:YES completion:nil];
            }
        }else{
            RTFilePreVC *vc = [RTFilePreVC new];
            vc.fileInfo = model.info;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

@end
