//
//  CPPerformanceListVC.m
//  CPDevTools
//
//  Created by mac on 2017/8/1.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CPPerformanceListVC.h"
#import "CPPerformanceInfoVC.h"

#import "CPRunloopMonitor.h"

@interface CPPerformanceListVC ()

@property (nonatomic, strong) NSMutableArray<CPRunloopModel *> * runloopInfoList;

@end

@implementation CPPerformanceListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray<CPRunloopModel *> *)runloopInfoList {
    
    if (_runloopInfoList == nil) {
        _runloopInfoList = [CPRunloopMonitor sharedMonitor].runloopInfoList;
    }
    return _runloopInfoList;
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
    
    return self.runloopInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CPPerformanceListCell" forIndexPath:indexPath];
    
    if (indexPath.row < self.runloopInfoList.count) {
        
        UILabel *dateLabel = [cell viewWithTag:100];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *date = [dateFormatter stringFromDate:self.runloopInfoList[indexPath.row].date];
        dateLabel.text = date;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.runloopInfoList.count) {
        CPPerformanceInfoVC *vc = [CPPerformanceInfoVC performanceInfoVC:self.runloopInfoList[indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
