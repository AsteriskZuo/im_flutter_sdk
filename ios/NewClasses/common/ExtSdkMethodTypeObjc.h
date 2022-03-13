#import <Foundation/Foundation.h>

#pragma mark - EMClientWrapper
static NSString * _Nonnull const ExtSDkMethodKeyInit = @"init";
static NSString * _Nonnull const ExtSDkMethodKeyCreateAccount = @"createAccount";
static NSString * _Nonnull const ExtSDkMethodKeyLogin = @"login";
static NSString * _Nonnull const ExtSDkMethodKeyLogout = @"logout";
static NSString * _Nonnull const ExtSDkMethodKeyChangeAppKey = @"changeAppKey";
static NSString * _Nonnull const ExtSDkMethodKeyIsLoggedInBefore = @"isLoggedInBefore";
static NSString * _Nonnull const ExtSDkMethodKeyUploadLog = @"uploadLog";
static NSString * _Nonnull const ExtSDkMethodKeyCompressLogs = @"compressLogs";
static NSString * _Nonnull const ExtSDkMethodKeyKickDevice = @"kickDevice";
static NSString * _Nonnull const ExtSDkMethodKeyKickAllDevices = @"kickAllDevices";
static NSString * _Nonnull const ExtSDkMethodKeyCurrentUser = @"currentUser";
static NSString * _Nonnull const ExtSDkMethodKeyGetLoggedInDevicesFromServer = @"getLoggedInDevicesFromServer";

#pragma mark - EMClientDelegate
static NSString * _Nonnull const ExtSDkMethodKeyOnConnected = @"onConnected";
static NSString * _Nonnull const ExtSDkMethodKeyOnDisconnected = @"onDisconnected";
static NSString * _Nonnull const ExtSDkMethodKeyOnMultiDeviceEvent = @"onMultiDeviceEvent";

static NSString * _Nonnull const ExtSDkMethodKeySendDataToFlutter = @"onSendDataToFlutter";

#pragma mark - EMContactManagerWrapper
static NSString * _Nonnull const ExtSDkMethodKeyAddContact = @"addContact";
static NSString * _Nonnull const ExtSDkMethodKeyDeleteContact = @"deleteContact";
static NSString * _Nonnull const ExtSDkMethodKeyGetAllContactsFromServer = @"getAllContactsFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyGetAllContactsFromDB = @"getAllContactsFromDB";
static NSString * _Nonnull const ExtSDkMethodKeyAddUserToBlockList = @"addUserToBlockList";
static NSString * _Nonnull const ExtSDkMethodKeyRemoveUserFromBlockList = @"removeUserFromBlockList";
static NSString * _Nonnull const ExtSDkMethodKeyGetBlockListFromServer = @"getBlockListFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyGetBlockListFromDB = @"getBlockListFromDB";
static NSString * _Nonnull const ExtSDkMethodKeyAcceptInvitation = @"acceptInvitation";
static NSString * _Nonnull const ExtSDkMethodKeyDeclineInvitation = @"declineInvitation";
static NSString * _Nonnull const ExtSDkMethodKeyGetSelfIdsOnOtherPlatform = @"getSelfIdsOnOtherPlatform";

#pragma mark - EMContactDelegate
static NSString * _Nonnull const ExtSDkMethodKeyOnContactChanged = @"onContactChanged";

#pragma mark - EMChatManagerWrapper
static NSString * _Nonnull const ExtSDkMethodKeySendMessage = @"sendMessage";
static NSString * _Nonnull const ExtSDkMethodKeyResendMessage = @"resendMessage";
static NSString * _Nonnull const ExtSDkMethodKeyAckMessageRead = @"ackMessageRead";
static NSString * _Nonnull const ExtSDkMethodKeyAckGroupMessageRead = @"ackGroupMessageRead";
static NSString * _Nonnull const ExtSDkMethodKeyAckConversationRead = @"ackConversationRead";
static NSString * _Nonnull const ExtSDkMethodKeyRecallMessage = @"recallMessage";
static NSString * _Nonnull const ExtSDkMethodKeyGetConversation = @"getConversation";
static NSString * _Nonnull const ExtSDkMethodKeyMarkAllChatMsgAsRead = @"markAllChatMsgAsRead";
static NSString * _Nonnull const ExtSDkMethodKeyGetUnreadMessageCount = @"getUnreadMessageCount";
static NSString * _Nonnull const ExtSDkMethodKeyUpdateChatMessage = @"updateChatMessage";
static NSString * _Nonnull const ExtSDkMethodKeyDownloadAttachment = @"downloadAttachment";
static NSString * _Nonnull const ExtSDkMethodKeyDownloadThumbnail = @"downloadThumbnail";
static NSString * _Nonnull const ExtSDkMethodKeyImportMessages = @"importMessages";
static NSString * _Nonnull const ExtSDkMethodKeyLoadAllConversations = @"loadAllConversations";
static NSString * _Nonnull const ExtSDkMethodKeyGetConversationsFromServer = @"getConversationsFromServer";

