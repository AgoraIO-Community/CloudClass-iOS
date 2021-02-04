//
//  CourseTipsViewDebugVC.m
//  AgoraEducation
//
//  Created by ZYP on 2021/2/3.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "CourseTipsViewDebugVC.h"
#import "AgoraEduSDK-swift.h"

@interface CourseTipsViewDebugVC ()

@end

@implementation CourseTipsViewDebugVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *imag = [UIImage imageNamed:@"backgroundImage"];
    UIColor *color = [UIColor colorWithPatternImage:imag];
    [self.view setBackgroundColor: color];
    
    AgoraCourseTipsView *v1 = [AgoraCourseTipsView new];
    AgoraCourseTipsView *v2 = [AgoraCourseTipsView new];

    [v1 setStyleWithStyle:AgoraCourseTipsView.styleNromal];
    [v2 setStyleWithStyle:AgoraCourseTipsView.styleAlert];

    v1.translatesAutoresizingMaskIntoConstraints = true;
    v2.translatesAutoresizingMaskIntoConstraints = true;
    
    v1.frame = CGRectMake(0, 100, UIScreen.mainScreen.bounds.size.width, AgoraCourseTipsView.allHeight);
    v2.frame = CGRectMake(0, 100 + 100, UIScreen.mainScreen.bounds.size.width, AgoraCourseTipsView.allHeight);
        
    [self.view addSubview:v1];
    [self.view addSubview:v2];
    
    [v1 setTextWithText:@"距离教室关闭还有1分钟" usingRedAttribe:true redAttrRange:NSMakeRange(8, 1)];
    [v2 setTextWithText:@"你的网络状况不佳，可能影响上课哦！" usingRedAttribe:false redAttrRange:NSMakeRange(0, 0)];
}



@end
