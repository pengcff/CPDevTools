//
//  CPCrashMonitor.m
//  CPDevTools
//
//  Created by peng on 2017/7/28.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CPCrashMonitor.h"

#import "CPSafeKVO.h"
#import "CPSafeSelector.h"

#define kPlistPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"CPCrashData.plist"]


@implementation CPCrashModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        
        self.reason = dictionary[@"reason"];
        self.currentThread = dictionary[@"currentThead"];
        self.allThread = dictionary[@"allThread"];
        self.date = dictionary[@"date"];
    }
    return self;
}

- (NSDictionary *)modelToDictionary {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:self.reason forKey:@"reason"];
    [dictionary setValue:self.currentThread forKey:@"currentThead"];
    [dictionary setValue:self.allThread forKey:@"allThread"];
    [dictionary setValue:self.date forKey:@"date"];
    
    return dictionary;
}

- (void)dataSave {
    
    NSString *plistPath = kPlistPath;
    
    NSMutableDictionary *crashDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    if (crashDic) {
        NSMutableArray *crashInfoList = [crashDic[@"list"] mutableCopy];
        [crashInfoList addObject:[self modelToDictionary]];
        
        [crashDic setValue:crashInfoList forKey:@"list"];
        [crashDic writeToFile:plistPath atomically:YES];
        
    }else {
        
        crashDic = [NSMutableDictionary dictionary];
        NSMutableArray *crashInfoList = [NSMutableArray array];
        [crashInfoList addObject:[self modelToDictionary]];
        
        [crashDic setValue:crashInfoList forKey:@"list"];
        [crashDic writeToFile:plistPath atomically:YES];
    }
}

@end


@implementation CPCrashMonitor

static NSUncaughtExceptionHandler *oldExceptionHandler;

void CPuncaughtExceptionHandler(NSException *exception) {
    
    oldExceptionHandler(exception);
    
    CPCrashModel *crashModel = [[CPCrashModel alloc] init];
    crashModel.reason = exception.reason;
    crashModel.currentThread = [exception.callStackSymbols description];
    
    [crashModel dataSave];
}

static CPCrashMonitor *_sharedMonitor;
+ (instancetype)sharedMonitor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMonitor = [[self alloc] init];
    });
    return _sharedMonitor;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleCrashMessage:)
                                                     name:@"CPCrashMontorCrashMessage"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)start {
    
    if (isatty(STDOUT_FILENO) == NO) {
        //连着xcode时不开启
        oldExceptionHandler = NSGetUncaughtExceptionHandler();
        NSSetUncaughtExceptionHandler(&CPuncaughtExceptionHandler);
    }
}

- (void)handleCrashMessage:(NSNotification *)notification {
    
    NSDictionary *info = notification.userInfo;
    
    if (info) {
        
        CPCrashModel *crashModel = [[CPCrashModel alloc] init];
        crashModel.reason = info[@"reason"];
        crashModel.currentThread = info[@"currentThread"];
        crashModel.allThread = info[@"allThread"];
        crashModel.date = [NSDate date];
        
        [crashModel dataSave];
    }
}

- (NSArray *)crashList {
    
    NSString *plistPath = kPlistPath;
    NSMutableDictionary *crashDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSArray *list = crashDic[@"list"];
    
    NSMutableArray *crashList = [NSMutableArray array];
    for (NSDictionary *dic in list) {
        CPCrashModel *model = [[CPCrashModel alloc] initWithDictionary:dic];
        [crashList addObject:model];
    }
    
    _crashList = [[[crashList reverseObjectEnumerator] allObjects] copy];
    
    return _crashList;
}

- (void)isEnableGuardKVO:(BOOL)isEnable {
    
    self.isEnableKVO = isEnable;
    if (isEnable) {
        [CPSafeKVO enabled];
    }else {
        [CPSafeKVO disabled];
    }
}

- (void)isEnableGuardSelector:(BOOL)isEnable {
    
    self.isEnableSelector = isEnable;
    if (isEnable) {
        [CPSafeSelector enabled];
    }else {
        [CPSafeSelector disabled];
    }
}

- (void)cleanLocalData {
    
    NSString *plistPath = kPlistPath;
    NSMutableDictionary *crashDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    [crashDic setValue:[NSArray array] forKey:@"list"];
    
    [crashDic writeToFile:plistPath atomically:YES];
}

@end
