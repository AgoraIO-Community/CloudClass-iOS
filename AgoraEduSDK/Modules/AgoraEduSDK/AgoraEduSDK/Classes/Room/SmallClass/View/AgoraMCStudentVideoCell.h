//
//  StudentVideoViewCell.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/8/13.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudentVideoStream : AgoraRTEStream
@property (nonatomic, assign) NSInteger totalReward;
@end

NS_ASSUME_NONNULL_BEGIN

@interface AgoraMCStudentVideoCell : UICollectionViewCell
@property (nonatomic, weak) UIView *videoCanvasView;
@property (nonatomic, strong) AgoraRTEStream *userModel;

@end

NS_ASSUME_NONNULL_END
