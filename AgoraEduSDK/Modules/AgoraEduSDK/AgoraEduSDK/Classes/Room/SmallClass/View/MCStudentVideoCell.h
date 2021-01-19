//
//  StudentVideoViewCell.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/8/13.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudentVideoStream : EduStream
@property (nonatomic, assign) NSInteger totalReward;
@end

NS_ASSUME_NONNULL_BEGIN

@interface MCStudentVideoCell : UICollectionViewCell
@property (nonatomic, weak) UIView *videoCanvasView;
@property (nonatomic, strong) EduStream *userModel;

@end

NS_ASSUME_NONNULL_END
