//
//  WhiteGlobalStateModel.h
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/9/3.
//

#import <Whiteboard/Whiteboard.h>

NS_ASSUME_NONNULL_BEGIN

@interface WhiteGlobalStateModel : WhiteGlobalState
@property (nonatomic, assign) BOOL follow;
@property (nonatomic, strong) NSArray<NSString *> *grantUsers;
@end

NS_ASSUME_NONNULL_END
