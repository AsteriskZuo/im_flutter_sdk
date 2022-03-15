#import "ExtSdkDispatch.h"
#import "ExtSdkDelegateObjc.h"
#import "ExtSdkMethodTypeObjc.h"

#import "ExtSdkClientWrapper.h"
#import "ExtSdkChatManagerWrapper.h"
#import "ExtSdkChatroomManagerWrapper.h"
#import "ExtSdkContactManagerWrapper.h"
#import "ExtSdkConversationWrapper.h"
#import "ExtSdkGroupManagerWrapper.h"
#import "ExtSdkPushManagerWrapper.h"
#import "ExtSdkUserInfoManagerWrapper.h"

static NSString* const TAG = @"ExtSdkDispatch";
@interface ExtSdkDispatch () {
    id<ExtSdkDelegateObjc> _listener;
}

@end

@implementation ExtSdkDispatch

+ (nonnull instancetype)getInstance {
    static ExtSdkDispatch *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
      instance = [[ExtSdkDispatch alloc] init];
    });
    return instance;
}

- (void)addListener:(nonnull id<ExtSdkDelegateObjc>)listener {
    NSLog(@"%@: addListener:", TAG);
    _listener = listener;
}

- (void)callSdkApi:(nonnull NSString *)methodType
        withParams:(nullable id<NSObject>)params
      withCallback:(nonnull id<ExtSdkCallbackObjc>)callback {
    NSLog(@"%@: callSdkApi:", TAG);
           NSDictionary * ps = (NSDictionary*)params;

    switch ([ExtSdkMethodTypeObjc getEnumValue:methodType]) {
            
            /// #pragma mark - EMClientWrapper value
            case ExtSdkMethodKeyInitValue: [[ExtSdkClientWrapper getInstance] initSDKWithDict:ps result:callback]; break;
            case ExtSdkMethodKeyCreateAccountValue: [[ExtSdkClientWrapper getInstance] createAccount:ps result:callback]; break;
            case ExtSdkMethodKeyLoginValue: [[ExtSdkClientWrapper getInstance] login:ps result:callback]; break;
            case ExtSdkMethodKeyLogoutValue: [[ExtSdkClientWrapper getInstance] logout:ps result:callback]; break;
            case ExtSdkMethodKeyChangeAppKeyValue: [[ExtSdkClientWrapper getInstance] changeAppKey:ps result:callback]; break;
            case ExtSdkMethodKeyIsLoggedInBeforeValue: [[ExtSdkClientWrapper getInstance] isLoggedInBefore:ps result:callback]; break;
            case ExtSdkMethodKeyUploadLogValue: [[ExtSdkClientWrapper getInstance] uploadLog:ps result:callback]; break;
            case ExtSdkMethodKeyCompressLogsValue: [[ExtSdkClientWrapper getInstance] compressLogs:ps result:callback]; break;
            case ExtSdkMethodKeyKickDeviceValue: [[ExtSdkClientWrapper getInstance] kickDevice:ps result:callback]; break;
            case ExtSdkMethodKeyKickAllDevicesValue: [[ExtSdkClientWrapper getInstance] kickAllDevices:ps result:callback]; break;
            case ExtSdkMethodKeyCurrentUserValue: [[ExtSdkClientWrapper getInstance] getCurrentUser:ps result:callback]; break;
            case ExtSdkMethodKeyGetLoggedInDevicesFromServerValue: [[ExtSdkClientWrapper getInstance] getLoggedInDevicesFromServer:ps result:callback]; break;

            /// #pragma mark - EMClientDelegate value
            case ExtSdkMethodKeyOnConnectedValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyOnDisconnectedValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyOnMultiDeviceEventValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;

            case ExtSdkMethodKeySendDataToFlutterValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;

            /// #pragma mark - EMContactManagerWrapper value
            case ExtSdkMethodKeyAddContactValue: [[ExtSdkContactManagerWrapper getInstance] addContact:ps result:callback]; break;
            case ExtSdkMethodKeyDeleteContactValue: [[ExtSdkContactManagerWrapper getInstance] deleteContact:ps result:callback]; break;
            case ExtSdkMethodKeyGetAllContactsFromServerValue: [[ExtSdkContactManagerWrapper getInstance] getAllContactsFromServer:ps result:callback]; break;
            case ExtSdkMethodKeyGetAllContactsFromDBValue: [[ExtSdkContactManagerWrapper getInstance] getAllContactsFromDB:ps result:callback]; break;
            case ExtSdkMethodKeyAddUserToBlockListValue: [[ExtSdkContactManagerWrapper getInstance] addUserToBlockList:ps result:callback]; break;
            case ExtSdkMethodKeyRemoveUserFromBlockListValue: [[ExtSdkContactManagerWrapper getInstance] removeUserFromBlockList:ps result:callback]; break;
            case ExtSdkMethodKeyGetBlockListFromServerValue: [[ExtSdkContactManagerWrapper getInstance] getBlockListFromServer:ps result:callback]; break;
            case ExtSdkMethodKeyGetBlockListFromDBValue: [[ExtSdkContactManagerWrapper getInstance] getBlockListFromDB:ps result:callback]; break;
            case ExtSdkMethodKeyAcceptInvitationValue: [[ExtSdkContactManagerWrapper getInstance] acceptInvitation:ps result:callback]; break;
            case ExtSdkMethodKeyDeclineInvitationValue: [[ExtSdkContactManagerWrapper getInstance] declineInvitation:ps result:callback]; break;
            case ExtSdkMethodKeyGetSelfIdsOnOtherPlatformValue: [[ExtSdkContactManagerWrapper getInstance] getSelfIdsOnOtherPlatform:ps result:callback]; break;

            /// #pragma mark - EMContactDelegate value
            case ExtSdkMethodKeyOnContactChangedValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;

            /// #pragma mark - EMChatManagerWrapper value
            case ExtSdkMethodKeySendMessageValue: [[ExtSdkChatManagerWrapper getInstance] sendMessage:ps withMethodType:ExtSdkMethodKeySendMessage result:callback]; break;
            case ExtSdkMethodKeyResendMessageValue: [[ExtSdkChatManagerWrapper getInstance] resendMessage:ps  withMethodType:ExtSdkMethodKeyResendMessage result:callback]; break;
            case ExtSdkMethodKeyAckMessageReadValue: [[ExtSdkChatManagerWrapper getInstance] ackMessageRead:ps  withMethodType:ExtSdkMethodKeyAckMessageRead result:callback]; break;
            case ExtSdkMethodKeyAckGroupMessageReadValue: [[ExtSdkChatManagerWrapper getInstance] ackMessageRead:ps withMethodType:ExtSdkMethodKeyAckGroupMessageRead result:callback]; break;
            case ExtSdkMethodKeyAckConversationReadValue: [[ExtSdkChatManagerWrapper getInstance] ackConversationRead:ps withMethodType:ExtSdkMethodKeyAckConversationRead result:callback]; break;
            case ExtSdkMethodKeyRecallMessageValue: [[ExtSdkChatManagerWrapper getInstance] recallMessage:ps withMethodType:ExtSdkMethodKeyRecallMessage result:callback]; break;
            case ExtSdkMethodKeyGetConversationValue: [[ExtSdkChatManagerWrapper getInstance] getConversation:ps  withMethodType:ExtSdkMethodKeyGetConversation result:callback]; break;
            case ExtSdkMethodKeyMarkAllChatMsgAsReadValue: [[ExtSdkChatManagerWrapper getInstance] markAllMessagesAsRead:ps withMethodType:ExtSdkMethodKeyMarkAllChatMsgAsRead result:callback]; break;
            case ExtSdkMethodKeyGetUnreadMessageCountValue: [[ExtSdkChatManagerWrapper getInstance] getUnreadMessageCount:ps  withMethodType:ExtSdkMethodKeyGetUnreadMessageCount result:callback]; break;
            case ExtSdkMethodKeyUpdateChatMessageValue: [[ExtSdkChatManagerWrapper getInstance] updateChatMessage:ps withMethodType:ExtSdkMethodKeyUpdateChatMessage result:callback]; break;
            case ExtSdkMethodKeyDownloadAttachmentValue: [[ExtSdkChatManagerWrapper getInstance] downloadAttachment:ps withMethodType:ExtSdkMethodKeyDownloadAttachment result:callback]; break;
            case ExtSdkMethodKeyDownloadThumbnailValue: [[ExtSdkChatManagerWrapper getInstance] downloadThumbnail:ps withMethodType:ExtSdkMethodKeyDownloadThumbnail result:callback]; break;
            case ExtSdkMethodKeyImportMessagesValue: [[ExtSdkChatManagerWrapper getInstance] importMessages:ps  withMethodType:ExtSdkMethodKeyImportMessages result:callback]; break;
            case ExtSdkMethodKeyLoadAllConversationsValue: [[ExtSdkChatManagerWrapper getInstance] loadAllConversations:ps  withMethodType:ExtSdkMethodKeyLoadAllConversations result:callback]; break;
            case ExtSdkMethodKeyGetConversationsFromServerValue: [[ExtSdkChatManagerWrapper getInstance] getConversationsFromServer:ps withMethodType:ExtSdkMethodKeyGetConversationsFromServer result:callback]; break;

            case ExtSdkMethodKeyDeleteConversationValue: [[ExtSdkChatManagerWrapper getInstance] deleteConversation:ps withMethodType:ExtSdkMethodKeyDeleteConversation result:callback]; break;
            //case ExtSdkMethodKeySetVoiceMessageListenedValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            //case ExtSdkMethodKeyUpdateParticipantValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyUpdateConversationsNameValue: [[ExtSdkChatManagerWrapper getInstance] updateConversationsName:ps  withMethodType:ExtSdkMethodKeyUpdateConversationsName result:callback]; break;
            case ExtSdkMethodKeyFetchHistoryMessagesValue: [[ExtSdkChatManagerWrapper getInstance] fetchHistoryMessages:ps withMethodType:ExtSdkMethodKeyFetchHistoryMessages result:callback]; break;
            case ExtSdkMethodKeySearchChatMsgFromDBValue: [[ExtSdkChatManagerWrapper getInstance] searchChatMsgFromDB:ps withMethodType:ExtSdkMethodKeySearchChatMsgFromDB result:callback]; break;
            case ExtSdkMethodKeyGetMessageValue: [[ExtSdkChatManagerWrapper getInstance] getMessageWithMessageId:ps withMethodType:ExtSdkMethodKeyGetMessage result:callback]; break;
            case ExtSdkMethodKeyAsyncFetchGroupAcksValue: [[ExtSdkChatManagerWrapper getInstance] fetchGroupReadAck:ps withMethodType:ExtSdkMethodKeyAsyncFetchGroupAcks result:callback]; break;

            /// #pragma mark - EMChatManagerDelegate value
            case ExtSdkMethodKeyOnMessagesReceivedValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyOnCmdMessagesReceivedValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyOnMessagesReadValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyOnGroupMessageReadValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyOnMessagesDeliveredValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyOnMessagesRecalledValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;

            case ExtSdkMethodKeyOnConversationUpdateValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyOnConversationHasReadValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;

            /// #pragma mark - EMMessageListener value
            case ExtSdkMethodKeyOnMessageProgressUpdateValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyOnMessageSuccessValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyOnMessageErrorValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyOnMessageReadAckValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyOnMessageDeliveryAckValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyOnMessageStatusChangedValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;

            /// #pragma mark - EMConversationWrapper value

            case ExtSdkMethodKeyGetUnreadMsgCountValue: [[ExtSdkConversationWrapper getInstance] getUnreadMsgCount:ps result:callback]; break;
            case ExtSdkMethodKeyMarkAllMsgsAsReadValue: [[ExtSdkConversationWrapper getInstance] markAllMsgsAsRead:ps result:callback]; break;
            case ExtSdkMethodKeyMarkMsgAsReadValue: [[ExtSdkConversationWrapper getInstance] markMsgAsRead:ps result:callback]; break;
            case ExtSdkMethodKeySyncConversationExtValue: [[ExtSdkConversationWrapper getInstance] syncConversationExt:ps result:callback]; break;
            case ExtSdkMethodKeySyncConversationNameValue: [[ExtSdkConversationWrapper getInstance] syncConversationName:ps result:callback]; break;
            case ExtSdkMethodKeyRemoveMsgValue: [[ExtSdkConversationWrapper getInstance] removeMsg:ps result:callback]; break;
            case ExtSdkMethodKeyGetLatestMsgValue: [[ExtSdkConversationWrapper getInstance] getLatestMsg:ps result:callback]; break;
            case ExtSdkMethodKeyGetLatestMsgFromOthersValue: [[ExtSdkConversationWrapper getInstance] getLatestMsgFromOthers:ps result:callback]; break;
            case ExtSdkMethodKeyClearAllMsgValue: [[ExtSdkConversationWrapper getInstance] clearAllMsg:ps result:callback]; break;
            case ExtSdkMethodKeyInsertMsgValue: [[ExtSdkConversationWrapper getInstance] insertMsg:ps result:callback]; break;
            case ExtSdkMethodKeyAppendMsgValue: [[ExtSdkConversationWrapper getInstance] appendMsg:ps result:callback]; break;
            case ExtSdkMethodKeyUpdateConversationMsgValue: [[ExtSdkConversationWrapper getInstance] updateConversationMsg:ps result:callback]; break;

            case ExtSdkMethodKeyLoadMsgWithIdValue: [[ExtSdkConversationWrapper getInstance] loadMsgWithId:ps result:callback]; break;
            case ExtSdkMethodKeyLoadMsgWithStartIdValue: [[ExtSdkConversationWrapper getInstance] loadMsgWithStartId:ps result:callback]; break;
            case ExtSdkMethodKeyLoadMsgWithKeywordsValue: [[ExtSdkConversationWrapper getInstance] loadMsgWithKeywords:ps result:callback]; break;
            case ExtSdkMethodKeyLoadMsgWithMsgTypeValue: [[ExtSdkConversationWrapper getInstance] loadMsgWithMsgType:ps result:callback]; break;
            case ExtSdkMethodKeyLoadMsgWithTimeValue: [[ExtSdkConversationWrapper getInstance] loadMsgWithTime:ps result:callback]; break;

            /// #pragma mark - EMChatroomManagerWrapper value

            case ExtSdkMethodKeyJoinChatRoomValue: [[ExtSdkChatroomManagerWrapper getInstance] joinChatRoom:ps result:callback]; break;
            case ExtSdkMethodKeyLeaveChatRoomValue: [[ExtSdkChatroomManagerWrapper getInstance] leaveChatRoom:ps result:callback]; break;
            case ExtSdkMethodKeyGetChatroomsFromServerValue: [[ExtSdkChatroomManagerWrapper getInstance] getChatroomsFromServer:ps result:callback]; break;
            case ExtSdkMethodKeyFetchChatRoomFromServerValue: [[ExtSdkChatroomManagerWrapper getInstance] fetchChatroomFromServer:ps result:callback]; break;
            case ExtSdkMethodKeyGetChatRoomValue: [[ExtSdkChatroomManagerWrapper getInstance] getChatRoom:ps result:callback]; break;
            case ExtSdkMethodKeyGetAllChatRoomsValue: [[ExtSdkChatroomManagerWrapper getInstance] getAllChatRooms:ps result:callback]; break;
            case ExtSdkMethodKeyCreateChatRoomValue: [[ExtSdkChatroomManagerWrapper getInstance] createChatRoom:ps result:callback]; break;
            case ExtSdkMethodKeyDestroyChatRoomValue: [[ExtSdkChatroomManagerWrapper getInstance] destroyChatRoom:ps result:callback]; break;
            case ExtSdkMethodKeyChatRoomUpdateSubjectValue: [[ExtSdkChatroomManagerWrapper getInstance] chatRoomUpdateSubject:ps result:callback]; break;
            case ExtSdkMethodKeyChatRoomUpdateDescriptionValue: [[ExtSdkChatroomManagerWrapper getInstance] chatRoomUpdateDescription:ps result:callback]; break;
            case ExtSdkMethodKeyGetChatroomMemberListFromServerValue: [[ExtSdkChatroomManagerWrapper getInstance] getChatroomMemberListFromServer:ps result:callback]; break;
            case ExtSdkMethodKeyChatRoomMuteMembersValue: [[ExtSdkChatroomManagerWrapper getInstance] chatRoomMuteMembers:ps result:callback]; break;
            case ExtSdkMethodKeyChatRoomUnmuteMembersValue: [[ExtSdkChatroomManagerWrapper getInstance] chatRoomUnmuteMembers:ps result:callback]; break;
            case ExtSdkMethodKeyChangeChatRoomOwnerValue: [[ExtSdkChatroomManagerWrapper getInstance] changeChatRoomOwner:ps result:callback]; break;
            case ExtSdkMethodKeyChatRoomAddAdminValue: [[ExtSdkChatroomManagerWrapper getInstance] chatRoomAddAdmin:ps result:callback]; break;
            case ExtSdkMethodKeyChatRoomRemoveAdminValue: [[ExtSdkChatroomManagerWrapper getInstance] chatRoomRemoveAdmin:ps result:callback]; break;
            case ExtSdkMethodKeyGetChatroomMuteListFromServerValue: [[ExtSdkChatroomManagerWrapper getInstance] getChatroomMuteListFromServer:ps result:callback]; break;
            case ExtSdkMethodKeyChatRoomRemoveMembersValue: [[ExtSdkChatroomManagerWrapper getInstance] chatRoomRemoveMembers:ps result:callback]; break;
            case ExtSdkMethodKeyChatRoomBlockMembersValue: [[ExtSdkChatroomManagerWrapper getInstance] chatRoomBlockMembers:ps result:callback]; break;
            case ExtSdkMethodKeyChatRoomUnblockMembersValue: [[ExtSdkChatroomManagerWrapper getInstance] chatRoomUnblockMembers:ps result:callback]; break;
            case ExtSdkMethodKeyFetchChatroomBlockListFromServerValue: [[ExtSdkChatroomManagerWrapper getInstance] fetchChatroomBlockListFromServer:ps result:callback]; break;
            case ExtSdkMethodKeyUpdateChatRoomAnnouncementValue: [[ExtSdkChatroomManagerWrapper getInstance] updateChatRoomAnnouncement:ps result:callback]; break;
            case ExtSdkMethodKeyFetchChatroomAnnouncementValue: [[ExtSdkChatroomManagerWrapper getInstance] fetchChatroomAnnouncement:ps result:callback]; break;

            case ExtSdkMethodKeyAddMembersToChatRoomWhiteListValue: [[ExtSdkChatroomManagerWrapper getInstance] addMembersToChatRoomWhiteList:ps result:callback]; break;
            case ExtSdkMethodKeyRemoveMembersFromChatRoomWhiteListValue: [[ExtSdkChatroomManagerWrapper getInstance] removeMembersFromChatRoomWhiteList:ps result:callback]; break;
            case ExtSdkMethodKeyFetchChatRoomWhiteListFromServerValue: [[ExtSdkChatroomManagerWrapper getInstance] fetchChatRoomWhiteListFromServer:ps result:callback]; break;
            case ExtSdkMethodKeyIsMemberInChatRoomWhiteListFromServerValue: [[ExtSdkChatroomManagerWrapper getInstance] isMemberInChatRoomWhiteListFromServer:ps result:callback]; break;

            case ExtSdkMethodKeyMuteAllChatRoomMembersValue: [[ExtSdkChatroomManagerWrapper getInstance] muteAllChatRoomMembers:ps result:callback]; break;
            case ExtSdkMethodKeyUnMuteAllChatRoomMembersValue: [[ExtSdkChatroomManagerWrapper getInstance] unMuteAllChatRoomMembers:ps result:callback]; break;

            /// #pragma mark - EMChatroomManagerDelegate value
            case ExtSdkMethodKeyChatroomChangedValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;

            /// #pragma mark - EMGroupManagerWrapper value

            case ExtSdkMethodKeyGetGroupWithIdValue: [[ExtSdkGroupManagerWrapper getInstance] getGroupWithId: ps result:callback]; break; 
            case ExtSdkMethodKeyGetJoinedGroupsValue: [[ExtSdkGroupManagerWrapper getInstance] getJoinedGroups: ps result:callback]; break; 
            case ExtSdkMethodKeyGetGroupsWithoutPushNotificationValue: [[ExtSdkGroupManagerWrapper getInstance] getGroupsWithoutPushNotification: ps result:callback]; break; 
            case ExtSdkMethodKeyGetJoinedGroupsFromServerValue: [[ExtSdkGroupManagerWrapper getInstance] getJoinedGroupsFromServer: ps result:callback]; break; 
            case ExtSdkMethodKeyGetPublicGroupsFromServerValue: [[ExtSdkGroupManagerWrapper getInstance] getPublicGroupsFromServer: ps result:callback]; break; 
            case ExtSdkMethodKeyCreateGroupValue: [[ExtSdkGroupManagerWrapper getInstance] createGroup: ps result:callback]; break; 
            case ExtSdkMethodKeyGetGroupSpecificationFromServerValue: [[ExtSdkGroupManagerWrapper getInstance] getGroupSpecificationFromServer: ps result:callback]; break; 
            case ExtSdkMethodKeyGetGroupMemberListFromServerValue: [[ExtSdkGroupManagerWrapper getInstance] getGroupMemberListFromServer: ps result:callback]; break; 
            case ExtSdkMethodKeyGetGroupBlockListFromServerValue: [[ExtSdkGroupManagerWrapper getInstance] getGroupBlockListFromServer: ps result:callback]; break; 
            case ExtSdkMethodKeyGetGroupMuteListFromServerValue: [[ExtSdkGroupManagerWrapper getInstance] getGroupMuteListFromServer: ps result:callback]; break; 
            case ExtSdkMethodKeyGetGroupWhiteListFromServerValue: [[ExtSdkGroupManagerWrapper getInstance] getGroupWhiteListFromServer: ps result:callback]; break; 
            case ExtSdkMethodKeyIsMemberInWhiteListFromServerValue: [[ExtSdkGroupManagerWrapper getInstance] isMemberInWhiteListFromServer: ps result:callback]; break; 
            case ExtSdkMethodKeyGetGroupFileListFromServerValue: [[ExtSdkGroupManagerWrapper getInstance] getGroupFileListFromServer: ps result:callback]; break; 
            case ExtSdkMethodKeyGetGroupAnnouncementFromServerValue: [[ExtSdkGroupManagerWrapper getInstance] getGroupAnnouncementFromServer: ps result:callback]; break; 
            case ExtSdkMethodKeyAddMembersValue: [[ExtSdkGroupManagerWrapper getInstance] addMembers: ps result:callback]; break; 
            case ExtSdkMethodKeyInviterUserValue: [[ExtSdkGroupManagerWrapper getInstance] inviterUser: ps result:callback]; break; 
            case ExtSdkMethodKeyRemoveMembersValue: [[ExtSdkGroupManagerWrapper getInstance] removeMembers: ps result:callback]; break; 
            case ExtSdkMethodKeyBlockMembersValue: [[ExtSdkGroupManagerWrapper getInstance] blockMembers: ps result:callback]; break; 
            case ExtSdkMethodKeyUnblockMembersValue: [[ExtSdkGroupManagerWrapper getInstance] unblockMembers: ps result:callback]; break; 
            case ExtSdkMethodKeyUpdateGroupSubjectValue: [[ExtSdkGroupManagerWrapper getInstance] updateGroupSubject: ps result:callback]; break; 
            case ExtSdkMethodKeyUpdateDescriptionValue: [[ExtSdkGroupManagerWrapper getInstance] updateDescription: ps result:callback]; break; 
            case ExtSdkMethodKeyLeaveGroupValue: [[ExtSdkGroupManagerWrapper getInstance] leaveGroup: ps result:callback]; break; 
            case ExtSdkMethodKeyDestroyGroupValue: [[ExtSdkGroupManagerWrapper getInstance] destroyGroup: ps result:callback]; break; 
            case ExtSdkMethodKeyBlockGroupValue: [[ExtSdkGroupManagerWrapper getInstance] blockGroup: ps result:callback]; break; 
            case ExtSdkMethodKeyUnblockGroupValue: [[ExtSdkGroupManagerWrapper getInstance] unblockGroup: ps result:callback]; break; 
            case ExtSdkMethodKeyUpdateGroupOwnerValue: [[ExtSdkGroupManagerWrapper getInstance] updateGroupOwner: ps result:callback]; break; 
            case ExtSdkMethodKeyAddAdminValue: [[ExtSdkGroupManagerWrapper getInstance] addAdmin: ps result:callback]; break; 
            case ExtSdkMethodKeyRemoveAdminValue: [[ExtSdkGroupManagerWrapper getInstance] removeAdmin: ps result:callback]; break; 
            case ExtSdkMethodKeyMuteMembersValue: [[ExtSdkGroupManagerWrapper getInstance] muteMembers: ps result:callback]; break; 
            case ExtSdkMethodKeyUnMuteMembersValue: [[ExtSdkGroupManagerWrapper getInstance] unMuteMembers: ps result:callback]; break; 
            case ExtSdkMethodKeyMuteAllMembersValue: [[ExtSdkGroupManagerWrapper getInstance] muteAllMembers: ps result:callback]; break; 
            case ExtSdkMethodKeyUnMuteAllMembersValue: [[ExtSdkGroupManagerWrapper getInstance] unMuteAllMembers: ps result:callback]; break; 
            case ExtSdkMethodKeyAddWhiteListValue: [[ExtSdkGroupManagerWrapper getInstance] addWhiteList: ps result:callback]; break; 
            case ExtSdkMethodKeyRemoveWhiteListValue: [[ExtSdkGroupManagerWrapper getInstance] removeWhiteList: ps result:callback]; break; 
            case ExtSdkMethodKeyUploadGroupSharedFileValue: [[ExtSdkGroupManagerWrapper getInstance] uploadGroupSharedFile: ps result:callback]; break; 
            case ExtSdkMethodKeyDownloadGroupSharedFileValue: [[ExtSdkGroupManagerWrapper getInstance] downloadGroupSharedFile: ps result:callback]; break; 
            case ExtSdkMethodKeyRemoveGroupSharedFileValue: [[ExtSdkGroupManagerWrapper getInstance] removeGroupSharedFile: ps result:callback]; break; 
            case ExtSdkMethodKeyUpdateGroupAnnouncementValue: [[ExtSdkGroupManagerWrapper getInstance] updateGroupAnnouncement: ps result:callback]; break; 
            case ExtSdkMethodKeyUpdateGroupExtValue: [[ExtSdkGroupManagerWrapper getInstance] updateGroupExt: ps result:callback]; break; 
            case ExtSdkMethodKeyJoinPublicGroupValue: [[ExtSdkGroupManagerWrapper getInstance] joinPublicGroup: ps result:callback]; break; 
            case ExtSdkMethodKeyRequestToJoinPublicGroupValue: [[ExtSdkGroupManagerWrapper getInstance] requestToJoinPublicGroup: ps result:callback]; break; 
            case ExtSdkMethodKeyAcceptJoinApplicationValue: [[ExtSdkGroupManagerWrapper getInstance] acceptJoinApplication: ps result:callback]; break;
            case ExtSdkMethodKeyDeclineJoinApplicationValue: [[ExtSdkGroupManagerWrapper getInstance] declineJoinApplication: ps result:callback]; break; 
            case ExtSdkMethodKeyAcceptInvitationFromGroupValue: [[ExtSdkGroupManagerWrapper getInstance] acceptInvitationFromGroup: ps result:callback]; break; 
            case ExtSdkMethodKeyDeclineInvitationFromGroupValue: [[ExtSdkGroupManagerWrapper getInstance] declineInvitationFromGroup: ps result:callback]; break; 
            case ExtSdkMethodKeyIgnoreGroupPushValue: [[ExtSdkGroupManagerWrapper getInstance] ignoreGroupPush: ps result:callback]; break; 

            /// #pragma mark - ExtSdkGroupManagerDelegate
            case ExtSdkMethodKeyOnGroupChangedValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;

            /// #pragma mark - EMPushManagerWrapper value
            case ExtSdkMethodKeyGetImPushConfigValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyGetImPushConfigFromServerValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyUpdatePushNicknameValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;

            case ExtSdkMethodKeyImPushNoDisturbValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyUpdateImPushStyleValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyUpdateGroupPushServiceValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyGetNoDisturbGroupsValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyBindDeviceTokenValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;


            /// #pragma mark - EMUserInfoManagerWrapper value
            case ExtSdkMethodKeyUpdateOwnUserInfoValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyUpdateOwnUserInfoWithTypeValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyFetchUserInfoByIdValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;
            case ExtSdkMethodKeyFetchUserInfoByIdWithTypeValue: [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]]; break;

    default:
            [callback onFail:1 withExtension:[NSString stringWithFormat:@"not implement: %@", methodType]];
        break;
    }
}

- (void)delListener:(nonnull id<ExtSdkDelegateObjc>)listener {
    NSLog(@"%@: delListener:", TAG);
}

- (void)init:(nonnull id<NSObject>)config {
    NSLog(@"%@: init:", TAG);
}

- (void)unInit:(nullable id<NSObject>)params {
    NSLog(@"%@: unInit:", TAG);
}

- (void)onReceive:(nonnull NSString *)methodType
       withParams:(nullable NSObject *)params {
    NSLog(@"%@: onReceive: %@: %@", TAG, methodType, nil != params ? params : @"");
    [_listener onReceive:methodType withParams:params];
}

@end
