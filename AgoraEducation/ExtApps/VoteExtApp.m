//
//  VoteExtApp.m
//  AgoraEducation
//  Copyright © 2021 Agora. All rights reserved.
//

#import "VoteExtApp.h"
#import "VoteListCell.h"

static const int s_wnddefWidth = 240;

@interface VoteItem : NSObject
@property (nonatomic, copy) NSString *name;
@property (assign, nonatomic) NSInteger selNum;
@property (assign, nonatomic) NSInteger totalNum;
@end

@implementation VoteItem
- (instancetype)init{
    self = [super init];
    if (self) {
        self.name = @"";
        self.selNum = self.totalNum = 0;
    }
    return self;
}
@end

@interface VoteExtApp ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) NSInteger titleHeight;
@property (nonatomic, strong) UIView *viewContent;
@property (nonatomic, strong) UIButton *voteBtn;
@property (nonatomic, strong) UITableView* curTableView;
@property (nonatomic, strong) UILabel* typeLabel;
@property (nonatomic, strong) NSMutableArray<VoteItem*> *voteDataSource;
@property (nonatomic, strong) NSMutableArray<NSNumber*> *selecItems;
@property (nonatomic, copy) NSString *nsTopic;
@property (assign, nonatomic) NSInteger currentVoteType;//0单选，1多选
@property (assign, nonatomic) NSInteger currentVoteStatus;//-1初始未知状态，0投票状态，1投票结果
@end

@implementation VoteExtApp
#pragma mark - Data callback
- (void)propertiesDidUpdate:(NSDictionary *)properties {
    [super propertiesDidUpdate:properties];
    
    if (properties.allValues.count <= 0) {
        return;
    }
    
    self.currentVoteType = [properties[@"mulChoice"] boolValue] == NO ? 0 : 1;//0单选，1多选
    self.nsTopic = properties[@"title"];
    
    NSArray* items = [properties objectForKey:@"items"];
    NSArray* students = [properties objectForKey:@"students"];
    
    [self refreshTypeVoteTxt];
    [self.voteDataSource removeAllObjects];
    if (NULL != items) {
        for (NSString* str in items) {
            VoteItem* item = [[VoteItem alloc] init];
            item.name = str;
            item.selNum = 0;
            item.totalNum = ((NULL == students) ? 0 : students.count);
            [self.voteDataSource addObject:item];
        }
    }
    BOOL isHaveMyResul = NO;
    if (NULL != students) {
        for (NSString* stuname in students) {
            NSString* ssitKey = [NSString stringWithFormat:@"student%@", stuname];
            NSDictionary *ssit = [properties objectForKey:ssitKey];
            if (NULL != ssit) {
                NSArray* answers = [ssit objectForKey:@"answer"];
                if (nil != answers) {
                    if ([stuname isEqualToString:self.localUserInfo.userUuid]) {
                        isHaveMyResul = YES;
                    }
                    
                    for (NSString* ans in answers) {
                        for (int i = 0; i < self.voteDataSource.count; ++i) {
                            if([ans isEqualToString: self.voteDataSource[i].name]){
                                self.voteDataSource[i].selNum += 1;
                            }
                        }
                    }
                }
            }
        }
    }
    
    NSString *nowState = properties[@"state"];
    if ([nowState isEqualToString:@"end"]) {
        if (1 == self.currentVoteStatus && nil != self.curTableView) {
            [self.curTableView reloadData];
        }else{
            self.currentVoteStatus = 1;
            [self initResultViews];
        }
    }else{
        if (nil == self.curTableView || -1 == self.currentVoteStatus) {
            if (isHaveMyResul || 1 == self.currentVoteStatus){
                self.currentVoteStatus = 1;
                [self initResultViews];
            }else{
                self.currentVoteStatus = 0;
                [self initVoteViews];
            }
        }else{
            [self.curTableView reloadData];
        }
    }
}

#pragma mark - Life cycle
- (void)extAppDidLoad:(AgoraExtAppContext *)context {
    self.currentVoteStatus = -1;
    self.curTableView = nil;
    [self initBaseViews];
    [self initData:context.properties];
    //[self restSubmit];
}

- (void)extAppWillUnload {
    self.currentVoteStatus = 0;
}

#pragma mark - VoteExtApp

- (void)initData:(NSDictionary *)properties {
    if (nil == self.selecItems) {
        self.selecItems = [NSMutableArray<NSNumber*> new];
    }
    if (nil == self.voteDataSource) {
        self.voteDataSource = [NSMutableArray<VoteItem*> new];
    }
    [self.selecItems removeAllObjects];
    [self.voteDataSource removeAllObjects];
    [self propertiesDidUpdate:properties];
}

