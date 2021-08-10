//
//  ChatView.m
//  ChatWidget
//
//  Created by lixiaoming on 2021/7/4.
//

#import "ChatView.h"
#import "EMMessageModel.h"
#import "EMMessageStringCell.h"
#import "EMMessageCell.h"
#import "UIImage+ChatExt.h"
#import <Masonry/Masonry.h>
#import "EMDateHelper.h"
#import "ChatWidget+Localizable.h"

@interface NilMsgView ()
@property (nonatomic,strong) UIImageView* nilMsgImageView;
@property (nonatomic,strong) UILabel* nilMsgLable;
@end

@implementation NilMsgView

- (instancetype)init
{
    self = [super init];
    if(self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    self.nilMsgImageView = [[UIImageView alloc] init];
    self.nilMsgImageView.image = [UIImage imageNamedFromBundle:@"icon_nil"];
    [self addSubview:self.nilMsgImageView];
    [self.nilMsgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self);
        make.width.equalTo(@80);
        make.height.equalTo(@72);
    }];
    
    self.nilMsgLable = [[UILabel alloc] init];
    self.nilMsgLable.text = [ChatWidget LocalizedString:@"ChatEmptyText"];
    self.nilMsgLable.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.nilMsgLable];
    [self.nilMsgLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.centerX.equalTo(self);
        make.height.equalTo(@20);
        make.width.equalTo(self);
    }];
}

@end

@interface ShowAnnouncementView ()
@property (nonatomic,strong) UIButton* announcementButton;
@property (nonatomic,weak) ChatView* parantView;
@end

@implementation ShowAnnouncementView

- (instancetype)init
{
    self = [super init];
    if(self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    self.backgroundColor = [UIColor colorWithRed:253/255.0 green:249/255.0 blue:244/255.0 alpha:1.0];
    self.announcementButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.announcementButton setImage:[UIImage imageNamedFromBundle:@"icon_notice"] forState:UIControlStateNormal];
    [self.announcementButton setTitle:@"" forState:UIControlStateNormal];
    [self.announcementButton setTitleColor:[UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.announcementButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    self.announcementButton.titleLabel.numberOfLines = 1;
    [self addSubview:self.announcementButton];
    self.announcementButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.announcementButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.announcementButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.height.equalTo(self);
        make.width.equalTo(self).with.multipliedBy(0.8);
    }];
    [self.announcementButton addTarget:self action:@selector(announcementAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)announcementAction
{
    if(self.parantView.delegate) {
        [self.parantView.delegate chatViewDidClickAnnouncement];
    }
}

@end

@interface ChatView ()<UITableViewDelegate, UITableViewDataSource, ChatBarDelegate,EMMessageCellDelegate>
@property (nonatomic,strong) NilMsgView* nilMsgView;
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic,strong) ShowAnnouncementView* showAnnouncementView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *msgIdArray;
//消息格式化
@property (nonatomic) NSTimeInterval msgTimelTag;
//长按操作栏
@property (strong, nonatomic) NSIndexPath *menuIndexPath;
@property (nonatomic, strong) UIMenuController *menuController;
@property (nonatomic, strong) UIMenuItem *recallMenuItem;
// 删除的消息
@property (nonatomic, strong) NSMutableArray<NSString*>* msgsToDel;
@end

@implementation ChatView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.msgTimelTag = -1;
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    self.backgroundColor = [UIColor whiteColor];
    self.nilMsgView = [[NilMsgView alloc] init];
    [self addSubview:self.nilMsgView];
    [self.nilMsgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@100);
        make.center.equalTo(self);
    }];
    
    self.showAnnouncementView = [[ShowAnnouncementView alloc] init];
    self.showAnnouncementView.parantView = self;
    [self addSubview:self.showAnnouncementView];
    self.showAnnouncementView.hidden = YES;
    [self.showAnnouncementView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.height.equalTo(@24);
    }];
    [self bringSubviewToFront:self.showAnnouncementView];
    
    [self addSubview:self.tableView];
    
    self.chatBar = [[ChatBar alloc] init];
    self.chatBar.delegate = self;
    self.chatBar.layer.cornerRadius = 4;
    [self addSubview:self.chatBar];
    [self bringSubviewToFront:self.chatBar];
    [self sendSubviewToBack:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.width.equalTo(self);
            make.bottom.equalTo(self).offset(-40);
    }];
    [self.chatBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.width.equalTo(self);
        make.height.equalTo(@40);
    }];
}

- (void)setAnnouncement:(NSString *)announcement
{
    _announcement = announcement;
    self.showAnnouncementView.hidden = _announcement.length == 0;
//    announcement = [announcement stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
//    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
//    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
//    NSArray *parts = [announcement componentsSeparatedByCharactersInSet:whitespaces];
//    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
//    announcement = [filteredArray componentsJoinedByString:@" "];

    [self.showAnnouncementView.announcementButton setTitle:announcement forState:UIControlStateNormal];
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
////    self.tableView.frame = CGRectMake(0, 0, self.bounds.size.width,self.bounds.size.height - 40);
////    self.chatBar.frame = CGRectMake(0, self.bounds.size.height - 40, self.bounds.size.width, 40);
//}

#pragma mark - getter

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [UIView new];
    }
    
    return _tableView;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (UIMenuController *)menuController
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    
    return _menuController;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIMenuItem *)recallMenuItem
{
    if (_recallMenuItem == nil) {
        _recallMenuItem = [[UIMenuItem alloc] initWithTitle:[ChatWidget LocalizedString:@"ChatRecall"] action:@selector(recallMenuItemAction:)];
    }
    
    return _recallMenuItem;
}

