//
//  AgoraMCStudentVideoListView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/14.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraMCStudentVideoCell.h"

typedef void(^ StudentVideoList)(AgoraMCStudentVideoCell * _Nonnull cell, AgoraRTEStream * _Nonnull stream);

NS_ASSUME_NONNULL_BEGIN

@interface AgoraMCStudentVideoListView : UIView
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, strong) StudentVideoList studentVideoList;
- (void)updateStudentArray:(NSArray<AgoraRTEStream*> *)array;
@end

NS_ASSUME_NONNULL_END