- (void)initBaseViews {
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
    self.view.agora_width = s_wnddefWidth;
    //self.view.agora_height = s_wnddefHeight;
    
    self.titleHeight = 30;
    {
        UIView *viewTitle = [[UIView alloc] init];
        viewTitle.frame = CGRectMake(0, 0, self.view.agora_width, self.titleHeight);
        viewTitle.layer.borderWidth = 1;
        viewTitle.layer.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.49].CGColor;
        viewTitle.layer.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:252/255.0 alpha:1.0].CGColor;
        viewTitle.layer.cornerRadius = 6;
        [self.view addSubview: viewTitle];
        
        UILabel *labelTitle = [[UILabel alloc] init];
        labelTitle.font = [UIFont systemFontOfSize:13.0];
        labelTitle.text = NSLocalizedString(@"Vote_title", nil);
        labelTitle.textColor = [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0];
        labelTitle.textAlignment = NSTextAlignmentLeft;
        labelTitle.alpha = 1.0;
        [viewTitle addSubview:labelTitle];
        [labelTitle sizeToFit];
        labelTitle.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *titlecenter = [NSLayoutConstraint constraintWithItem:labelTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:viewTitle attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *titleleft = [NSLayoutConstraint constraintWithItem:labelTitle attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:viewTitle attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10];
        [viewTitle addConstraint:titlecenter];
        [viewTitle addConstraint:titleleft];
        
        UIView *viewType = [[UIView alloc] init];
        viewType.layer.borderWidth = 0.8;
        viewType.layer.borderColor = [UIColor colorWithRed:53/255.0 green:123/255.0 blue:246/255.0 alpha:1.0].CGColor;
        viewType.layer.cornerRadius = 8;
        [viewTitle addSubview: viewType];
        
        self.typeLabel = [[UILabel alloc] init];
        self.typeLabel.font = [UIFont systemFontOfSize:11.0];
        self.typeLabel.textColor = [UIColor colorWithRed:53/255.0 green:123/255.0 blue:246/255.0 alpha:1.0];
        self.typeLabel.textAlignment = NSTextAlignmentCenter;
        [self refreshTypeVoteTxt];
        [viewTitle addSubview: self.typeLabel];
        [self.typeLabel sizeToFit];
        
        viewType.translatesAutoresizingMaskIntoConstraints = NO;
        self.typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint *conscenter = [NSLayoutConstraint constraintWithItem:viewType attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:viewTitle attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        NSLayoutConstraint *consleft = [NSLayoutConstraint constraintWithItem:viewType attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:labelTitle attribute:NSLayoutAttributeRight multiplier:1.0 constant:6];
        NSLayoutConstraint *conswidth = [NSLayoutConstraint constraintWithItem:viewType attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.typeLabel attribute:NSLayoutAttributeWidth multiplier:1.0 constant:12];
        NSLayoutConstraint *consheigth = [NSLayoutConstraint constraintWithItem:viewType attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.typeLabel attribute:NSLayoutAttributeHeight multiplier:1.0 constant:4];
        NSLayoutConstraint *labelcenterx = [NSLayoutConstraint constraintWithItem:self.typeLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:viewType attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        NSLayoutConstraint *labelcentery = [NSLayoutConstraint constraintWithItem:self.typeLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:viewType attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        
        [viewTitle addConstraint:conscenter];
        [viewTitle addConstraint:consleft];
        [viewTitle addConstraint:conswidth];
        [viewTitle addConstraint:consheigth];
        [viewTitle addConstraint:labelcenterx];
        [viewTitle addConstraint:labelcentery];
    }
    UIView *_line = [[UIView alloc] init];
    _line.frame = CGRectMake(0, self.titleHeight, self.view.agora_width, 1);
    _line.layer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:247/255.0 alpha:1.0].CGColor;
    [self.view addSubview: _line];
    self.titleHeight += 1;
    
    self.viewContent = [[UIView alloc] init];
    [self.view addSubview: self.viewContent];
    
    self.viewContent.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *ctleft = [NSLayoutConstraint constraintWithItem:self.viewContent attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:15];
    NSLayoutConstraint *cttop = [NSLayoutConstraint constraintWithItem:self.viewContent attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.titleHeight];
    NSLayoutConstraint *ctright = [NSLayoutConstraint constraintWithItem:self.viewContent attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-15];
    [self.view addConstraint:ctleft];
    [self.view addConstraint:cttop];
    [self.view addConstraint:ctright];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *agvbottom = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewContent attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.view addConstraint:agvbottom];
}

