//
//  OneToOneNavigationView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/12.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraRoomProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraEENavigationView : UIView
@property (nonatomic, weak) id <AgoraRoomProtocol> delegate;
- (void)initTimerCount:(NSInteger)timeCount;
- (void)startTimer;
- (void)stopTimer;
- (void)updateClassName:(NSString *)name;
- (void)updateSignalImageName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
