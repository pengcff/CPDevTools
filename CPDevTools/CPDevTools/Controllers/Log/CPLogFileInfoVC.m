//
//  CPLogFileInfoVC.m
//  CPDevTools
//
//  Created by mac on 2017/8/15.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CPLogFileInfoVC.h"
#import "CPLogMonitor.h"
#import "CPDeveToolsDefine.h"


@interface CPLogFileInfoVC ()

@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, assign) BOOL isLocalLog;

@end

@implementation CPLogFileInfoVC

+ (instancetype)logFileInfoVC:(id)model {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CPMonitor" bundle:CPBundle];
    CPLogFileInfoVC *vc = [sb instantiateViewControllerWithIdentifier:@"CPLogFileInfoVC"];
    
    vc.model = model;
    vc.isLocalLog = YES;
    
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.isLocalLog) {
        NSString *log = [[CPLogMonitor sharedMonitor] fileContentWithFileName:self.model error:nil];
        self.logTextView.text = log;
    }else {
        self.logTextView.text = [CPLogMonitor sharedMonitor].realtimeLog;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
