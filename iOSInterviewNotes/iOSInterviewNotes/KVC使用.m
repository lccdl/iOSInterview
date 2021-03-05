//
//  KVC使用.m
//  iOSInterviewNotes
//
//  Created by 李臣臣 on 2021/3/5.
//

#import "KVC使用.h"

@implementation KVC__

+ (BOOL)accessInstanceVariablesDirectly{
    return NO;
}

+ (void)timerUse{
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"come on girls~");
    }];
//    [NSRunLoop.mainRunLoop addTimer:timer forMode:NSRunLoopCommonModes];
    NSLog(@"结束runloop");
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
        NSLog(@"结束runloop");
    }];
    [thread start];
    NSLog(@"方法结束");
}

@end
