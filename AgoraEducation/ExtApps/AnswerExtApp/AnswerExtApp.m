//
//  AnswerExtApp.m
//  AgoraEducation
//  Copyright © 2021 Agora. All rights reserved.
//

#import "AnswerExtApp.h"
@import AgoraEduContext;
@import AgoraEduExtApp;

static const int s_btnSubmitWidth = 80;

@interface AnswerExtApp ()<AgoraEduWhiteBoardHandler>
@property (nonatomic, strong) UILabel *countDownLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger countDown; // second
@property (nonatomic, assign) NSInteger titleHeight;
@property (nonatomic, assign) BOOL canChange; // 是否能修改答案
@property (nonatomic, assign) BOOL isMeRightAns; // 自己是否是正确答案
@property (nonatomic, assign) BOOL isManualModifyUI; // 是否是手动点击修改答案
@property (nonatomic, strong) UIView *viewContent;
@property (nonatomic, strong) UIButton *resultBtn;
@property (nonatomic, strong) NSArray<NSString*> *answerDatas;
@property (nonatomic, strong) NSMutableArray<NSString*> *myAnswerItems;
@property (nonatomic, strong) NSMutableArray<UIButton*> *answerBtns;

@property (assign, nonatomic) NSInteger currentAnsType;//0单选，1多选
@property (assign, nonatomic) NSInteger currentAnsStatus;//-1初始未知状态，0答题状态，1答题修改答案状态，2答题结果
@property (assign, nonatomic) NSInteger anwserPersonnel;//已经答题人员
@property (assign, nonatomic) NSInteger totalPersonnel;//总人数
@property (assign, nonatomic) NSInteger rightPersonnel;//正确的人员数
@property (nonatomic, copy) NSString *strRightkey;      //正确答案
@property (nonatomic, copy) NSString *startTime;     //开始答题时间戳
@end

@implementation AnswerExtApp
#pragma mark - Data callback
- (void)propertiesDidUpdate:(NSDictionary *)properties {
    [super propertiesDidUpdate:properties];
    
    if (properties.allValues.count <= 0) {
        return;
    }
    
    self.rightPersonnel = 0;
    self.anwserPersonnel = 0;
    self.totalPersonnel = 1;
    self.currentAnsType = [properties[@"mulChoice"] boolValue] == NO ? 0 : 1;//0单选，1多选
    self.canChange = [properties[@"canChange"] boolValue];
    self.answerDatas = [properties objectForKey:@"items"];
    [self.myAnswerItems removeAllObjects];
    self.isMeRightAns = NO;
    self.strRightkey = @"";
    
    //deal
    [self dealLogic:properties];
}

#pragma mark - Life cycle
- (void)extAppDidLoad:(AgoraEduExtAppContext *)context {
    self.timer = nil;
    self.currentAnsType = 0;
    self.countDown = 0;
    self.currentAnsStatus = -1;
    self.isManualModifyUI = NO;
    if (nil == self.myAnswerItems) {
        self.myAnswerItems = [NSMutableArray<NSString*> new];
    }
    if (nil == self.answerBtns) {
        self.answerBtns = [NSMutableArray<UIButton*> new];
    }
    [self initBaseViews];
    [self initData:context.properties];
    
    [context.contextPool.whiteBoard registerBoardEventHandler:self];
}

- (void)extAppWillUnload {
}

#pragma mark - AgoraEduWhiteBoardHandler
// 有权限就可以移动白板，否则不可以
- (void)onSetDrawingEnabled:(BOOL)enabled {
    self.view.agora_is_draggable = enabled;
}