static NSString * _Nonnull const ExtSDkMethodKeyDeleteConversation = @"deleteConversation";
//static NSString * _Nonnull const ExtSDkMethodKeySetVoiceMessageListened = @"setVoiceMessageListened";
//static NSString * _Nonnull const ExtSDkMethodKeyUpdateParticipant = @"updateParticipant";
static NSString * _Nonnull const ExtSDkMethodKeyUpdateConversationsName = @"updateConversationsName";
static NSString * _Nonnull const ExtSDkMethodKeyFetchHistoryMessages = @"fetchHistoryMessages";
static NSString * _Nonnull const ExtSDkMethodKeySearchChatMsgFromDB = @"searchChatMsgFromDB";
static NSString * _Nonnull const ExtSDkMethodKeyGetMessage = @"getMessage";
static NSString * _Nonnull const ExtSDkMethodKeyAsyncFetchGroupAcks = @"asyncFetchGroupAcks";

#pragma mark - EMChatManagerDelegate
static NSString * _Nonnull const ExtSDkMethodKeyOnMessagesReceived = @"onMessagesReceived";
static NSString * _Nonnull const ExtSDkMethodKeyOnCmdMessagesReceived = @"onCmdMessagesReceived";
static NSString * _Nonnull const ExtSDkMethodKeyOnMessagesRead = @"onMessagesRead";
static NSString * _Nonnull const ExtSDkMethodKeyOnGroupMessageRead = @"onGroupMessageRead";
static NSString * _Nonnull const ExtSDkMethodKeyOnMessagesDelivered = @"onMessagesDelivered";
static NSString * _Nonnull const ExtSDkMethodKeyOnMessagesRecalled = @"onMessagesRecalled";

static NSString * _Nonnull const ExtSDkMethodKeyOnConversationUpdate = @"onConversationUpdate";
static NSString * _Nonnull const ExtSDkMethodKeyOnConversationHasRead = @"onConversationHasRead";

#pragma mark - EMMessageListener
static NSString * _Nonnull const ExtSDkMethodKeyOnMessageProgressUpdate = @"onMessageProgressUpdate";
static NSString * _Nonnull const ExtSDkMethodKeyOnMessageSuccess = @"onMessageSuccess";
static NSString * _Nonnull const ExtSDkMethodKeyOnMessageError = @"onMessageError";
static NSString * _Nonnull const ExtSDkMethodKeyOnMessageReadAck = @"onMessageReadAck";
static NSString * _Nonnull const ExtSDkMethodKeyOnMessageDeliveryAck = @"onMessageDeliveryAck";
static NSString * _Nonnull const ExtSDkMethodKeyOnMessageStatusChanged = @"onMessageStatusChanged";

#pragma mark - EMConversationWrapper

static NSString * _Nonnull const ExtSDkMethodKeyGetUnreadMsgCount = @"getUnreadMsgCount";
static NSString * _Nonnull const ExtSDkMethodKeyMarkAllMsgsAsRead = @"markAllMessagesAsRead";
static NSString * _Nonnull const ExtSDkMethodKeyMarkMsgAsRead = @"markMessageAsRead";
static NSString * _Nonnull const ExtSDkMethodKeySyncConversationExt = @"syncConversationExt";
static NSString * _Nonnull const ExtSDkMethodKeySyncConversationName = @"syncConversationName";
static NSString * _Nonnull const ExtSDkMethodKeyRemoveMsg = @"removeMessage";
static NSString * _Nonnull const ExtSDkMethodKeyGetLatestMsg = @"getLatestMessage";
static NSString * _Nonnull const ExtSDkMethodKeyGetLatestMsgFromOthers = @"getLatestMessageFromOthers";
static NSString * _Nonnull const ExtSDkMethodKeyClearAllMsg = @"clearAllMessages";
static NSString * _Nonnull const ExtSDkMethodKeyInsertMsg = @"insertMessage";
static NSString * _Nonnull const ExtSDkMethodKeyAppendMsg = @"appendMessage";
static NSString * _Nonnull const ExtSDkMethodKeyUpdateConversationMsg = @"updateConversationMessage";

