//
//  ExtSdkChatroomManagerWrapper.m
//  im_flutter_sdk
//
//  Created by easemob-DN0164 on 2019/10/18.
//

#import "ExtSdkChatroomManagerWrapper.h"
#import "ExtSdkMethodTypeObjc.h"

#import "ExtSdkToJson.h"

@interface ExtSdkChatroomManagerWrapper () <EMChatroomManagerDelegate>

@end

@implementation ExtSdkChatroomManagerWrapper

+ (nonnull instancetype)getInstance {
    static ExtSdkChatroomManagerWrapper *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
      instance = [[ExtSdkChatroomManagerWrapper alloc] init];
    });
    return instance;
}


#pragma mark - Actions

- (void)getChatroomsFromServer:(NSDictionary *)param
                        result:(nonnull id<ExtSdkCallbackObjc>)result {
    NSInteger page = [param[@"pageNum"] integerValue];
    NSInteger pageSize = [param[@"pageSize"] integerValue];

    __weak typeof(self) weakSelf = self;

    [EMClient.sharedClient.roomManager
        getChatroomsFromServerWithPage:page
                              pageSize:pageSize
                            completion:^(EMPageResult *aResult,
                                         EMError *aError) {
                              [weakSelf onResult:result
                                  withMethodType:
                                      ExtSdkMethodKeyGetChatroomsFromServer
                                       withError:aError
                                      withParams:[aResult toJsonObject]];
                            }];
}

- (void)createChatRoom:(NSDictionary *)param
                result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSString *subject = param[@"subject"];
    NSString *description = param[@"desc"];
    NSArray *invitees = param[@"members"];
    NSString *message = param[@"welcomeMsg"];
    NSInteger maxMembersCount = [param[@"maxUserCount"] integerValue];
    [EMClient.sharedClient.roomManager
        createChatroomWithSubject:subject
                      description:description
                         invitees:invitees
                          message:message
                  maxMembersCount:maxMembersCount
                       completion:^(EMChatroom *aChatroom, EMError *aError) {
                         [weakSelf onResult:result
                             withMethodType:ExtSdkMethodKeyCreateChatRoom
                                  withError:aError
                                 withParams:[aChatroom toJsonObject]];
                       }];
}

- (void)joinChatRoom:(NSDictionary *)param
              result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager
        joinChatroom:chatroomId
          completion:^(EMChatroom *aChatroom, EMError *aError) {
            [weakSelf onResult:result
                withMethodType:ExtSdkMethodKeyJoinChatRoom
                     withError:aError
                    withParams:@(!!aChatroom)];
          }];
}

- (void)leaveChatRoom:(NSDictionary *)param
               result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager
        leaveChatroom:chatroomId
           completion:^(EMError *aError) {
             [weakSelf onResult:result
                 withMethodType:ExtSdkMethodKeyLeaveChatRoom
                      withError:aError
                     withParams:nil];
           }];
}

- (void)destroyChatRoom:(NSDictionary *)param
                 result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager
        destroyChatroom:chatroomId
             completion:^(EMError *aError) {
               [weakSelf onResult:result
                   withMethodType:ExtSdkMethodKeyDestroyChatRoom
                        withError:aError
                       withParams:nil];
             }];
}

- (void)fetchChatroomFromServer:(NSDictionary *)param
                             result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager
        getChatroomSpecificationFromServerWithId:chatroomId
                                      completion:^(EMChatroom *aChatroom,
                                                   EMError *aError) {
                                        [weakSelf onResult:result
                                            withMethodType:
                                                ExtSdkMethodKeyFetchChatRoomFromServer
                                                 withError:aError
                                                withParams:[aChatroom toJsonObject]];
                                      }];
}

- (void)getChatRoom:(NSDictionary *)param
             result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;
    EMChatroom *chatroom = [EMChatroom chatroomWithId:param[@"roomId"]];
    [weakSelf onResult:result
        withMethodType:ExtSdkMethodKeyGetChatRoom
             withError:nil
            withParams:[chatroom toJsonObject]];
}

- (void)getAllChatRooms:(NSDictionary *)param
                 result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.roomManager
        getChatroomsFromServerWithPage:0
                              pageSize:-1
                            completion:^(EMPageResult *aResult,
                                         EMError *aError) {
                              NSMutableArray *list = [NSMutableArray array];
                              for (EMChatroom *room in aResult.list) {
                                  [list addObject:[room toJsonObject]];
                              }

                              [weakSelf onResult:result
                                  withMethodType:ExtSdkMethodKeyGetAllChatRooms
                                       withError:aError
                                      withParams:list];
                            }];
}