#pragma mark - VoteExtApp
- (void)dealLogic:(NSDictionary *)properties {
    NSArray* rightKey = [properties objectForKey:@"answer"];
    if (nil != rightKey) {
        self.strRightkey = [rightKey componentsJoinedByString:@""];
    }
    
    self.startTime = properties[@"startTime"];
    NSInteger start = [self.startTime integerValue];
    NSInteger current = [[NSDate date] timeIntervalSince1970];
    self.countDown = current - start;
    
    BOOL isHaveMyResul = NO;
    NSArray* students = [properties objectForKey:@"students"];
    if (NULL != students) {
        self.totalPersonnel = students.count;
        for (NSString* stuname in students) {
            //根据总学生，查找已经答题的学生
            //如果能找到当前学生相关属性，则认为该学生已答题
            NSString* ssitKey = [NSString stringWithFormat:@"student%@", stuname];
            NSDictionary *ssit = [properties objectForKey:ssitKey];
            if (NULL != ssit) {
                //计算答题人数
                ++self.anwserPersonnel;
                
                //获取当前学生的答题项
                NSArray* answers = [ssit objectForKey:@"answer"];
                if (nil != answers) {
                    if ([stuname isEqualToString:self.localUserInfo.userUuid]) {
                        //答题的是自己，且有了答案
                        isHaveMyResul = YES;
                        //保存自己的答题项
                        [self.myAnswerItems addObjectsFromArray: answers];
                    }
                    
                    //计算正确率
                    if([self array:rightKey isEqualTo:answers]){
                        ++self.rightPersonnel;
                        if ([stuname isEqualToString:self.localUserInfo.userUuid]){
                            //自己的答案是正确的
                            self.isMeRightAns = YES;
                        }
                    }
                }
            }
        }
    }
    
    NSString *nowState = properties[@"state"];
    if([nowState isEqualToString:@"start"]){
        if (-1 == self.currentAnsStatus || 2 == self.currentAnsStatus) {
            self.currentAnsStatus = 0;
            [self initAnswerViews];
            [self startTimer];
        }
        if (isHaveMyResul && !self.isManualModifyUI) {
            //收到自己的答案，且自己并未点击修改答案，则修正和跳转到修改答案界面状态
            [self switchToChgUIByRecvResult];
        }
    }else if([nowState isEqualToString:@"end"]){
        //已结束，显示结果页面
        NSString *endTime = properties[@"endTime"];
        NSInteger end = [endTime integerValue];
        self.countDown = end - start;
        self.countDownLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)(self.countDown / 3600), (long)(self.countDown / 60), (long)(self.countDown % 60)];
        
        self.currentAnsStatus = 2;
        [self initResultViews];
    }
}

- (void)initBaseViews {
    //[self.view setUserInteractionEnabled:NO];
    [self.view agora_clear_constraint];
    
    self.view.layer.borderWidth = 1;
    self.view.layer.borderColor = [UIColor colorWithRed:227/255.0 green:227/255.0 blue:236/255.0 alpha:1.0].CGColor;
    self.view.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    self.view.layer.cornerRadius = 6;
    self.view.layer.shadowColor = [UIColor colorWithRed:47/255.0 green:65/255.0 blue:146/255.0 alpha:0.15].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0,2);
    self.view.layer.shadowOpacity = 1;
    self.view.layer.shadowRadius = 6;
    
    self.view.agora_center_x = 0;
    self.view.agora_center_y = 0;
    self.view.agora_width = 240;
    self.view.agora_height = 158;
    
    self.titleHeight = 30;
    {
        UIView *viewTitle = [[UIView alloc] init];
        viewTitle.frame = CGRectMake(0, 0, self.view.agora_width, self.titleHeight);
        viewTitle.layer.borderWidth = 1;
        viewTitle.layer.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.49].CGColor;
        viewTitle.layer.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:252/255.0 alpha:1.0].CGColor;
        viewTitle.layer.cornerRadius = 6;
        [self.view addSubview: viewTitle];
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10,0,65,self.titleHeight)];
        labelTitle.font = [UIFont systemFontOfSize:13.0];
        labelTitle.text = NSLocalizedString(@"Answer_title", nil);
        labelTitle.textColor = [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0];
        labelTitle.textAlignment = NSTextAlignmentLeft;
        labelTitle.alpha = 1.0;
        [viewTitle addSubview:labelTitle];
        [labelTitle sizeToFit];
        labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *titleleft = [NSLayoutConstraint constraintWithItem:labelTitle attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:viewTitle attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10];
        NSLayoutConstraint *titlecenter = [NSLayoutConstraint constraintWithItem:labelTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:viewTitle attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        [viewTitle addConstraint:titleleft];
        [viewTitle addConstraint:titlecenter];
        
        self.countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(70,0,70,self.titleHeight)];
        self.countDownLabel.font = [UIFont systemFontOfSize:13.0];
        self.countDownLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:@"00:00:00"attributes: @{NSForegroundColorAttributeName: [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0]}];
        self.countDownLabel.textAlignment = NSTextAlignmentLeft;
        self.countDownLabel.alpha = 1.0;
        [viewTitle addSubview:self.countDownLabel];
        self.countDownLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *countleft = [NSLayoutConstraint constraintWithItem:self.countDownLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:labelTitle attribute:NSLayoutAttributeRight multiplier:1.0 constant:5];
        NSLayoutConstraint *countcenter = [NSLayoutConstraint constraintWithItem:self.countDownLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:labelTitle attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        [viewTitle addConstraint:countleft];
        [viewTitle addConstraint:countcenter];
    }
    
    self.viewContent = [[UIView alloc] initWithFrame:CGRectMake(0, self.titleHeight, self.view.agora_width, self.view.agora_height - self.titleHeight)];
    [self.view addSubview: self.viewContent];
}

