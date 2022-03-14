#import <Foundation/Foundation.h>

#pragma mark - EMClientWrapper
static NSString * _Nonnull const ExtSdkMethodKeyInit = @"init";
static NSString * _Nonnull const ExtSdkMethodKeyCreateAccount = @"createAccount";
static NSString * _Nonnull const ExtSdkMethodKeyLogin = @"login";
static NSString * _Nonnull const ExtSdkMethodKeyLogout = @"logout";
static NSString * _Nonnull const ExtSdkMethodKeyChangeAppKey = @"changeAppKey";
static NSString * _Nonnull const ExtSdkMethodKeyIsLoggedInBefore = @"isLoggedInBefore";
static NSString * _Nonnull const ExtSdkMethodKeyUploadLog = @"uploadLog";
static NSString * _Nonnull const ExtSdkMethodKeyCompressLogs = @"compressLogs";
static NSString * _Nonnull const ExtSdkMethodKeyKickDevice = @"kickDevice";
static NSString * _Nonnull const ExtSdkMethodKeyKickAllDevices = @"kickAllDevices";
static NSString * _Nonnull const ExtSdkMethodKeyCurrentUser = @"currentUser";
static NSString * _Nonnull const ExtSdkMethodKeyGetLoggedInDevicesFromServer = @"getLoggedInDevicesFromServer";

#pragma mark - EMClientDelegate
static NSString * _Nonnull const ExtSdkMethodKeyOnConnected = @"onConnected";
static NSString * _Nonnull const ExtSdkMethodKeyOnDisconnected = @"onDisconnected";
static NSString * _Nonnull const ExtSdkMethodKeyOnMultiDeviceEvent = @"onMultiDeviceEvent";

static NSString * _Nonnull const ExtSdkMethodKeySendDataToFlutter = @"onSendDataToFlutter";

#pragma mark - EMContactManagerWrapper
static NSString * _Nonnull const ExtSdkMethodKeyAddContact = @"addContact";
static NSString * _Nonnull const ExtSdkMethodKeyDeleteContact = @"deleteContact";
static NSString * _Nonnull const ExtSdkMethodKeyGetAllContactsFromServer = @"getAllContactsFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyGetAllContactsFromDB = @"getAllContactsFromDB";
static NSString * _Nonnull const ExtSdkMethodKeyAddUserToBlockList = @"addUserToBlockList";
static NSString * _Nonnull const ExtSdkMethodKeyRemoveUserFromBlockList = @"removeUserFromBlockList";
static NSString * _Nonnull const ExtSdkMethodKeyGetBlockListFromServer = @"getBlockListFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyGetBlockListFromDB = @"getBlockListFromDB";
static NSString * _Nonnull const ExtSdkMethodKeyAcceptInvitation = @"acceptInvitation";
static NSString * _Nonnull const ExtSdkMethodKeyDeclineInvitation = @"declineInvitation";
static NSString * _Nonnull const ExtSdkMethodKeyGetSelfIdsOnOtherPlatform = @"getSelfIdsOnOtherPlatform";

#pragma mark - EMContactDelegate
static NSString * _Nonnull const ExtSdkMethodKeyOnContactChanged = @"onContactChanged";

#pragma mark - EMChatManagerWrapper
static NSString * _Nonnull const ExtSdkMethodKeySendMessage = @"sendMessage";
static NSString * _Nonnull const ExtSdkMethodKeyResendMessage = @"resendMessage";
static NSString * _Nonnull const ExtSdkMethodKeyAckMessageRead = @"ackMessageRead";
static NSString * _Nonnull const ExtSdkMethodKeyAckGroupMessageRead = @"ackGroupMessageRead";
static NSString * _Nonnull const ExtSdkMethodKeyAckConversationRead = @"ackConversationRead";
static NSString * _Nonnull const ExtSdkMethodKeyRecallMessage = @"recallMessage";
static NSString * _Nonnull const ExtSdkMethodKeyGetConversation = @"getConversation";
static NSString * _Nonnull const ExtSdkMethodKeyMarkAllChatMsgAsRead = @"markAllChatMsgAsRead";
static NSString * _Nonnull const ExtSdkMethodKeyGetUnreadMessageCount = @"getUnreadMessageCount";
static NSString * _Nonnull const ExtSdkMethodKeyUpdateChatMessage = @"updateChatMessage";
static NSString * _Nonnull const ExtSdkMethodKeyDownloadAttachment = @"downloadAttachment";
static NSString * _Nonnull const ExtSdkMethodKeyDownloadThumbnail = @"downloadThumbnail";
static NSString * _Nonnull const ExtSdkMethodKeyImportMessages = @"importMessages";
static NSString * _Nonnull const ExtSdkMethodKeyLoadAllConversations = @"loadAllConversations";
static NSString * _Nonnull const ExtSdkMethodKeyGetConversationsFromServer = @"getConversationsFromServer";

