//
//  AgoraWhiteBoardViewManager.h
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Whiteboard/Whiteboard.h>
#import "WhiteBoardToolControlView.h"
#import "WhiteBoardColorControlView.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraWhiteBoardViewManager : NSObject

@property (nonatomic, weak) WhiteBoardView *boardView;

@end

NS_ASSUME_NONNULL_END
