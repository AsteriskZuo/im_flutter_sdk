//
//  EMChatroomManagerWrapper.m
//  im_flutter_sdk
//
//  Created by easemob-DN0164 on 2019/10/18.
//

#import "EMChatroomManagerWrapper.h"
#import "EMSDKMethod.h"

#import "EMCursorResult+Flutter.h"
#import "EMPageResult+Flutter.h"
#import "EMChatroom+Flutter.h"


@interface EMChatroomManagerWrapper () <EMChatroomManagerDelegate>

@end

@implementation EMChatroomManagerWrapper

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
        
        [EMClient.sharedClient.roomManager addDelegate:self delegateQueue:nil];
    }
    return self;
}


#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([ChatJoinChatRoom isEqualToString:call.method])
    {
        [self joinChatroom:call.arguments
               channelName:call.method
                    result:result];
    }
    else if ([ChatLeaveChatRoom isEqualToString:call.method]) {
        [self leaveChatroom:call.arguments
                channelName:call.method
                     result:result];
    }
    else if ([ChatGetChatroomsFromServer isEqualToString:call.method]) {
        [self getChatroomsFromServer:call.arguments
                         channelName:call.method
                              result:result];
    }
    else if ([ChatCreateChatRoom isEqualToString:call.method]) {
        [self createChatroom:call.arguments
                 channelName:call.method
                      result:result];
    }
    else if ([ChatDestroyChatRoom isEqualToString:call.method]) {
        [self destroyChatRoom:call.arguments
                  channelName:call.method
                       result:result];
    }
    else if ([ChatFetchChatRoomFromServer isEqualToString:call.method]) {
        [self fetchChatroomInfoFromServer:call.arguments
                              channelName:call.method
                                   result:result];
    }
    else if ([ChatGetChatRoom isEqualToString:call.method]) {
        [self getChatroom:call.arguments
              channelName:call.method
                   result:result];
    }
    else if ([ChatGetAllChatRooms isEqualToString:call.method]) {
        [self getAllChatrooms:call.arguments
                  channelName:call.method
                       result:result];
    }
    else if ([ChatGetChatroomMemberListFromServer isEqualToString:call.method]) {
        [self getChatroomMemberListFromServer:call.arguments
                                  channelName:call.method
                                       result:result];
    }
    else if ([ChatFetchChatroomBlockListFromServer isEqualToString:call.method]) {
        [self fetchChatroomBlockListFromServer:call.arguments
                                   channelName:call.method
                                        result:result];
    }
    else if ([ChatGetChatroomMuteListFromServer isEqualToString:call.method]) {
        [self getChatroomMuteListFromServer:call.arguments
                                channelName:call.method
                                     result:result];
    }
    else if ([ChatFetchChatroomAnnouncement isEqualToString:call.method]) {
        [self fetchChatroomAnnouncement:call.arguments
                            channelName:call.method
                                 result:result];
    }
    else if ([ChatChatRoomUpdateSubject isEqualToString:call.method]) {
        [self chatRoomUpdateSubject:call.arguments
                        channelName:call.method
                             result:result];
    }
    else if ([ChatChatRoomUpdateDescription isEqualToString:call.method]) {
        [self chatRoomUpdateDescription:call.arguments
                            channelName:call.method
                                 result:result];
    }
    else if ([ChatChatRoomRemoveMembers isEqualToString:call.method]) {
        [self chatRoomRemoveMembers:call.arguments
                        channelName:call.method
                             result:result];
    }
    else if ([ChatChatRoomBlockMembers isEqualToString:call.method]) {
        [self chatRoomBlockMembers:call.arguments
                       channelName:call.method
                            result:result];
    }
    else if ([ChatChatRoomUnblockMembers isEqualToString:call.method]) {
        [self chatRoomUnblockMembers:call.arguments
                         channelName:call.method
                              result:result];
    }
    else if ([ChatChangeChatRoomOwner isEqualToString:call.method]) {
        [self chatRoomChangeOwner:call.arguments
                      channelName:call.method
                           result:result];
    }
    else if ([ChatChatRoomAddAdmin isEqualToString:call.method]) {
        [self chatRoomAddAdmin:call.arguments
                   channelName:call.method
                        result:result];
    }
    else if ([ChatChatRoomRemoveAdmin isEqualToString:call.method]) {
        [self chatRoomRemoveAdmin:call.arguments
                      channelName:call.method
                           result:result];
    }
    else if ([ChatChatRoomMuteMembers isEqualToString:call.method]) {
        [self chatRoomMuteMembers:call.arguments
                      channelName:call.method
                           result:result];
    }
    else if ([ChatChatRoomUnmuteMembers isEqualToString:call.method]) {
        [self chatRoomUnmuteMembers:call.arguments
                        channelName:call.method
                             result:result];
    }
    else if ([ChatUpdateChatRoomAnnouncement isEqualToString:call.method]) {
        [self updateChatroomAnnouncement:call.arguments
                             channelName:call.method
                                  result:result];
    }
    else if ([ChatAddMembersToChatRoomWhiteList isEqualToString:call.method]) {
        [self addMembersToChatRoomWhiteList:call.arguments
                                channelName:call.method
                                     result:result];
    }
    else if ([ChatRemoveMembersFromChatRoomWhiteList isEqualToString:call.method]) {
        [self removeMembersFromChatRoomWhiteList:call.arguments
                                     channelName:call.method
                                          result:result];
    }
    else if ([ChatFetchChatRoomWhiteListFromServer isEqualToString:call.method]) {
        [self fetchChatRoomWhiteListFromServer:call.arguments
                                   channelName:call.method
                                        result:result];
    }
    else if ([ChatIsMemberInChatRoomWhiteListFromServer isEqualToString:call.method]) {
        [self isMemberInChatRoomWhiteListFromServer:call.arguments
                                        channelName:call.method
                                             result:result];
    }
    else if ([ChatMuteAllChatRoomMembers isEqualToString:call.method]) {
        [self muteAllChatRoomMembers:call.arguments
                         channelName:call.method
                              result:result];
    }
    else if ([ChatUnMuteAllChatRoomMembers isEqualToString:call.method]) {
        [self unMuteAllChatRoomMembers:call.arguments
                           channelName:call.method
                                result:result];
    }
    else {
        [super handleMethodCall:call result:result];
    }
}