static NSString * _Nonnull const ExtSdkMethodKeyDeleteConversation = @"deleteConversation";
//static NSString * _Nonnull const ExtSdkMethodKeySetVoiceMessageListened = @"setVoiceMessageListened";
//static NSString * _Nonnull const ExtSdkMethodKeyUpdateParticipant = @"updateParticipant";
static NSString * _Nonnull const ExtSdkMethodKeyUpdateConversationsName = @"updateConversationsName";
static NSString * _Nonnull const ExtSdkMethodKeyFetchHistoryMessages = @"fetchHistoryMessages";
static NSString * _Nonnull const ExtSdkMethodKeySearchChatMsgFromDB = @"searchChatMsgFromDB";
static NSString * _Nonnull const ExtSdkMethodKeyGetMessage = @"getMessage";
static NSString * _Nonnull const ExtSdkMethodKeyAsyncFetchGroupAcks = @"asyncFetchGroupAcks";

#pragma mark - EMChatManagerDelegate
static NSString * _Nonnull const ExtSdkMethodKeyOnMessagesReceived = @"onMessagesReceived";
static NSString * _Nonnull const ExtSdkMethodKeyOnCmdMessagesReceived = @"onCmdMessagesReceived";
static NSString * _Nonnull const ExtSdkMethodKeyOnMessagesRead = @"onMessagesRead";
static NSString * _Nonnull const ExtSdkMethodKeyOnGroupMessageRead = @"onGroupMessageRead";
static NSString * _Nonnull const ExtSdkMethodKeyOnMessagesDelivered = @"onMessagesDelivered";
static NSString * _Nonnull const ExtSdkMethodKeyOnMessagesRecalled = @"onMessagesRecalled";

static NSString * _Nonnull const ExtSdkMethodKeyOnConversationUpdate = @"onConversationUpdate";
static NSString * _Nonnull const ExtSdkMethodKeyOnConversationHasRead = @"onConversationHasRead";

#pragma mark - EMMessageListener
static NSString * _Nonnull const ExtSdkMethodKeyOnMessageProgressUpdate = @"onMessageProgressUpdate";
static NSString * _Nonnull const ExtSdkMethodKeyOnMessageSuccess = @"onMessageSuccess";
static NSString * _Nonnull const ExtSdkMethodKeyOnMessageError = @"onMessageError";
static NSString * _Nonnull const ExtSdkMethodKeyOnMessageReadAck = @"onMessageReadAck";
static NSString * _Nonnull const ExtSdkMethodKeyOnMessageDeliveryAck = @"onMessageDeliveryAck";
static NSString * _Nonnull const ExtSdkMethodKeyOnMessageStatusChanged = @"onMessageStatusChanged";

#pragma mark - EMConversationWrapper

static NSString * _Nonnull const ExtSdkMethodKeyGetUnreadMsgCount = @"getUnreadMsgCount";
static NSString * _Nonnull const ExtSdkMethodKeyMarkAllMsgsAsRead = @"markAllMessagesAsRead";
static NSString * _Nonnull const ExtSdkMethodKeyMarkMsgAsRead = @"markMessageAsRead";
static NSString * _Nonnull const ExtSdkMethodKeySyncConversationExt = @"syncConversationExt";
static NSString * _Nonnull const ExtSdkMethodKeySyncConversationName = @"syncConversationName";
static NSString * _Nonnull const ExtSdkMethodKeyRemoveMsg = @"removeMessage";
static NSString * _Nonnull const ExtSdkMethodKeyGetLatestMsg = @"getLatestMessage";
static NSString * _Nonnull const ExtSdkMethodKeyGetLatestMsgFromOthers = @"getLatestMessageFromOthers";
static NSString * _Nonnull const ExtSdkMethodKeyClearAllMsg = @"clearAllMessages";
static NSString * _Nonnull const ExtSdkMethodKeyInsertMsg = @"insertMessage";
static NSString * _Nonnull const ExtSdkMethodKeyAppendMsg = @"appendMessage";
static NSString * _Nonnull const ExtSdkMethodKeyUpdateConversationMsg = @"updateConversationMessage";

