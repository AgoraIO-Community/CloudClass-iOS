//
//  MainViewController.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/5/9.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MainViewController.h"
#import "EEClassRoomTypeView.h"
#import "SettingViewController.h"
#import "UIView+Toast.h"
#import "KeyCenter.h"
#import <AgoraEduSDK/AgoraEduSDK.h>
#import "TokenBuilder.h"
#import "ViewDebugVC.h"

#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
#define BASE_URL @"http://api-solutions-dev.bj2.agoralab.co"

@interface MainViewController ()<EEClassRoomTypeDelegate, UITextFieldDelegate, AgoraEduClassroomDelegate, AgoraEduReplayDelegate>

@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UITextField *classNameTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextFiled;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomCon;
@property (weak, nonatomic) IBOutlet UIButton *roomTypeBtn;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (nonatomic, weak) EEClassRoomTypeView *classRoomTypeView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, assign) AgoraEduRoomType roomType;

@end

@implementation MainViewController

#pragma mark LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self addTouchedRecognizer];
    [self addNotification];
    
    BOOL eyeCare = [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULT_EYE_CARE];
    AgoraEduSDKConfig *defaultConfig = [[AgoraEduSDKConfig alloc] initWithAppId:KeyCenter.appId eyeCare:eyeCare];
    [AgoraEduSDK setConfig:defaultConfig];
    
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel = NSSelectorFromString(@"setBaseURL:");
    if ([AgoraEduSDK respondsToSelector:sel]) {
        [AgoraEduSDK performSelector:sel withObject:BASE_URL];
    }
    
    SEL sel1 = NSSelectorFromString(@"setLogConsoleState:");
    if ([AgoraEduSDK respondsToSelector:sel1]) {
        [AgoraEduSDK performSelector:sel1 withObject:@(1)];
    }
#pragma clang diagnostic pop
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Private Function
- (void)setupView {
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.frame= CGRectMake((kScreenWidth -100)/2, (kScreenHeight - 100)/2, 100, 100);
    self.activityIndicator.color = [UIColor grayColor];
    self.activityIndicator.backgroundColor = [UIColor whiteColor];
    self.activityIndicator.hidesWhenStopped = YES;
    
    EEClassRoomTypeView *classRoomTypeView = [EEClassRoomTypeView initWithXib:CGRectMake(30, kScreenHeight - 300, kScreenWidth - 60, 190)];
    [self.view addSubview:classRoomTypeView];
    self.classRoomTypeView = classRoomTypeView;
    classRoomTypeView.hidden = YES;
    classRoomTypeView.delegate = self;
    
    self.classNameTextFiled.delegate = self;
    self.userNameTextFiled.delegate = self;
    
    self.classNameTextFiled.keyboardType = UIKeyboardTypeASCIICapable;
    self.userNameTextFiled.keyboardType = UIKeyboardTypeASCIICapable;
}

- (void)addTouchedRecognizer {
    UITapGestureRecognizer *touchedControl = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedBegan:)];
    [self.baseView addGestureRecognizer:touchedControl];
}
- (void)touchedBegan:(UIGestureRecognizer *)recognizer {
    [self.classNameTextFiled resignFirstResponder];
    [self.userNameTextFiled resignFirstResponder];
    self.classRoomTypeView.hidden  = YES;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottom = frame.size.height;
    self.textViewBottomCon.constant = bottom;
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    self.textViewBottomCon.constant = 261;
}

