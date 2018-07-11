//
//  CPRunloopMonitor.h
//  CPDevTools
//
//  Created by peng on 2017/8/1.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPRunloopModel : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSString *mainThread;
@property (nonatomic, copy) NSString *allThread;

@end


@interface CPRunloopMonitor : NSObject

@property (nonatomic, strong) NSMutableArray *runloopInfoList;

+ (instancetype)sharedMonitor;

- (void)start;
- (void)stop;

@end