static NSString * _Nonnull const ExtSdkMethodKeyLoadMsgWithId = @"loadMsgWithId";
static NSString * _Nonnull const ExtSdkMethodKeyLoadMsgWithStartId = @"loadMsgWithStartId";
static NSString * _Nonnull const ExtSdkMethodKeyLoadMsgWithKeywords = @"loadMsgWithKeywords";
static NSString * _Nonnull const ExtSdkMethodKeyLoadMsgWithMsgType = @"loadMsgWithMsgType";
static NSString * _Nonnull const ExtSdkMethodKeyLoadMsgWithTime = @"loadMsgWithTime";

#pragma mark - EMChatroomManagerWrapper

static NSString * _Nonnull const ExtSdkMethodKeyJoinChatRoom = @"joinChatRoom";
static NSString * _Nonnull const ExtSdkMethodKeyLeaveChatRoom = @"leaveChatRoom";
static NSString * _Nonnull const ExtSdkMethodKeyGetChatroomsFromServer = @"fetchPublicChatRoomsFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyFetchChatRoomFromServer = @"fetchChatRoomInfoFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyGetChatRoom = @"getChatRoom";
static NSString * _Nonnull const ExtSdkMethodKeyGetAllChatRooms = @"getAllChatRooms";
static NSString * _Nonnull const ExtSdkMethodKeyCreateChatRoom = @"createChatRoom";
static NSString * _Nonnull const ExtSdkMethodKeyDestroyChatRoom = @"destroyChatRoom";
static NSString * _Nonnull const ExtSdkMethodKeyChatRoomUpdateSubject = @"changeChatRoomSubject";
static NSString * _Nonnull const ExtSdkMethodKeyChatRoomUpdateDescription = @"changeChatRoomDescription";
static NSString * _Nonnull const ExtSdkMethodKeyGetChatroomMemberListFromServer = @"fetchChatRoomMembers";
static NSString * _Nonnull const ExtSdkMethodKeyChatRoomMuteMembers = @"muteChatRoomMembers";
static NSString * _Nonnull const ExtSdkMethodKeyChatRoomUnmuteMembers = @"unMuteChatRoomMembers";
static NSString * _Nonnull const ExtSdkMethodKeyChangeChatRoomOwner = @"changeChatRoomOwner";
static NSString * _Nonnull const ExtSdkMethodKeyChatRoomAddAdmin = @"addChatRoomAdmin";
static NSString * _Nonnull const ExtSdkMethodKeyChatRoomRemoveAdmin = @"removeChatRoomAdmin";
static NSString * _Nonnull const ExtSdkMethodKeyGetChatroomMuteListFromServer = @"fetchChatRoomMuteList";
static NSString * _Nonnull const ExtSdkMethodKeyChatRoomRemoveMembers = @"removeChatRoomMembers";
static NSString * _Nonnull const ExtSdkMethodKeyChatRoomBlockMembers = @"blockChatRoomMembers";
static NSString * _Nonnull const ExtSdkMethodKeyChatRoomUnblockMembers = @"unBlockChatRoomMembers";
static NSString * _Nonnull const ExtSdkMethodKeyFetchChatroomBlockListFromServer = @"fetchChatRoomBlockList";
static NSString * _Nonnull const ExtSdkMethodKeyUpdateChatRoomAnnouncement = @"updateChatRoomAnnouncement";
static NSString * _Nonnull const ExtSdkMethodKeyFetchChatroomAnnouncement = @"fetchChatRoomAnnouncement";

static NSString * _Nonnull const ExtSdkMethodKeyAddMembersToChatRoomWhiteList = @"addMembersToChatRoomWhiteList";
static NSString * _Nonnull const ExtSdkMethodKeyRemoveMembersFromChatRoomWhiteList = @"removeMembersFromChatRoomWhiteList";
static NSString * _Nonnull const ExtSdkMethodKeyFetchChatRoomWhiteListFromServer = @"fetchChatRoomWhiteListFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyIsMemberInChatRoomWhiteListFromServer = @"isMemberInChatRoomWhiteListFromServer";

