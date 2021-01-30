//
//  AgoraMCStudentListView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraRoomProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraMCStudentListView : UIView
@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, weak)id<AgoraRoomProtocol> delegate;
- (void)updateStudentArray:(NSArray<AgoraRTEStream*> *)array;
- (void)updateGrantStudentArray:(NSArray<NSString*> *)grantUsers;

@end

NS_ASSUME_NONNULL_END