static NSString * _Nonnull const ExtSDkMethodKeyLoadMsgWithId = @"loadMsgWithId";
static NSString * _Nonnull const ExtSDkMethodKeyLoadMsgWithStartId = @"loadMsgWithStartId";
static NSString * _Nonnull const ExtSDkMethodKeyLoadMsgWithKeywords = @"loadMsgWithKeywords";
static NSString * _Nonnull const ExtSDkMethodKeyLoadMsgWithMsgType = @"loadMsgWithMsgType";
static NSString * _Nonnull const ExtSDkMethodKeyLoadMsgWithTime = @"loadMsgWithTime";

#pragma mark - EMChatroomManagerWrapper

static NSString * _Nonnull const ExtSDkMethodKeyJoinChatRoom = @"joinChatRoom";
static NSString * _Nonnull const ExtSDkMethodKeyLeaveChatRoom = @"leaveChatRoom";
static NSString * _Nonnull const ExtSDkMethodKeyGetChatroomsFromServer = @"fetchPublicChatRoomsFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyFetchChatRoomFromServer = @"fetchChatRoomInfoFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyGetChatRoom = @"getChatRoom";
static NSString * _Nonnull const ExtSDkMethodKeyGetAllChatRooms = @"getAllChatRooms";
static NSString * _Nonnull const ExtSDkMethodKeyCreateChatRoom = @"createChatRoom";
static NSString * _Nonnull const ExtSDkMethodKeyDestroyChatRoom = @"destroyChatRoom";
static NSString * _Nonnull const ExtSDkMethodKeyChatRoomUpdateSubject = @"changeChatRoomSubject";
static NSString * _Nonnull const ExtSDkMethodKeyChatRoomUpdateDescription = @"changeChatRoomDescription";
static NSString * _Nonnull const ExtSDkMethodKeyGetChatroomMemberListFromServer = @"fetchChatRoomMembers";
static NSString * _Nonnull const ExtSDkMethodKeyChatRoomMuteMembers = @"muteChatRoomMembers";
static NSString * _Nonnull const ExtSDkMethodKeyChatRoomUnmuteMembers = @"unMuteChatRoomMembers";
static NSString * _Nonnull const ExtSDkMethodKeyChangeChatRoomOwner = @"changeChatRoomOwner";
static NSString * _Nonnull const ExtSDkMethodKeyChatRoomAddAdmin = @"addChatRoomAdmin";
static NSString * _Nonnull const ExtSDkMethodKeyChatRoomRemoveAdmin = @"removeChatRoomAdmin";
static NSString * _Nonnull const ExtSDkMethodKeyGetChatroomMuteListFromServer = @"fetchChatRoomMuteList";
static NSString * _Nonnull const ExtSDkMethodKeyChatRoomRemoveMembers = @"removeChatRoomMembers";
static NSString * _Nonnull const ExtSDkMethodKeyChatRoomBlockMembers = @"blockChatRoomMembers";
static NSString * _Nonnull const ExtSDkMethodKeyChatRoomUnblockMembers = @"unBlockChatRoomMembers";
static NSString * _Nonnull const ExtSDkMethodKeyFetchChatroomBlockListFromServer = @"fetchChatRoomBlockList";
static NSString * _Nonnull const ExtSDkMethodKeyUpdateChatRoomAnnouncement = @"updateChatRoomAnnouncement";
static NSString * _Nonnull const ExtSDkMethodKeyFetchChatroomAnnouncement = @"fetchChatRoomAnnouncement";

static NSString * _Nonnull const ExtSDkMethodKeyAddMembersToChatRoomWhiteList = @"addMembersToChatRoomWhiteList";
static NSString * _Nonnull const ExtSDkMethodKeyRemoveMembersFromChatRoomWhiteList = @"removeMembersFromChatRoomWhiteList";
static NSString * _Nonnull const ExtSDkMethodKeyFetchChatRoomWhiteListFromServer = @"fetchChatRoomWhiteListFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyIsMemberInChatRoomWhiteListFromServer = @"isMemberInChatRoomWhiteListFromServer";

