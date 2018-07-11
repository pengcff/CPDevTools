//
//  CPCrashGuardVC.m
//  CPDevTools
//
//  Created by peng on 2017/10/11.
//  Copyright © 2017年 cinvoke. All rights reserved.
//

#import "CPCrashGuardVC.h"
#import "CPCrashMonitor.h"

#import "CPDeveToolsDefine.h"

@interface CPCrashGuardVC ()

@property (weak, nonatomic) IBOutlet UISwitch *safeKVOSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *safeSelectorSwitch;

@end

@implementation CPCrashGuardVC

+ (instancetype)crashGuradVC {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CPMonitor" bundle:CPBundle];
    CPCrashGuardVC *vc = [sb instantiateViewControllerWithIdentifier:@"CPCrashGuardVC"];
    
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.safeKVOSwitch.on = [CPCrashMonitor sharedMonitor].isEnableKVO;
    self.safeSelectorSwitch.on = [CPCrashMonitor sharedMonitor].isEnableSelector;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)safeKVOSwitchClick:(UISwitch *)sender {
    
    [[CPCrashMonitor sharedMonitor] isEnableGuardKVO:sender.isOn];
}

- (IBAction)safeSelectorSwitchClick:(UISwitch *)sender {
    
    [[CPCrashMonitor sharedMonitor] isEnableGuardSelector:sender.isOn];
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
