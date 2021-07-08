//
//  EMMsgImageBubbleView.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageBubbleView.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMMsgImageBubbleView : EMMessageBubbleView

- (void)setThumbnailImageWithLocalPath:(NSString *)aLocalPath
                            remotePath:(NSString *)aRemotePath
                          thumbImgSize:(CGSize)aThumbSize
                               imgSize:(CGSize)aSize;

@end

NS_ASSUME_NONNULL_END
