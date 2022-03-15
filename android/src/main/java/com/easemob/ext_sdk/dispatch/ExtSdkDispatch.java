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
        try {
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
                case ExtSdkMethodType.addContact: EMContactManagerWrapper.getInstance().addContact(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.deleteContact: EMContactManagerWrapper.getInstance().deleteContact(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getAllContactsFromServer: EMContactManagerWrapper.getInstance().getAllContactsFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getAllContactsFromDB: EMContactManagerWrapper.getInstance().getAllContactsFromDB(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.addUserToBlockList: EMContactManagerWrapper.getInstance().addUserToBlockList(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.removeUserFromBlockList: EMContactManagerWrapper.getInstance().removeUserFromBlockList(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getBlockListFromServer: EMContactManagerWrapper.getInstance().getBlockListFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getBlockListFromDB: EMContactManagerWrapper.getInstance().getBlockListFromDB(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.acceptInvitation: EMContactManagerWrapper.getInstance().acceptInvitation(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.declineInvitation: EMContactManagerWrapper.getInstance().declineInvitation(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getSelfIdsOnOtherPlatform: EMContactManagerWrapper.getInstance().getSelfIdsOnOtherPlatform(jsonParams, methodType, callback); break;


                case ExtSdkMethodType.onContactChanged: callback.fail(1, "no implement: " + methodType); break;

/// EMChatManager methods
                case ExtSdkMethodType.sendMessage: EMChatManagerWrapper.getInstance().sendMessage(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.resendMessage: EMChatManagerWrapper.getInstance().resendMessage(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.ackMessageRead: EMChatManagerWrapper.getInstance().ackMessageRead(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.ackGroupMessageRead: EMChatManagerWrapper.getInstance().ackGroupMessageRead(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.ackConversationRead: EMChatManagerWrapper.getInstance().ackConversationRead(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.recallMessage: EMChatManagerWrapper.getInstance().recallMessage(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getConversation: EMChatManagerWrapper.getInstance().getConversation(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.markAllChatMsgAsRead: EMChatManagerWrapper.getInstance().markAllChatMsgAsRead(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getUnreadMessageCount: EMChatManagerWrapper.getInstance().getUnreadMessageCount(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.updateChatMessage: EMChatManagerWrapper.getInstance().updateChatMessage(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.downloadAttachment: EMChatManagerWrapper.getInstance().downloadAttachment(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.downloadThumbnail: EMChatManagerWrapper.getInstance().downloadThumbnail(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.importMessages: EMChatManagerWrapper.getInstance().importMessages(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.loadAllConversations: EMChatManagerWrapper.getInstance().loadAllConversations(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getConversationsFromServer: EMChatManagerWrapper.getInstance().getConversationsFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.deleteConversation: EMChatManagerWrapper.getInstance().deleteConversation(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.fetchHistoryMessages: EMChatManagerWrapper.getInstance().fetchHistoryMessages(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.searchChatMsgFromDB: EMChatManagerWrapper.getInstance().searchChatMsgFromDB(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getMessage: EMChatManagerWrapper.getInstance().getMessage(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.asyncFetchGroupAcks: EMChatManagerWrapper.getInstance().asyncFetchGroupAcks(jsonParams, methodType, callback); break;

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
                case ExtSdkMethodType.getUnreadMsgCount: EMConversationWrapper.getInstance().getUnreadMsgCount(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.markAllMessagesAsRead: EMConversationWrapper.getInstance().markAllMessagesAsRead(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.markMessageAsRead: EMConversationWrapper.getInstance().markMessageAsRead(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.syncConversationExt: EMConversationWrapper.getInstance().syncConversationExt(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.syncConversationName: EMConversationWrapper.getInstance().syncConversationName(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.removeMessage: EMConversationWrapper.getInstance().removeMessage(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getLatestMessage: EMConversationWrapper.getInstance().getLatestMessage(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getLatestMessageFromOthers: EMConversationWrapper.getInstance().getLatestMessageFromOthers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.clearAllMessages: EMConversationWrapper.getInstance().clearAllMessages(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.insertMessage: EMConversationWrapper.getInstance().insertMessage(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.appendMessage: EMConversationWrapper.getInstance().appendMessage(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.updateConversationMessage: EMConversationWrapper.getInstance().updateConversationMessage(jsonParams, methodType, callback); break;

// 根据消息id获取消息
                case ExtSdkMethodType.loadMsgWithId: EMConversationWrapper.getInstance().loadMsgWithId(jsonParams, methodType, callback); break;
// 根据起始消息id获取消息
                case ExtSdkMethodType.loadMsgWithStartId: EMConversationWrapper.getInstance().loadMsgWithStartId(jsonParams, methodType, callback); break;
// 根据关键字获取消息
                case ExtSdkMethodType.loadMsgWithKeywords: EMConversationWrapper.getInstance().loadMsgWithKeywords(jsonParams, methodType, callback); break;
// 根据消息类型获取消息
                case ExtSdkMethodType.loadMsgWithMsgType: EMConversationWrapper.getInstance().loadMsgWithMsgType(jsonParams, methodType, callback); break;
// 通过时间获取消息
                case ExtSdkMethodType.loadMsgWithTime: EMConversationWrapper.getInstance().loadMsgWithTime(jsonParams, methodType, callback); break;

// EMChatRoomManager
                case ExtSdkMethodType.joinChatRoom: EMChatRoomManagerWrapper.getInstance().joinChatRoom(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.leaveChatRoom: EMChatRoomManagerWrapper.getInstance().leaveChatRoom(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.fetchPublicChatRoomsFromServer: EMChatRoomManagerWrapper.getInstance().fetchPublicChatRoomsFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.fetchChatRoomInfoFromServer: EMChatRoomManagerWrapper.getInstance().fetchChatRoomInfoFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getChatRoom: EMChatRoomManagerWrapper.getInstance().getChatRoom(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getAllChatRooms: EMChatRoomManagerWrapper.getInstance().getAllChatRooms(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.createChatRoom: EMChatRoomManagerWrapper.getInstance().createChatRoom(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.destroyChatRoom: EMChatRoomManagerWrapper.getInstance().destroyChatRoom(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.changeChatRoomSubject: EMChatRoomManagerWrapper.getInstance().changeChatRoomSubject(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.changeChatRoomDescription: EMChatRoomManagerWrapper.getInstance().changeChatRoomDescription(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.fetchChatRoomMembers: EMChatRoomManagerWrapper.getInstance().fetchChatRoomMembers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.muteChatRoomMembers: EMChatRoomManagerWrapper.getInstance().muteChatRoomMembers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.unMuteChatRoomMembers: EMChatRoomManagerWrapper.getInstance().unMuteChatRoomMembers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.changeChatRoomOwner: EMChatRoomManagerWrapper.getInstance().changeChatRoomOwner(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.addChatRoomAdmin: EMChatRoomManagerWrapper.getInstance().addChatRoomAdmin(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.removeChatRoomAdmin: EMChatRoomManagerWrapper.getInstance().removeChatRoomAdmin(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.fetchChatRoomMuteList: EMChatRoomManagerWrapper.getInstance().fetchChatRoomMuteList(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.removeChatRoomMembers: EMChatRoomManagerWrapper.getInstance().removeChatRoomMembers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.blockChatRoomMembers: EMChatRoomManagerWrapper.getInstance().blockChatRoomMembers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.unBlockChatRoomMembers: EMChatRoomManagerWrapper.getInstance().unBlockChatRoomMembers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.fetchChatRoomBlockList: EMChatRoomManagerWrapper.getInstance().fetchChatRoomBlockList(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.updateChatRoomAnnouncement: EMChatRoomManagerWrapper.getInstance().updateChatRoomAnnouncement(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.fetchChatRoomAnnouncement: EMChatRoomManagerWrapper.getInstance().fetchChatRoomAnnouncement(jsonParams, methodType, callback); break;

                case ExtSdkMethodType.addMembersToChatRoomWhiteList: EMChatRoomManagerWrapper.getInstance().addMembersToChatRoomWhiteList(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.removeMembersFromChatRoomWhiteList: EMChatRoomManagerWrapper.getInstance().removeMembersFromChatRoomWhiteList(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.fetchChatRoomWhiteListFromServer: EMChatRoomManagerWrapper.getInstance().fetchChatRoomWhiteListFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.isMemberInChatRoomWhiteListFromServer: EMChatRoomManagerWrapper.getInstance().isMemberInChatRoomWhiteListFromServer(jsonParams, methodType, callback); break;

                case ExtSdkMethodType.muteAllChatRoomMembers: EMChatRoomManagerWrapper.getInstance().muteAllChatRoomMembers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.unMuteAllChatRoomMembers: EMChatRoomManagerWrapper.getInstance().unMuteAllChatRoomMembers(jsonParams, methodType, callback); break;


// EMChatRoomManagerListener
                case ExtSdkMethodType.chatRoomChange: callback.fail(1, "no implement: " + methodType); break;

/// EMGroupManager
                case ExtSdkMethodType.getGroupWithId: EMGroupManagerWrapper.getInstance().getGroupWithId(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getJoinedGroups: EMGroupManagerWrapper.getInstance().getJoinedGroups(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getGroupsWithoutPushNotification: EMGroupManagerWrapper.getInstance().getGroupsWithoutPushNotification(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getJoinedGroupsFromServer: EMGroupManagerWrapper.getInstance().getJoinedGroupsFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getPublicGroupsFromServer: EMGroupManagerWrapper.getInstance().getPublicGroupsFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.createGroup: EMGroupManagerWrapper.getInstance().createGroup(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getGroupSpecificationFromServer: EMGroupManagerWrapper.getInstance().getGroupSpecificationFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getGroupMemberListFromServer: EMGroupManagerWrapper.getInstance().getGroupMemberListFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getGroupBlockListFromServer: EMGroupManagerWrapper.getInstance().getGroupBlockListFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getGroupMuteListFromServer: EMGroupManagerWrapper.getInstance().getGroupMuteListFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getGroupWhiteListFromServer: EMGroupManagerWrapper.getInstance().getGroupWhiteListFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.isMemberInWhiteListFromServer: EMGroupManagerWrapper.getInstance().isMemberInWhiteListFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getGroupFileListFromServer: EMGroupManagerWrapper.getInstance().getGroupFileListFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.getGroupAnnouncementFromServer: EMGroupManagerWrapper.getInstance().getGroupAnnouncementFromServer(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.addMembers: EMGroupManagerWrapper.getInstance().addMembers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.inviterUser: EMGroupManagerWrapper.getInstance().inviterUser(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.removeMembers: EMGroupManagerWrapper.getInstance().removeMembers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.blockMembers: EMGroupManagerWrapper.getInstance().blockMembers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.unblockMembers: EMGroupManagerWrapper.getInstance().unblockMembers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.updateGroupSubject: EMGroupManagerWrapper.getInstance().updateGroupSubject(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.updateDescription: EMGroupManagerWrapper.getInstance().updateDescription(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.leaveGroup: EMGroupManagerWrapper.getInstance().leaveGroup(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.destroyGroup: EMGroupManagerWrapper.getInstance().destroyGroup(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.blockGroup: EMGroupManagerWrapper.getInstance().blockGroup(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.unblockGroup: EMGroupManagerWrapper.getInstance().unblockGroup(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.updateGroupOwner: EMGroupManagerWrapper.getInstance().updateGroupOwner(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.addAdmin: EMGroupManagerWrapper.getInstance().addAdmin(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.removeAdmin: EMGroupManagerWrapper.getInstance().removeAdmin(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.muteMembers: EMGroupManagerWrapper.getInstance().muteMembers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.unMuteMembers: EMGroupManagerWrapper.getInstance().unMuteMembers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.muteAllMembers: EMGroupManagerWrapper.getInstance().muteAllMembers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.unMuteAllMembers: EMGroupManagerWrapper.getInstance().unMuteAllMembers(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.addWhiteList: EMGroupManagerWrapper.getInstance().addWhiteList(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.removeWhiteList: EMGroupManagerWrapper.getInstance().removeWhiteList(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.uploadGroupSharedFile: EMGroupManagerWrapper.getInstance().uploadGroupSharedFile(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.downloadGroupSharedFile: EMGroupManagerWrapper.getInstance().downloadGroupSharedFile(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.removeGroupSharedFile: EMGroupManagerWrapper.getInstance().removeGroupSharedFile(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.updateGroupAnnouncement: EMGroupManagerWrapper.getInstance().updateGroupAnnouncement(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.updateGroupExt: EMGroupManagerWrapper.getInstance().updateGroupExt(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.joinPublicGroup: EMGroupManagerWrapper.getInstance().joinPublicGroup(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.requestToJoinPublicGroup: EMGroupManagerWrapper.getInstance().requestToJoinPublicGroup(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.acceptJoinApplication: EMGroupManagerWrapper.getInstance().acceptJoinApplication(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.declineJoinApplication: EMGroupManagerWrapper.getInstance().declineJoinApplication(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.acceptInvitationFromGroup: EMGroupManagerWrapper.getInstance().acceptInvitationFromGroup(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.declineInvitationFromGroup: EMGroupManagerWrapper.getInstance().declineInvitationFromGroup(jsonParams, methodType, callback); break;
                case ExtSdkMethodType.ignoreGroupPush: EMGroupManagerWrapper.getInstance().ignoreGroupPush(jsonParams, methodType, callback); break;

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
        } catch (JSONException e) {
            EMWrapper.onError(callback, e, null);
        }
    }

    public void onReceive(@NonNull String methodType, @Nullable Object data) {
        listener.onReceive(methodType, data);
    }

    private ExtSdkListener listener;
}
