//
//  ExtSdkMethodType.m
//  im_flutter_sdk
//
//  Created by asterisk on 2022/3/11.
//

#import "ExtSdkMethodTypeObjc.h"

@implementation ExtSdkMethodTypeObjc

+ (int)getEnumValue:(nonnull NSString*)key {
    static NSDictionary * methodMap;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        methodMap =  @{
            
            
            /// EMClientWrapper
            ExtSdkMethodKeyInit: @(ExtSdkMethodKeyInitValue),
            ExtSdkMethodKeyCreateAccount: @(ExtSdkMethodKeyCreateAccountValue),
            ExtSdkMethodKeyLogin: @(ExtSdkMethodKeyLoginValue),
            ExtSdkMethodKeyLogout: @(ExtSdkMethodKeyLogoutValue),
            ExtSdkMethodKeyChangeAppKey: @(ExtSdkMethodKeyChangeAppKeyValue),
            ExtSdkMethodKeyIsLoggedInBefore: @(ExtSdkMethodKeyIsLoggedInBeforeValue),
            ExtSdkMethodKeyUploadLog: @(ExtSdkMethodKeyUploadLogValue),
            ExtSdkMethodKeyCompressLogs: @(ExtSdkMethodKeyCompressLogsValue),
            ExtSdkMethodKeyKickDevice: @(ExtSdkMethodKeyKickDeviceValue),
            ExtSdkMethodKeyKickAllDevices: @(ExtSdkMethodKeyKickAllDevicesValue),
            ExtSdkMethodKeyCurrentUser: @(ExtSdkMethodKeyCurrentUserValue),
            ExtSdkMethodKeyGetLoggedInDevicesFromServer: @(ExtSdkMethodKeyGetLoggedInDevicesFromServerValue),

            /// EMClientDelegate
            ExtSdkMethodKeyOnConnected: @(ExtSdkMethodKeyOnConnectedValue),
            ExtSdkMethodKeyOnDisconnected: @(ExtSdkMethodKeyOnDisconnectedValue),
            ExtSdkMethodKeyOnMultiDeviceEvent: @(ExtSdkMethodKeyOnMultiDeviceEventValue),

            ExtSdkMethodKeySendDataToFlutter: @(ExtSdkMethodKeySendDataToFlutterValue),

            /// EMContactManagerWrapper
            ExtSdkMethodKeyAddContact: @(ExtSdkMethodKeyAddContactValue),
            ExtSdkMethodKeyDeleteContact: @(ExtSdkMethodKeyDeleteContactValue),
            ExtSdkMethodKeyGetAllContactsFromServer: @(ExtSdkMethodKeyGetAllContactsFromServerValue),
            ExtSdkMethodKeyGetAllContactsFromDB: @(ExtSdkMethodKeyGetAllContactsFromDBValue),
            ExtSdkMethodKeyAddUserToBlockList: @(ExtSdkMethodKeyAddUserToBlockListValue),
            ExtSdkMethodKeyRemoveUserFromBlockList: @(ExtSdkMethodKeyRemoveUserFromBlockListValue),
            ExtSdkMethodKeyGetBlockListFromServer: @(ExtSdkMethodKeyGetBlockListFromServerValue),
            ExtSdkMethodKeyGetBlockListFromDB: @(ExtSdkMethodKeyGetBlockListFromDBValue),
            ExtSdkMethodKeyAcceptInvitation: @(ExtSdkMethodKeyAcceptInvitationValue),
            ExtSdkMethodKeyDeclineInvitation: @(ExtSdkMethodKeyDeclineInvitationValue),
            ExtSdkMethodKeyGetSelfIdsOnOtherPlatform: @(ExtSdkMethodKeyGetSelfIdsOnOtherPlatformValue),

            /// EMContactDelegate
            ExtSdkMethodKeyOnContactChanged: @(ExtSdkMethodKeyOnContactChangedValue),

            /// EMChatManagerWrapper
            ExtSdkMethodKeySendMessage: @(ExtSdkMethodKeySendMessageValue),
            ExtSdkMethodKeyResendMessage: @(ExtSdkMethodKeyResendMessageValue),
            ExtSdkMethodKeyAckMessageRead: @(ExtSdkMethodKeyAckMessageReadValue),
            ExtSdkMethodKeyAckGroupMessageRead: @(ExtSdkMethodKeyAckGroupMessageReadValue),
            ExtSdkMethodKeyAckConversationRead: @(ExtSdkMethodKeyAckConversationReadValue),
            ExtSdkMethodKeyRecallMessage: @(ExtSdkMethodKeyRecallMessageValue),
            ExtSdkMethodKeyGetConversation: @(ExtSdkMethodKeyGetConversationValue),
            ExtSdkMethodKeyMarkAllChatMsgAsRead: @(ExtSdkMethodKeyMarkAllChatMsgAsReadValue),
            ExtSdkMethodKeyGetUnreadMessageCount: @(ExtSdkMethodKeyGetUnreadMessageCountValue),
            ExtSdkMethodKeyUpdateChatMessage: @(ExtSdkMethodKeyUpdateChatMessageValue),
            ExtSdkMethodKeyDownloadAttachment: @(ExtSdkMethodKeyDownloadAttachmentValue),
            ExtSdkMethodKeyDownloadThumbnail: @(ExtSdkMethodKeyDownloadThumbnailValue),
            ExtSdkMethodKeyImportMessages: @(ExtSdkMethodKeyImportMessagesValue),
            ExtSdkMethodKeyLoadAllConversations: @(ExtSdkMethodKeyLoadAllConversationsValue),
            ExtSdkMethodKeyGetConversationsFromServer: @(ExtSdkMethodKeyGetConversationsFromServerValue),

            ExtSdkMethodKeyDeleteConversation: @(ExtSdkMethodKeyDeleteConversationValue),
            //ExtSdkMethodKeySetVoiceMessageListened: @(ExtSdkMethodKeySetVoiceMessageListenedValue),
            //ExtSdkMethodKeyUpdateParticipant: @(ExtSdkMethodKeyUpdateParticipantValue),
            ExtSdkMethodKeyUpdateConversationsName: @(ExtSdkMethodKeyUpdateConversationsNameValue),
            ExtSdkMethodKeyFetchHistoryMessages: @(ExtSdkMethodKeyFetchHistoryMessagesValue),
            ExtSdkMethodKeySearchChatMsgFromDB: @(ExtSdkMethodKeySearchChatMsgFromDBValue),
            ExtSdkMethodKeyGetMessage: @(ExtSdkMethodKeyGetMessageValue),
            ExtSdkMethodKeyAsyncFetchGroupAcks: @(ExtSdkMethodKeyAsyncFetchGroupAcksValue),

            /// EMChatManagerDelegate
            ExtSdkMethodKeyOnMessagesReceived: @(ExtSdkMethodKeyOnMessagesReceivedValue),
            ExtSdkMethodKeyOnCmdMessagesReceived: @(ExtSdkMethodKeyOnCmdMessagesReceivedValue),
            ExtSdkMethodKeyOnMessagesRead: @(ExtSdkMethodKeyOnMessagesReadValue),
            ExtSdkMethodKeyOnGroupMessageRead: @(ExtSdkMethodKeyOnGroupMessageReadValue),
            ExtSdkMethodKeyOnMessagesDelivered: @(ExtSdkMethodKeyOnMessagesDeliveredValue),
            ExtSdkMethodKeyOnMessagesRecalled: @(ExtSdkMethodKeyOnMessagesRecalledValue),

            ExtSdkMethodKeyOnConversationUpdate: @(ExtSdkMethodKeyOnConversationUpdateValue),
            ExtSdkMethodKeyOnConversationHasRead: @(ExtSdkMethodKeyOnConversationHasReadValue),

            /// EMMessageListener
            ExtSdkMethodKeyOnMessageProgressUpdate: @(ExtSdkMethodKeyOnMessageProgressUpdateValue),
            ExtSdkMethodKeyOnMessageSuccess: @(ExtSdkMethodKeyOnMessageSuccessValue),
            ExtSdkMethodKeyOnMessageError: @(ExtSdkMethodKeyOnMessageErrorValue),
            ExtSdkMethodKeyOnMessageReadAck: @(ExtSdkMethodKeyOnMessageReadAckValue),
            ExtSdkMethodKeyOnMessageDeliveryAck: @(ExtSdkMethodKeyOnMessageDeliveryAckValue),
            ExtSdkMethodKeyOnMessageStatusChanged: @(ExtSdkMethodKeyOnMessageStatusChangedValue),

            /// EMConversationWrapper

            ExtSdkMethodKeyGetUnreadMsgCount: @(ExtSdkMethodKeyGetUnreadMsgCountValue),
            ExtSdkMethodKeyMarkAllMsgsAsRead: @(ExtSdkMethodKeyMarkAllMsgsAsReadValue),
            ExtSdkMethodKeyMarkMsgAsRead: @(ExtSdkMethodKeyMarkMsgAsReadValue),
            ExtSdkMethodKeySyncConversationExt: @(ExtSdkMethodKeySyncConversationExtValue),
            ExtSdkMethodKeySyncConversationName: @(ExtSdkMethodKeySyncConversationNameValue),
            ExtSdkMethodKeyRemoveMsg: @(ExtSdkMethodKeyRemoveMsgValue),
            ExtSdkMethodKeyGetLatestMsg: @(ExtSdkMethodKeyGetLatestMsgValue),
            ExtSdkMethodKeyGetLatestMsgFromOthers: @(ExtSdkMethodKeyGetLatestMsgFromOthersValue),
            ExtSdkMethodKeyClearAllMsg: @(ExtSdkMethodKeyClearAllMsgValue),
            ExtSdkMethodKeyInsertMsg: @(ExtSdkMethodKeyInsertMsgValue),
            ExtSdkMethodKeyAppendMsg: @(ExtSdkMethodKeyAppendMsgValue),
            ExtSdkMethodKeyUpdateConversationMsg: @(ExtSdkMethodKeyUpdateConversationMsgValue),

            ExtSdkMethodKeyLoadMsgWithId: @(ExtSdkMethodKeyLoadMsgWithIdValue),
            ExtSdkMethodKeyLoadMsgWithStartId: @(ExtSdkMethodKeyLoadMsgWithStartIdValue),
            ExtSdkMethodKeyLoadMsgWithKeywords: @(ExtSdkMethodKeyLoadMsgWithKeywordsValue),
            ExtSdkMethodKeyLoadMsgWithMsgType: @(ExtSdkMethodKeyLoadMsgWithMsgTypeValue),
            ExtSdkMethodKeyLoadMsgWithTime: @(ExtSdkMethodKeyLoadMsgWithTimeValue),

            /// EMChatroomManagerWrapper

            ExtSdkMethodKeyJoinChatRoom: @(ExtSdkMethodKeyJoinChatRoomValue),
            ExtSdkMethodKeyLeaveChatRoom: @(ExtSdkMethodKeyLeaveChatRoomValue),
            ExtSdkMethodKeyGetChatroomsFromServer: @(ExtSdkMethodKeyGetChatroomsFromServerValue),
            ExtSdkMethodKeyFetchChatRoomFromServer: @(ExtSdkMethodKeyFetchChatRoomFromServerValue),
            ExtSdkMethodKeyGetChatRoom: @(ExtSdkMethodKeyGetChatRoomValue),
            ExtSdkMethodKeyGetAllChatRooms: @(ExtSdkMethodKeyGetAllChatRoomsValue),
            ExtSdkMethodKeyCreateChatRoom: @(ExtSdkMethodKeyCreateChatRoomValue),
            ExtSdkMethodKeyDestroyChatRoom: @(ExtSdkMethodKeyDestroyChatRoomValue),
            ExtSdkMethodKeyChatRoomUpdateSubject: @(ExtSdkMethodKeyChatRoomUpdateSubjectValue),
            ExtSdkMethodKeyChatRoomUpdateDescription: @(ExtSdkMethodKeyChatRoomUpdateDescriptionValue),
            ExtSdkMethodKeyGetChatroomMemberListFromServer: @(ExtSdkMethodKeyGetChatroomMemberListFromServerValue),
            ExtSdkMethodKeyChatRoomMuteMembers: @(ExtSdkMethodKeyChatRoomMuteMembersValue),
            ExtSdkMethodKeyChatRoomUnmuteMembers: @(ExtSdkMethodKeyChatRoomUnmuteMembersValue),
            ExtSdkMethodKeyChangeChatRoomOwner: @(ExtSdkMethodKeyChangeChatRoomOwnerValue),
            ExtSdkMethodKeyChatRoomAddAdmin: @(ExtSdkMethodKeyChatRoomAddAdminValue),
            ExtSdkMethodKeyChatRoomRemoveAdmin: @(ExtSdkMethodKeyChatRoomRemoveAdminValue),
            ExtSdkMethodKeyGetChatroomMuteListFromServer: @(ExtSdkMethodKeyGetChatroomMuteListFromServerValue),
            ExtSdkMethodKeyChatRoomRemoveMembers: @(ExtSdkMethodKeyChatRoomRemoveMembersValue),
            ExtSdkMethodKeyChatRoomBlockMembers: @(ExtSdkMethodKeyChatRoomBlockMembersValue),
            ExtSdkMethodKeyChatRoomUnblockMembers: @(ExtSdkMethodKeyChatRoomUnblockMembersValue),
            ExtSdkMethodKeyFetchChatroomBlockListFromServer: @(ExtSdkMethodKeyFetchChatroomBlockListFromServerValue),
            ExtSdkMethodKeyUpdateChatRoomAnnouncement: @(ExtSdkMethodKeyUpdateChatRoomAnnouncementValue),
            ExtSdkMethodKeyFetchChatroomAnnouncement: @(ExtSdkMethodKeyFetchChatroomAnnouncementValue),

            ExtSdkMethodKeyAddMembersToChatRoomWhiteList: @(ExtSdkMethodKeyAddMembersToChatRoomWhiteListValue),
            ExtSdkMethodKeyRemoveMembersFromChatRoomWhiteList: @(ExtSdkMethodKeyRemoveMembersFromChatRoomWhiteListValue),
            ExtSdkMethodKeyFetchChatRoomWhiteListFromServer: @(ExtSdkMethodKeyFetchChatRoomWhiteListFromServerValue),
            ExtSdkMethodKeyIsMemberInChatRoomWhiteListFromServer: @(ExtSdkMethodKeyIsMemberInChatRoomWhiteListFromServerValue),

            ExtSdkMethodKeyMuteAllChatRoomMembers: @(ExtSdkMethodKeyMuteAllChatRoomMembersValue),
            ExtSdkMethodKeyUnMuteAllChatRoomMembers: @(ExtSdkMethodKeyUnMuteAllChatRoomMembersValue),


            ExtSdkMethodKeyChatroomChanged: @(ExtSdkMethodKeyChatroomChangedValue),

            /// EMGroupManagerWrapper

            ExtSdkMethodKeyGetGroupWithId: @(ExtSdkMethodKeyGetGroupWithIdValue),
            ExtSdkMethodKeyGetJoinedGroups: @(ExtSdkMethodKeyGetJoinedGroupsValue),
            ExtSdkMethodKeyGetGroupsWithoutPushNotification: @(ExtSdkMethodKeyGetGroupsWithoutPushNotificationValue),
            ExtSdkMethodKeyGetJoinedGroupsFromServer: @(ExtSdkMethodKeyGetJoinedGroupsFromServerValue),
            ExtSdkMethodKeyGetPublicGroupsFromServer: @(ExtSdkMethodKeyGetPublicGroupsFromServerValue),
            ExtSdkMethodKeyCreateGroup: @(ExtSdkMethodKeyCreateGroupValue),
            ExtSdkMethodKeyGetGroupSpecificationFromServer: @(ExtSdkMethodKeyGetGroupSpecificationFromServerValue),
            ExtSdkMethodKeyGetGroupMemberListFromServer: @(ExtSdkMethodKeyGetGroupMemberListFromServerValue),
            ExtSdkMethodKeyGetGroupBlockListFromServer: @(ExtSdkMethodKeyGetGroupBlockListFromServerValue),
            ExtSdkMethodKeyGetGroupMuteListFromServer: @(ExtSdkMethodKeyGetGroupMuteListFromServerValue),
            ExtSdkMethodKeyGetGroupWhiteListFromServer: @(ExtSdkMethodKeyGetGroupWhiteListFromServerValue),
            ExtSdkMethodKeyIsMemberInWhiteListFromServer: @(ExtSdkMethodKeyIsMemberInWhiteListFromServerValue),
            ExtSdkMethodKeyGetGroupFileListFromServer: @(ExtSdkMethodKeyGetGroupFileListFromServerValue),
            ExtSdkMethodKeyGetGroupAnnouncementFromServer: @(ExtSdkMethodKeyGetGroupAnnouncementFromServerValue),
            ExtSdkMethodKeyAddMembers: @(ExtSdkMethodKeyAddMembersValue),
            ExtSdkMethodKeyInviterUser: @(ExtSdkMethodKeyInviterUserValue),
            ExtSdkMethodKeyRemoveMembers: @(ExtSdkMethodKeyRemoveMembersValue),
            ExtSdkMethodKeyBlockMembers: @(ExtSdkMethodKeyBlockMembersValue),
            ExtSdkMethodKeyUnblockMembers: @(ExtSdkMethodKeyUnblockMembersValue),
            ExtSdkMethodKeyUpdateGroupSubject: @(ExtSdkMethodKeyUpdateGroupSubjectValue),
            ExtSdkMethodKeyUpdateDescription: @(ExtSdkMethodKeyUpdateDescriptionValue),
            ExtSdkMethodKeyLeaveGroup: @(ExtSdkMethodKeyLeaveGroupValue),
            ExtSdkMethodKeyDestroyGroup: @(ExtSdkMethodKeyDestroyGroupValue),
            ExtSdkMethodKeyBlockGroup: @(ExtSdkMethodKeyBlockGroupValue),
            ExtSdkMethodKeyUnblockGroup: @(ExtSdkMethodKeyUnblockGroupValue),
            ExtSdkMethodKeyUpdateGroupOwner: @(ExtSdkMethodKeyUpdateGroupOwnerValue),
            ExtSdkMethodKeyAddAdmin: @(ExtSdkMethodKeyAddAdminValue),
            ExtSdkMethodKeyRemoveAdmin: @(ExtSdkMethodKeyRemoveAdminValue),
            ExtSdkMethodKeyMuteMembers: @(ExtSdkMethodKeyMuteMembersValue),
            ExtSdkMethodKeyUnMuteMembers: @(ExtSdkMethodKeyUnMuteMembersValue),
            ExtSdkMethodKeyMuteAllMembers: @(ExtSdkMethodKeyMuteAllMembersValue),
            ExtSdkMethodKeyUnMuteAllMembers: @(ExtSdkMethodKeyUnMuteAllMembersValue),
            ExtSdkMethodKeyAddWhiteList: @(ExtSdkMethodKeyAddWhiteListValue),
            ExtSdkMethodKeyRemoveWhiteList: @(ExtSdkMethodKeyRemoveWhiteListValue),
            ExtSdkMethodKeyUploadGroupSharedFile: @(ExtSdkMethodKeyUploadGroupSharedFileValue),
            ExtSdkMethodKeyDownloadGroupSharedFile: @(ExtSdkMethodKeyDownloadGroupSharedFileValue),
            ExtSdkMethodKeyRemoveGroupSharedFile: @(ExtSdkMethodKeyRemoveGroupSharedFileValue),
            ExtSdkMethodKeyUpdateGroupAnnouncement: @(ExtSdkMethodKeyUpdateGroupAnnouncementValue),
            ExtSdkMethodKeyUpdateGroupExt: @(ExtSdkMethodKeyUpdateGroupExtValue),
            ExtSdkMethodKeyJoinPublicGroup: @(ExtSdkMethodKeyJoinPublicGroupValue),
            ExtSdkMethodKeyRequestToJoinPublicGroup: @(ExtSdkMethodKeyRequestToJoinPublicGroupValue),
            ExtSdkMethodKeyAcceptJoinApplication: @(ExtSdkMethodKeyAcceptJoinApplicationValue),
            ExtSdkMethodKeyDeclineJoinApplication: @(ExtSdkMethodKeyDeclineJoinApplicationValue),
            ExtSdkMethodKeyAcceptInvitationFromGroup: @(ExtSdkMethodKeyAcceptInvitationFromGroupValue),
            ExtSdkMethodKeyDeclineInvitationFromGroup: @(ExtSdkMethodKeyDeclineInvitationFromGroupValue),
            ExtSdkMethodKeyIgnoreGroupPush: @(ExtSdkMethodKeyIgnoreGroupPushValue),

            ExtSdkMethodKeyOnGroupChanged: @(ExtSdkMethodKeyOnGroupChangedValue),

            /// EMPushManagerWrapper
            ExtSdkMethodKeyGetImPushConfig: @(ExtSdkMethodKeyGetImPushConfigValue),
            ExtSdkMethodKeyGetImPushConfigFromServer: @(ExtSdkMethodKeyGetImPushConfigFromServerValue),
            ExtSdkMethodKeyUpdatePushNickname: @(ExtSdkMethodKeyUpdatePushNicknameValue),

            ExtSdkMethodKeyImPushNoDisturb: @(ExtSdkMethodKeyImPushNoDisturbValue),
            ExtSdkMethodKeyUpdateImPushStyle: @(ExtSdkMethodKeyUpdateImPushStyleValue),
            ExtSdkMethodKeyUpdateGroupPushService: @(ExtSdkMethodKeyUpdateGroupPushServiceValue),
            ExtSdkMethodKeyGetNoDisturbGroups: @(ExtSdkMethodKeyGetNoDisturbGroupsValue),
            ExtSdkMethodKeyBindDeviceToken: @(ExtSdkMethodKeyBindDeviceTokenValue),


            /// EMUserInfoManagerWrapper
            ExtSdkMethodKeyUpdateOwnUserInfo: @(ExtSdkMethodKeyUpdateOwnUserInfoValue),
            ExtSdkMethodKeyUpdateOwnUserInfoWithType: @(ExtSdkMethodKeyUpdateOwnUserInfoWithTypeValue),
            ExtSdkMethodKeyFetchUserInfoById: @(ExtSdkMethodKeyFetchUserInfoByIdValue),
            ExtSdkMethodKeyFetchUserInfoByIdWithType: @(ExtSdkMethodKeyFetchUserInfoByIdWithTypeValue),



        };
    });
    if (nil != key) {
        NSNumber* value = [methodMap valueForKey:key];
        if (nil != value) {
            return [value intValue];
        }
    }
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"invoke method type is not exist: %@", key]
                                 userInfo:nil];
}
//
//- (int)getValue {
//    return 0;
//}
//
//- (void)test {
//    switch ([ExtSdkMethodType getEnumValue:(ExtSdkMethodKeyGetJoinedGroups)]) {
//        case 1:
//
//            break;
//        case 2:
//
//            break;
//        case ExtSdkMethodKeyGetJoinedGroupsValue:
//
//            break;
//        default:
//            break;
//    }
//}

@end
