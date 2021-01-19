//
//  BaseModel.h
//  AgoraEdu
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BaseModel <NSObject>

@property (nonatomic, strong) NSString *msg;
@property (nonatomic, assign) NSInteger code;

@end

NS_ASSUME_NONNULL_END
