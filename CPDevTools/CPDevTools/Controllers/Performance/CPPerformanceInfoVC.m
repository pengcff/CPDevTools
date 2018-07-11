//
//  CPPerformanceInfoVC.m
//  CPDevTools
//
//  Created by peng on 2017/8/1.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CPPerformanceInfoVC.h"
#import "CPRunloopMonitor.h"
#import "CPDeveToolsDefine.h"

@interface CPPerformanceInfoVC ()

@property (weak, nonatomic) IBOutlet UILabel *mainThreadLabel;
@property (weak, nonatomic) IBOutlet UILabel *allThreadLabel;

@property (nonatomic, strong) CPRunloopModel *model;

@end

@implementation CPPerformanceInfoVC

+ (instancetype)performanceInfoVC:(id)model {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CPMonitor" bundle:CPBundle];
    CPPerformanceInfoVC *vc = [sb instantiateViewControllerWithIdentifier:@"CPPerformanceInfoVC"];
    
    vc.model = model;
    
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mainThreadLabel.text = self.model.mainThread;
    
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