static NSString * _Nonnull const ExtSdkMethodKeyMuteAllChatRoomMembers = @"muteAllChatRoomMembers";
static NSString * _Nonnull const ExtSdkMethodKeyUnMuteAllChatRoomMembers = @"umMuteAllChatRoomMembers";


static NSString * _Nonnull const ExtSdkMethodKeyChatroomChanged = @"onChatRoomChanged";

#pragma mark - EMGroupManagerWrapper

static NSString * _Nonnull const ExtSdkMethodKeyGetGroupWithId = @"getGroupWithId";
static NSString * _Nonnull const ExtSdkMethodKeyGetJoinedGroups = @"getJoinedGroups";
static NSString * _Nonnull const ExtSdkMethodKeyGetGroupsWithoutPushNotification = @"getGroupsWithoutPushNotification";
static NSString * _Nonnull const ExtSdkMethodKeyGetJoinedGroupsFromServer = @"getJoinedGroupsFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyGetPublicGroupsFromServer = @"getPublicGroupsFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyCreateGroup = @"createGroup";
static NSString * _Nonnull const ExtSdkMethodKeyGetGroupSpecificationFromServer = @"getGroupSpecificationFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyGetGroupMemberListFromServer = @"getGroupMemberListFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyGetGroupBlockListFromServer = @"getGroupBlockListFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyGetGroupMuteListFromServer = @"getGroupMuteListFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyGetGroupWhiteListFromServer = @"getGroupWhiteListFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyIsMemberInWhiteListFromServer = @"isMemberInWhiteListFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyGetGroupFileListFromServer = @"getGroupFileListFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyGetGroupAnnouncementFromServer = @"getGroupAnnouncementFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyAddMembers = @"addMembers";
static NSString * _Nonnull const ExtSdkMethodKeyInviterUser = @"inviterUser";
static NSString * _Nonnull const ExtSdkMethodKeyRemoveMembers = @"removeMembers";
static NSString * _Nonnull const ExtSdkMethodKeyBlockMembers = @"blockMembers";
static NSString * _Nonnull const ExtSdkMethodKeyUnblockMembers = @"unblockMembers";
static NSString * _Nonnull const ExtSdkMethodKeyUpdateGroupSubject = @"updateGroupSubject";
static NSString * _Nonnull const ExtSdkMethodKeyUpdateDescription = @"updateDescription";
static NSString * _Nonnull const ExtSdkMethodKeyLeaveGroup = @"leaveGroup";
static NSString * _Nonnull const ExtSdkMethodKeyDestroyGroup = @"destroyGroup";
static NSString * _Nonnull const ExtSdkMethodKeyBlockGroup = @"blockGroup";
static NSString * _Nonnull const ExtSdkMethodKeyUnblockGroup = @"unblockGroup";
static NSString * _Nonnull const ExtSdkMethodKeyUpdateGroupOwner = @"updateGroupOwner";
static NSString * _Nonnull const ExtSdkMethodKeyAddAdmin = @"addAdmin";
static NSString * _Nonnull const ExtSdkMethodKeyRemoveAdmin = @"removeAdmin";
static NSString * _Nonnull const ExtSdkMethodKeyMuteMembers = @"muteMembers";
static NSString * _Nonnull const ExtSdkMethodKeyUnMuteMembers = @"unMuteMembers";
static NSString * _Nonnull const ExtSdkMethodKeyMuteAllMembers = @"muteAllMembers";
static NSString * _Nonnull const ExtSdkMethodKeyUnMuteAllMembers = @"unMuteAllMembers";
static NSString * _Nonnull const ExtSdkMethodKeyAddWhiteList = @"addWhiteList";
static NSString * _Nonnull const ExtSdkMethodKeyRemoveWhiteList = @"removeWhiteList";
static NSString * _Nonnull const ExtSdkMethodKeyUploadGroupSharedFile = @"uploadGroupSharedFile";
static NSString * _Nonnull const ExtSdkMethodKeyDownloadGroupSharedFile = @"downloadGroupSharedFile";
static NSString * _Nonnull const ExtSdkMethodKeyRemoveGroupSharedFile = @"removeGroupSharedFile";
static NSString * _Nonnull const ExtSdkMethodKeyUpdateGroupAnnouncement = @"updateGroupAnnouncement";
static NSString * _Nonnull const ExtSdkMethodKeyUpdateGroupExt = @"updateGroupExt";
static NSString * _Nonnull const ExtSdkMethodKeyJoinPublicGroup = @"joinPublicGroup";
static NSString * _Nonnull const ExtSdkMethodKeyRequestToJoinPublicGroup = @"requestToJoinPublicGroup";
static NSString * _Nonnull const ExtSdkMethodKeyAcceptJoinApplication = @"acceptJoinApplication";
static NSString * _Nonnull const ExtSdkMethodKeyDeclineJoinApplication = @"declineJoinApplication";
static NSString * _Nonnull const ExtSdkMethodKeyAcceptInvitationFromGroup = @"acceptInvitationFromGroup";
static NSString * _Nonnull const ExtSdkMethodKeyDeclineInvitationFromGroup = @"declineInvitationFromGroup";
static NSString * _Nonnull const ExtSdkMethodKeyIgnoreGroupPush = @"ignoreGroupPush";