static NSString * _Nonnull const ExtSDkMethodKeyMuteAllChatRoomMembers = @"muteAllChatRoomMembers";
static NSString * _Nonnull const ExtSDkMethodKeyUnMuteAllChatRoomMembers = @"umMuteAllChatRoomMembers";


static NSString * _Nonnull const ExtSDkMethodKeyChatroomChanged = @"onChatRoomChanged";

#pragma mark - EMGroupManagerWrapper

static NSString * _Nonnull const ExtSDkMethodKeyGetGroupWithId = @"getGroupWithId";
static NSString * _Nonnull const ExtSDkMethodKeyGetJoinedGroups = @"getJoinedGroups";
static NSString * _Nonnull const ExtSDkMethodKeyGetGroupsWithoutPushNotification = @"getGroupsWithoutPushNotification";
static NSString * _Nonnull const ExtSDkMethodKeyGetJoinedGroupsFromServer = @"getJoinedGroupsFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyGetPublicGroupsFromServer = @"getPublicGroupsFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyCreateGroup = @"createGroup";
static NSString * _Nonnull const ExtSDkMethodKeyGetGroupSpecificationFromServer = @"getGroupSpecificationFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyGetGroupMemberListFromServer = @"getGroupMemberListFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyGetGroupBlockListFromServer = @"getGroupBlockListFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyGetGroupMuteListFromServer = @"getGroupMuteListFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyGetGroupWhiteListFromServer = @"getGroupWhiteListFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyIsMemberInWhiteListFromServer = @"isMemberInWhiteListFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyGetGroupFileListFromServer = @"getGroupFileListFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyGetGroupAnnouncementFromServer = @"getGroupAnnouncementFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyAddMembers = @"addMembers";
static NSString * _Nonnull const ExtSDkMethodKeyInviterUser = @"inviterUser";
static NSString * _Nonnull const ExtSDkMethodKeyRemoveMembers = @"removeMembers";
static NSString * _Nonnull const ExtSDkMethodKeyBlockMembers = @"blockMembers";
static NSString * _Nonnull const ExtSDkMethodKeyUnblockMembers = @"unblockMembers";
static NSString * _Nonnull const ExtSDkMethodKeyUpdateGroupSubject = @"updateGroupSubject";
static NSString * _Nonnull const ExtSDkMethodKeyUpdateDescription = @"updateDescription";
static NSString * _Nonnull const ExtSDkMethodKeyLeaveGroup = @"leaveGroup";
static NSString * _Nonnull const ExtSDkMethodKeyDestroyGroup = @"destroyGroup";
static NSString * _Nonnull const ExtSDkMethodKeyBlockGroup = @"blockGroup";
static NSString * _Nonnull const ExtSDkMethodKeyUnblockGroup = @"unblockGroup";
static NSString * _Nonnull const ExtSDkMethodKeyUpdateGroupOwner = @"updateGroupOwner";
static NSString * _Nonnull const ExtSDkMethodKeyAddAdmin = @"addAdmin";
static NSString * _Nonnull const ExtSDkMethodKeyRemoveAdmin = @"removeAdmin";
static NSString * _Nonnull const ExtSDkMethodKeyMuteMembers = @"muteMembers";
static NSString * _Nonnull const ExtSDkMethodKeyUnMuteMembers = @"unMuteMembers";
static NSString * _Nonnull const ExtSDkMethodKeyMuteAllMembers = @"muteAllMembers";
static NSString * _Nonnull const ExtSDkMethodKeyUnMuteAllMembers = @"unMuteAllMembers";
static NSString * _Nonnull const ExtSDkMethodKeyAddWhiteList = @"addWhiteList";
static NSString * _Nonnull const ExtSDkMethodKeyRemoveWhiteList = @"removeWhiteList";
static NSString * _Nonnull const ExtSDkMethodKeyUploadGroupSharedFile = @"uploadGroupSharedFile";
static NSString * _Nonnull const ExtSDkMethodKeyDownloadGroupSharedFile = @"downloadGroupSharedFile";
static NSString * _Nonnull const ExtSDkMethodKeyRemoveGroupSharedFile = @"removeGroupSharedFile";
static NSString * _Nonnull const ExtSDkMethodKeyUpdateGroupAnnouncement = @"updateGroupAnnouncement";
static NSString * _Nonnull const ExtSDkMethodKeyUpdateGroupExt = @"updateGroupExt";
static NSString * _Nonnull const ExtSDkMethodKeyJoinPublicGroup = @"joinPublicGroup";
static NSString * _Nonnull const ExtSDkMethodKeyRequestToJoinPublicGroup = @"requestToJoinPublicGroup";
static NSString * _Nonnull const ExtSDkMethodKeyAcceptJoinApplication = @"acceptJoinApplication";
static NSString * _Nonnull const ExtSDkMethodKeyDeclineJoinApplication = @"declineJoinApplication";
static NSString * _Nonnull const ExtSDkMethodKeyAcceptInvitationFromGroup = @"acceptInvitationFromGroup";
static NSString * _Nonnull const ExtSDkMethodKeyDeclineInvitationFromGroup = @"declineInvitationFromGroup";
static NSString * _Nonnull const ExtSDkMethodKeyIgnoreGroupPush = @"ignoreGroupPush";