- (NSMutableArray<NSString*>*)msgsToDel
{
    if(!_msgsToDel) {
        _msgsToDel = [NSMutableArray<NSString*> array];
    }
    return _msgsToDel;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [self.dataArray objectAtIndex:indexPath.row];
    NSString *cellString = nil;
    if ([obj isKindOfClass:[NSString class]]) {
        cellString = (NSString *)obj;
    } else if ([obj isKindOfClass:[EMMessageModel class]]) {
        EMMessageModel *model = (EMMessageModel *)obj;
        if (model.type == EMMessageTypeExtRecall) {
            cellString = [ChatWidget LocalizedString:@"ChatRecallAMessage"];
        }
        if (model.emModel.body.type == EMMessageBodyTypeCmd) {
            EMCmdMessageBody* cmdBody = (EMCmdMessageBody*)model.emModel.body;
            NSString*action = cmdBody.action;
            NSDictionary* ext = model.emModel.ext;
            if([action isEqualToString:@"DEL"]) {
                cellString = [ChatWidget LocalizedString:@"ChatTeacherRemoveMsg"];
            }
            if([action isEqualToString:@"setAllMute"]) {
                cellString = [ChatWidget LocalizedString:@"ChatTeacherMuteAll"];
            }
            if([action isEqualToString:@"removeAllMute"]) {
                cellString = [ChatWidget LocalizedString:@"ChatTeacherUnmuteAll"];
            }
            if([action isEqualToString:@"mute"] || [action isEqualToString:@"unmute"]) {
                NSString* muteMember = [ext objectForKey:@"muteMember"];
                
                if(muteMember.length > 0 && [[EMClient sharedClient].currentUsername isEqualToString:muteMember]) {
                    NSString* muteNickname = [ext objectForKey:@"muteNickName"];
                    NSString* teacherNickName = [ext objectForKey:@"nickName"];
                    if([action isEqualToString:@"mute"]) {
                        cellString = [NSString stringWithFormat: [ChatWidget LocalizedString:@"ChatMutedByTeacher"],teacherNickName];
                    }else{
                        cellString = [NSString stringWithFormat: [ChatWidget LocalizedString:@"ChatUnmutedByTeacher"],teacherNickName];
                    }
                    
                }
            }
        }
    }
    if ([cellString length] > 0) {
        EMMessageStringCell *cell = (EMMessageStringCell *)[tableView dequeueReusableCellWithIdentifier:@"EMMessageTimeCell"];
        // Configure the cell...
        if (cell == nil) {
            cell = [[EMMessageStringCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMMessageTimeCell"];
        }

        [cell updatetext:cellString];
        return cell;
    } else {
        EMMessageModel *model = (EMMessageModel *)obj;
        NSString *identifier = [EMMessageCell cellIdentifierWithDirection:model.direction type:model.type];
        // Configure the cell...
        EMMessageCell *cell = (EMMessageCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[EMMessageCell alloc] initWithDirection:model.direction type:model.type];
            cell.delegate = self;
        }
        cell.model = model;
        return cell;
    }
}

- (void)removDelMsg:(NSString*)aDelMsgId fromArray:(NSMutableArray*)array
{
    NSEnumerator *enumerator = [array reverseObjectEnumerator];
    //forin遍历
    for (EMMessageModel *model in enumerator) {
        if([model.emModel.messageId isEqualToString:aDelMsgId]) {
            [array removeObject:model];
        }
    }
}

-(NSMutableArray*)msgIdArray
{
    if(!_msgIdArray) {
        _msgIdArray = [NSMutableArray array];
    }
    return _msgIdArray;
}

- (NSArray *)_formatMessages:(NSArray<EMMessage *> *)aMessages
{
    NSMutableArray *formated = [[NSMutableArray alloc] init];

    for (int i = 0; i < [aMessages count]; i++) {
        EMMessage *msg = aMessages[i];
        if([self.msgIdArray containsObject:msg.messageId]) {
            continue;
        }else{
            [self.msgIdArray addObject:msg.messageId];
        }

        // cmd消息不展示
        if(msg.body.type == EMMessageBodyTypeCmd) {
            EMCmdMessageBody* cmdBody = (EMCmdMessageBody*)msg.body;
            if([cmdBody.action isEqualToString:@"DEL"]) {
                NSString* msgIdToDel = [msg.ext objectForKey:@"msgId"];
                if(msgIdToDel.length > 0) {
                    [self.msgsToDel addObject:msgIdToDel];
                    [self removDelMsg:msgIdToDel fromArray:formated];
                    [self removDelMsg:msgIdToDel fromArray:self.dataArray];
                }
            }else if(!( [cmdBody.action isEqualToString:@"setAllMute"] || [cmdBody.action isEqualToString:@"removeAllMute"])){
                if([cmdBody.action isEqualToString:@"mute"] || [cmdBody.action isEqualToString:@"unmute"]) {
                    NSString* muteMember = [msg.ext objectForKey:@"muteMember"];
                    if(![[EMClient sharedClient].currentUsername isEqualToString:muteMember])
                        continue;
                }else
                    continue;
            }
        }
        if(msg.body.type == EMMessageBodyTypeCustom) {
            continue;
        }
        if (msg.chatType == EMChatTypeChat && !msg.isReadAcked && (msg.body.type == EMMessageBodyTypeText || msg.body.type == EMMessageBodyTypeLocation)) {
            if([self.msgsToDel containsObject:msg.messageId])
                continue;
            [[EMClient sharedClient].chatManager sendMessageReadAck:msg.messageId toUser:msg.conversationId completion:nil];
        } else if (msg.chatType == EMChatTypeGroupChat && !msg.isReadAcked && (msg.body.type == EMMessageBodyTypeText || msg.body.type == EMMessageBodyTypeLocation)) {
        }
        
        CGFloat interval = (self.msgTimelTag - msg.timestamp) / 1000;
        if (self.msgTimelTag < 0 || interval > 60 || interval < -60) {
            NSString *timeStr = [EMDateHelper formattedTimeFromTimeInterval:msg.timestamp];
            //[formated addObject:timeStr];
            self.msgTimelTag = msg.timestamp;
        }
        
        EMMessageModel *model = [[EMMessageModel alloc] initWithEMMessage:msg];
        [formated addObject:model];
    }
    
    return formated;
}

- (void)scrollToBottomRow
{
    if ([self.dataArray count] > 0) {
        [self.tableView setNeedsLayout];
        [self.tableView layoutIfNeeded];
        NSInteger toRow = self.dataArray.count - 1;
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:toRow inSection:0];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView scrollToRowAtIndexPath:toIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    }
}

