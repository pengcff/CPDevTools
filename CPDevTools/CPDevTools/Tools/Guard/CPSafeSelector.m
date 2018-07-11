//
//  CPSafeSelector.m
//  CPDevTools
//
//  Created by peng on 2017/3/31.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CPSafeSelector.h"
#import "BSBacktraceLogger.h"

#import <objc/runtime.h>

//傀儡类名
static const char *className = "CPStubProxy";
//目标类
static NSString *targetClass;

//转换为安全的消息
static int CP_SafetySelector(id self, SEL cmd) {
    return 0;
}


@implementation NSObject (CPSafeSelector)


//去掉Xcode的警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

//重新写NSObject的消息转发
- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    //NSLog(@"[%@ %@]",self.class,NSStringFromSelector(aSelector));
    
    Class kclass = objc_getClass(className);
    if (kclass) {
        
        u_int count;
        Method *methods= class_copyMethodList([self class], &count);
        for (int i = 0; i < count ; i++){
            SEL name = method_getName(methods[i]);
            NSString *methodName = [NSString stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
            
            //如果类自身有重写这些消息转发方法就不处理了,让他自己处理
            if ([methodName isEqualToString:@"forwardInvocation:"]
                ||[methodName isEqualToString:@"resolveInstanceMethod:"]
                ||[methodName isEqualToString:@"forwardingTargetForSelector:"]) {
                
                return nil;
            }
        }
        
        targetClass=NSStringFromClass([self class]);
        
        NSLog(@"\n**** Crash Warning ****:"
              @"\n**** Crash type:unrecognized selector ****:"
              @"\n**** Object :%@ ****:"
              @"\n**** Selector :%@ ****:"
              @"\n**** NSThread callStackSymbols ****:"
              @"\n%@",targetClass,NSStringFromSelector(aSelector),[NSThread callStackSymbols]);
        
        NSDictionary *info = @{@"reason":[NSString stringWithFormat:@"[%@ %@]:unrecognized selector",
                                          targetClass,NSStringFromSelector(aSelector)],
                               @"currentThread":[BSBacktraceLogger bs_backtraceOfCurrentThread],
                               @"allThread":[BSBacktraceLogger bs_backtraceOfAllThread]};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CPCrashMontorCrashMessage"
                                                            object:nil
                                                          userInfo:info];
        
        
        
        class_addMethod(kclass, aSelector, (IMP)CP_SafetySelector, "@@:");
        id instance = [[kclass alloc] init];
        //把消息转发到傀儡类上
        return instance;
    }
    
    return nil;
}
#pragma clang diagnostic pop

@end


@implementation CPSafeSelector

+ (void)enabled {
    
    //创建傀儡类
    Class kclass = objc_getClass(className);
    if (!kclass) {
        Class superClass = [NSObject class];
        kclass = objc_allocateClassPair(superClass, className, 0);
    }
    objc_registerClassPair(kclass);
}

+ (void)disabled {
    
    //销毁傀儡类
    Class kclass = objc_getClass(className);
    if (kclass) {
        objc_disposeClassPair(kclass);
    }
}

@end