static NSString * _Nonnull const ExtSDkMethodKeyOnGroupChanged = @"onGroupChanged";

#pragma mark - EMPushManagerWrapper
static NSString * _Nonnull const ExtSDkMethodKeyGetImPushConfig = @"getImPushConfig";
static NSString * _Nonnull const ExtSDkMethodKeyGetImPushConfigFromServer = @"getImPushConfigFromServer";
static NSString * _Nonnull const ExtSDkMethodKeyUpdatePushNickname = @"updatePushNickname";

static NSString * _Nonnull const ExtSDkMethodKeyImPushNoDisturb = @"imPushNoDisturb";
static NSString * _Nonnull const ExtSDkMethodKeyUpdateImPushStyle = @"updateImPushStyle";
static NSString * _Nonnull const ExtSDkMethodKeyUpdateGroupPushService = @"updateGroupPushService";
static NSString * _Nonnull const ExtSDkMethodKeyGetNoDisturbGroups = @"getNoDisturbGroups";
static NSString * _Nonnull const ExtSDkMethodKeyBindDeviceToken = @"updateAPNsPushToken";


#pragma mark - EMUserInfoManagerWrapper
static NSString * _Nonnull const ExtSDkMethodKeyUpdateOwnUserInfo = @"updateOwnUserInfo";
static NSString * _Nonnull const ExtSDkMethodKeyUpdateOwnUserInfoWithType = @"updateOwnUserInfoWithType";
static NSString * _Nonnull const ExtSDkMethodKeyFetchUserInfoById = @"fetchUserInfoById";
static NSString * _Nonnull const ExtSDkMethodKeyFetchUserInfoByIdWithType = @"fetchUserInfoByIdWithType";






#pragma mark - EMClientWrapper value
static const int ExtSDkMethodKeyInitValue = 100;
static const int ExtSDkMethodKeyCreateAccountValue = 101;
static const int ExtSDkMethodKeyLoginValue = 102;
static const int ExtSDkMethodKeyLogoutValue = 103;
static const int ExtSDkMethodKeyChangeAppKeyValue = 104;
static const int ExtSDkMethodKeyIsLoggedInBeforeValue = 105;
static const int ExtSDkMethodKeyUploadLogValue = 106;
static const int ExtSDkMethodKeyCompressLogsValue = 107;
static const int ExtSDkMethodKeyKickDeviceValue = 108;
static const int ExtSDkMethodKeyKickAllDevicesValue = 109;
static const int ExtSDkMethodKeyCurrentUserValue = 110;
static const int ExtSDkMethodKeyGetLoggedInDevicesFromServerValue = 111;

#pragma mark - EMClientDelegate value
static const int ExtSDkMethodKeyOnConnectedValue = 200;
static const int ExtSDkMethodKeyOnDisconnectedValue = 201;
static const int ExtSDkMethodKeyOnMultiDeviceEventValue = 202;

static const int ExtSDkMethodKeySendDataToFlutterValue = 203;