static NSString * _Nonnull const ExtSdkMethodKeyOnGroupChanged = @"onGroupChanged";

#pragma mark - EMPushManagerWrapper
static NSString * _Nonnull const ExtSdkMethodKeyGetImPushConfig = @"getImPushConfig";
static NSString * _Nonnull const ExtSdkMethodKeyGetImPushConfigFromServer = @"getImPushConfigFromServer";
static NSString * _Nonnull const ExtSdkMethodKeyUpdatePushNickname = @"updatePushNickname";

static NSString * _Nonnull const ExtSdkMethodKeyImPushNoDisturb = @"imPushNoDisturb";
static NSString * _Nonnull const ExtSdkMethodKeyUpdateImPushStyle = @"updateImPushStyle";
static NSString * _Nonnull const ExtSdkMethodKeyUpdateGroupPushService = @"updateGroupPushService";
static NSString * _Nonnull const ExtSdkMethodKeyGetNoDisturbGroups = @"getNoDisturbGroups";
static NSString * _Nonnull const ExtSdkMethodKeyBindDeviceToken = @"updateAPNsPushToken";


#pragma mark - EMUserInfoManagerWrapper
static NSString * _Nonnull const ExtSdkMethodKeyUpdateOwnUserInfo = @"updateOwnUserInfo";
static NSString * _Nonnull const ExtSdkMethodKeyUpdateOwnUserInfoWithType = @"updateOwnUserInfoWithType";
static NSString * _Nonnull const ExtSdkMethodKeyFetchUserInfoById = @"fetchUserInfoById";
static NSString * _Nonnull const ExtSdkMethodKeyFetchUserInfoByIdWithType = @"fetchUserInfoByIdWithType";






#pragma mark - EMClientWrapper value
static const int ExtSdkMethodKeyInitValue = 100;
static const int ExtSdkMethodKeyCreateAccountValue = 101;
static const int ExtSdkMethodKeyLoginValue = 102;
static const int ExtSdkMethodKeyLogoutValue = 103;
static const int ExtSdkMethodKeyChangeAppKeyValue = 104;
static const int ExtSdkMethodKeyIsLoggedInBeforeValue = 105;
static const int ExtSdkMethodKeyUploadLogValue = 106;
static const int ExtSdkMethodKeyCompressLogsValue = 107;
static const int ExtSdkMethodKeyKickDeviceValue = 108;
static const int ExtSdkMethodKeyKickAllDevicesValue = 109;
static const int ExtSdkMethodKeyCurrentUserValue = 110;
static const int ExtSdkMethodKeyGetLoggedInDevicesFromServerValue = 111;

#pragma mark - EMClientDelegate value
static const int ExtSdkMethodKeyOnConnectedValue = 200;
static const int ExtSdkMethodKeyOnDisconnectedValue = 201;
static const int ExtSdkMethodKeyOnMultiDeviceEventValue = 202;

static const int ExtSdkMethodKeySendDataToFlutterValue = 203;

