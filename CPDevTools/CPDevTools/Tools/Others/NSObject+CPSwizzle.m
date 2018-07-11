//
//  NSObject+CPSwizzle.m
//  CPDevTools
//
//  Created by mac on 2017/8/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSObject+CPSwizzle.h"
#import <objc/runtime.h>

@implementation NSObject (CPSwizzle)

/*
+ (void)load {
    
    [self mothodSwizzleClass:@"class" Old:@"" New:@""];
}
 */

+ (void)mothodSwizzleClass:(NSString *)className
                       Old:(NSString *)oldMothod
                       new:(NSString *)newMothod {
    
    Method oldMothods = class_getInstanceMethod(NSClassFromString(className), NSSelectorFromString(oldMothod));
    Method newMothods = class_getInstanceMethod(NSClassFromString(className), NSSelectorFromString(newMothod));
    
    BOOL didAddMethod =
    class_addMethod(NSClassFromString(className),
                    NSSelectorFromString(oldMothod),
                    method_getImplementation(newMothods),
                    method_getTypeEncoding(newMothods));
    
    if (didAddMethod) {
        class_replaceMethod(NSClassFromString(className),
                            NSSelectorFromString(newMothod),
                            method_getImplementation(oldMothods),
                            method_getTypeEncoding(oldMothods));
    } else {
        method_exchangeImplementations(oldMothods, newMothods);
    }
    
};

@end