#pragma mark - EMContactManagerWrapper value
static const int ExtSDkMethodKeyAddContactValue = 300;
static const int ExtSDkMethodKeyDeleteContactValue = 301;
static const int ExtSDkMethodKeyGetAllContactsFromServerValue = 302;
static const int ExtSDkMethodKeyGetAllContactsFromDBValue = 303;
static const int ExtSDkMethodKeyAddUserToBlockListValue = 304;
static const int ExtSDkMethodKeyRemoveUserFromBlockListValue = 305;
static const int ExtSDkMethodKeyGetBlockListFromServerValue = 306;
static const int ExtSDkMethodKeyGetBlockListFromDBValue = 307;
static const int ExtSDkMethodKeyAcceptInvitationValue = 308;
static const int ExtSDkMethodKeyDeclineInvitationValue = 309;
static const int ExtSDkMethodKeyGetSelfIdsOnOtherPlatformValue = 310;

#pragma mark - EMContactDelegate value
static const int ExtSDkMethodKeyOnContactChangedValue = 400;

#pragma mark - EMChatManagerWrapper value
static const int ExtSDkMethodKeySendMessageValue = 500;
static const int ExtSDkMethodKeyResendMessageValue = 501;
static const int ExtSDkMethodKeyAckMessageReadValue = 502;
static const int ExtSDkMethodKeyAckGroupMessageReadValue = 503;
static const int ExtSDkMethodKeyAckConversationReadValue = 504;
static const int ExtSDkMethodKeyRecallMessageValue = 505;
static const int ExtSDkMethodKeyGetConversationValue = 506;
static const int ExtSDkMethodKeyMarkAllChatMsgAsReadValue = 507;
static const int ExtSDkMethodKeyGetUnreadMessageCountValue = 508;
static const int ExtSDkMethodKeyUpdateChatMessageValue = 509;
static const int ExtSDkMethodKeyDownloadAttachmentValue = 510;
static const int ExtSDkMethodKeyDownloadThumbnailValue = 511;
static const int ExtSDkMethodKeyImportMessagesValue = 512;
static const int ExtSDkMethodKeyLoadAllConversationsValue = 513;
static const int ExtSDkMethodKeyGetConversationsFromServerValue = 514;

static const int ExtSDkMethodKeyDeleteConversationValue = 515;
//static const int ExtSDkMethodKeySetVoiceMessageListenedValue = 516;
//static const int ExtSDkMethodKeyUpdateParticipantValue = 517;
static const int ExtSDkMethodKeyUpdateConversationsNameValue = 518;
static const int ExtSDkMethodKeyFetchHistoryMessagesValue = 519;
static const int ExtSDkMethodKeySearchChatMsgFromDBValue = 520;
static const int ExtSDkMethodKeyGetMessageValue = 521;
static const int ExtSDkMethodKeyAsyncFetchGroupAcksValue = 522;

#pragma mark - EMChatManagerDelegate value
static const int ExtSDkMethodKeyOnMessagesReceivedValue = 600;
static const int ExtSDkMethodKeyOnCmdMessagesReceivedValue = 601;
static const int ExtSDkMethodKeyOnMessagesReadValue = 602;
static const int ExtSDkMethodKeyOnGroupMessageReadValue = 603;
static const int ExtSDkMethodKeyOnMessagesDeliveredValue = 604;
static const int ExtSDkMethodKeyOnMessagesRecalledValue = 605;

static const int ExtSDkMethodKeyOnConversationUpdateValue = 606;
static const int ExtSDkMethodKeyOnConversationHasReadValue = 607;

#pragma mark - EMMessageListener value
static const int ExtSDkMethodKeyOnMessageProgressUpdateValue = 1200;
static const int ExtSDkMethodKeyOnMessageSuccessValue = 1201;
static const int ExtSDkMethodKeyOnMessageErrorValue = 1202;
static const int ExtSDkMethodKeyOnMessageReadAckValue = 1203;
static const int ExtSDkMethodKeyOnMessageDeliveryAckValue = 1204;
static const int ExtSDkMethodKeyOnMessageStatusChangedValue = 1205;

#pragma mark - EMConversationWrapper value

