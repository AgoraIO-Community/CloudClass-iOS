//
//  WhiteBoardJoinOptions.h
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WhiteBoardJoinOptions : NSObject

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *boardId;
@property (nonatomic, copy) NSString *boardToken;

@end

NS_ASSUME_NONNULL_END