- (void)getChatroomMemberListFromServer:(NSDictionary *)param
                                 result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSString *chatroomId = param[@"roomId"];
    NSString *cursor = param[@"cursor"];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager
        getChatroomMemberListFromServerWithId:chatroomId
                                       cursor:cursor
                                     pageSize:pageSize
                                   completion:^(EMCursorResult *aResult,
                                                EMError *aError) {
                                     [weakSelf onResult:result
                                         withMethodType:
                                             ExtSdkMethodKeyGetChatroomMemberListFromServer
                                              withError:aError
                                             withParams:[aResult toJsonObject]];
                                   }];
}

- (void)fetchChatroomBlockListFromServer:(NSDictionary *)param
                                  result:
                                      (nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSString *chatroomId = param[@"roomId"];
    NSInteger pageNumber = [param[@"pageNum"] integerValue];
    ;
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager
        getChatroomBlacklistFromServerWithId:chatroomId
                                  pageNumber:pageNumber
                                    pageSize:pageSize
                                  completion:^(NSArray *aList,
                                               EMError *aError) {
                                    [weakSelf onResult:result
                                        withMethodType:
                                            ExtSdkMethodKeyFetchChatroomBlockListFromServer
                                             withError:aError
                                            withParams:aList];
                                  }];
}

- (void)getChatroomMuteListFromServer:(NSDictionary *)param
                               result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSString *chatroomId = param[@"roomId"];
    NSInteger pageNumber = [param[@"pageNum"] integerValue];
    NSInteger pageSize = [param[@"pageSize"] integerValue];
    [EMClient.sharedClient.roomManager
        getChatroomMuteListFromServerWithId:chatroomId
                                 pageNumber:pageNumber
                                   pageSize:pageSize
                                 completion:^(NSArray *aList, EMError *aError) {
                                   [weakSelf onResult:result
                                       withMethodType:
                                           ExtSdkMethodKeyGetChatroomMuteListFromServer
                                            withError:aError
                                           withParams:aList];
                                 }];
}

- (void)fetchChatroomAnnouncement:(NSDictionary *)param
                           result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager
        getChatroomAnnouncementWithId:chatroomId
                           completion:^(NSString *aAnnouncement,
                                        EMError *aError) {
                             [weakSelf onResult:result
                                 withMethodType:
                                     ExtSdkMethodKeyFetchChatroomAnnouncement
                                      withError:aError
                                     withParams:aAnnouncement];
                           }];
}

- (void)chatRoomUpdateSubject:(NSDictionary *)param
                       result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSString *subject = param[@"subject"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager
        updateSubject:subject
          forChatroom:chatroomId
           completion:^(EMChatroom *aChatroom, EMError *aError) {
             [weakSelf onResult:result
                 withMethodType:ExtSdkMethodKeyChatRoomUpdateSubject
                      withError:aError
                     withParams:nil];
           }];
}

- (void)chatRoomUpdateDescription:(NSDictionary *)param
                           result:(nonnull id<ExtSdkCallbackObjc>)result {
    __weak typeof(self) weakSelf = self;
    NSString *description = param[@"description"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager
        updateDescription:description
              forChatroom:chatroomId
               completion:^(EMChatroom *aChatroom, EMError *aError) {
                 [weakSelf onResult:result
                     withMethodType:ExtSdkMethodKeyChatRoomUpdateDescription
                          withError:aError
                         withParams:nil];
               }];
}

- (void)chatRoomRemoveMembers:(NSDictionary *)param
                       result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager
        removeMembers:members
         fromChatroom:chatroomId
           completion:^(EMChatroom *aChatroom, EMError *aError) {
             [weakSelf onResult:result
                 withMethodType:ExtSdkMethodKeyChatRoomRemoveMembers
                      withError:aError
                     withParams:nil];
           }];
}

- (void)chatRoomBlockMembers:(NSDictionary *)param
                      result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager
        blockMembers:members
        fromChatroom:chatroomId
          completion:^(EMChatroom *aChatroom, EMError *aError) {
            [weakSelf onResult:result
                withMethodType:ExtSdkMethodKeyChatRoomBlockMembers
                     withError:aError
                    withParams:nil];
          }];
}

- (void)chatRoomUnblockMembers:(NSDictionary *)param
                        result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSArray *members = param[@"members"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager
        unblockMembers:members
          fromChatroom:chatroomId
            completion:^(EMChatroom *aChatroom, EMError *aError) {
              [weakSelf onResult:result
                  withMethodType:ExtSdkMethodKeyChatRoomUnblockMembers
                       withError:aError
                      withParams:nil];
            }];
}