#pragma mark - Actions

- (void)getChatroomsFromServer:(NSDictionary *)param
                   channelName:(NSString *)aChannelName
                        result:(FlutterResult)result {
    NSInteger page = [param[@"pageNum"] integerValue];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    
    __weak typeof(self) weakSelf = self;
    
    [EMClient.sharedClient.roomManager getChatroomsFromServerWithPage:page
                                                             pageSize:pageSize
                                                           completion:^(EMPageResult *aResult, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aResult toJson]];
    }];
}

- (void)createChatroom:(NSDictionary *)param
           channelName:(NSString *)aChannelName
                result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *subject = param[@"subject"];
    NSString *description = param[@"desc"];
    NSArray *invitees = param[@"members"];
    NSString *message = param[@"welcomeMsg"];
    NSInteger maxMembersCount = [param[@"maxUserCount"] integerValue];
    [EMClient.sharedClient.roomManager createChatroomWithSubject:subject
                                                     description:description
                                                        invitees:invitees
                                                         message:message
                                                 maxMembersCount:maxMembersCount
                                                      completion:^(EMChatroom *aChatroom, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aChatroom toJson]];
    }];
}

- (void)joinChatroom:(NSDictionary *)param
         channelName:(NSString *)aChannelName
              result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager joinChatroom:chatroomId
                                         completion:^(EMChatroom *aChatroom, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!!aChatroom)];
    }];
}

- (void)leaveChatroom:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager leaveChatroom:chatroomId
                                          completion:^(EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)destroyChatRoom:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager destroyChatroom:chatroomId completion:^(EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)fetchChatroomInfoFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager getChatroomSpecificationFromServerWithId:chatroomId
                                                                     completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aChatroom toJson]];
        
    }];
}

- (void)getChatroom:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self)weakSelf = self;
    EMChatroom *chatroom = [EMChatroom chatroomWithId:param[@"roomId"]];
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:[chatroom toJson]];
}

- (void)getAllChatrooms:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager getChatroomsFromServerWithPage:0
                                                             pageSize:-1
                                                           completion:^(EMPageResult *aResult, EMError *aError)
     {
        NSMutableArray *list = [NSMutableArray array];
        for (EMChatroom *room in aResult.list) {
            [list addObject:[room toJson]];
        }
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:list];
    }];
}

- (void)getChatroomMemberListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    NSString *cursor = param[@"cursor"];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager getChatroomMemberListFromServerWithId:chatroomId
                                                                      cursor:cursor
                                                                    pageSize:pageSize
                                                                  completion:^(EMCursorResult *aResult, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aResult toJson]];

    }];
}

- (void)fetchChatroomBlockListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    NSInteger pageNumber = [param[@"pageNum"] integerValue];;
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager getChatroomBlacklistFromServerWithId:chatroomId
                                                                 pageNumber:pageNumber
                                                                   pageSize:pageSize
                                                                 completion:^(NSArray *aList, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aList];
    }];
}

