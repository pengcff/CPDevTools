//
//  CPLogMonitor.h
//  CPDevTools
//
//  Created by peng on 2017/8/1.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPLogMonitor : NSObject

@property (nonatomic, copy) NSString *realtimeLog;

+ (instancetype)sharedMonitor;

- (void)start;

- (void)setDefaultLogPath:(NSString *)logPath;

- (NSArray <NSString *>*)eunmFileName;

- (NSString *)fileContentWithFileName:(NSString *)fileName error:(NSError *)error;

@end
