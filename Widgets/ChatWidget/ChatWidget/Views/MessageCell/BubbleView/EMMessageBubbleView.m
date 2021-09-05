//
//  EMMessageBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageBubbleView.h"
#import "UIImage+ChatExt.h"

@implementation EMMessageBubbleView

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
{
    self = [super init];
    if (self) {
        _direction = aDirection;
        _type = aType;
    }
    
    return self;
}

- (void)setupBubbleBackgroundImage
{
    if (self.direction == EMMessageDirectionSend) {
        self.backgroundColor = [UIColor colorWithRed:225/255.0 green:235/255.0 blue:252/255.0 alpha:1.0];
        //self.image = [[UIImage imageNamedFromBundle:@"msg_bg_send"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    } else {
        self.layer.borderWidth = 1;
        self.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
        self.layer.borderColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:241/255.0 alpha:1.0].CGColor;
        //self.image = [[UIImage imageNamedFromBundle:@"msg_bg_recv"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    }
}



@end
