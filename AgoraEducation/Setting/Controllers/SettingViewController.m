//
//  SettingViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/16.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingViewCell.h"
#import <AgoraEduSDK/AgoraClassroomSDK.h>
#import "KeyCenter.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource,SettingCellDelegate>
@property (nonatomic, weak) UITableView *settingTableView;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.title = NSLocalizedString(@"SettingText", nil);
    [self setUpView];
}

- (void)setUpView {
    UITableView *settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:(UITableViewStylePlain)];
    settingTableView.dataSource = self;
    settingTableView.delegate = self;
    [self.view addSubview:settingTableView];
    self.settingTableView = settingTableView;
    settingTableView.tableFooterView = [[UIView alloc] init];
    
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    CGRect rectNav = self.navigationController.navigationBar.frame;
    
    UILabel *footView = [[UILabel alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - rectStatus.size.height - rectNav.size.height - 50, [UIScreen mainScreen].bounds.size.width, 20)];
    footView.textAlignment = NSTextAlignmentCenter;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    footView.text = [NSString stringWithFormat:@"App:v%@  SDK:v%@", app_Version, [AgoraClassroomSDK version]];
    
    footView.font = [UIFont systemFontOfSize:16];
    [settingTableView addSubview:footView];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"page-prev"] forState:(UIControlStateNormal)];
    [backButton addTarget:self action:@selector(backBarButton:) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem =item;
}

- (void)backBarButton:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    if (!cell) {
        cell = [[SettingViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"SettingCell"];
        cell.delegate = self;
    }
    
    BOOL eyeCare = [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULT_EYE_CARE];
    [cell switchOn:eyeCare];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.f;
}

- (void)settingSwitchCallBack:(UISwitch *)sender {
    
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:USER_DEFAULT_EYE_CARE];
    [[NSUserDefaults standardUserDefaults] synchronize];
   
    AgoraEduSDKConfig *config = [[AgoraEduSDKConfig alloc] initWithAppId:KeyCenter.appId eyeCare:sender.on];
    [AgoraClassroomSDK setConfig:config];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end