- (void)initResultViews {
    [self stopTimer];
    self.isManualModifyUI = NO;
    
    NSString* strMyAnwser = [self.myAnswerItems componentsJoinedByString:@""];
    [self.answerBtns removeAllObjects];
    self.resultBtn = nil;
    [self.viewContent.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.view.agora_height = 180;
  
    self.viewContent.frame = CGRectMake(0, self.titleHeight, self.view.agora_width, self.view.agora_height - self.titleHeight);
    
    UIView* viewCenter = [[UIView alloc] initWithFrame:CGRectMake(45, 22, self.view.agora_width - 90, self.view.agora_height - self.titleHeight - 22)];
    [self.viewContent addSubview: viewCenter];
    
    int posy = 0;
    int posh = 18;
    {
        UILabel *label0 = [[UILabel alloc] initWithFrame:CGRectMake(0,posy,60,posh)];
        label0.font = [UIFont systemFontOfSize:13.0];
        label0.text = NSLocalizedString(@"Answer_respondents", nil);
        label0.textColor = [UIColor colorWithRed:123/255.0 green:136/255.0 blue:160/255.0 alpha:1.0];
        label0.textAlignment = NSTextAlignmentLeft;
        [viewCenter addSubview:label0];
        [label0 sizeToFit];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0,posy,60,posh)];
        label1.font = [UIFont systemFontOfSize:13.0];
        NSString* stxt = [NSString stringWithFormat:@"%d/%d", (int)self.anwserPersonnel, (int)self.totalPersonnel];
        label1.attributedText = [[NSMutableAttributedString alloc] initWithString:stxt attributes: @{NSForegroundColorAttributeName: [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0]}];
        label1.textAlignment = NSTextAlignmentLeft;
        [viewCenter addSubview:label1];
        [label1 sizeToFit];
        label1.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *consleft = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:label0 attribute:NSLayoutAttributeRight multiplier:1.0 constant:4];
        NSLayoutConstraint *constop = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label0 attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        [viewCenter addConstraint:consleft];
        [viewCenter addConstraint:constop];
        
        posy += (posh + 10);
    }
    
    {
        UILabel *label0 = [[UILabel alloc] initWithFrame:CGRectMake(0,posy,60,posh)];
        label0.font = [UIFont systemFontOfSize:13.0];
        label0.text = NSLocalizedString(@"Answer_rate", nil);
        label0.textColor = [UIColor colorWithRed:123/255.0 green:136/255.0 blue:160/255.0 alpha:1.0];
        label0.textAlignment = NSTextAlignmentLeft;
        [viewCenter addSubview:label0];
        [label0 sizeToFit];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0,posy,60,posh)];
        label1.font = [UIFont systemFontOfSize:13.0];
        float te = (float)self.rightPersonnel / (float)self.totalPersonnel;
        NSString* stxt = [NSString stringWithFormat:@"%d%%", (int)(te * 100)];
        label1.attributedText = [[NSMutableAttributedString alloc] initWithString:stxt attributes: @{NSForegroundColorAttributeName: [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0]}];
        label1.textAlignment = NSTextAlignmentLeft;
        [viewCenter addSubview:label1];
        [label1 sizeToFit];
        label1.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *consleft = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:label0 attribute:NSLayoutAttributeRight multiplier:1.0 constant:4];
        NSLayoutConstraint *constop = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label0 attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        [viewCenter addConstraint:consleft];
        [viewCenter addConstraint:constop];
        
        posy += (posh + 10);
    }
    
    {
        UILabel *label0 = [[UILabel alloc] initWithFrame:CGRectMake(0,posy,60,posh)];
        label0.font = [UIFont systemFontOfSize:13.0];
        label0.text = NSLocalizedString(@"Answer_right", nil);
        label0.textColor = [UIColor colorWithRed:123/255.0 green:136/255.0 blue:160/255.0 alpha:1.0];
        label0.textAlignment = NSTextAlignmentLeft;
        [viewCenter addSubview:label0];
        [label0 sizeToFit];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0,posy,60,posh)];
        label1.font = [UIFont systemFontOfSize:13.0];
        label1.attributedText = [[NSMutableAttributedString alloc] initWithString:self.strRightkey attributes: @{NSForegroundColorAttributeName: [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0]}];
        label1.textAlignment = NSTextAlignmentLeft;
        [viewCenter addSubview:label1];
        [label1 sizeToFit];
        label1.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *consleft = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:label0 attribute:NSLayoutAttributeRight multiplier:1.0 constant:4];
        NSLayoutConstraint *constop = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label0 attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        [viewCenter addConstraint:consleft];
        [viewCenter addConstraint:constop];
        
        posy += (posh + 10);
    }
    
    {
        UILabel *label0 = [[UILabel alloc] initWithFrame:CGRectMake(0,posy,60,posh)];
        label0.font = [UIFont systemFontOfSize:13.0];
        label0.text = NSLocalizedString(@"Answer_myans", nil);
        label0.textColor = [UIColor colorWithRed:123/255.0 green:136/255.0 blue:160/255.0 alpha:1.0];
        label0.textAlignment = NSTextAlignmentLeft;
        [viewCenter addSubview:label0];
        [label0 sizeToFit];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0,posy,60,posh)];
        label1.font = [UIFont systemFontOfSize:13.0];
        label1.text = strMyAnwser;
        label1.textColor = self.isMeRightAns ? [UIColor colorWithRed:11/255.0 green:173/255.0 blue:105/255.0 alpha:1.0] : [UIColor colorWithRed:240/255.0 green:76/255.0 blue:54/255.0 alpha:1.0];
        label1.textAlignment = NSTextAlignmentLeft;
        [viewCenter addSubview:label1];
        [label1 sizeToFit];
        label1.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *consleft = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:label0 attribute:NSLayoutAttributeRight multiplier:1.0 constant:4];
        NSLayoutConstraint *constop = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label0 attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        [viewCenter addConstraint:consleft];
        [viewCenter addConstraint:constop];
        
        posy += (posh + 10);
    }
    
}

