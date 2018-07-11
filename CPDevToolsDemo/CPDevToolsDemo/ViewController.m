//
//  ViewController.m
//  CPDevTools
//
//  Created by mac on 2017/2/24.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "KVOTest.h"
#import <objc/runtime.h>

#import <CPDevTools.h>

#import "AFNetworking.h"

#define LogsPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"Logs"]

@interface ViewController ()

@property (nonatomic, strong) KVOTest *test;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //开启网络抓包(AFNetworking初始化前开启)
    [[CPNetworkMonitor sharedMonitor] start];
    //开启卡顿监控
    [[CPRunloopMonitor sharedMonitor] start];
    //开启沙盒Log文件查看
    [[CPLogMonitor sharedMonitor] setDefaultLogPath:LogsPath];
    //开始实时监听NSLog
    [[CPLogMonitor sharedMonitor] start];
    
    //开启奔溃抓取(建议在其他奔溃抓取工具初始后再开启,避免被覆盖)
    [[CPCrashMonitor sharedMonitor] start];
    //开启KVO奔溃保护
    [[CPCrashMonitor sharedMonitor] isEnableGuardKVO:YES];
    //开启unrecognized selector奔溃保护
    [[CPCrashMonitor sharedMonitor] isEnableGuardSelector:YES];
    
    [[CPRecordMonitor sharedMonitor] startRecordViewControllerWithFilter:^(__unsafe_unretained Class iclass, NSMutableArray *classList) {
        
    }];
    
    //开启系统监控(需要在[window makeKeyAndVisible]后开启)
    [CPSystemMonitor start];
    
    //NSArray *filterStrs = @[@"_UI",@"UI"];
    //NSArray *classList = [self getClassListWithString:@"VC" filterList:filterStrs];
    //NSLog(@"");
    
    //unrecognized selector test
    UIFont *font = [UIFont systemFontOfSize:12];
    
    if (((NSString *)font).length>0) {
        NSLog(@"aaaa");
    }
    
    if ([((NSString *)font) isEqualToString:@"hh"]) {
        NSLog(@"bbbb");
    }
    
    
    //kvo test
    self.test = [KVOTest new];
    KVOTest *test2 = [KVOTest new];
    
    [self.test addObserver:test2 forKeyPath:NSStringFromSelector(@selector(count)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    
    //Network test
    NSString *urlStr = [NSString stringWithFormat:@"http://api.map.baidu.com/geocoder/v2/?ak=XAI63yh37FD9M7GhruInLHa58nXUnyPT&location=%@,%@&output=json&pois=0",@(23),@(23)];
    
    AFHTTPSessionManager *sessionTast = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
    sessionTast.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [sessionTast POST:@"http://api.map.baidu.com/geocoder/v2/" parameters:@{@"ak":@"XAI63yh37FD9M7GhruInLHa58nXUnyPT",@"location":@"23,23",@"output":@"json",@"pois":@"0"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        NSLog(@"%@",responseDic);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
    }];
    
    
    NSString *log = [CPLogMonitor sharedMonitor].realtimeLog;
    
    NSLog(@"%@",log);
    
}


- (NSArray *)getClassListWithString:(NSString *)string filterList:(NSArray *)filterList {
    
    NSMutableArray *classList = [NSMutableArray array];
    
    unsigned int outCount;
    Class *classes = objc_copyClassList(&outCount);
    for (int i = 0; i < outCount; i++) {
        
        const char *className = class_getName(classes[i]);
        NSString *classString = [NSString stringWithCString:className encoding:NSUTF8StringEncoding];
        NSRange vcRange = [classString rangeOfString:string];
        
        if (vcRange.length && (vcRange.location + vcRange.length) == classString.length) {
            BOOL isFilter = NO;
            for (NSString *filter in filterList) {
                if ([classString containsString:filter]) {
                    isFilter = YES;
                    break;
                }
            }
            if (!isFilter) {
                [classList addObject:classString];
            }
        }
    }
    free(classes);
    
    /*
    int numClasses = 0, newNumClasses = objc_getClassList(NULL, 0);
    Class *classes = NULL;
    while (numClasses < newNumClasses) {
        
        numClasses = newNumClasses;
        classes = (Class *)realloc(classes, sizeof(Class) * numClasses);
        newNumClasses = objc_getClassList(classes, numClasses);
        
        for (int i = 0; i < numClasses; i++) {
            
            const char *className = class_getName(classes[i]);
            NSString *classString = [NSString stringWithCString:className encoding:NSUTF8StringEncoding];
            NSRange vcRange = [classString rangeOfString:string];
            
            if (vcRange.length && (vcRange.location + vcRange.length) == classString.length) {
                BOOL isFilter = NO;
                for (NSString *filter in filterList) {
                    if ([classString containsString:filter]) {
                        isFilter = YES;
                        break;
                    }
                }
                if (!isFilter) {
                    [classList addObject:classString];
                }
            }
        }
    }
    free(classes);
     */
    return [classList copy];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.test.count = 10;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
