//
//  RecordModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/8/4.
//  Copyright © 2020 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpAppModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RecordState) {
    RecordStateRecording = 1,
    RecordStateFinished = 2,
    RecordStateWaitDownload = 3,
    RecordStateWaitConvert = 4,
    RecordStateWaitUpload = 5,
};

@interface RecordDetailsModel : NSObject
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) EduRoleType role;//1老师 2学生
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;
@end

@interface RecordInfoModel : NSObject
@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, strong) NSString *recordId;
@property (nonatomic, strong) NSString *boardId;
@property (nonatomic, strong) NSString *boardToken;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, assign) RecordState status;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSArray<RecordDetailsModel*> *recordDetails;
@end

@interface RecordDataModel : NSObject
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger nextId;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSArray<RecordInfoModel *> *list;
@end

@interface RecordModel : AppBaseModel
@property (nonatomic, strong) RecordDataModel *data;
@end

NS_ASSUME_NONNULL_END