- (void)changeChatRoomOwner:(NSDictionary *)param
                     result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSString *chatroomId = param[@"roomId"];
    NSString *newOwner = param[@"newOwner"];
    [EMClient.sharedClient.roomManager
        updateChatroomOwner:chatroomId
                   newOwner:newOwner
                 completion:^(EMChatroom *aChatroom, EMError *aError) {
                   [weakSelf onResult:result
                       withMethodType:ExtSdkMethodKeyChangeChatRoomOwner
                            withError:aError
                           withParams:nil];
                 }];
}

- (void)chatRoomAddAdmin:(NSDictionary *)param
                  result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSString *admin = param[@"admin"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager
          addAdmin:admin
        toChatroom:chatroomId
        completion:^(EMChatroom *aChatroomp, EMError *aError) {
          [weakSelf onResult:result
              withMethodType:ExtSdkMethodKeyChatRoomAddAdmin
                   withError:aError
                  withParams:nil];
        }];
}

- (void)chatRoomRemoveAdmin:(NSDictionary *)param
                     result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSString *admin = param[@"admin"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager
         removeAdmin:admin
        fromChatroom:chatroomId
          completion:^(EMChatroom *aChatroom, EMError *aError) {
            [weakSelf onResult:result
                withMethodType:ExtSdkMethodKeyChatRoomRemoveAdmin
                     withError:aError
                    withParams:nil];
          }];
}

- (void)chatRoomMuteMembers:(NSDictionary *)param
                     result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSArray *muteMembers = param[@"muteMembers"];
    NSInteger muteMilliseconds = [param[@"duration"] integerValue];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager
             muteMembers:muteMembers
        muteMilliseconds:muteMilliseconds
            fromChatroom:chatroomId
              completion:^(EMChatroom *aChatroom, EMError *aError) {
                [weakSelf onResult:result
                    withMethodType:ExtSdkMethodKeyChatRoomMuteMembers
                         withError:aError
                        withParams:nil];
              }];
}

- (void)chatRoomUnmuteMembers:(NSDictionary *)param
                       result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSArray *unMuteMembers = param[@"unMuteMembers"];
    NSString *chatroomId = param[@"roomId"];
    [EMClient.sharedClient.roomManager
        unmuteMembers:unMuteMembers
         fromChatroom:chatroomId
           completion:^(EMChatroom *aChatroom, EMError *aError) {
             [weakSelf onResult:result
                 withMethodType:ExtSdkMethodKeyChatRoomUnmuteMembers
                      withError:aError
                     withParams:nil];
           }];
}

- (void)updateChatRoomAnnouncement:(NSDictionary *)param
                            result:(nonnull id<ExtSdkCallbackObjc>)result {

    __weak typeof(self) weakSelf = self;

    NSString *chatroomId = param[@"roomId"];
    NSString *announcement = param[@"announcement"];
    [EMClient.sharedClient.roomManager
        updateChatroomAnnouncementWithId:chatroomId
                            announcement:announcement
                              completion:^(EMChatroom *aChatroom,
                                           EMError *aError) {
                                [weakSelf onResult:result
                                    withMethodType:
                                        ExtSdkMethodKeyUpdateChatRoomAnnouncement
                                         withError:aError
                                        withParams:@(!aError)];
                              }];
}

// TODO: chatroom white list.
- (void)addMembersToChatRoomWhiteList:(NSDictionary *)param
                               result:(nonnull id<ExtSdkCallbackObjc>)result {
}

- (void)removeMembersFromChatRoomWhiteList:(NSDictionary *)param
                                    result:
                                        (nonnull id<ExtSdkCallbackObjc>)result {
}

- (void)isMemberInChatRoomWhiteListFromServer:(NSDictionary *)param
                                       result:(nonnull id<ExtSdkCallbackObjc>)
                                                  result {
}

- (void)fetchChatRoomWhiteListFromServer:(NSDictionary *)param
                                  result:
                                      (nonnull id<ExtSdkCallbackObjc>)result {
}

- (void)muteAllChatRoomMembers:(NSDictionary *)param
                        result:(nonnull id<ExtSdkCallbackObjc>)result {
}

- (void)unMuteAllChatRoomMembers:(NSDictionary *)param
                          result:(nonnull id<ExtSdkCallbackObjc>)result {
}

#pragma mark - EMChatroomManagerDelegate

- (void)userDidJoinChatroom:(EMChatroom *)aChatroom user:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type" : @"onMemberJoined",
        @"roomId" : aChatroom.chatroomId,
        @"participant" : aUsername
    };
    [self onReceive:ExtSdkMethodKeyChatroomChanged withParams:map];
}

- (void)userDidLeaveChatroom:(EMChatroom *)aChatroom
                        user:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type" : @"onMemberExited",
        @"roomId" : aChatroom.chatroomId,
        @"roomName" : aChatroom.subject,
        @"participant" : aUsername
    };
    [self onReceive:ExtSdkMethodKeyChatroomChanged withParams:map];
}