#pragma mark - EMContactManagerWrapper value
static const int ExtSdkMethodKeyAddContactValue = 300;
static const int ExtSdkMethodKeyDeleteContactValue = 301;
static const int ExtSdkMethodKeyGetAllContactsFromServerValue = 302;
static const int ExtSdkMethodKeyGetAllContactsFromDBValue = 303;
static const int ExtSdkMethodKeyAddUserToBlockListValue = 304;
static const int ExtSdkMethodKeyRemoveUserFromBlockListValue = 305;
static const int ExtSdkMethodKeyGetBlockListFromServerValue = 306;
static const int ExtSdkMethodKeyGetBlockListFromDBValue = 307;
static const int ExtSdkMethodKeyAcceptInvitationValue = 308;
static const int ExtSdkMethodKeyDeclineInvitationValue = 309;
static const int ExtSdkMethodKeyGetSelfIdsOnOtherPlatformValue = 310;

#pragma mark - EMContactDelegate value
static const int ExtSdkMethodKeyOnContactChangedValue = 400;

#pragma mark - EMChatManagerWrapper value
static const int ExtSdkMethodKeySendMessageValue = 500;
static const int ExtSdkMethodKeyResendMessageValue = 501;
static const int ExtSdkMethodKeyAckMessageReadValue = 502;
static const int ExtSdkMethodKeyAckGroupMessageReadValue = 503;
static const int ExtSdkMethodKeyAckConversationReadValue = 504;
static const int ExtSdkMethodKeyRecallMessageValue = 505;
static const int ExtSdkMethodKeyGetConversationValue = 506;
static const int ExtSdkMethodKeyMarkAllChatMsgAsReadValue = 507;
static const int ExtSdkMethodKeyGetUnreadMessageCountValue = 508;
static const int ExtSdkMethodKeyUpdateChatMessageValue = 509;
static const int ExtSdkMethodKeyDownloadAttachmentValue = 510;
static const int ExtSdkMethodKeyDownloadThumbnailValue = 511;
static const int ExtSdkMethodKeyImportMessagesValue = 512;
static const int ExtSdkMethodKeyLoadAllConversationsValue = 513;
static const int ExtSdkMethodKeyGetConversationsFromServerValue = 514;

static const int ExtSdkMethodKeyDeleteConversationValue = 515;
//static const int ExtSdkMethodKeySetVoiceMessageListenedValue = 516;
//static const int ExtSdkMethodKeyUpdateParticipantValue = 517;
static const int ExtSdkMethodKeyUpdateConversationsNameValue = 518;
static const int ExtSdkMethodKeyFetchHistoryMessagesValue = 519;
static const int ExtSdkMethodKeySearchChatMsgFromDBValue = 520;
static const int ExtSdkMethodKeyGetMessageValue = 521;
static const int ExtSdkMethodKeyAsyncFetchGroupAcksValue = 522;

#pragma mark - EMChatManagerDelegate value
static const int ExtSdkMethodKeyOnMessagesReceivedValue = 600;
static const int ExtSdkMethodKeyOnCmdMessagesReceivedValue = 601;
static const int ExtSdkMethodKeyOnMessagesReadValue = 602;
static const int ExtSdkMethodKeyOnGroupMessageReadValue = 603;
static const int ExtSdkMethodKeyOnMessagesDeliveredValue = 604;
static const int ExtSdkMethodKeyOnMessagesRecalledValue = 605;

static const int ExtSdkMethodKeyOnConversationUpdateValue = 606;
static const int ExtSdkMethodKeyOnConversationHasReadValue = 607;

#pragma mark - EMMessageListener value
static const int ExtSdkMethodKeyOnMessageProgressUpdateValue = 1200;
static const int ExtSdkMethodKeyOnMessageSuccessValue = 1201;
static const int ExtSdkMethodKeyOnMessageErrorValue = 1202;
static const int ExtSdkMethodKeyOnMessageReadAckValue = 1203;
static const int ExtSdkMethodKeyOnMessageDeliveryAckValue = 1204;
static const int ExtSdkMethodKeyOnMessageStatusChangedValue = 1205;

#pragma mark - EMConversationWrapper value

static const int ExtSdkMethodKeyGetUnreadMsgCountValue = 700;
static const int ExtSdkMethodKeyMarkAllMsgsAsReadValue = 701;
static const int ExtSdkMethodKeyMarkMsgAsReadValue = 702;
static const int ExtSdkMethodKeySyncConversationExtValue = 703;
static const int ExtSdkMethodKeySyncConversationNameValue = 704;
static const int ExtSdkMethodKeyRemoveMsgValue = 705;
static const int ExtSdkMethodKeyGetLatestMsgValue = 706;
static const int ExtSdkMethodKeyGetLatestMsgFromOthersValue = 707;
static const int ExtSdkMethodKeyClearAllMsgValue = 708;
static const int ExtSdkMethodKeyInsertMsgValue = 709;
static const int ExtSdkMethodKeyAppendMsgValue = 710;
static const int ExtSdkMethodKeyUpdateConversationMsgValue = 711;

