//
//  CPRecordMonitor.m
//  CPDevTools
//
//  Created by peng on 2018/7/5.
//  Copyright © 2018年 cinvoke. All rights reserved.
//

#import "CPRecordMonitor.h"
#import "NSObject+CPSwizzle.h"
#import <UIKit/UIKit.h>

#define kPlistPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"CPRecordData.plist"]

@implementation UIViewController (CPSwizzle)

- (void)CP_viewDidAppear:(BOOL)animated {
    
    NSString *className = NSStringFromClass(self.class);
    for (NSString *class in [CPRecordMonitor sharedMonitor].recordVCDic.allKeys) {
        if ([class isEqualToString:className]) {
            NSInteger count = [[CPRecordMonitor sharedMonitor].recordVCDic[class] integerValue];
            count ++;
            [[CPRecordMonitor sharedMonitor].recordVCDic setValue:@(count) forKey:class];
            [[CPRecordMonitor sharedMonitor].recordVCDic writeToFile:kPlistPath atomically:YES];
        }
    }
    [self CP_viewDidAppear:animated];
}

@end


@interface CPRecordMonitor ()

@end

@implementation CPRecordMonitor

static CPRecordMonitor *_sharedMonitor;
+ (instancetype)sharedMonitor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMonitor = [[self alloc] init];
    });
    return _sharedMonitor;
}

- (void)startRecordViewControllerWithFilter:(bFilter)filter {
    
    NSMutableArray *classList = [NSMutableArray array];
    
    unsigned int outCount;
    Class *classes = objc_copyClassList(&outCount);
    for (int i = 0; i < outCount; i++) {
        if (filter) {
            filter(classes[i],classList);
        }
    }
    free(classes);
    
    self.recordVCDic = [[NSMutableDictionary alloc] initWithContentsOfFile:kPlistPath];
    if (!self.recordVCDic) {
        self.recordVCDic = @{}.mutableCopy;
        for (NSString *className in classList) {
            [self.recordVCDic setValue:@(0) forKey:className];
        }
    }
    
    [NSObject mothodSwizzleClass:@"UIViewController"
                             Old:@"viewDidAppear:"
                             new:@"CP_viewDidAppear:"];
}

- (void)cleanLocalData {
    
    NSMutableDictionary *tempDic = self.recordVCDic;
    for (NSString *key in tempDic.allKeys) {
        [self.recordVCDic setValue:@(0) forKey:key];
    }
    [self.recordVCDic writeToFile:kPlistPath atomically:YES];
}

@end
