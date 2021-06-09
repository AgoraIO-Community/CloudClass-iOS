//
//  WhiteBoardExtApp.m
//  AgoraEducation
//
//  Created by Cavan on 2021/4/8.
//  Copyright © 2021 Agora. All rights reserved.
//

#import <AgoraWhiteBoard/AgoraWhiteBoard.h>
#import "WhiteBoardExtApp.h"

@interface WhiteBoardExtApp ()
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) AgoraWhiteBoardManager *manager;
@property (nonatomic, strong) UIView *boardContainer;
@end

@implementation WhiteBoardExtApp
#pragma mark - Life cycle
- (void)extAppDidLoad:(AgoraExtAppContext *)context {
    [self initWhiteBoard];
    [self initViews];
    [self layoutViews];
    [self joinBoard];
}

- (void)extAppWillUnload {
    [self.manager leaveWithSuccess:nil
                           failure:nil];
}

#pragma mark - WhiteBoardExtApp
- (void)initViews {
    
    self.boardContainer = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.boardContainer];
    
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.closeButton setTitle:@"Close"
                      forState:UIControlStateNormal];
    [self.closeButton setTitleColor:UIColor.grayColor
                           forState:UIControlStateNormal];
    [self.closeButton addTarget:self
                         action:@selector(doCloseButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    [self.boardContainer addSubview:self.manager.contentView];
}

- (void)layoutViews {
    CGFloat buttonWidth = 100;
    CGFloat buttonHeight = 40;
    CGFloat distance = 10;
    CGFloat buttonX = self.view.frame.size.width - buttonWidth - distance;
    CGFloat buttonY = distance;
    
    self.closeButton.frame = CGRectMake(buttonX,
                                        buttonY,
                                        buttonWidth,
                                        buttonHeight);
    
    CGFloat boardWidth = self.view.bounds.size.width - (distance * 2);
    CGFloat boardHeight = self.view.bounds.size.height - (distance * 2);
    CGFloat boardX = distance;
    CGFloat boardY = distance;
    
    self.boardContainer.frame = CGRectMake(boardX,
                                           boardY,
                                           boardWidth,
                                           boardHeight);
    
    self.manager.contentView.frame = self.boardContainer.bounds;
}

- (void)doCloseButtonPressed {
    [self unload];
}

- (void)initWhiteBoard {
    NSString *caches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *directory = [NSString stringWithFormat:@"%@/AgoraDownload/", caches];
    AgoraWhiteBoardConfiguration *configuration = [[AgoraWhiteBoardConfiguration alloc] init];
    configuration.appId = self.properties[@"boardAppId"];
    
    self.manager = [[AgoraWhiteBoardManager alloc] initWithCoursewareDirectory:directory
                                                                        config:configuration];
    [self.manager setTool:WhiteBoardToolTypePencil];
}

- (void)joinBoard {
    AgoraWhiteBoardJoinOptions *options = [[AgoraWhiteBoardJoinOptions alloc] init];
    options.boardId = self.properties[@"boardId"];
    options.boardToken = self.properties[@"boardToken"];
    
    [self.manager joinWithOptions:options
                          success:^{
        NSLog(@"00- join");
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"00- fail");
    }];
}
@end
