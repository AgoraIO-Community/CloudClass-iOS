//
//  RecordPropertyModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/8/9.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#define CMD_SIGNAL_REPLAY 2

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecordPropertyModel : NSObject
@property (nonatomic, strong) NSString *recordId;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) NSInteger startTime;
@end

NS_ASSUME_NONNULL_END
