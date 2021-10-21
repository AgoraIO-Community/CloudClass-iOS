//
//  NSTimer+Block.m
//  ChatWidget
//
//  Created by lixiaoming on 2021/10/18.
//

#import "NSTimer+Block.h"

@implementation NSTimer (Block)
+ (NSTimer *)block_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void (^)(void))block repeats:(BOOL)repeats {
    
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(block_selector:) userInfo:[block copy] repeats:repeats];
}

+ (void)block_selector:(NSTimer *)timer {
    void(^block)(void) = timer.userInfo;
    if (block) {
        block();
    }
}
@end
