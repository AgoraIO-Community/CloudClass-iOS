//
//  AgoraMCStudentViewCell.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraMCStreamInfo.h"
#import "AgoraRoomProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface AgoraMCStudentViewCell : UITableViewCell

@property (nonatomic, weak) id<AgoraRoomProtocol> delegate;

@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, strong) AgoraMCStreamInfo *stream;
@property (weak, nonatomic) IBOutlet UIButton *muteAudioButton;
@property (weak, nonatomic) IBOutlet UIButton *muteVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *muteWhiteButton;

- (void)updateEnableButtons:(NSString *)userUuid;

@end

NS_ASSUME_NONNULL_END