- (void)getChatroomMuteListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    NSInteger pageNumber = [param[@"pageNum"] integerValue];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager getChatroomMuteListFromServerWithId:chatroomId
                                                                pageNumber:pageNumber
                                                                  pageSize:pageSize
                                                                completion:^(NSArray *aList, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aList];
    }];
}

- (void)fetchChatroomAnnouncement:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager getChatroomAnnouncementWithId:chatroomId
                                                          completion:^(NSString *aAnnouncement, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aAnnouncement];
    }];
}

- (void)chatRoomUpdateSubject:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *subject = param[@"subject"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager updateSubject:subject
                                         forChatroom:chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomUpdateDescription:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *description = param[@"description"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager updateDescription:description
                                             forChatroom:chatroomId
                                              completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomRemoveMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager removeMembers:members
                                        fromChatroom:chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomBlockMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager blockMembers:members
                                       fromChatroom:chatroomId
                                         completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomUnblockMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager unblockMembers:members
                                         fromChatroom:chatroomId
                                           completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomChangeOwner:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    NSString *newOwner = param[@"newOwner"];
    [EMClient.sharedClient.roomManager updateChatroomOwner:chatroomId
                                                  newOwner:newOwner
                                                completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomAddAdmin:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *admin = param[@"admin"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager addAdmin:admin
                                     toChatroom:chatroomId
                                     completion:^(EMChatroom *aChatroomp, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomRemoveAdmin:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *admin = param[@"admin"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager removeAdmin:admin
                                      fromChatroom:chatroomId
                                        completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomMuteMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *muteMembers = param[@"muteMembers"];
    NSInteger muteMilliseconds = [param[@"duration"] integerValue];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager muteMembers:muteMembers
                                  muteMilliseconds:muteMilliseconds
                                      fromChatroom:chatroomId
                                        completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)chatRoomUnmuteMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *unMuteMembers = param[@"unMuteMembers"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager unmuteMembers:unMuteMembers
                                        fromChatroom:chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)updateChatroomAnnouncement:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *chatroomId = param[@"roomId"];
    NSString *announcement = param[@"announcement"];
    [EMClient.sharedClient.roomManager updateChatroomAnnouncementWithId:chatroomId
                                                           announcement:announcement
                                                             completion:^(EMChatroom *aChatroom, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}


- (void)addMembersToChatRoomWhiteList:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *roomId = param[@"roomId"];
    NSArray *ary = param[@"members"];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager addWhiteListMembers:ary
                                               fromChatroom:roomId
                                                 completion:^(EMChatroom *aChatroom, EMError *aError)
      {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }] ;
}

- (void)removeMembersFromChatRoomWhiteList:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *roomId = param[@"roomId"];
    NSArray *ary = param[@"members"];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager removeWhiteListMembers:ary fromChatroom:roomId completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)isMemberInChatRoomWhiteListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *roomId = param[@"roomId"];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager isMemberInWhiteListFromServerWithChatroomId:roomId
                                                                        completion:^(BOOL inWhiteList, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(inWhiteList)];
    }];
}

- (void)fetchChatRoomWhiteListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *roomId = param[@"roomId"];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager getChatroomWhiteListFromServerWithId:roomId
                                                                 completion:^(NSArray *aList, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aList];
    }];
}

- (void)muteAllChatRoomMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *roomId = param[@"roomId"];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager muteAllMembersFromChatroom:roomId
                                                       completion:^(EMChatroom *aChatroom, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)unMuteAllChatRoomMembers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *roomId = param[@"roomId"];
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager unmuteAllMembersFromChatroom:roomId
                                                       completion:^(EMChatroom *aChatroom, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@(!aError)];
    }];

}

#pragma mark - EMChatroomManagerWrapper

- (void)userDidJoinChatroom:(EMChatroom *)aChatroom
                       user:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@"onMemberJoined",
        @"roomId":aChatroom.chatroomId,
        @"participant":aUsername
    };
    [self.channel invokeMethod:ChatChatroomChanged
                     arguments:map];
    
}

- (void)userDidLeaveChatroom:(EMChatroom *)aChatroom
                        user:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@"onMemberExited",
        @"roomId":aChatroom.chatroomId,
        @"roomName":aChatroom.subject,
        @"participant":aUsername
    };
    [self.channel invokeMethod:ChatChatroomChanged
                     arguments:map];
}

