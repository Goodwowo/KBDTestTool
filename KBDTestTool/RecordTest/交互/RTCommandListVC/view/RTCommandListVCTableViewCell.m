#import "RTCommandListVCTableViewCell.h"
#import "RecordTestHeader.h"

@interface RTCommandListVCTableViewCell ()

@property (nonatomic,strong)UIImageView *hintImg;
@property (nonatomic,strong)UIImageView *selectImg;
@property (nonatomic,strong)UILabel *hintLabel;

@property (nonatomic,weak)RTCommandListVCCellModel *dataModel;

@end

@implementation RTCommandListVCTableViewCell

- (void)refreshUI:(RTCommandListVCCellModel *)dataModel{
    _dataModel = dataModel;
    if (dataModel.identify) {
        self.hintLabel.text = [dataModel.identify debugDescription];
    }else if (dataModel.operationModel){
        self.hintLabel.text = [dataModel.operationModel debugDescription];
    }
    switch (dataModel.runResultType) {
        case OperationRunResultTypeNoRun:
            self.hintImg.backgroundColor = [UIColor whiteColor];
            self.hintLabel.textColor = [UIColor whiteColor];
            break;
        case OperationRunResultTypeRunSuccess:
            self.hintImg.backgroundColor = [UIColor greenColor];
            self.hintLabel.textColor = [UIColor greenColor];
            break;
        case OperationRunResultTypeFailure:
            self.hintImg.backgroundColor = [UIColor redColor];
            self.hintLabel.textColor = [UIColor redColor];
            break;
        default:
            break;
    }
    self.selectImg.hidden = !dataModel.isShowSelect;
    self.hintImg.hidden = dataModel.isShowSelect;
    if (dataModel.isShowSelect) {
        self.selectImg.image = dataModel.isSelect ? [UIImage imageNamed:@"RTCommandListSelect"] : [UIImage imageNamed:@"RTCommandListNoSelect"];
        self.selectImg.backgroundColor = dataModel.isSelect ? [UIColor greenColor] : [UIColor clearColor];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        self.hintImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, 12, 15, 15)];
        [self.contentView addSubview:self.hintImg];
        [self.hintImg cornerRadius];
        self.hintLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, [UIScreen mainScreen].bounds.size.width - 35, 44)];
        self.hintLabel.textColor = [UIColor whiteColor];
        self.hintLabel.font = [UIFont systemFontOfSize:14];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [self.contentView addSubview:self.hintLabel];
        self.hintImg.image = [UIImage imageNamed:@"SuspendBall_startrecord"];
        self.selectImg = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 20, 12, 15, 15)];
        [self.contentView addSubview:self.selectImg];
        [self.selectImg cornerRadius];
    }
    return self;
}

@end
