//
//  CPRecordMonitor.h
//  CPDevTools
//
//  Created by peng on 2018/7/5.
//  Copyright © 2018年 cinvoke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef void(^bFilter)(Class iclass,NSMutableArray *classList);

@interface CPRecordMonitor : NSObject

@property (nonatomic, strong) NSMutableDictionary *recordVCDic;
@property (nonatomic, strong) NSMutableDictionary *nameVCDic;

+ (instancetype)sharedMonitor;

- (void)startRecordViewControllerWithFilter:(bFilter)filter;


@end
