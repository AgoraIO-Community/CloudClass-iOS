//
//  AgoraReplayModuleManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "AgoraReplayModuleManager.h"
#import "UIView+AgoraEduToast.h"
#import "AgoraHTTPManager.h"
#import "AgoraEduKeyCenter.h"
#import "AgoraEduTopVC.h"
#import "AgoraEduSDK.h"

#define RECORD_BASE_URL @"https://agora-adc-artifacts.oss-accelerate.aliyuncs.com/"

@implementation AgoraReplayModuleManager

+ (void)enterReplayViewControllerWithRoomId:(NSString *)roomId {
    
    [AgoraEduManager.shareManager.roomManager getLocalUserWithSuccess:^(AgoraRTELocalUser * _Nonnull user) {
        
        AgoraRecordInfoConfiguration *config = [AgoraRecordInfoConfiguration new];
        config.appId = AgoraEduKeyCenter.agoraAppid;
        config.roomUuid = roomId;
        config.token = AgoraEduManager.shareManager.token;
        config.userUuid = user.userUuid;
        [AgoraHTTPManager getRecordInfoWithConfig:config success:^(AgoraRecordModel * _Nonnull recordModel) {
            
            if(recordModel.data.list.count == 0){
                [[UIApplication sharedApplication].windows.firstObject makeToast:AgoraEduLocalizedString(@"ReplayListFailedText", nil)];
                return;
            }
            
            NSArray *resultArray = [recordModel.data.list sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    AgoraRecordInfoModel *model1 = (AgoraRecordInfoModel*)obj1;
                    AgoraRecordInfoModel *model2 = (AgoraRecordInfoModel*)obj2;
                    NSComparisonResult result = [@(model1.startTime) compare:@(model2.startTime)];
                    return result == NSOrderedAscending;  // 降序
            }];
            
            AgoraRecordInfoModel *recordInfoModel = resultArray.firstObject;
            NSInteger status = recordInfoModel.status;
            if(status == RecordStateRecording
               || status == RecordStateFinished
               || status == RecordStateWaitDownload
               || status == RecordStateWaitConvert
               || status == RecordStateWaitUpload) {
                
                if(status != RecordStateFinished) {
                    [[UIApplication sharedApplication].windows.firstObject makeToast:AgoraEduLocalizedString(@"QuaryReplayFailedText", nil)];
                    return;
                }
            }
            
            NSString *urlString = @"";
            if ([recordInfoModel.url containsString:@"http://"] || [recordInfoModel.url containsString:@"https://"]) {
                urlString = recordInfoModel.url;
                
            } else {
                urlString = [RECORD_BASE_URL stringByAppendingString: recordInfoModel.url];
            }
            
            AgoraEduReplayConfig *config = [[AgoraEduReplayConfig alloc] initWithBoardAppId:AgoraEduKeyCenter.boardAppid boardId:recordInfoModel.boardId boardToken:recordInfoModel.boardToken videoUrl:urlString beginTime:recordInfoModel.startTime endTime:recordInfoModel.endTime];
            AgoraEduReplay *replay = [AgoraEduSDK replay:config delegate:nil];
            if (replay != nil) {
                [AgoraEduManager.shareManager.classroom setValue:replay forKey:@"replay"];
            }
                
        } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
            [[UIApplication sharedApplication].windows.firstObject makeToast:error.localizedDescription];
        }];
        
    } failure:^(NSError * _Nonnull error) {
        [[UIApplication sharedApplication].windows.firstObject makeToast:error.localizedDescription];
    }];
}

@end