static const int ExtSdkMethodKeyLoadMsgWithIdValue = 712;
static const int ExtSdkMethodKeyLoadMsgWithStartIdValue = 713;
static const int ExtSdkMethodKeyLoadMsgWithKeywordsValue = 714;
static const int ExtSdkMethodKeyLoadMsgWithMsgTypeValue = 715;
static const int ExtSdkMethodKeyLoadMsgWithTimeValue = 716;

#pragma mark - EMChatroomManagerWrapper value

static const int ExtSdkMethodKeyJoinChatRoomValue = 800;
static const int ExtSdkMethodKeyLeaveChatRoomValue = 801;
static const int ExtSdkMethodKeyGetChatroomsFromServerValue = 802;
static const int ExtSdkMethodKeyFetchChatRoomFromServerValue = 803;
static const int ExtSdkMethodKeyGetChatRoomValue = 804;
static const int ExtSdkMethodKeyGetAllChatRoomsValue = 805;
static const int ExtSdkMethodKeyCreateChatRoomValue = 806;
static const int ExtSdkMethodKeyDestroyChatRoomValue = 807;
static const int ExtSdkMethodKeyChatRoomUpdateSubjectValue = 808;
static const int ExtSdkMethodKeyChatRoomUpdateDescriptionValue = 809;
static const int ExtSdkMethodKeyGetChatroomMemberListFromServerValue = 810;
static const int ExtSdkMethodKeyChatRoomMuteMembersValue = 811;
static const int ExtSdkMethodKeyChatRoomUnmuteMembersValue = 812;
static const int ExtSdkMethodKeyChangeChatRoomOwnerValue = 813;
static const int ExtSdkMethodKeyChatRoomAddAdminValue = 814;
static const int ExtSdkMethodKeyChatRoomRemoveAdminValue = 815;
static const int ExtSdkMethodKeyGetChatroomMuteListFromServerValue = 816;
static const int ExtSdkMethodKeyChatRoomRemoveMembersValue = 817;
static const int ExtSdkMethodKeyChatRoomBlockMembersValue = 818;
static const int ExtSdkMethodKeyChatRoomUnblockMembersValue = 819;
static const int ExtSdkMethodKeyFetchChatroomBlockListFromServerValue = 820;
static const int ExtSdkMethodKeyUpdateChatRoomAnnouncementValue = 821;
static const int ExtSdkMethodKeyFetchChatroomAnnouncementValue = 822;

static const int ExtSdkMethodKeyAddMembersToChatRoomWhiteListValue = 823;
static const int ExtSdkMethodKeyRemoveMembersFromChatRoomWhiteListValue = 824;
static const int ExtSdkMethodKeyFetchChatRoomWhiteListFromServerValue = 825;
static const int ExtSdkMethodKeyIsMemberInChatRoomWhiteListFromServerValue = 826;

static const int ExtSdkMethodKeyMuteAllChatRoomMembersValue = 827;
static const int ExtSdkMethodKeyUnMuteAllChatRoomMembersValue = 828;


static const int ExtSdkMethodKeyChatroomChangedValue = 829;

#pragma mark - EMGroupManagerWrapper value