- (void)updateMsgs:(NSMutableArray<EMMessage*>*)msgArray
{
    NSArray *formated = [self _formatMessages:msgArray];
    [self.dataArray addObjectsFromArray:formated];
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.tableView reloadData];
        if(weakself.dataArray.count > 0){
            weakself.nilMsgView.hidden = YES;
        }
        [weakself scrollToBottomRow];
    });
}

#pragma mark - ChatBarDelegate
- (void)msgWillSend:(NSString *)aMsgText
{
    [self.delegate msgWillSend:aMsgText];
}

#pragma mark - EMMessageCellDelegate
- (void)messageCellDidSelected:(EMMessageCell *)aCell
{
    
}


- (void)recallMenuItemAction:(UIMenuItem *)aItem
{
    if (self.menuIndexPath == nil) {
        return;
    }
    
    NSIndexPath *indexPath = self.menuIndexPath;
    __weak typeof(self) weakself = self;
    EMMessageModel *model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
    
    [[EMClient sharedClient].chatManager recallMessageWithMessageId:model.emModel.messageId completion:^(EMError *aError) {
        if (!aError) {
            EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:[ChatWidget LocalizedString:@"ChatRecallAMessage"]];
            NSString *from = [[EMClient sharedClient] currentUsername];
            NSString *to = self.chatManager.chatRoomId;
            EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:@{MSG_EXT_RECALL:@(YES)}];
            message.chatType = EMChatTypeChatRoom;
            message.isRead = YES;
            message.timestamp = model.emModel.timestamp;
            message.localTime = model.emModel.localTime;
            EMConversation* roomConvesation = [[[EMClient sharedClient] chatManager] getConversationWithConvId:self.chatManager.chatRoomId];
            [roomConvesation insertMessage:message error:nil];
            
            EMMessageModel *model = [[EMMessageModel alloc] initWithEMMessage:message];
            [weakself.dataArray replaceObjectAtIndex:indexPath.row withObject:model];
            [weakself.tableView reloadData];
        }
    }];
    
    self.menuIndexPath = nil;
}

- (void)_showMenuViewController:(EMMessageCell *)aCell
                          model:(EMMessageModel *)aModel
{
    [self becomeFirstResponder];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    if (aModel.emModel.direction == EMMessageDirectionSend) {
        [items addObject:self.recallMenuItem];
    }
    
    [self.menuController setMenuItems:items];
    [self.menuController setTargetRect:aCell.bubbleView.frame inView:aCell];
    [self.menuController setMenuVisible:YES animated:NO];
}

- (void)messageCellDidLongPress:(EMMessageCell *)aCell
{
    return;
    self.menuIndexPath = [self.tableView indexPathForCell:aCell];
    [self _showMenuViewController:aCell model:aCell.model];
}

- (void)messageCellDidResend:(EMMessageModel *)aModel
{
    
}

- (void)messageReadReceiptDetil:(EMMessageCell *)aCell
{
    
}

@end
