//
//  WhiteBoardConfiguration.h
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WhiteBoardConfiguration : NSObject

@property (nonatomic, copy) NSString *appId;

/** 文档转网页中字体文件映射关系 */
@property (nonatomic, copy, nullable) NSDictionary *fonts;

@end

NS_ASSUME_NONNULL_END
