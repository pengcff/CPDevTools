//
//  CPLogFileListVC.m
//  CPDevTools
//
//  Created by peng on 2017/8/1.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CPLogFileListVC.h"
#import "CPLogFileInfoVC.h"

#import "CPLogMonitor.h"


@interface CPLogFileListVC ()<
UITableViewDataSource,
UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *logsTableView;

@property (nonatomic, strong) NSMutableArray *logList;

@end

@implementation CPLogFileListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.logList = [[[CPLogMonitor sharedMonitor] eunmFileName] copy];
    
    [self.logsTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.logList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CPLogFileListCell" forIndexPath:indexPath];
    if (indexPath.row < self.logList.count) {
        UILabel *label = [cell viewWithTag:100];
        label.text = self.logList[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.logList.count) {
        CPLogFileInfoVC *vc = [CPLogFileInfoVC logFileInfoVC:self.logList[indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