static const int ExtSDkMethodKeyGetUnreadMsgCountValue = 700;
static const int ExtSDkMethodKeyMarkAllMsgsAsReadValue = 701;
static const int ExtSDkMethodKeyMarkMsgAsReadValue = 702;
static const int ExtSDkMethodKeySyncConversationExtValue = 703;
static const int ExtSDkMethodKeySyncConversationNameValue = 704;
static const int ExtSDkMethodKeyRemoveMsgValue = 705;
static const int ExtSDkMethodKeyGetLatestMsgValue = 706;
static const int ExtSDkMethodKeyGetLatestMsgFromOthersValue = 707;
static const int ExtSDkMethodKeyClearAllMsgValue = 708;
static const int ExtSDkMethodKeyInsertMsgValue = 709;
static const int ExtSDkMethodKeyAppendMsgValue = 710;
static const int ExtSDkMethodKeyUpdateConversationMsgValue = 711;

static const int ExtSDkMethodKeyLoadMsgWithIdValue = 712;
static const int ExtSDkMethodKeyLoadMsgWithStartIdValue = 713;
static const int ExtSDkMethodKeyLoadMsgWithKeywordsValue = 714;
static const int ExtSDkMethodKeyLoadMsgWithMsgTypeValue = 715;
static const int ExtSDkMethodKeyLoadMsgWithTimeValue = 716;

#pragma mark - EMChatroomManagerWrapper value

static const int ExtSDkMethodKeyJoinChatRoomValue = 800;
static const int ExtSDkMethodKeyLeaveChatRoomValue = 801;
static const int ExtSDkMethodKeyGetChatroomsFromServerValue = 802;
static const int ExtSDkMethodKeyFetchChatRoomFromServerValue = 803;
static const int ExtSDkMethodKeyGetChatRoomValue = 804;
static const int ExtSDkMethodKeyGetAllChatRoomsValue = 805;
static const int ExtSDkMethodKeyCreateChatRoomValue = 806;
static const int ExtSDkMethodKeyDestroyChatRoomValue = 807;
static const int ExtSDkMethodKeyChatRoomUpdateSubjectValue = 808;
static const int ExtSDkMethodKeyChatRoomUpdateDescriptionValue = 809;
static const int ExtSDkMethodKeyGetChatroomMemberListFromServerValue = 810;
static const int ExtSDkMethodKeyChatRoomMuteMembersValue = 811;
static const int ExtSDkMethodKeyChatRoomUnmuteMembersValue = 812;
static const int ExtSDkMethodKeyChangeChatRoomOwnerValue = 813;
static const int ExtSDkMethodKeyChatRoomAddAdminValue = 814;
static const int ExtSDkMethodKeyChatRoomRemoveAdminValue = 815;
static const int ExtSDkMethodKeyGetChatroomMuteListFromServerValue = 816;
static const int ExtSDkMethodKeyChatRoomRemoveMembersValue = 817;
static const int ExtSDkMethodKeyChatRoomBlockMembersValue = 818;
static const int ExtSDkMethodKeyChatRoomUnblockMembersValue = 819;
static const int ExtSDkMethodKeyFetchChatroomBlockListFromServerValue = 820;
static const int ExtSDkMethodKeyUpdateChatRoomAnnouncementValue = 821;
static const int ExtSDkMethodKeyFetchChatroomAnnouncementValue = 822;

static const int ExtSDkMethodKeyAddMembersToChatRoomWhiteListValue = 823;
static const int ExtSDkMethodKeyRemoveMembersFromChatRoomWhiteListValue = 824;
static const int ExtSDkMethodKeyFetchChatRoomWhiteListFromServerValue = 825;
static const int ExtSDkMethodKeyIsMemberInChatRoomWhiteListFromServerValue = 826;

static const int ExtSDkMethodKeyMuteAllChatRoomMembersValue = 827;
static const int ExtSDkMethodKeyUnMuteAllChatRoomMembersValue = 828;


static const int ExtSDkMethodKeyChatroomChangedValue = 829;

#pragma mark - EMGroupManagerWrapper value

