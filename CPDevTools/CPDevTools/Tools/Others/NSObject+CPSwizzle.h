//
//  NSObject+CPSwizzle.h
//  CPDevTools
//
//  Created by mac on 2017/8/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (CPSwizzle)

+ (void)mothodSwizzleClass:(NSString *)className
                       Old:(NSString *)oldMothod
                       new:(NSString *)newMothod;

@end