- (BOOL)checkFieldTextLen:(NSString *)text {
    int strlength = 0;
    char *p = (char *)[text cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0; i < [text lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    if(strlength <= 20){
        return YES;
    } else {
       return NO;
    }
}

- (BOOL)checkFieldTextFormat:(NSString *)text {
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
    NSString *filtered = [[text componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [text isEqualToString:filtered];
}

#pragma mark Click Event
- (IBAction)popupRoomType:(UIButton *)sender {
    self.classRoomTypeView.hidden = NO;
}

- (IBAction)joinRoom:(UIButton *)sender {

    NSString *userName = self.userNameTextFiled.text;
    NSString *roomName = self.classNameTextFiled.text;
    
    if (userName.length == 0
        || roomName.length == 0
        || ![self checkFieldTextLen:userName]
        || ![self checkFieldTextLen:roomName]) {
        
        NSBundle *mainBundle = [NSBundle bundleForClass:self.class];

        NSString *str =  NSLocalizedStringFromTableInBundle(@"UserNameVerifyText", nil, mainBundle, nil);
        
        [AlertViewUtil showAlertWithController:self title:str];
        return;
    }
    
    if (![self checkFieldTextFormat:userName]
        || ![self checkFieldTextFormat:roomName]) {
        
        [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"UserNameFormatVerifyText", nil)];
        return;
    }
    
    if ([self.roomTypeBtn.titleLabel.text isEqualToString:NSLocalizedString(@"OneToOneText", nil)]) {
        self.roomType = AgoraEduRoomType1V1;
    } else if ([self.roomTypeBtn.titleLabel.text isEqualToString:NSLocalizedString(@"SmallClassText", nil)]) {
        self.roomType = AgoraEduRoomTypeSmall;
    } else if ([self.roomTypeBtn.titleLabel.text isEqualToString:NSLocalizedString(@"BigClassText", nil)]) {
        self.roomType = AgoraEduRoomTypeBig;
    } else {
        [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"RoomTypeVerifyText", nil)];
        return;
    }
    
    // userName + role
    self.userUuid = [NSString stringWithFormat:@"%@%ld", userName, (long)AgoraEduRoleTypeStudent];
    // userName + roomtype
    self.roomUuid = [NSString stringWithFormat:@"%@%ld", roomName, (long)self.roomType];

    // generate rtmtoken locally:
    // NSString *rtmToken = [TokenBuilder buildToken:KeyCenter.appId appCertificate:@"<#Your Agora Certificate Id#>" userUuid:self.userUuid];

    [self launchClassroom:userName userUuid:self.userUuid roomName:roomName roomUuid:self.roomUuid roomType:self.roomType token:KeyCenter.rtmToken];
}

- (void)launchClassroom:(NSString *)userName userUuid:(NSString *)userUuid roomName:(NSString *)roomName roomUuid:(NSString *)roomUuid roomType:(AgoraEduRoomType)roomType token:(NSString *)token {

    AgoraEduLaunchConfig *config = [[AgoraEduLaunchConfig alloc] initWithUserName:userName userUuid:userUuid roleType:AgoraEduRoleTypeStudent roomName:roomName roomUuid:roomUuid roomType:roomType token:token];
    [AgoraEduSDK launch:config delegate:self];
}

- (void)launchReplay {
    
    // from records api
    NSString *boardAppId = @"";
    NSString *boardId = @"";
    NSString *boardToken = @"";
    NSString *videoUrl = @"";
    NSInteger beginTime = 0;
    NSInteger endTime = 0;

    AgoraEduReplayConfig *config = [[AgoraEduReplayConfig alloc] initWithBoardAppId:boardAppId boardId:boardId boardToken:boardToken videoUrl:videoUrl beginTime:beginTime endTime:endTime];
    
    [AgoraEduSDK replay:config delegate:self];
}

- (void)setLoadingVisible:(BOOL)show {
    if(show) {
        [self.activityIndicator startAnimating];
        [self.joinButton setEnabled:NO];
    } else {
        [self.activityIndicator stopAnimating];
        [self.joinButton setEnabled:YES];
    }
}

- (IBAction)settingAction:(UIButton *)sender {
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark EEClassRoomTypeDelegate
- (void)selectRoomTypeName:(NSString *)name {
    [self.roomTypeBtn setTitleColor:[UIColor colorWithHex:0x333333]  forState:(UIControlStateNormal)];
    [self.roomTypeBtn setTitle:name forState:(UIControlStateNormal)];
    self.classRoomTypeView.hidden = YES;
}

#pragma mark AgoraEduClassroomDelegate
- (void)classroom:(AgoraEduClassroom *)classroom didReceivedEvent:(AgoraEduEvent)event {

    NSLog(@"classroom:%@ event:%d", classroom, event);
}

#pragma mark AgoraEduReplayDelegate
- (void)replay:(AgoraEduReplay *)replay didReceivedEvent:(AgoraEduEvent)event {
    NSLog(@"replay:%@ event:%d", replay, event);
}

#ifdef DEBUG
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ViewDebugVC *vc = [ViewDebugVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
#endif

@end
