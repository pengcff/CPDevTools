//
//  CPCrashInfoVC.m
//  CPDevTools
//
//  Created by mac on 2017/8/1.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CPCrashInfoVC.h"
#import "CPCrashMonitor.h"
#import "CPDeveToolsDefine.h"

@interface CPCrashInfoVC ()

@property (weak, nonatomic) IBOutlet UILabel *currentThreadLabel;
@property (weak, nonatomic) IBOutlet UILabel *allThreadLabel;

@property (nonatomic, strong) CPCrashModel *model;

@end

@implementation CPCrashInfoVC

+ (instancetype)crashInfoVC:(id)model {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CPMonitor" bundle:CPBundle];
    CPCrashInfoVC *vc = [sb instantiateViewControllerWithIdentifier:@"CPCrashInfoVC"];
    
    vc.model = model;
    
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.currentThreadLabel.text = self.model.currentThread;
    
    self.allThreadLabel.text = self.model.allThread;
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
