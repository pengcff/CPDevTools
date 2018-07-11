//
//  CPRunloopMonitor.m
//  CPDevTools
//
//  Created by mac on 2017/8/1.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CPRunloopMonitor.h"
#import "BSBacktraceLogger.h"

@implementation CPRunloopModel

@end

@interface CPRunloopMonitor ()
{
    CFRunLoopObserverRef observer;
    
@public
    dispatch_semaphore_t semaphore;
    CFRunLoopActivity activity;
}

@end

@implementation CPRunloopMonitor

static CPRunloopMonitor *_sharedMonitor;
+ (instancetype)sharedMonitor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMonitor = [[self alloc] init];
    });
    return _sharedMonitor;
}

- (NSMutableArray *)runloopInfoList {
    if (_runloopInfoList == nil) {
        _runloopInfoList = [NSMutableArray array];
    }
    return _runloopInfoList;
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    CPRunloopMonitor *moniotr = (__bridge CPRunloopMonitor*)info;
    
    moniotr->activity = activity;
    
    dispatch_semaphore_t semaphore = moniotr->semaphore;
    dispatch_semaphore_signal(semaphore);
}

- (void)stop
{
    if (!observer)
        return;
    
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    CFRelease(observer);
    observer = NULL;
}

- (void)start
{
    if (observer)
        return;
    
    // 信号
    semaphore = dispatch_semaphore_create(0);
    
    // 注册RunLoop状态观察
    CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
    observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                       kCFRunLoopAllActivities,
                                       YES,
                                       0,
                                       &runLoopObserverCallBack,
                                       &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    
    // 在子线程监控时长
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (YES)
        {
            long st = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 20*NSEC_PER_MSEC));
            if (st != 0)
            {
                if (!observer)
                {
                    semaphore = 0;
                    activity = 0;
                    return;
                }
                
                if (activity==kCFRunLoopBeforeSources || activity==kCFRunLoopAfterWaiting)
                {
                    CPRunloopModel *model = [[CPRunloopModel alloc] init];
                    model.date = [NSDate date];
                    model.mainThread = [BSBacktraceLogger bs_backtraceOfMainThread];
                    model.allThread = [BSBacktraceLogger bs_backtraceOfAllThread];
                    
                    [self.runloopInfoList insertObject:model atIndex:0];
                }
            }
        }
    });
}


@end
