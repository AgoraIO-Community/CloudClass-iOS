//
//  MCStreamInfo.h
//  AgoraEducation
//
//  Created by SRS on 2020/12/3.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MCStreamInfo : NSObject
@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) BOOL hasAudio;
@property (nonatomic, assign) BOOL hasVideo;
@property (nonatomic, assign) NSInteger streamState;// 0=offline 1=online
@property (nonatomic, assign) NSInteger userState;// 0=offline 1=online

- (instancetype)initWithUserUuid:(NSString *)userUuid userName:(NSString *)userName hasAudio:(BOOL)hasAudio hasVideo:(BOOL)hasVideo streamState:(NSInteger)streamState userState:(NSInteger)userState;

@end


NS_ASSUME_NONNULL_END
