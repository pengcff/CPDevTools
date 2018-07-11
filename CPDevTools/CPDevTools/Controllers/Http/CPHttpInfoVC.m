//
//  CPHttpInfoVC.m
//  CPDevTools
//
//  Created by peng on 2017/7/26.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CPHttpInfoVC.h"
#import "CPNetworkMonitor.h"
#import "CPDeveToolsDefine.h"

@interface CPHttpInfoVC ()

//Data
@property (nonatomic, strong) CPHttpModel *model;

//UI
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *requestLabel;
@property (weak, nonatomic) IBOutlet UILabel *responseLabel;


@end

@implementation CPHttpInfoVC

+ (instancetype)httpInfoVC:(id)model {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CPMonitor" bundle:CPBundle];
    CPHttpInfoVC *vc = [sb instantiateViewControllerWithIdentifier:@"CPHttpInfoVC"];
    
    vc.model = model;
    
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.urlLabel.text = self.model.URL;
    
    self.codeLabel.text = self.model.error ? [NSString stringWithFormat:@"%@(%@)",@(self.model.statusCode),self.model.error] : [NSString stringWithFormat:@"%@",@(self.model.statusCode)];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSString *requestStartTime = [dateFormatter stringFromDate:self.model.requestStartTime];
    NSString *requestEndTime = [dateFormatter stringFromDate:self.model.requestEndTime];
    
    NSString *responseStartTime = [dateFormatter stringFromDate:self.model.responseStartTime];
    NSString *responseEndTime = [dateFormatter stringFromDate:self.model.responseEndTime];
    
    NSString *timeStr = @"";
    timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@"requestStartTime:   %@\n",requestStartTime]];
    timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@"requestEndTime:     %@\n",requestEndTime]];
    timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@"responseStartTime:  %@\n",responseStartTime]];
    timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@"responseEndTime:    %@\n",responseEndTime]];
    
    self.timeLabel.text = timeStr;
    
    NSString *headerStr = @"";
    for (NSString *key in self.model.header.allKeys) {
        headerStr = [headerStr stringByAppendingString:[NSString stringWithFormat:@"%@:%@\n",key,self.model.header[key]]];
    }
    self.headerLabel.text = headerStr;
    
    
    self.requestLabel.text = self.model.request;
    
    
    self.responseLabel.text = self.model.response;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)requestCopyBtnClick:(UIButton *)sender {
    
    [UIPasteboard generalPasteboard].string = self.requestLabel.text;
}

- (IBAction)responseCopyBtnClick:(UIButton *)sender {
    
    [UIPasteboard generalPasteboard].string = self.responseLabel.text;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
