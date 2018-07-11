//
//  CPCrashInfoListVC.m
//  CPDevTools
//
//  Created by peng on 2017/8/1.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CPCrashInfoListVC.h"
#import "CPCrashInfoVC.h"
#import "CPCrashGuardVC.h"

#import "CPCrashMonitor.h"

@interface CPCrashInfoListVC ()

@property (weak, nonatomic) IBOutlet UITableView *crashTableView;

@property (nonatomic ,strong) NSMutableArray<CPCrashModel *> *crashInfoList;

@end

@implementation CPCrashInfoListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray<CPCrashModel *> *)crashInfoList {
    
    if (_crashInfoList == nil) {
        _crashInfoList = [CPCrashMonitor sharedMonitor].crashList;
    }
    
    return _crashInfoList;
}

- (IBAction)guardBtnClick:(UIButton *)sender {
    
    CPCrashGuardVC *crashGuardVC = [CPCrashGuardVC crashGuradVC];
    [self.navigationController pushViewController:crashGuardVC animated:YES];
}

- (IBAction)cleanBtnClick:(UIButton *)sender {
    
    [[CPCrashMonitor sharedMonitor] cleanLocalData];
    self.crashInfoList = nil;
    [self.crashTableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */
#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.crashInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CPCrashInfoListCell" forIndexPath:indexPath];
    
    if (indexPath.row < self.crashInfoList.count) {
        
        UILabel *urlLabel = [cell viewWithTag:100];
        urlLabel.text = self.crashInfoList[indexPath.row].reason;
        
        UILabel *dateLabel = [cell viewWithTag:101];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *date = [dateFormatter stringFromDate:self.crashInfoList[indexPath.row].date];
        dateLabel.text = date;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.crashInfoList.count) {
        CPCrashInfoVC *vc = [CPCrashInfoVC crashInfoVC:self.crashInfoList[indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
