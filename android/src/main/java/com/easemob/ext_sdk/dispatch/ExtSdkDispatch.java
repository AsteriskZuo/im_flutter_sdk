package com.easemob.ext_sdk.dispatch;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.easemob.ext_sdk.common.ExtSdkApi;
import com.easemob.ext_sdk.common.ExtSdkCallback;
import com.easemob.ext_sdk.common.ExtSdkListener;
import com.easemob.ext_sdk.common.ExtSdkMethodType;

import org.json.JSONException;
import org.json.JSONObject;

public class ExtSdkDispatch implements ExtSdkApi {

    private static class SingleHolder {
        static ExtSdkDispatch instance = new ExtSdkDispatch();
    }

    public static ExtSdkDispatch getInstance() {
        return ExtSdkDispatch.SingleHolder.instance;
    }

    @Override
    public void init(@NonNull Object config) {

    }

    @Override
    public void unInit(@Nullable Object params) {

    }

    @Override
    public void addListener(@NonNull ExtSdkListener listener) {
        this.listener = listener;
    }

    @Override
    public void delListener(@NonNull ExtSdkListener listener) {

    }

    @Override
    public void callSdkApi(@NonNull String methodType, @Nullable Object params, @NonNull ExtSdkCallback callback) {
        JSONObject jsonParams = (JSONObject)params;
        switch (methodType) {
            /// EMClient methods
            case ExtSdkMethodType.init: EMClientWrapper.getInstance().init(jsonParams, methodType, callback); break;
            case ExtSdkMethodType.createAccount: EMClientWrapper.getInstance().createAccount(jsonParams, methodType, callback); break;
            case ExtSdkMethodType.login: EMClientWrapper.getInstance().login(jsonParams, methodType, callback); break;
            case ExtSdkMethodType.logout: EMClientWrapper.getInstance().logout(jsonParams, methodType, callback); break;
            case ExtSdkMethodType.changeAppKey: EMClientWrapper.getInstance().changeAppKey(jsonParams, methodType, callback); break;
            case ExtSdkMethodType.isLoggedInBefore: EMClientWrapper.getInstance().isLoggedInBefore(jsonParams, methodType, callback); break;
            case ExtSdkMethodType.updateCurrentUserNick: EMClientWrapper.getInstance().updateCurrentUserNick(jsonParams, methodType, callback); break;
            case ExtSdkMethodType.uploadLog: EMClientWrapper.getInstance().uploadLog(jsonParams, methodType, callback); break;
            case ExtSdkMethodType.compressLogs: EMClientWrapper.getInstance().compressLogs(jsonParams, methodType, callback); break;
            case ExtSdkMethodType.kickDevice: EMClientWrapper.getInstance().kickDevice(jsonParams, methodType, callback); break;
            case ExtSdkMethodType.kickAllDevices: EMClientWrapper.getInstance().kickAllDevices(jsonParams, methodType, callback); break;
            case ExtSdkMethodType.getLoggedInDevicesFromServer: EMClientWrapper.getInstance().getLoggedInDevicesFromServer(jsonParams, methodType, callback); break;
            case ExtSdkMethodType.getCurrentUser: EMClientWrapper.getInstance().getCurrentUser(jsonParams, methodType, callback); break;

            case ExtSdkMethodType.onConnected: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.onDisconnected: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.onMultiDeviceEvent: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.onSendDataToFlutter: callback.fail(1, "no implement: " + methodType); break;

/// EMContactManager methods
            case ExtSdkMethodType.addContact: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.deleteContact: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getAllContactsFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getAllContactsFromDB: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.addUserToBlockList: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.removeUserFromBlockList: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getBlockListFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getBlockListFromDB: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.acceptInvitation: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.declineInvitation: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getSelfIdsOnOtherPlatform: callback.fail(1, "no implement: " + methodType); break;


            case ExtSdkMethodType.onContactChanged: callback.fail(1, "no implement: " + methodType); break;

/// EMChatManager methods
            case ExtSdkMethodType.sendMessage: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.resendMessage: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.ackMessageRead: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.ackGroupMessageRead: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.ackConversationRead: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.recallMessage: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getConversation: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.markAllChatMsgAsRead: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getUnreadMessageCount: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.updateChatMessage: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.downloadAttachment: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.downloadThumbnail: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.importMessages: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.loadAllConversations: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getConversationsFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.deleteConversation: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.fetchHistoryMessages: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.searchChatMsgFromDB: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getMessage: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.asyncFetchGroupAcks: callback.fail(1, "no implement: " + methodType); break;

/// EMChatManager listener
            case ExtSdkMethodType.onMessagesReceived: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.onCmdMessagesReceived: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.onMessagesRead: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.onGroupMessageRead: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.onMessagesDelivered: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.onMessagesRecalled: callback.fail(1, "no implement: " + methodType); break;

            case ExtSdkMethodType.onConversationUpdate: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.onConversationHasRead: callback.fail(1, "no implement: " + methodType); break;

/// EMMessage listener
            case ExtSdkMethodType.onMessageProgressUpdate: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.onMessageError: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.onMessageSuccess: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.onMessageReadAck: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.onMessageDeliveryAck: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.onMessageStatusChanged: callback.fail(1, "no implement: " + methodType); break;

/// EMConversation
            case ExtSdkMethodType.getUnreadMsgCount: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.markAllMessagesAsRead: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.markMessageAsRead: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.syncConversationExt: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.syncConversationName: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.removeMessage: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getLatestMessage: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getLatestMessageFromOthers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.clearAllMessages: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.insertMessage: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.appendMessage: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.updateConversationMessage: callback.fail(1, "no implement: " + methodType); break;

// 根据消息id获取消息
            case ExtSdkMethodType.loadMsgWithId: callback.fail(1, "no implement: " + methodType); break;
// 根据起始消息id获取消息
            case ExtSdkMethodType.loadMsgWithStartId: callback.fail(1, "no implement: " + methodType); break;
// 根据关键字获取消息
            case ExtSdkMethodType.loadMsgWithKeywords: callback.fail(1, "no implement: " + methodType); break;
// 根据消息类型获取消息
            case ExtSdkMethodType.loadMsgWithMsgType: callback.fail(1, "no implement: " + methodType); break;
// 通过时间获取消息
            case ExtSdkMethodType.loadMsgWithTime: callback.fail(1, "no implement: " + methodType); break;

// EMChatRoomManager
            case ExtSdkMethodType.joinChatRoom: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.leaveChatRoom: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.fetchPublicChatRoomsFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.fetchChatRoomInfoFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getChatRoom: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getAllChatRooms: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.createChatRoom: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.destroyChatRoom: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.changeChatRoomSubject: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.changeChatRoomDescription: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.fetchChatRoomMembers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.muteChatRoomMembers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.unMuteChatRoomMembers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.changeChatRoomOwner: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.addChatRoomAdmin: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.removeChatRoomAdmin: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.fetchChatRoomMuteList: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.removeChatRoomMembers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.blockChatRoomMembers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.unBlockChatRoomMembers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.fetchChatRoomBlockList: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.updateChatRoomAnnouncement: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.fetchChatRoomAnnouncement: callback.fail(1, "no implement: " + methodType); break;

            case ExtSdkMethodType.addMembersToChatRoomWhiteList: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.removeMembersFromChatRoomWhiteList: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.fetchChatRoomWhiteListFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.isMemberInChatRoomWhiteListFromServer: callback.fail(1, "no implement: " + methodType); break;

            case ExtSdkMethodType.muteAllChatRoomMembers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.unMuteAllChatRoomMembers: callback.fail(1, "no implement: " + methodType); break;


// EMChatRoomManagerListener
            case ExtSdkMethodType.chatRoomChange: callback.fail(1, "no implement: " + methodType); break;

/// EMGroupManager
            case ExtSdkMethodType.getGroupWithId: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getJoinedGroups: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getGroupsWithoutPushNotification: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getJoinedGroupsFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getPublicGroupsFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.createGroup: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getGroupSpecificationFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getGroupMemberListFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getGroupBlockListFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getGroupMuteListFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getGroupWhiteListFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.isMemberInWhiteListFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getGroupFileListFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getGroupAnnouncementFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.addMembers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.inviterUser: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.removeMembers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.blockMembers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.unblockMembers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.updateGroupSubject: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.updateDescription: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.leaveGroup: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.destroyGroup: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.blockGroup: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.unblockGroup: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.updateGroupOwner: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.addAdmin: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.removeAdmin: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.muteMembers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.unMuteMembers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.muteAllMembers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.unMuteAllMembers: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.addWhiteList: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.removeWhiteList: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.uploadGroupSharedFile: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.downloadGroupSharedFile: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.removeGroupSharedFile: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.updateGroupAnnouncement: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.updateGroupExt: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.joinPublicGroup: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.requestToJoinPublicGroup: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.acceptJoinApplication: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.declineJoinApplication: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.acceptInvitationFromGroup: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.declineInvitationFromGroup: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.ignoreGroupPush: callback.fail(1, "no implement: " + methodType); break;

/// EMGroupManagerListener
            case ExtSdkMethodType.onGroupChanged: callback.fail(1, "no implement: " + methodType); break;

/// EMPushManager
            case ExtSdkMethodType.getImPushConfig: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getImPushConfigFromServer: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.updatePushNickname: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.updateHMSPushToken: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.updateFCMPushToken: callback.fail(1, "no implement: " + methodType); break;

/// ImPushConfig
            case ExtSdkMethodType.imPushNoDisturb: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.updateImPushStyle: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.updateGroupPushService: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.getNoDisturbGroups: callback.fail(1, "no implement: " + methodType); break;


/// EMUserInfoManager
            case ExtSdkMethodType.updateOwnUserInfo: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.updateOwnUserInfoWithType: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.fetchUserInfoById: callback.fail(1, "no implement: " + methodType); break;
            case ExtSdkMethodType.fetchUserInfoByIdWithType: callback.fail(1, "no implement: " + methodType); break;

            default: callback.fail(1, "no implement: " + methodType); break;
        }
    }

    public void onReceive(@NonNull String methodType, @Nullable Object data) {
        listener.onReceive(methodType, data);
    }

    private ExtSdkListener listener;
}