- (void)didDismissFromChatroom:(EMChatroom *)aChatroom
                        reason:(EMChatroomBeKickedReason)aReason {
    NSString *type;
    NSDictionary *map;
    if (aReason == EMChatroomBeKickedReasonDestroyed) {
        type = @"onChatRoomDestroyed";
        map = @{
            @"type":type,
            @"roomId":aChatroom.chatroomId,
            @"roomName":aChatroom.subject
        };
    } else if (aReason == EMChatroomBeKickedReasonBeRemoved) {
        type = @"onRemovedFromChatRoom";
        map = @{
            @"type":type,
            @"roomId":aChatroom.chatroomId,
            @"roomName":aChatroom.subject,
            @"participant":[[EMClient sharedClient] currentUsername]
        };
    }
    
    [self.channel invokeMethod:ChatChatroomChanged
                     arguments:map];
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
                addedMutedMembers:(NSArray *)aMutes
                       muteExpire:(NSInteger)aMuteExpire {
    NSDictionary *map = @{
        @"type":@"onMuteListAdded",
        @"roomId":aChatroom.chatroomId,
        @"mutes":aMutes,
        @"expireTime":[NSString stringWithFormat:@"%ld", aMuteExpire]
    };
    [self.channel invokeMethod:ChatChatroomChanged
                     arguments:map];
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
              removedMutedMembers:(NSArray *)aMutes {
    NSDictionary *map = @{
        @"type":@"onMuteListRemoved",
        @"roomId":aChatroom.chatroomId,
        @"mutes":aMutes
    };
    [self.channel invokeMethod:ChatChatroomChanged
                     arguments:map];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin {
    NSDictionary *map = @{
        @"type":@"onAdminAdded",
        @"roomId":aChatroom.chatroomId,
        @"admin":aAdmin
    };
    [self.channel invokeMethod:ChatChatroomChanged
                     arguments:map];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                      removedAdmin:(NSString *)aAdmin {
    NSDictionary *map = @{
        @"type":@"onAdminRemoved",
        @"roomId":aChatroom.chatroomId,
        @"admin":aAdmin
    };
    [self.channel invokeMethod:ChatChatroomChanged
                     arguments:map];
}

- (void)chatroomOwnerDidUpdate:(EMChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner {
    NSDictionary *map = @{
        @"type":@"onOwnerChanged",
        @"roomId":aChatroom.chatroomId,
        @"newOwner":aNewOwner,
        @"oldOwner":aOldOwner
    };
    [self.channel invokeMethod:ChatChatroomChanged
                     arguments:map];
}

- (void)chatroomAnnouncementDidUpdate:(EMChatroom *)aChatroom
                         announcement:(NSString *)aAnnouncement {
    NSDictionary *map = @{
        @"type":@"onAnnouncementChanged",
        @"roomId":aChatroom.chatroomId,
        @"announcement":aAnnouncement
    };
    [self.channel invokeMethod:ChatChatroomChanged
                     arguments:map];
}

- (void)chatroomWhiteListDidUpdate:(EMChatroom *)aChatroom
             addedWhiteListMembers:(NSArray *)aMembers {
    NSDictionary *map = @{
        @"type":@"onWhiteListAdded",
        @"roomId":aChatroom.chatroomId,
        @"whitelist":aMembers
    };
    [self.channel invokeMethod:ChatChatroomChanged
                     arguments:map];
}


- (void)chatroomWhiteListDidUpdate:(EMChatroom *)aChatroom
           removedWhiteListMembers:(NSArray *)aMembers {
    NSDictionary *map = @{
        @"type":@"onWhiteListRemoved",
        @"roomId":aChatroom.chatroomId,
        @"whitelist":aMembers
    };
    [self.channel invokeMethod:ChatChatroomChanged
                     arguments:map];
}


- (void)chatroomAllMemberMuteChanged:(EMChatroom *)aChatroom
                    isAllMemberMuted:(BOOL)aMuted {
    NSDictionary *map = @{
        @"type":@"onAllMemberMuteStateChanged",
        @"roomId":aChatroom.chatroomId,
        @"isMuted":@(aMuted)
    };
    [self.channel invokeMethod:ChatChatroomChanged
                     arguments:map];
}

#pragma mark - EMChatroom Pack Method

// 聊天室成员获取结果转字典
- (NSDictionary *)dictionaryWithCursorResult:(EMCursorResult *)cursorResult
{
    NSDictionary *resultDict = @{@"data":cursorResult.list,
                                 @"cursor":cursorResult.cursor
                                };
    return resultDict;
}

@end
