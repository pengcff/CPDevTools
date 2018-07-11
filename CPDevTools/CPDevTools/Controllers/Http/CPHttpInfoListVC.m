//
//  CPHttpInfoListVC.m
//  CPDevTools
//
//  Created by mac on 2017/7/26.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CPHttpInfoListVC.h"
#import "CPNetworkMonitor.h"
#import "CPHttpInfoVC.h"

@interface CPHttpInfoListVC ()
<UITableViewDataSource,
UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray<CPHttpModel *> *httpInfoList;

@end

@implementation CPHttpInfoListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setter/Getter
- (NSMutableArray<CPHttpModel *> *)httpInfoList {
    
    return [CPNetworkMonitor sharedMonitor].httpList;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.httpInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CPHttpInfoListCell" forIndexPath:indexPath];
    
    if (indexPath.row < self.httpInfoList.count) {
        
        UILabel *urlLabel = [cell viewWithTag:100];
        urlLabel.text = self.httpInfoList[indexPath.row].URL;
        
        UILabel *dateLabel = [cell viewWithTag:101];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        dateLabel.text = [dateFormatter stringFromDate:self.httpInfoList[indexPath.row].requestStartTime];
        
        
        UILabel *codeLabel = [cell viewWithTag:102];
        codeLabel.text = [NSString stringWithFormat:@"code:%@",@(self.httpInfoList[indexPath.row].statusCode)];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.httpInfoList.count) {
        
        CPHttpInfoVC *vc = [CPHttpInfoVC httpInfoVC:self.httpInfoList[indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