- (void)didDismissFromChatroom:(EMChatroom *)aChatroom
                        reason:(EMChatroomBeKickedReason)aReason {
    NSString *type;
    NSDictionary *map;
    if (aReason == EMChatroomBeKickedReasonDestroyed) {
        type = @"onChatRoomDestroyed";
        map = @{
            @"type" : type,
            @"roomId" : aChatroom.chatroomId,
            @"roomName" : aChatroom.subject
        };
    } else if (aReason == EMChatroomBeKickedReasonBeRemoved) {
        type = @"onRemovedFromChatRoom";
        map = @{
            @"type" : type,
            @"roomId" : aChatroom.chatroomId,
            @"roomName" : aChatroom.subject,
            @"participant" : [[EMClient sharedClient] currentUsername]
        };
    }

    [self onReceive:ExtSdkMethodKeyChatroomChanged withParams:map];
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
                addedMutedMembers:(NSArray *)aMutes
                       muteExpire:(NSInteger)aMuteExpire {
    NSDictionary *map = @{
        @"type" : @"onMuteListAdded",
        @"roomId" : aChatroom.chatroomId,
        @"mutes" : aMutes,
        @"expireTime" : [NSString stringWithFormat:@"%ld", aMuteExpire]
    };
    [self onReceive:ExtSdkMethodKeyChatroomChanged withParams:map];
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
              removedMutedMembers:(NSArray *)aMutes {
    NSDictionary *map = @{
        @"type" : @"onMuteListRemoved",
        @"roomId" : aChatroom.chatroomId,
        @"mutes" : aMutes
    };
    [self onReceive:ExtSdkMethodKeyChatroomChanged withParams:map];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin {
    NSDictionary *map = @{
        @"type" : @"onAdminAdded",
        @"roomId" : aChatroom.chatroomId,
        @"admin" : aAdmin
    };
    [self onReceive:ExtSdkMethodKeyChatroomChanged withParams:map];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                      removedAdmin:(NSString *)aAdmin {
    NSDictionary *map = @{
        @"type" : @"onAdminRemoved",
        @"roomId" : aChatroom.chatroomId,
        @"admin" : aAdmin
    };
    [self onReceive:ExtSdkMethodKeyChatroomChanged withParams:map];
}

- (void)chatroomOwnerDidUpdate:(EMChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner {
    NSDictionary *map = @{
        @"type" : @"onOwnerChanged",
        @"roomId" : aChatroom.chatroomId,
        @"newOwner" : aNewOwner,
        @"oldOwner" : aOldOwner
    };
    [self onReceive:ExtSdkMethodKeyChatroomChanged withParams:map];
}

- (void)chatroomAnnouncementDidUpdate:(EMChatroom *)aChatroom
                         announcement:(NSString *)aAnnouncement {
    NSDictionary *map = @{
        @"type" : @"onAnnouncementChanged",
        @"roomId" : aChatroom.chatroomId,
        @"announcement" : aAnnouncement
    };
    [self onReceive:ExtSdkMethodKeyChatroomChanged withParams:map];
}

- (void)chatroomWhiteListDidUpdate:(EMChatroom *)aChatroom
             addedWhiteListMembers:(NSArray *)aMembers {
    NSDictionary *map = @{
        @"type" : @"onWhiteListAdded",
        @"roomId" : aChatroom.chatroomId,
        @"whitelist" : aMembers
    };
    [self onReceive:ExtSdkMethodKeyChatroomChanged withParams:map];
}

- (void)chatroomWhiteListDidUpdate:(EMChatroom *)aChatroom
           removedWhiteListMembers:(NSArray *)aMembers {
    NSDictionary *map = @{
        @"type" : @"onWhiteListRemoved",
        @"roomId" : aChatroom.chatroomId,
        @"whitelist" : aMembers
    };
    [self onReceive:ExtSdkMethodKeyChatroomChanged withParams:map];
}

- (void)chatroomAllMemberMuteChanged:(EMChatroom *)aChatroom
                    isAllMemberMuted:(BOOL)aMuted {
    NSDictionary *map = @{
        @"type" : @"onAllMemberMuteStateChanged",
        @"roomId" : aChatroom.chatroomId,
        @"isMuted" : @(aMuted)
    };
    [self onReceive:ExtSdkMethodKeyChatroomChanged withParams:map];
}

#pragma mark - EMChatroom Pack Method

// 聊天室成员获取结果转字典
- (NSDictionary *)dictionaryWithCursorResult:(EMCursorResult *)cursorResult {
    NSDictionary *resultDict =
        @{@"data" : cursorResult.list, @"cursor" : cursorResult.cursor};
    return resultDict;
}

@end