- (void)initAnswerViews {
    self.resultBtn = nil;
    [self.answerBtns removeAllObjects];
    [self.viewContent.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (nil == self.answerDatas) return;
    
    int totalColumns = 4;
    CGFloat marginY = 10;
    // 答题数据按钮的尺寸
    CGFloat appW = 40;
    CGFloat appH = 40;
    
    if(self.answerDatas.count > 0){
        self.view.agora_height += ((self.answerDatas.count - 1) / totalColumns * (appH + marginY) );
        self.viewContent.frame = CGRectMake(0, self.titleHeight, self.view.agora_width, self.view.agora_height - self.titleHeight);
    }
    
    {
        CGFloat marginX = (self.view.agora_width - totalColumns * appW) / (totalColumns + 1);
        for (int index = 0; index < self.answerDatas.count; ++index) {
            
            int row = index / totalColumns;
            int col = index % totalColumns;

            CGFloat appX = marginX + col * (appW + marginX);
            CGFloat appY = 22 + row * (appH + marginY);
            
            UIButton* answerBtn = [[UIButton alloc] initWithFrame:CGRectMake(appX, appY, appW, appH)];
            answerBtn.tag = index;
            answerBtn.layer.cornerRadius = 12.0;
            answerBtn.titleLabel.font = [UIFont systemFontOfSize:20];
            [answerBtn setTitle:self.answerDatas[index] forState:UIControlStateNormal];
            [answerBtn setTitleColor:[UIColor colorWithRed:189/255.0 green:189/255.0 blue:202/255.0 alpha:1.0] forState:UIControlStateNormal];
            [answerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            answerBtn.layer.borderWidth = 0.8;
            answerBtn.layer.borderColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:247/255.0 alpha:1.0].CGColor;
            [answerBtn addTarget:self action:@selector(answerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            answerBtn.adjustsImageWhenHighlighted = NO;
            [self.viewContent addSubview:answerBtn];
            [self.answerBtns addObject:answerBtn];
        }
    }
    
    {
        int btnwidth = s_btnSubmitWidth;
        int btnheight = 30;
        self.resultBtn = [[UIButton alloc] initWithFrame:CGRectMake(((self.view.agora_width - btnwidth) / 2), (self.view.agora_height - 20 - btnheight - self.titleHeight) , btnwidth, btnheight)];
        self.resultBtn.layer.cornerRadius = 15.0;
        self.resultBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [self.resultBtn setBackgroundColor:[UIColor colorWithRed:192/255.0 green:214/255.0 blue:255/255.0 alpha:1.0]];
        [self.resultBtn setTitle:NSLocalizedString(@"Answer_sumbit", nil) forState:UIControlStateNormal];
        [self.resultBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.resultBtn.layer.borderColor = [UIColor colorWithRed:53/255.0 green:123/255.0 blue:246/255.0 alpha:1.0].CGColor;
        [self.resultBtn addTarget:self action:@selector(resultBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.viewContent addSubview:self.resultBtn];
    }
}

- (void)answerBtnClick:(UIButton *)button {
    if (0 != self.currentAnsStatus || button.tag >= self.answerDatas.count) {
        return;
    }
    
    BOOL isHaveSelected = NO;
    if (button.isSelected) {
        button.selected = NO;
        button.layer.borderWidth = 0.8;
        button.layer.borderColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:247/255.0 alpha:1.0].CGColor;
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        
        for (UIButton* exbtn in self.answerBtns) {
            if (exbtn.isSelected) {
                isHaveSelected = YES;
                break;
            }
        }
    }else{
        if (1 != self.currentAnsType) {
            //不可多选则移除其他
            for (UIButton* exbtn in self.answerBtns) {
                exbtn.selected = NO;
                exbtn.layer.borderWidth = 0.8;
                exbtn.layer.borderColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:247/255.0 alpha:1.0].CGColor;
                
                [exbtn setBackgroundImage:nil forState:UIControlStateNormal];
            }
        }
        button.selected = YES;
        button.layer.borderWidth = 0;
        [button setBackgroundImage:[UIImage imageNamed:@"answer"] forState:UIControlStateNormal];
        
        isHaveSelected = YES;
    }
    
    if (nil != self.resultBtn) {
        if (isHaveSelected) {
            [self.resultBtn setBackgroundColor:[UIColor colorWithRed:53/255.0 green:123/255.0 blue:246/255.0 alpha:1.0]];
            [self.resultBtn setEnabled:YES];
        }else{
            [self.resultBtn setBackgroundColor:[UIColor colorWithRed:192/255.0 green:214/255.0 blue:255/255.0 alpha:1.0]];
            [self.resultBtn setEnabled:NO];
        }
    }
}

-(void)resultBtnClick{
    if (0 == self.currentAnsStatus) {
        //提交答案
        self.isManualModifyUI = NO;
        if([self resultSubmit]){
            [self switchToChgUI];
        }
    }else if (1 == self.currentAnsStatus) {
        self.isManualModifyUI = YES;
        self.currentAnsStatus = 0;
        for (UIButton* exbtn in self.answerBtns) {
            if (exbtn.isSelected) {
                [exbtn setBackgroundImage:[UIImage imageNamed:@"answer"] forState:UIControlStateNormal];
            }
        }
        [self.resultBtn setBackgroundColor:[UIColor colorWithRed:53/255.0 green:123/255.0 blue:246/255.0 alpha:1.0]];
        [self.resultBtn setTitle:NSLocalizedString(@"Answer_sumbit", nil) forState:UIControlStateNormal];
        [self.resultBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.resultBtn.layer.borderWidth = 0.0;
        if (self.resultBtn.frame.size.width - s_btnSubmitWidth > 5) {
            self.resultBtn.frame = CGRectMake(self.resultBtn.frame.origin.x + ((self.resultBtn.frame.size.width - s_btnSubmitWidth) / 2), self.resultBtn.frame.origin.y, s_btnSubmitWidth, self.resultBtn.frame.size.height);
        }
    }
}

-(void)switchToChgUIByRecvResult{
    for (UIButton* exbtn in self.answerBtns) {
        if (exbtn.tag < self.answerDatas.count) {
            if ([self.myAnswerItems containsObject:self.answerDatas[exbtn.tag]]) {
                [exbtn setSelected:YES];
            }else{
                [exbtn setSelected:NO];
            }
        }
    }
    [self switchToChgUI];
}

//修改答案界面
-(void)switchToChgUI{
    if(self.canChange){
        self.currentAnsStatus = 1;
        for (UIButton* exbtn in self.answerBtns) {
            if (exbtn.isSelected) {
                [exbtn setBackgroundImage:[UIImage imageNamed:@"answer_dis"] forState:UIControlStateNormal];
            }
        }
        
        NSString* nstr = NSLocalizedString(@"Answer_modify", nil);
        [self.resultBtn setBackgroundColor:[UIColor whiteColor]];
        [self.resultBtn setTitle:nstr forState:UIControlStateNormal];
        [self.resultBtn setTitleColor:[UIColor colorWithRed:53/255.0 green:123/255.0 blue:246/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.resultBtn.layer.borderWidth = 1;
        
        CGSize btnSize = [nstr sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:self.resultBtn.titleLabel.font.fontName size:self.resultBtn.titleLabel.font.pointSize]}];
        if (btnSize.width - self.resultBtn.frame.size.width > 5) {
            btnSize.width += 38;
            
            self.resultBtn.frame = CGRectMake(self.resultBtn.frame.origin.x - ((btnSize.width - self.resultBtn.frame.size.width) / 2), self.resultBtn.frame.origin.y, btnSize.width, self.resultBtn.frame.size.height);
        }
    }else{
        self.currentAnsStatus = 2;
        [self initResultViews];
    }
}

-(BOOL)resultSubmit{
    //选中项提交到答案
    NSMutableArray<NSString*>* answers = [NSMutableArray<NSString*> new];
    for (UIButton* exbtn in self.answerBtns) {
        if (exbtn.isSelected) {
            if (exbtn.tag < self.answerDatas.count) {
                [answers addObject:self.answerDatas[exbtn.tag]];
            }
        }
    }
    
    if (answers.count <= 0) {
        return NO;
    }
    
    NSDate *date = [NSDate date];
    NSTimeInterval timestamp = date.timeIntervalSince1970;
    NSString *replyTime = [NSString stringWithFormat:@"%ld", (long)timestamp];
    NSString *idKey = [NSString stringWithFormat:@"student%@", self.localUserInfo.userUuid];
    NSDictionary *properties = @{idKey: @{@"answer":answers,@"replyTime":replyTime,@"startTime":self.startTime}};

    [self updateProperties:properties success:^{
        NSLog(@"answer-- update properties successs");
    } fail:^(AgoraExtAppError * _Nonnull error) {
        NSLog(@"answer-- update properties fail");
    }];
    return YES;
}

-(void)restSubmit{
    NSString *idKey = [NSString stringWithFormat:@"student%@", self.localUserInfo.userUuid];
    [self deleteProperties:@[idKey] success:^{
        NSLog(@"answer-- delete properties successs");
    } fail:^(AgoraExtAppError * _Nonnull error) {
        NSLog(@"answer-- delete properties fail");
    }];
}

- (void)initData:(NSDictionary *)properties {
    [self propertiesDidUpdate:properties];
}

- (BOOL)array:(NSArray *)array1 isEqualTo:(NSArray *)array2 {
    if (array1.count != array2.count) {
        return NO;
    }
    for (NSString *str in array1) {
        if (![array2 containsObject:str]) {
            return NO;
        }
    }
    for (NSString *str in array2) {
        if (![array1 containsObject:str]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Timer
- (void)startTimer {
    [self stopTimer];
    
    self.countDownLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)(self.countDown / 3600), (long)(self.countDown / 60), (long)(self.countDown % 60)];
    
    __weak AnswerExtApp *weakSelf = self;
    
    self.timer = [NSTimer timerWithTimeInterval:1.0
                                        repeats:YES
                                          block:^(NSTimer * _Nonnull timer) {
        weakSelf.countDown += 1;
        
        weakSelf.countDownLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)(weakSelf.countDown / 3600), (long)(weakSelf.countDown / 60), (long)(weakSelf.countDown % 60)];
        
//        if (weakSelf.countDown <= 0) {
//            [weakSelf stopTimer];
//        }
    }];
    
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    [self.timer fire];
}

- (void)stopTimer {
    if (nil != self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)dealloc {
    [self stopTimer];
}
@end
