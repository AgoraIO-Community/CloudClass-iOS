//
//  NSTimer+Block.h
//  ChatWidget
//
//  Created by lixiaoming on 2021/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (Block)
+ (NSTimer *)block_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void (^)(void))block repeats:(BOOL)repeats;
@end

NS_ASSUME_NONNULL_END
