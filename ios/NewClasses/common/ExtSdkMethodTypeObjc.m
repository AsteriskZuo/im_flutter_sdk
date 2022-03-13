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
            ExtSDkMethodKeyInit: @(ExtSDkMethodKeyInitValue),
            ExtSDkMethodKeyCreateAccount: @(ExtSDkMethodKeyCreateAccountValue),
            ExtSDkMethodKeyLogin: @(ExtSDkMethodKeyLoginValue),
            ExtSDkMethodKeyLogout: @(ExtSDkMethodKeyLogoutValue),
            ExtSDkMethodKeyChangeAppKey: @(ExtSDkMethodKeyChangeAppKeyValue),
            ExtSDkMethodKeyIsLoggedInBefore: @(ExtSDkMethodKeyIsLoggedInBeforeValue),
            ExtSDkMethodKeyUploadLog: @(ExtSDkMethodKeyUploadLogValue),
            ExtSDkMethodKeyCompressLogs: @(ExtSDkMethodKeyCompressLogsValue),
            ExtSDkMethodKeyKickDevice: @(ExtSDkMethodKeyKickDeviceValue),
            ExtSDkMethodKeyKickAllDevices: @(ExtSDkMethodKeyKickAllDevicesValue),
            ExtSDkMethodKeyCurrentUser: @(ExtSDkMethodKeyCurrentUserValue),
            ExtSDkMethodKeyGetLoggedInDevicesFromServer: @(ExtSDkMethodKeyGetLoggedInDevicesFromServerValue),

            /// EMClientDelegate
            ExtSDkMethodKeyOnConnected: @(ExtSDkMethodKeyOnConnectedValue),
            ExtSDkMethodKeyOnDisconnected: @(ExtSDkMethodKeyOnDisconnectedValue),
            ExtSDkMethodKeyOnMultiDeviceEvent: @(ExtSDkMethodKeyOnMultiDeviceEventValue),

            ExtSDkMethodKeySendDataToFlutter: @(ExtSDkMethodKeySendDataToFlutterValue),

            /// EMContactManagerWrapper
            ExtSDkMethodKeyAddContact: @(ExtSDkMethodKeyAddContactValue),
            ExtSDkMethodKeyDeleteContact: @(ExtSDkMethodKeyDeleteContactValue),
            ExtSDkMethodKeyGetAllContactsFromServer: @(ExtSDkMethodKeyGetAllContactsFromServerValue),
            ExtSDkMethodKeyGetAllContactsFromDB: @(ExtSDkMethodKeyGetAllContactsFromDBValue),
            ExtSDkMethodKeyAddUserToBlockList: @(ExtSDkMethodKeyAddUserToBlockListValue),
            ExtSDkMethodKeyRemoveUserFromBlockList: @(ExtSDkMethodKeyRemoveUserFromBlockListValue),
            ExtSDkMethodKeyGetBlockListFromServer: @(ExtSDkMethodKeyGetBlockListFromServerValue),
            ExtSDkMethodKeyGetBlockListFromDB: @(ExtSDkMethodKeyGetBlockListFromDBValue),
            ExtSDkMethodKeyAcceptInvitation: @(ExtSDkMethodKeyAcceptInvitationValue),
            ExtSDkMethodKeyDeclineInvitation: @(ExtSDkMethodKeyDeclineInvitationValue),
            ExtSDkMethodKeyGetSelfIdsOnOtherPlatform: @(ExtSDkMethodKeyGetSelfIdsOnOtherPlatformValue),

            /// EMContactDelegate
            ExtSDkMethodKeyOnContactChanged: @(ExtSDkMethodKeyOnContactChangedValue),

            /// EMChatManagerWrapper
            ExtSDkMethodKeySendMessage: @(ExtSDkMethodKeySendMessageValue),
            ExtSDkMethodKeyResendMessage: @(ExtSDkMethodKeyResendMessageValue),
            ExtSDkMethodKeyAckMessageRead: @(ExtSDkMethodKeyAckMessageReadValue),
            ExtSDkMethodKeyAckGroupMessageRead: @(ExtSDkMethodKeyAckGroupMessageReadValue),
            ExtSDkMethodKeyAckConversationRead: @(ExtSDkMethodKeyAckConversationReadValue),
            ExtSDkMethodKeyRecallMessage: @(ExtSDkMethodKeyRecallMessageValue),
            ExtSDkMethodKeyGetConversation: @(ExtSDkMethodKeyGetConversationValue),
            ExtSDkMethodKeyMarkAllChatMsgAsRead: @(ExtSDkMethodKeyMarkAllChatMsgAsReadValue),
            ExtSDkMethodKeyGetUnreadMessageCount: @(ExtSDkMethodKeyGetUnreadMessageCountValue),
            ExtSDkMethodKeyUpdateChatMessage: @(ExtSDkMethodKeyUpdateChatMessageValue),
            ExtSDkMethodKeyDownloadAttachment: @(ExtSDkMethodKeyDownloadAttachmentValue),
            ExtSDkMethodKeyDownloadThumbnail: @(ExtSDkMethodKeyDownloadThumbnailValue),
            ExtSDkMethodKeyImportMessages: @(ExtSDkMethodKeyImportMessagesValue),
            ExtSDkMethodKeyLoadAllConversations: @(ExtSDkMethodKeyLoadAllConversationsValue),
            ExtSDkMethodKeyGetConversationsFromServer: @(ExtSDkMethodKeyGetConversationsFromServerValue),

            ExtSDkMethodKeyDeleteConversation: @(ExtSDkMethodKeyDeleteConversationValue),
            //ExtSDkMethodKeySetVoiceMessageListened: @(ExtSDkMethodKeySetVoiceMessageListenedValue),
            //ExtSDkMethodKeyUpdateParticipant: @(ExtSDkMethodKeyUpdateParticipantValue),
            ExtSDkMethodKeyUpdateConversationsName: @(ExtSDkMethodKeyUpdateConversationsNameValue),
            ExtSDkMethodKeyFetchHistoryMessages: @(ExtSDkMethodKeyFetchHistoryMessagesValue),
            ExtSDkMethodKeySearchChatMsgFromDB: @(ExtSDkMethodKeySearchChatMsgFromDBValue),
            ExtSDkMethodKeyGetMessage: @(ExtSDkMethodKeyGetMessageValue),
            ExtSDkMethodKeyAsyncFetchGroupAcks: @(ExtSDkMethodKeyAsyncFetchGroupAcksValue),

            /// EMChatManagerDelegate
            ExtSDkMethodKeyOnMessagesReceived: @(ExtSDkMethodKeyOnMessagesReceivedValue),
            ExtSDkMethodKeyOnCmdMessagesReceived: @(ExtSDkMethodKeyOnCmdMessagesReceivedValue),
            ExtSDkMethodKeyOnMessagesRead: @(ExtSDkMethodKeyOnMessagesReadValue),
            ExtSDkMethodKeyOnGroupMessageRead: @(ExtSDkMethodKeyOnGroupMessageReadValue),
            ExtSDkMethodKeyOnMessagesDelivered: @(ExtSDkMethodKeyOnMessagesDeliveredValue),
            ExtSDkMethodKeyOnMessagesRecalled: @(ExtSDkMethodKeyOnMessagesRecalledValue),

            ExtSDkMethodKeyOnConversationUpdate: @(ExtSDkMethodKeyOnConversationUpdateValue),
            ExtSDkMethodKeyOnConversationHasRead: @(ExtSDkMethodKeyOnConversationHasReadValue),

            /// EMMessageListener
            ExtSDkMethodKeyOnMessageProgressUpdate: @(ExtSDkMethodKeyOnMessageProgressUpdateValue),
            ExtSDkMethodKeyOnMessageSuccess: @(ExtSDkMethodKeyOnMessageSuccessValue),
            ExtSDkMethodKeyOnMessageError: @(ExtSDkMethodKeyOnMessageErrorValue),
            ExtSDkMethodKeyOnMessageReadAck: @(ExtSDkMethodKeyOnMessageReadAckValue),
            ExtSDkMethodKeyOnMessageDeliveryAck: @(ExtSDkMethodKeyOnMessageDeliveryAckValue),
            ExtSDkMethodKeyOnMessageStatusChanged: @(ExtSDkMethodKeyOnMessageStatusChangedValue),

            /// EMConversationWrapper

            ExtSDkMethodKeyGetUnreadMsgCount: @(ExtSDkMethodKeyGetUnreadMsgCountValue),
            ExtSDkMethodKeyMarkAllMsgsAsRead: @(ExtSDkMethodKeyMarkAllMsgsAsReadValue),
            ExtSDkMethodKeyMarkMsgAsRead: @(ExtSDkMethodKeyMarkMsgAsReadValue),
            ExtSDkMethodKeySyncConversationExt: @(ExtSDkMethodKeySyncConversationExtValue),
            ExtSDkMethodKeySyncConversationName: @(ExtSDkMethodKeySyncConversationNameValue),
            ExtSDkMethodKeyRemoveMsg: @(ExtSDkMethodKeyRemoveMsgValue),
            ExtSDkMethodKeyGetLatestMsg: @(ExtSDkMethodKeyGetLatestMsgValue),
            ExtSDkMethodKeyGetLatestMsgFromOthers: @(ExtSDkMethodKeyGetLatestMsgFromOthersValue),
            ExtSDkMethodKeyClearAllMsg: @(ExtSDkMethodKeyClearAllMsgValue),
            ExtSDkMethodKeyInsertMsg: @(ExtSDkMethodKeyInsertMsgValue),
            ExtSDkMethodKeyAppendMsg: @(ExtSDkMethodKeyAppendMsgValue),
            ExtSDkMethodKeyUpdateConversationMsg: @(ExtSDkMethodKeyUpdateConversationMsgValue),

            ExtSDkMethodKeyLoadMsgWithId: @(ExtSDkMethodKeyLoadMsgWithIdValue),
            ExtSDkMethodKeyLoadMsgWithStartId: @(ExtSDkMethodKeyLoadMsgWithStartIdValue),
            ExtSDkMethodKeyLoadMsgWithKeywords: @(ExtSDkMethodKeyLoadMsgWithKeywordsValue),
            ExtSDkMethodKeyLoadMsgWithMsgType: @(ExtSDkMethodKeyLoadMsgWithMsgTypeValue),
            ExtSDkMethodKeyLoadMsgWithTime: @(ExtSDkMethodKeyLoadMsgWithTimeValue),

            /// EMChatroomManagerWrapper

            ExtSDkMethodKeyJoinChatRoom: @(ExtSDkMethodKeyJoinChatRoomValue),
            ExtSDkMethodKeyLeaveChatRoom: @(ExtSDkMethodKeyLeaveChatRoomValue),
            ExtSDkMethodKeyGetChatroomsFromServer: @(ExtSDkMethodKeyGetChatroomsFromServerValue),
            ExtSDkMethodKeyFetchChatRoomFromServer: @(ExtSDkMethodKeyFetchChatRoomFromServerValue),
            ExtSDkMethodKeyGetChatRoom: @(ExtSDkMethodKeyGetChatRoomValue),
            ExtSDkMethodKeyGetAllChatRooms: @(ExtSDkMethodKeyGetAllChatRoomsValue),
            ExtSDkMethodKeyCreateChatRoom: @(ExtSDkMethodKeyCreateChatRoomValue),
            ExtSDkMethodKeyDestroyChatRoom: @(ExtSDkMethodKeyDestroyChatRoomValue),
            ExtSDkMethodKeyChatRoomUpdateSubject: @(ExtSDkMethodKeyChatRoomUpdateSubjectValue),
            ExtSDkMethodKeyChatRoomUpdateDescription: @(ExtSDkMethodKeyChatRoomUpdateDescriptionValue),
            ExtSDkMethodKeyGetChatroomMemberListFromServer: @(ExtSDkMethodKeyGetChatroomMemberListFromServerValue),
            ExtSDkMethodKeyChatRoomMuteMembers: @(ExtSDkMethodKeyChatRoomMuteMembersValue),
            ExtSDkMethodKeyChatRoomUnmuteMembers: @(ExtSDkMethodKeyChatRoomUnmuteMembersValue),
            ExtSDkMethodKeyChangeChatRoomOwner: @(ExtSDkMethodKeyChangeChatRoomOwnerValue),
            ExtSDkMethodKeyChatRoomAddAdmin: @(ExtSDkMethodKeyChatRoomAddAdminValue),
            ExtSDkMethodKeyChatRoomRemoveAdmin: @(ExtSDkMethodKeyChatRoomRemoveAdminValue),
            ExtSDkMethodKeyGetChatroomMuteListFromServer: @(ExtSDkMethodKeyGetChatroomMuteListFromServerValue),
            ExtSDkMethodKeyChatRoomRemoveMembers: @(ExtSDkMethodKeyChatRoomRemoveMembersValue),
            ExtSDkMethodKeyChatRoomBlockMembers: @(ExtSDkMethodKeyChatRoomBlockMembersValue),
            ExtSDkMethodKeyChatRoomUnblockMembers: @(ExtSDkMethodKeyChatRoomUnblockMembersValue),
            ExtSDkMethodKeyFetchChatroomBlockListFromServer: @(ExtSDkMethodKeyFetchChatroomBlockListFromServerValue),
            ExtSDkMethodKeyUpdateChatRoomAnnouncement: @(ExtSDkMethodKeyUpdateChatRoomAnnouncementValue),
            ExtSDkMethodKeyFetchChatroomAnnouncement: @(ExtSDkMethodKeyFetchChatroomAnnouncementValue),

            ExtSDkMethodKeyAddMembersToChatRoomWhiteList: @(ExtSDkMethodKeyAddMembersToChatRoomWhiteListValue),
            ExtSDkMethodKeyRemoveMembersFromChatRoomWhiteList: @(ExtSDkMethodKeyRemoveMembersFromChatRoomWhiteListValue),
            ExtSDkMethodKeyFetchChatRoomWhiteListFromServer: @(ExtSDkMethodKeyFetchChatRoomWhiteListFromServerValue),
            ExtSDkMethodKeyIsMemberInChatRoomWhiteListFromServer: @(ExtSDkMethodKeyIsMemberInChatRoomWhiteListFromServerValue),

            ExtSDkMethodKeyMuteAllChatRoomMembers: @(ExtSDkMethodKeyMuteAllChatRoomMembersValue),
            ExtSDkMethodKeyUnMuteAllChatRoomMembers: @(ExtSDkMethodKeyUnMuteAllChatRoomMembersValue),


            ExtSDkMethodKeyChatroomChanged: @(ExtSDkMethodKeyChatroomChangedValue),

            /// EMGroupManagerWrapper

            ExtSDkMethodKeyGetGroupWithId: @(ExtSDkMethodKeyGetGroupWithIdValue),
            ExtSDkMethodKeyGetJoinedGroups: @(ExtSDkMethodKeyGetJoinedGroupsValue),
            ExtSDkMethodKeyGetGroupsWithoutPushNotification: @(ExtSDkMethodKeyGetGroupsWithoutPushNotificationValue),
            ExtSDkMethodKeyGetJoinedGroupsFromServer: @(ExtSDkMethodKeyGetJoinedGroupsFromServerValue),
            ExtSDkMethodKeyGetPublicGroupsFromServer: @(ExtSDkMethodKeyGetPublicGroupsFromServerValue),
            ExtSDkMethodKeyCreateGroup: @(ExtSDkMethodKeyCreateGroupValue),
            ExtSDkMethodKeyGetGroupSpecificationFromServer: @(ExtSDkMethodKeyGetGroupSpecificationFromServerValue),
            ExtSDkMethodKeyGetGroupMemberListFromServer: @(ExtSDkMethodKeyGetGroupMemberListFromServerValue),
            ExtSDkMethodKeyGetGroupBlockListFromServer: @(ExtSDkMethodKeyGetGroupBlockListFromServerValue),
            ExtSDkMethodKeyGetGroupMuteListFromServer: @(ExtSDkMethodKeyGetGroupMuteListFromServerValue),
            ExtSDkMethodKeyGetGroupWhiteListFromServer: @(ExtSDkMethodKeyGetGroupWhiteListFromServerValue),
            ExtSDkMethodKeyIsMemberInWhiteListFromServer: @(ExtSDkMethodKeyIsMemberInWhiteListFromServerValue),
            ExtSDkMethodKeyGetGroupFileListFromServer: @(ExtSDkMethodKeyGetGroupFileListFromServerValue),
            ExtSDkMethodKeyGetGroupAnnouncementFromServer: @(ExtSDkMethodKeyGetGroupAnnouncementFromServerValue),
            ExtSDkMethodKeyAddMembers: @(ExtSDkMethodKeyAddMembersValue),
            ExtSDkMethodKeyInviterUser: @(ExtSDkMethodKeyInviterUserValue),
            ExtSDkMethodKeyRemoveMembers: @(ExtSDkMethodKeyRemoveMembersValue),
            ExtSDkMethodKeyBlockMembers: @(ExtSDkMethodKeyBlockMembersValue),
            ExtSDkMethodKeyUnblockMembers: @(ExtSDkMethodKeyUnblockMembersValue),
            ExtSDkMethodKeyUpdateGroupSubject: @(ExtSDkMethodKeyUpdateGroupSubjectValue),
            ExtSDkMethodKeyUpdateDescription: @(ExtSDkMethodKeyUpdateDescriptionValue),
            ExtSDkMethodKeyLeaveGroup: @(ExtSDkMethodKeyLeaveGroupValue),
            ExtSDkMethodKeyDestroyGroup: @(ExtSDkMethodKeyDestroyGroupValue),
            ExtSDkMethodKeyBlockGroup: @(ExtSDkMethodKeyBlockGroupValue),
            ExtSDkMethodKeyUnblockGroup: @(ExtSDkMethodKeyUnblockGroupValue),
            ExtSDkMethodKeyUpdateGroupOwner: @(ExtSDkMethodKeyUpdateGroupOwnerValue),
            ExtSDkMethodKeyAddAdmin: @(ExtSDkMethodKeyAddAdminValue),
            ExtSDkMethodKeyRemoveAdmin: @(ExtSDkMethodKeyRemoveAdminValue),
            ExtSDkMethodKeyMuteMembers: @(ExtSDkMethodKeyMuteMembersValue),
            ExtSDkMethodKeyUnMuteMembers: @(ExtSDkMethodKeyUnMuteMembersValue),
            ExtSDkMethodKeyMuteAllMembers: @(ExtSDkMethodKeyMuteAllMembersValue),
            ExtSDkMethodKeyUnMuteAllMembers: @(ExtSDkMethodKeyUnMuteAllMembersValue),
            ExtSDkMethodKeyAddWhiteList: @(ExtSDkMethodKeyAddWhiteListValue),
            ExtSDkMethodKeyRemoveWhiteList: @(ExtSDkMethodKeyRemoveWhiteListValue),
            ExtSDkMethodKeyUploadGroupSharedFile: @(ExtSDkMethodKeyUploadGroupSharedFileValue),
            ExtSDkMethodKeyDownloadGroupSharedFile: @(ExtSDkMethodKeyDownloadGroupSharedFileValue),
            ExtSDkMethodKeyRemoveGroupSharedFile: @(ExtSDkMethodKeyRemoveGroupSharedFileValue),
            ExtSDkMethodKeyUpdateGroupAnnouncement: @(ExtSDkMethodKeyUpdateGroupAnnouncementValue),
            ExtSDkMethodKeyUpdateGroupExt: @(ExtSDkMethodKeyUpdateGroupExtValue),
            ExtSDkMethodKeyJoinPublicGroup: @(ExtSDkMethodKeyJoinPublicGroupValue),
            ExtSDkMethodKeyRequestToJoinPublicGroup: @(ExtSDkMethodKeyRequestToJoinPublicGroupValue),
            ExtSDkMethodKeyAcceptJoinApplication: @(ExtSDkMethodKeyAcceptJoinApplicationValue),
            ExtSDkMethodKeyDeclineJoinApplication: @(ExtSDkMethodKeyDeclineJoinApplicationValue),
            ExtSDkMethodKeyAcceptInvitationFromGroup: @(ExtSDkMethodKeyAcceptInvitationFromGroupValue),
            ExtSDkMethodKeyDeclineInvitationFromGroup: @(ExtSDkMethodKeyDeclineInvitationFromGroupValue),
            ExtSDkMethodKeyIgnoreGroupPush: @(ExtSDkMethodKeyIgnoreGroupPushValue),

            ExtSDkMethodKeyOnGroupChanged: @(ExtSDkMethodKeyOnGroupChangedValue),

            /// EMPushManagerWrapper
            ExtSDkMethodKeyGetImPushConfig: @(ExtSDkMethodKeyGetImPushConfigValue),
            ExtSDkMethodKeyGetImPushConfigFromServer: @(ExtSDkMethodKeyGetImPushConfigFromServerValue),
            ExtSDkMethodKeyUpdatePushNickname: @(ExtSDkMethodKeyUpdatePushNicknameValue),

            ExtSDkMethodKeyImPushNoDisturb: @(ExtSDkMethodKeyImPushNoDisturbValue),
            ExtSDkMethodKeyUpdateImPushStyle: @(ExtSDkMethodKeyUpdateImPushStyleValue),
            ExtSDkMethodKeyUpdateGroupPushService: @(ExtSDkMethodKeyUpdateGroupPushServiceValue),
            ExtSDkMethodKeyGetNoDisturbGroups: @(ExtSDkMethodKeyGetNoDisturbGroupsValue),
            ExtSDkMethodKeyBindDeviceToken: @(ExtSDkMethodKeyBindDeviceTokenValue),


            /// EMUserInfoManagerWrapper
            ExtSDkMethodKeyUpdateOwnUserInfo: @(ExtSDkMethodKeyUpdateOwnUserInfoValue),
            ExtSDkMethodKeyUpdateOwnUserInfoWithType: @(ExtSDkMethodKeyUpdateOwnUserInfoWithTypeValue),
            ExtSDkMethodKeyFetchUserInfoById: @(ExtSDkMethodKeyFetchUserInfoByIdValue),
            ExtSDkMethodKeyFetchUserInfoByIdWithType: @(ExtSDkMethodKeyFetchUserInfoByIdWithTypeValue),



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
//    switch ([ExtSdkMethodType getEnumValue:(ExtSDkMethodKeyGetJoinedGroups)]) {
//        case 1:
//
//            break;
//        case 2:
//
//            break;
//        case ExtSDkMethodKeyGetJoinedGroupsValue:
//
//            break;
//        default:
//            break;
//    }
//}

@end
