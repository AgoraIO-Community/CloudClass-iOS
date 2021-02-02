//
//  AgoraMCStudentListView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "AgoraMCStudentListView.h"
#import "AgoraMCStudentViewCell.h"

@interface AgoraMCStudentListView ()<UITableViewDelegate, UITableViewDataSource, AgoraRoomProtocol>
@property (weak, nonatomic) UITableView *studentTableView;
@property (nonatomic, strong) NSArray<AgoraRTEStream*> *studentArray;
@property (nonatomic, strong) NSArray<NSString*> *grantUserArray;

@end

@implementation AgoraMCStudentListView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UITableView *studentTableView = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
    studentTableView.delegate = self;
    studentTableView.dataSource =self;
    [self addSubview:studentTableView];
    self.studentTableView = studentTableView;
    studentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.studentArray = [NSMutableArray array];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.studentTableView.frame = self.bounds;
}

- (void)updateStudentArray:(NSArray<AgoraRTEStream*> *)array {
    self.studentArray = [NSArray arrayWithArray:array];
    [self.studentTableView reloadData];
}

- (void)updateGrantStudentArray:(NSArray<NSString*> *)grantUsers {
    self.grantUserArray = [NSArray arrayWithArray:grantUsers];
    [self.studentTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.studentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AgoraMCStudentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"studentCell"];
    if (!cell) {
        cell = [[AgoraEduBundle loadNibNamed:@"AgoraMCStudentViewCell" owner:self options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }

    AgoraRTEStream *model = self.studentArray[indexPath.row];
    AgoraMCStreamInfo *infoModel = [[AgoraMCStreamInfo alloc] initWithUserUuid:model.userInfo.userUuid userName:model.userInfo.userName hasAudio:model.hasAudio hasVideo:model.hasVideo streamState:1 userState:1];

    cell.userUuid = self.userUuid;
    cell.stream = infoModel;
    [cell updateEnableButtons:infoModel.userUuid];
    cell.muteWhiteButton.selected = NO;
    if(self.grantUserArray != nil && [self.grantUserArray containsObject:infoModel.userUuid]) {
        cell.muteWhiteButton.selected = YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)setUserUuid:(NSString *)userUuid {
    _userUuid = userUuid;
    [self.studentTableView reloadData];
}

#pragma mark AgoraRoomProtocol
- (void)muteVideoStream:(BOOL)mute {
    if (self.delegate && [self.delegate respondsToSelector:@selector(muteVideoStream:)]) {
        [self.delegate muteVideoStream:mute];
    }
}
- (void)muteAudioStream:(BOOL)mute {
    if (self.delegate && [self.delegate respondsToSelector:@selector(muteAudioStream:)]) {
        [self.delegate muteAudioStream:mute];
    }
}

@end
