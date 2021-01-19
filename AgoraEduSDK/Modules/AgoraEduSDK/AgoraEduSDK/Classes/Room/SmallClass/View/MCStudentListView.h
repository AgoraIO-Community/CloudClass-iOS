//
//  MCStudentListView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCStudentListView : UIView
@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, weak)id<RoomProtocol> delegate;
- (void)updateStudentArray:(NSArray<EduStream*> *)array;
- (void)updateGrantStudentArray:(NSArray<NSString*> *)grantUsers;

@end

NS_ASSUME_NONNULL_END