static const int ExtSdkMethodKeyGetGroupWithIdValue = 900;
static const int ExtSdkMethodKeyGetJoinedGroupsValue = 901;
static const int ExtSdkMethodKeyGetGroupsWithoutPushNotificationValue = 902;
static const int ExtSdkMethodKeyGetJoinedGroupsFromServerValue = 903;
static const int ExtSdkMethodKeyGetPublicGroupsFromServerValue = 904;
static const int ExtSdkMethodKeyCreateGroupValue = 905;
static const int ExtSdkMethodKeyGetGroupSpecificationFromServerValue = 906;
static const int ExtSdkMethodKeyGetGroupMemberListFromServerValue = 907;
static const int ExtSdkMethodKeyGetGroupBlockListFromServerValue = 908;
static const int ExtSdkMethodKeyGetGroupMuteListFromServerValue = 909;
static const int ExtSdkMethodKeyGetGroupWhiteListFromServerValue = 910;
static const int ExtSdkMethodKeyIsMemberInWhiteListFromServerValue = 911;
static const int ExtSdkMethodKeyGetGroupFileListFromServerValue = 912;
static const int ExtSdkMethodKeyGetGroupAnnouncementFromServerValue = 913;
static const int ExtSdkMethodKeyAddMembersValue = 914;
static const int ExtSdkMethodKeyInviterUserValue = 915;
static const int ExtSdkMethodKeyRemoveMembersValue = 916;
static const int ExtSdkMethodKeyBlockMembersValue = 917;
static const int ExtSdkMethodKeyUnblockMembersValue = 918;
static const int ExtSdkMethodKeyUpdateGroupSubjectValue = 919;
static const int ExtSdkMethodKeyUpdateDescriptionValue = 920;
static const int ExtSdkMethodKeyLeaveGroupValue = 921;
static const int ExtSdkMethodKeyDestroyGroupValue = 922;
static const int ExtSdkMethodKeyBlockGroupValue = 923;
static const int ExtSdkMethodKeyUnblockGroupValue = 924;
static const int ExtSdkMethodKeyUpdateGroupOwnerValue = 925;
static const int ExtSdkMethodKeyAddAdminValue = 926;
static const int ExtSdkMethodKeyRemoveAdminValue = 927;
static const int ExtSdkMethodKeyMuteMembersValue = 928;
static const int ExtSdkMethodKeyUnMuteMembersValue = 929;
static const int ExtSdkMethodKeyMuteAllMembersValue = 930;
static const int ExtSdkMethodKeyUnMuteAllMembersValue = 931;
static const int ExtSdkMethodKeyAddWhiteListValue = 932;
static const int ExtSdkMethodKeyRemoveWhiteListValue = 933;
static const int ExtSdkMethodKeyUploadGroupSharedFileValue = 934;
static const int ExtSdkMethodKeyDownloadGroupSharedFileValue = 935;
static const int ExtSdkMethodKeyRemoveGroupSharedFileValue = 936;
static const int ExtSdkMethodKeyUpdateGroupAnnouncementValue = 937;
static const int ExtSdkMethodKeyUpdateGroupExtValue = 938;
static const int ExtSdkMethodKeyJoinPublicGroupValue = 939;
static const int ExtSdkMethodKeyRequestToJoinPublicGroupValue = 940;
static const int ExtSdkMethodKeyAcceptJoinApplicationValue = 941;
static const int ExtSdkMethodKeyDeclineJoinApplicationValue = 942;
static const int ExtSdkMethodKeyAcceptInvitationFromGroupValue = 943;
static const int ExtSdkMethodKeyDeclineInvitationFromGroupValue = 944;
static const int ExtSdkMethodKeyIgnoreGroupPushValue = 945;

static const int ExtSdkMethodKeyOnGroupChangedValue = 946;

#pragma mark - EMPushManagerWrapper value
static const int ExtSdkMethodKeyGetImPushConfigValue = 1000;
static const int ExtSdkMethodKeyGetImPushConfigFromServerValue = 1001;
static const int ExtSdkMethodKeyUpdatePushNicknameValue = 1002;

static const int ExtSdkMethodKeyImPushNoDisturbValue = 1003;
static const int ExtSdkMethodKeyUpdateImPushStyleValue = 1004;
static const int ExtSdkMethodKeyUpdateGroupPushServiceValue = 1005;
static const int ExtSdkMethodKeyGetNoDisturbGroupsValue = 1006;
static const int ExtSdkMethodKeyBindDeviceTokenValue = 1007;


#pragma mark - EMUserInfoManagerWrapper value
static const int ExtSdkMethodKeyUpdateOwnUserInfoValue = 1100;
static const int ExtSdkMethodKeyUpdateOwnUserInfoWithTypeValue = 1101;
static const int ExtSdkMethodKeyFetchUserInfoByIdValue = 1102;
static const int ExtSdkMethodKeyFetchUserInfoByIdWithTypeValue = 1103;

@interface ExtSdkMethodTypeObjc : NSObject

+ (int)getEnumValue:(nonnull NSString*)key;

@end