static const int ExtSDkMethodKeyGetGroupWithIdValue = 900;
static const int ExtSDkMethodKeyGetJoinedGroupsValue = 901;
static const int ExtSDkMethodKeyGetGroupsWithoutPushNotificationValue = 902;
static const int ExtSDkMethodKeyGetJoinedGroupsFromServerValue = 903;
static const int ExtSDkMethodKeyGetPublicGroupsFromServerValue = 904;
static const int ExtSDkMethodKeyCreateGroupValue = 905;
static const int ExtSDkMethodKeyGetGroupSpecificationFromServerValue = 906;
static const int ExtSDkMethodKeyGetGroupMemberListFromServerValue = 907;
static const int ExtSDkMethodKeyGetGroupBlockListFromServerValue = 908;
static const int ExtSDkMethodKeyGetGroupMuteListFromServerValue = 909;
static const int ExtSDkMethodKeyGetGroupWhiteListFromServerValue = 910;
static const int ExtSDkMethodKeyIsMemberInWhiteListFromServerValue = 911;
static const int ExtSDkMethodKeyGetGroupFileListFromServerValue = 912;
static const int ExtSDkMethodKeyGetGroupAnnouncementFromServerValue = 913;
static const int ExtSDkMethodKeyAddMembersValue = 914;
static const int ExtSDkMethodKeyInviterUserValue = 915;
static const int ExtSDkMethodKeyRemoveMembersValue = 916;
static const int ExtSDkMethodKeyBlockMembersValue = 917;
static const int ExtSDkMethodKeyUnblockMembersValue = 918;
static const int ExtSDkMethodKeyUpdateGroupSubjectValue = 919;
static const int ExtSDkMethodKeyUpdateDescriptionValue = 920;
static const int ExtSDkMethodKeyLeaveGroupValue = 921;
static const int ExtSDkMethodKeyDestroyGroupValue = 922;
static const int ExtSDkMethodKeyBlockGroupValue = 923;
static const int ExtSDkMethodKeyUnblockGroupValue = 924;
static const int ExtSDkMethodKeyUpdateGroupOwnerValue = 925;
static const int ExtSDkMethodKeyAddAdminValue = 926;
static const int ExtSDkMethodKeyRemoveAdminValue = 927;
static const int ExtSDkMethodKeyMuteMembersValue = 928;
static const int ExtSDkMethodKeyUnMuteMembersValue = 929;
static const int ExtSDkMethodKeyMuteAllMembersValue = 930;
static const int ExtSDkMethodKeyUnMuteAllMembersValue = 931;
static const int ExtSDkMethodKeyAddWhiteListValue = 932;
static const int ExtSDkMethodKeyRemoveWhiteListValue = 933;
static const int ExtSDkMethodKeyUploadGroupSharedFileValue = 934;
static const int ExtSDkMethodKeyDownloadGroupSharedFileValue = 935;
static const int ExtSDkMethodKeyRemoveGroupSharedFileValue = 936;
static const int ExtSDkMethodKeyUpdateGroupAnnouncementValue = 937;
static const int ExtSDkMethodKeyUpdateGroupExtValue = 938;
static const int ExtSDkMethodKeyJoinPublicGroupValue = 939;
static const int ExtSDkMethodKeyRequestToJoinPublicGroupValue = 940;
static const int ExtSDkMethodKeyAcceptJoinApplicationValue = 941;
static const int ExtSDkMethodKeyDeclineJoinApplicationValue = 942;
static const int ExtSDkMethodKeyAcceptInvitationFromGroupValue = 943;
static const int ExtSDkMethodKeyDeclineInvitationFromGroupValue = 944;
static const int ExtSDkMethodKeyIgnoreGroupPushValue = 945;

static const int ExtSDkMethodKeyOnGroupChangedValue = 946;

#pragma mark - EMPushManagerWrapper value
static const int ExtSDkMethodKeyGetImPushConfigValue = 1000;
static const int ExtSDkMethodKeyGetImPushConfigFromServerValue = 1001;
static const int ExtSDkMethodKeyUpdatePushNicknameValue = 1002;

static const int ExtSDkMethodKeyImPushNoDisturbValue = 1003;
static const int ExtSDkMethodKeyUpdateImPushStyleValue = 1004;
static const int ExtSDkMethodKeyUpdateGroupPushServiceValue = 1005;
static const int ExtSDkMethodKeyGetNoDisturbGroupsValue = 1006;
static const int ExtSDkMethodKeyBindDeviceTokenValue = 1007;


#pragma mark - EMUserInfoManagerWrapper value
static const int ExtSDkMethodKeyUpdateOwnUserInfoValue = 1100;
static const int ExtSDkMethodKeyUpdateOwnUserInfoWithTypeValue = 1101;
static const int ExtSDkMethodKeyFetchUserInfoByIdValue = 1102;
static const int ExtSDkMethodKeyFetchUserInfoByIdWithTypeValue = 1103;

@interface ExtSdkMethodTypeObjc : NSObject

+ (int)getEnumValue:(nonnull NSString*)key;

@end
