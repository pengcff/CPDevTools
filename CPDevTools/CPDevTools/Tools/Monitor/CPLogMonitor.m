//
//  CPLogMonitor.m
//  CPDevTools
//
//  Created by mac on 2017/8/1.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CPLogMonitor.h"

#import "fishhook.h"
#import <dlfcn.h>

@interface CPLogMonitor ()

@property (nonatomic, copy) NSString *defaultLogPath;

@end

@implementation CPLogMonitor

static void (*orig_NSLog)(NSString *format, ...);

void cp_NSLog(NSString *format, ...) {
    
    //可变参数格式化
    va_list args;
    va_start(args, format);
    NSString *formatStr = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    _sharedMonitor.realtimeLog = [_sharedMonitor.realtimeLog stringByAppendingFormat:@"%@\n",formatStr];
    
    orig_NSLog(@"%@",formatStr);
}

static CPLogMonitor *_sharedMonitor;
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
        
        self.realtimeLog = [NSString string];
    }
    return self;
}

- (void)start {
    
    orig_NSLog = dlsym(RTLD_DEFAULT, "NSLog");  //保存原始NSLog地址
    rebind_symbols((struct rebinding[1]){"NSLog", cp_NSLog}, 1);    //替换
    
}

- (void)setDefaultLogPath:(NSString *)logPath {
    
    _defaultLogPath = logPath;
}

- (NSArray <NSString *>*)eunmFileName {
    
    NSMutableArray *logFileNameList = [NSMutableArray array];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.defaultLogPath];
    for (NSString *logFile in enumerator) {
        [logFileNameList addObject:logFile];
    }
    
    return [logFileNameList copy];
}


- (NSString *)fileContentWithFileName:(NSString *)fileName error:(NSError *)error {
    
    NSString *filePath = [self.defaultLogPath stringByAppendingString:fileName];
    NSString *fileContent = [[NSString alloc] initWithContentsOfFile:filePath
                                                            encoding:NSUTF8StringEncoding error:&error];
    
    return fileContent;
}

@end
