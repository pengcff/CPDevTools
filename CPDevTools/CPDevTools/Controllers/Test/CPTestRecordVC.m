//
//  CPTestRecordVC.m
//  CPDevTools
//
//  Created by peng on 2018/7/5.
//  Copyright © 2018年 cinvoke. All rights reserved.
//

#import "CPTestRecordVC.h"
#import "CPRecordMonitor.h"

@interface CPTestRecordVC ()<
UITableViewDelegate,
UITableViewDataSource>

//UI
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataList;

@end

@implementation CPTestRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDictionary *recordVCDic = [CPRecordMonitor sharedMonitor].recordVCDic;
    NSArray *akeys = [recordVCDic keysSortedByValueUsingSelector:@selector(compare:)];
    self.dataList = [[akeys reverseObjectEnumerator] allObjects];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Target-Actions
- (IBAction)cleanBtnClick:(UIButton *)sender {
    [[CPRecordMonitor sharedMonitor] cleanLocalData];
    NSDictionary *recordVCDic = [CPRecordMonitor sharedMonitor].recordVCDic;
    NSArray *akeys = [recordVCDic keysSortedByValueUsingSelector:@selector(compare:)];
    self.dataList = [[akeys reverseObjectEnumerator] allObjects];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CPTestRecordCellID" forIndexPath:indexPath];
    
    if (indexPath.row < self.dataList.count) {
        NSString *key = self.dataList[indexPath.row];
        NSNumber *count = [[CPRecordMonitor sharedMonitor].recordVCDic valueForKey:key];
        NSString *name = [[CPRecordMonitor sharedMonitor].nameVCDic valueForKey:key];
        
        UILabel *nameLabel = [cell viewWithTag:100];
        UILabel *countLabel = [cell viewWithTag:101];
        
        nameLabel.text = name ? [NSString stringWithFormat:@"%@\n%@",name,key] : key;
        countLabel.text = [NSString stringWithFormat:@"次数:%@",count];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}


@end
