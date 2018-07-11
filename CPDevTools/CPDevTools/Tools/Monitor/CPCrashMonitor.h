//
//  CPCrashMonitor.h
//  CPDevTools
//
//  Created by peng on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPCrashModel : NSObject

@property (nonatomic, copy) NSString *reason;

@property (nonatomic, copy) NSString *currentThread;
@property (nonatomic, copy) NSString *allThread;

@property (nonatomic, strong) NSDate *date;

@end

@interface CPCrashMonitor : NSObject

@property (nonatomic, strong) NSMutableArray *crashList;
@property (nonatomic, assign) BOOL isEnableKVO;
@property (nonatomic, assign) BOOL isEnableSelector;

+ (instancetype)sharedMonitor;

- (void)start;

- (void)isEnableGuardKVO:(BOOL)isEnable;

- (void)isEnableGuardSelector:(BOOL)isEnable;

- (void)cleanLocalData;

@end
