//
//  CPSafeKVO.m
//  CPDevTools
//
//  Created by mac on 2017/3/31.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CPSafeKVO.h"
#import <objc/runtime.h>
#import "BSBacktraceLogger.h"
#import "NSObject+CPSwizzle.h"

static void *CP_KVOMapKey = &CP_KVOMapKey;
static void *CP_ObserverMapKey = &CP_ObserverMapKey;

@interface NSObject (CPSafeKVO)

@property (nonatomic, strong) NSMutableDictionary *CP_KVOMap;
@property (nonatomic, strong) NSMutableDictionary *CP_ObserverMap;

@end

@implementation NSObject (CPSafeKVO)

- (NSMutableDictionary *)CP_KVOMap {
    
    id CP_KVOMap = objc_getAssociatedObject(self, CP_KVOMapKey);
    return CP_KVOMap;
}

- (void)setCP_KVOMap:(NSMutableDictionary *)CP_KVOMap {
    objc_setAssociatedObject(self, CP_KVOMapKey, CP_KVOMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)CP_ObserverMap {
    
    id CP_ObserverMap = objc_getAssociatedObject(self, CP_ObserverMapKey);
    return CP_ObserverMap;
}

- (void)setCP_ObserverMap:(NSMutableDictionary *)CP_ObserverMap {
    objc_setAssociatedObject(self, CP_ObserverMapKey, CP_ObserverMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)CP_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(nullable void *)context{
    
    if (observer.CP_KVOMap == nil) {
        observer.CP_KVOMap = [NSMutableDictionary dictionary];
    }
    
    if (observer.CP_ObserverMap == nil) {
        observer.CP_ObserverMap = [NSMutableDictionary dictionary];;
    }
    
    NSString *targetKey = [NSString stringWithFormat:@"%p",self];
    
    if ([observer.CP_KVOMap objectForKey:targetKey] == nil) {
        
        [observer.CP_KVOMap setObject:[NSMutableArray array] forKey:targetKey];
        __weak typeof(self) weakSelf = self;
        [observer.CP_ObserverMap setObject:weakSelf forKey:targetKey];
    }
    
    NSMutableArray *keyPathList = [[observer.CP_KVOMap objectForKey:targetKey] mutableCopy];
    if ([keyPathList containsObject:keyPath] == NO) {
        [keyPathList addObject:keyPath];
        [observer.CP_KVOMap setObject:keyPathList forKey:targetKey];
    }else {
        //防止重复Add
        return;
    }
    
    [self CP_addObserver:observer forKeyPath:keyPath options:options context:context];
}

- (void)CP_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    //防止重复remove导致crash
    
    NSString *targetKey = [NSString stringWithFormat:@"%p",self];
    if ([observer.CP_ObserverMap objectForKey:targetKey] == nil) {
        //NSAssert(0, @"%@:%@ remove keyPath repeated",self,keyPath);
        return;
    }
    
    NSMutableArray *keyPathList = [[observer.CP_KVOMap objectForKey:targetKey] mutableCopy];
    if ([keyPathList containsObject:keyPath] == YES) {
        [keyPathList removeObject:keyPath];
        [observer.CP_KVOMap setObject:keyPathList forKey:targetKey];
    }else {
        return;
    }
    
    [self CP_removeObserver:observer forKeyPath:keyPath];
}

- (void)CP_dealloc {
    //dealloc之前先remove掉
    if (self.CP_KVOMap) {
        for (NSString *target in self.CP_KVOMap.allKeys) {
            id observer = [self.CP_ObserverMap objectForKey:target];
            NSArray *keyPathList = [self.CP_KVOMap objectForKey:target];
            for (NSString *keyPath in keyPathList) {
                [observer removeObserver:self forKeyPath:keyPath];
                
                NSLog(@"\n**** Crash Warning ****:"
                      @"\n**** Crash type:KVO unremove ****:"
                      @"\n**** Object :%@ ****:"
                      @"\n**** Keypath :%@ ****:"
                      @"\n**** NSThread callStackSymbols ****:"
                      @"\n%@",self,keyPath,[NSThread callStackSymbols]);
                
                
                NSDictionary *info = @{@"reason":[NSString stringWithFormat:@"[%@ %@]:unremoved KVO",
                                                  self,keyPath],
                                       @"currentThread":[BSBacktraceLogger bs_backtraceOfCurrentThread],
                                       @"allThread":[BSBacktraceLogger bs_backtraceOfAllThread]};
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CPCrashMontorCrashMessage"
                                                                    object:nil
                                                                  userInfo:info];
            }
        }
    }
    self.CP_KVOMap = nil;
    self.CP_ObserverMap = nil;
    
    //去掉Xcode的警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    //调用NSObject 原始dealloc
    [self performSelector:NSSelectorFromString(@"CP_dealloc")];
#pragma clang diagnostic pop
}


@end



@implementation CPSafeKVO

static bool isEnable = NO;

+ (void)enabled {
    
    if (isEnable) {
        return;
    }
    [self mothodSwizzleClass:@"NSObject"
                         Old:@"addObserver:forKeyPath:options:context:"
                         new:@"CP_addObserver:forKeyPath:options:context:"];
    
    [self mothodSwizzleClass:@"NSObject"
                         Old:@"removeObserver:forKeyPath:"
                         new:@"CP_removeObserver:forKeyPath:"];
    
    [self mothodSwizzleClass:@"NSObject"
                         Old:@"dealloc" new:@"CP_dealloc"];
    
    isEnable = YES;
}


+ (void)disabled {
    
    if (!isEnable) {
        return;
    }
    [self mothodSwizzleClass:@"NSObject"
                         Old:@"CP_addObserver:forKeyPath:options:context:"
                         new:@"addObserver:forKeyPath:options:context:"];
    
    [self mothodSwizzleClass:@"NSObject"
                         Old:@"CP_removeObserver:forKeyPath:"
                         new:@"removeObserver:forKeyPath:"];
    
    [self mothodSwizzleClass:@"NSObject"
                         Old:@"CP_dealloc" new:@"dealloc"];
    
    isEnable = NO;
}

@end