- (void)initResultViews {
    [self initVoteUI:YES];
}

- (void)initVoteViews {
    [self initVoteUI:NO];
}

- (void)initVoteUI: (BOOL)isResult{
    [self.viewContent removeConstraints:self.viewContent.constraints];
    [self.viewContent.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.voteBtn = nil;
    self.curTableView = nil;

    float ftableHeight = 78;
    if(self.voteDataSource.count > 2){
        if(3 == self.voteDataSource.count){
            ftableHeight += 38;
        }else{
            ftableHeight *= 2;
        }
    }
    
    UIView* viewCenter = [[UIView alloc] init];
    [self.viewContent addSubview: viewCenter];
    
    viewCenter.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *vwleft = [NSLayoutConstraint constraintWithItem:viewCenter attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.viewContent attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *vwright = [NSLayoutConstraint constraintWithItem:viewCenter attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.viewContent attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *vwtop = [NSLayoutConstraint constraintWithItem:viewCenter attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.viewContent attribute:NSLayoutAttributeTop multiplier:1.0 constant:15];
    [self.viewContent addConstraint:vwleft];
    [self.viewContent addConstraint:vwright];
    [self.viewContent addConstraint:vwtop];
    
    {
        UILabel* topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,viewCenter.frame.size.width,48)];
        topicLabel.numberOfLines = 0;
        topicLabel.font = [UIFont systemFontOfSize:12.0];
        topicLabel.text = self.nsTopic;
        topicLabel.textColor =  [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0];
        topicLabel.textAlignment = NSTextAlignmentLeft;
        [viewCenter addSubview: topicLabel];
        [topicLabel sizeToFit];
        topicLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *lableft = [NSLayoutConstraint constraintWithItem:topicLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:viewCenter attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *labright = [NSLayoutConstraint constraintWithItem:topicLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:viewCenter attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *labtop = [NSLayoutConstraint constraintWithItem:topicLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:viewCenter attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        [viewCenter addConstraint:lableft];
        [viewCenter addConstraint:labright];
        [viewCenter addConstraint:labtop];

        self.curTableView = [[UITableView alloc] init];
        self.curTableView.rowHeight = 38;
        self.curTableView.delegate = self;
        self.curTableView.dataSource = self;
        self.curTableView.layer.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.49].CGColor;
        self.curTableView.layer.borderWidth = 1;
        [self.curTableView registerClass:[VoteListCell class] forCellReuseIdentifier:NSStringFromClass([VoteListCell class])];
        self.curTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)) {
            self.curTableView.contentInsetAdjustmentBehavior = UIApplicationBackgroundFetchIntervalNever;
        }
        self.curTableView.scrollEnabled = ((self.voteDataSource.count > 4)? YES : NO);
        [viewCenter addSubview: self.curTableView];
        self.curTableView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *tableleft = [NSLayoutConstraint constraintWithItem:self.curTableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:viewCenter attribute:NSLayoutAttributeLeft multiplier:1.0 constant:isResult?5:0];
        NSLayoutConstraint *tableright = [NSLayoutConstraint constraintWithItem:self.curTableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:viewCenter attribute:NSLayoutAttributeRight multiplier:1.0 constant:isResult?-5:0];
        NSLayoutConstraint *tabletop = [NSLayoutConstraint constraintWithItem:self.curTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topicLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10];
        NSLayoutConstraint *tableheight = [NSLayoutConstraint constraintWithItem:self.curTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ftableHeight];
        [viewCenter addConstraint:tableleft];
        [viewCenter addConstraint:tableright];
        [viewCenter addConstraint:tabletop];
        [self.curTableView addConstraint:tableheight];

        if (isResult) {
            NSLayoutConstraint *vwbottom = [NSLayoutConstraint constraintWithItem:viewCenter attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.curTableView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20];
            [viewCenter addConstraint:vwbottom];
        }else{
            self.voteBtn = [[UIButton alloc] init];
            self.voteBtn.layer.cornerRadius = 15.0;
            self.voteBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
            [self.voteBtn setTitle:NSLocalizedString(@"Vote_submit", nil) forState:UIControlStateNormal];
            [self.voteBtn addTarget:self action:@selector(doVoteClick) forControlEvents:UIControlEventTouchUpInside];
            [viewCenter addSubview: self.voteBtn];
            [self voteBtnEnable:NO];
            self.voteBtn.translatesAutoresizingMaskIntoConstraints = NO;
            NSLayoutConstraint *btncenterx = [NSLayoutConstraint constraintWithItem:self.voteBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:viewCenter attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
            NSLayoutConstraint *btntop = [NSLayoutConstraint constraintWithItem:self.voteBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.curTableView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20];
            NSLayoutConstraint *btnwidth = [NSLayoutConstraint constraintWithItem:self.voteBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:90];
            NSLayoutConstraint *btnheight = [NSLayoutConstraint constraintWithItem:self.voteBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30];
            [viewCenter addConstraint:btncenterx];
            [viewCenter addConstraint:btntop];
            [self.voteBtn addConstraint:btnwidth];
            [self.voteBtn addConstraint:btnheight];
            
            NSLayoutConstraint *vwbottom = [NSLayoutConstraint constraintWithItem:viewCenter attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.voteBtn attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            [viewCenter addConstraint:vwbottom];
        }
    }
    
    NSLayoutConstraint *vcbottom = [NSLayoutConstraint constraintWithItem:self.viewContent attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:viewCenter attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20];
    [self.viewContent addConstraint:vcbottom];
}

- (void)refreshTypeVoteTxt {
    if (self.typeLabel) {
        self.typeLabel.text = ((1 == self.currentVoteType) ? NSLocalizedString(@"Option_mul", nil) : NSLocalizedString(@"Option_sing", nil));
    }
}

-(void)voteBtnEnable:(BOOL)enable{
    if(nil != self.voteBtn){
        if (enable) {
            [self.voteBtn setBackgroundColor:[UIColor colorWithRed:53/255.0 green:123/255.0 blue:246/255.0 alpha:1.0]];
        }else{
            [self.voteBtn setBackgroundColor:[UIColor colorWithRed:192/255.0 green:214/255.0 blue:255/255.0 alpha:1.0]];
        }
    }
}

-(void)resultSubmit{
    NSMutableArray<NSString*>* answers = [NSMutableArray<NSString*> new];
    for (NSNumber* item in self.selecItems) {
        int index = [item intValue];
        if (index < self.voteDataSource.count) {
            [answers addObject:self.voteDataSource[index].name];
        }
    }
    
    NSDate *date = [NSDate date];
    NSTimeInterval timestamp = date.timeIntervalSince1970;
    NSString *replyTime = [NSString stringWithFormat:@"%ld", (long)timestamp];
    NSString *idKey = [NSString stringWithFormat:@"student%@", self.localUserInfo.userUuid];
    NSDictionary *properties = @{idKey: @{@"answer":answers,@"replyTime":replyTime}};

    [self updateProperties:properties success:^{
        NSLog(@"vote-- update properties successs");
    } fail:^(AgoraExtAppError * _Nonnull error) {
        NSLog(@"vote-- update properties fail");
    }];
}

-(void)restSubmit{
    NSString *idKey = [NSString stringWithFormat:@"student%@", self.localUserInfo.userUuid];
    [self deleteProperties:@[idKey] success:^{
        NSLog(@"vote-- delete properties successs");
    } fail:^(AgoraExtAppError * _Nonnull error) {
        NSLog(@"vote-- delete properties fail");
    }];
}

#pragma mark - Button event
-(void)doVoteClick{
    [self resultSubmit];
    self.currentVoteStatus = 1;
    [self.selecItems removeAllObjects];
    [self initResultViews];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.voteDataSource.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    VoteListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"voteListCell"];
    if (cell == nil){
        cell = [[VoteListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"voteListCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setIsMulSel: 1 == self.currentVoteType];
    if (0 == self.currentVoteStatus) {
        BOOL sel = [self.selecItems containsObject:[[NSNumber alloc] initWithLong:indexPath.row]];
        [cell setSelStatus:self.voteDataSource[indexPath.row].name seleted:sel];
    }else{
        float te = 0.0;
        if (self.voteDataSource[indexPath.row].totalNum > 0) {
            te = (float)(self.voteDataSource[indexPath.row].selNum) / (float)(self.voteDataSource[indexPath.row].totalNum);
        }
        [cell setResStatus:self.voteDataSource[indexPath.row].name selNum:self.voteDataSource[indexPath.row].selNum percent:te];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber* sel = [[NSNumber alloc] initWithLong:indexPath.row];
    if ([self.selecItems containsObject: sel]) {
        [self.selecItems removeObject: sel];
    }else{
        if (1 != self.currentVoteType) {
            //不是多选则移除其他
            [self.selecItems removeAllObjects];
        }
        [self.selecItems addObject: sel];
    }
    [self voteBtnEnable:(self.selecItems.count > 0)];
    [tableView reloadData];
}

- (void)dealloc {
}


@end
