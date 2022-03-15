package com.easemob.ext_sdk.dispatch;


import com.easemob.ext_sdk.common.ExtSdkCallback;
import com.easemob.ext_sdk.common.ExtSdkMethodType;
import com.easemob.ext_sdk.common.ExtSdkThreadUtil;
import com.hyphenate.EMCallBack;
import com.hyphenate.EMGroupChangeListener;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMGroupInfo;
import com.hyphenate.chat.EMGroupOptions;
import com.hyphenate.chat.EMMucSharedFile;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.EMLog;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class EMGroupManagerWrapper extends EMWrapper {

    public static class SingleHolder {
        static EMGroupManagerWrapper instance = new EMGroupManagerWrapper();
    }

    public static EMGroupManagerWrapper getInstance() {
        return EMGroupManagerWrapper.SingleHolder.instance;
    }

    EMGroupManagerWrapper() {
        registerEaseListener();
    }

    public void getGroupWithId(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
        if (group != null) {
            onSuccess(result, channelName, EMGroupHelper.toJson(group));
        } else {
            onSuccess(result, channelName, null);
        }
    }

    public void getJoinedGroups(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        List<EMGroup> groups = EMClient.getInstance().groupManager().getAllGroups();
        onSuccess(result, channelName, groups);
    }

    public void getGroupsWithoutPushNotification(JSONObject param, String channelName, ExtSdkCallback result)
            throws JSONException {
        List<String> groups = EMClient.getInstance().pushManager().getNoPushGroups();
        onSuccess(result, channelName, groups);
    }

    public void getJoinedGroupsFromServer(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {

        int pageSize = param.getInt("pageSize");
        int pageNum = param.getInt("pageNum");

        EMClient.getInstance().groupManager().asyncGetJoinedGroupsFromServer(pageNum, pageSize, new EMValueCallBack<List<EMGroup>>() {
            @Override
            public void onSuccess(List<EMGroup> value) {
                List<Map> groupList = new ArrayList<>();
                for (EMGroup group : value) {
                    groupList.add(EMGroupHelper.toJson(group));
                }
                EMWrapper.onSuccess(result, channelName, groupList);
            }

            @Override
            public void onError(int error, String errorMsg) {
                EMWrapper.onError(result, error, errorMsg);
            }
        });
    }

    public void getPublicGroupsFromServer(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        int pageSize = param.getInt("pageSize");
        String cursor = param.getString("cursor");
        EMClient.getInstance().groupManager().asyncGetPublicGroupsFromServer(pageSize, cursor, new EMValueCallBack<EMCursorResult<EMGroupInfo>>() {
            @Override
            public void onSuccess(EMCursorResult<EMGroupInfo> value) {
                EMWrapper.onSuccess(result, channelName, EMCursorResultHelper.toJson(value));
            }

            @Override
            public void onError(int error, String errorMsg) {
                EMWrapper.onError(result, error, errorMsg);
            }
        });
    }

    public void createGroup(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupName = param.getString("groupName");
        String desc = param.getString("desc");
        JSONArray inviteMembers = param.getJSONArray("inviteMembers");
        String[] members = new String[inviteMembers.length()];
        for (int i = 0; i < inviteMembers.length(); i++) {
            members[i] = inviteMembers.getString(i);
        }
        String inviteReason = param.getString("inviteReason");
        EMGroupOptions options = EMGroupOptionsHelper.fromJson(param.getJSONObject("options"));
        EMClient.getInstance().groupManager().asyncCreateGroup(groupName, desc, members, inviteReason, options, new EMValueCallBack<EMGroup>() {
            @Override
            public void onSuccess(EMGroup value) {
                EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(value));
            }

            @Override
            public void onError(int error, String errorMsg) {
                EMWrapper.onError(result, error, errorMsg);
            }
        });
    }

    public void getGroupSpecificationFromServer(JSONObject param, String channelName, ExtSdkCallback result)
            throws JSONException {
        String groupId = param.getString("groupId");
        EMClient.getInstance().groupManager().asyncGetGroupFromServer(groupId, new EMValueCallBack<EMGroup>() {
            @Override
            public void onSuccess(EMGroup value) {
                EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(value));
            }

            @Override
            public void onError(int error, String errorMsg) {
                EMWrapper.onError(result, error, errorMsg);
            }
        });
    }

    public void getGroupMemberListFromServer(JSONObject param, String channelName, ExtSdkCallback result)
            throws JSONException {
        String groupId = param.getString("groupId");
        String cursor = param.getString("cursor");
        int pageSize = param.getInt("pageSize");
        EMClient.getInstance().groupManager().asyncFetchGroupMembers(groupId, cursor, pageSize, new EMValueCallBack<EMCursorResult<String>>() {
            @Override
            public void onSuccess(EMCursorResult<String> value) {
                EMWrapper.onSuccess(result, channelName, EMCursorResultHelper.toJson(value));
            }

            @Override
            public void onError(int error, String errorMsg) {
                EMWrapper.onError(result, error, errorMsg);
            }
        });

    }

    public void getGroupBlockListFromServer(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        int pageNum = param.getInt("pageNum");
        int pageSize = param.getInt("pageSize");
        EMClient.getInstance().groupManager().asyncGetBlockedUsers(groupId, pageNum, pageSize, new EMValueCallBack<List<String>>() {
                    @Override
                    public void onSuccess(List<String> value) {
                        EMWrapper.onSuccess(result, channelName, value);
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        EMWrapper.onError(result, error, errorMsg);
                    }
                });
    }

    public void getGroupMuteListFromServer(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        int pageNum = param.getInt("pageNum");
        int pageSize = param.getInt("pageSize");
        EMClient.getInstance().groupManager().asyncFetchGroupMuteList(groupId, pageNum, pageSize, new EMValueCallBack<Map<String, Long>>() {
                    @Override
                    public void onSuccess(Map<String, Long> value) {
                        EMWrapper.onSuccess(result, channelName, value.keySet().toArray());
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        EMWrapper.onError(result, error, errorMsg);
                    }
                });
    }

    public void getGroupWhiteListFromServer(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        EMClient.getInstance().groupManager().fetchGroupWhiteList(groupId,
                new EMValueCallBack<List<String>>() {
                    @Override
                    public void onSuccess(List<String> value) {
                        EMWrapper.onSuccess(result, channelName, value);
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        EMWrapper.onError(result, error, errorMsg);
                    }
                });
    }

    public void isMemberInWhiteListFromServer(JSONObject param, String channelName, ExtSdkCallback result)
            throws JSONException {
        String groupId = param.getString("groupId");
        EMClient.getInstance().groupManager().checkIfInGroupWhiteList(groupId,
                new EMValueCallBack<Boolean>() {
                    @Override
                    public void onSuccess(Boolean value) {
                        EMWrapper.onSuccess(result, channelName, value);
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        EMWrapper.onError(result, error, errorMsg);
                    }
                });
    }

    public void getGroupFileListFromServer(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        int pageNum = param.getInt("pageNum");
        int pageSize = param.getInt("pageSize");
        EMClient.getInstance().groupManager().asyncFetchGroupSharedFileList(groupId, pageNum, pageSize, new EMValueCallBack<List<EMMucSharedFile>>() {
                    @Override
                    public void onSuccess(List<EMMucSharedFile> value) {
                        List<Map> fileList = new ArrayList<>();
                        for (EMMucSharedFile file : value) {
                            fileList.add(EMMucSharedFileHelper.toJson(file));
                        }
                        EMWrapper.onSuccess(result, channelName, fileList);
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        EMWrapper.onError(result, error, errorMsg);
                    }
                });
    }

    public void getGroupAnnouncementFromServer(JSONObject param, String channelName, ExtSdkCallback result)
            throws JSONException {
        String groupId = param.getString("groupId");
        EMClient.getInstance().groupManager().asyncFetchGroupAnnouncement(groupId, new EMValueCallBack<String>() {
                    @Override
                    public void onSuccess(String value) {
                        EMWrapper.onSuccess(result, channelName, value);
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        EMWrapper.onError(result, error, errorMsg);
                    }
                });
    }

    public void inviterUser(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        String reason = null;
        if (param.has("reason")) {
            reason = param.getString("reason");
        }
        JSONArray array = param.getJSONArray("members");
        String[] members = new String[array.length()];
        for (int i = 0; i < array.length(); i++) {
            members[i] = array.getString(i);
        }
        EMClient.getInstance().groupManager().asyncInviteUser(groupId, members, reason, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        EMWrapper.onSuccess(result, channelName, true);
                    }

                    @Override
                    public void onError(int code, String error) {
                        EMWrapper.onError(result, code, error);
                    }

                    @Override
                    public void onProgress(int progress, String status) {

                    }
                });
    }

    public void addMembers(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        JSONArray array = param.getJSONArray("members");

        String[] members = new String[array.length()];
        for (int i = 0; i < array.length(); i++) {
            members[i] = array.getString(i);
        }
        EMClient.getInstance().groupManager().asyncAddUsersToGroup(groupId, members, new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        EMWrapper.onSuccess(result, channelName, true);
                    }

                    @Override
                    public void onError(int code, String error) {
                        EMWrapper.onError(result, code, error);
                    }

                    @Override
                    public void onProgress(int progress, String status) {

                    }
                });
    }

    public void removeMembers(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        JSONArray array = param.getJSONArray("members");

        List<String> members = new ArrayList<>();
        for (int i = 0; i < array.length(); i++) {
            members.add(array.getString(i));
        }

        EMClient.getInstance().groupManager().asyncRemoveUsersFromGroup(groupId, members,
                new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        EMWrapper.onSuccess(result, channelName, true);
                    }

                    @Override
                    public void onError(int code, String error) {
                        EMWrapper.onError(result, code, error);
                    }

                    @Override
                    public void onProgress(int progress, String status) {

                    }
                });
    }

    public void blockMembers(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        JSONArray array = param.getJSONArray("members");
        List<String> members = new ArrayList<>();
        for (int i = 0; i < array.length(); i++) {
            members.add(array.getString(i));
        }

        EMClient.getInstance().groupManager().asyncBlockUsers(groupId, members,
                new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        EMWrapper.onSuccess(result, channelName, true);
                    }

                    @Override
                    public void onError(int code, String error) {
                        EMWrapper.onError(result, code, error);
                    }

                    @Override
                    public void onProgress(int progress, String status) {

                    }
                });
    }

    public void unblockMembers(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        JSONArray array = param.getJSONArray("members");
        List<String> members = new ArrayList<>();
        for (int i = 0; i < array.length(); i++) {
            members.add(array.getString(i));
        }

        EMClient.getInstance().groupManager().asyncUnblockUsers(groupId, members,
                new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        EMWrapper.onSuccess(result, channelName, true);
                    }

                    @Override
                    public void onError(int code, String error) {
                        EMWrapper.onError(result, code, error);
                    }

                    @Override
                    public void onProgress(int progress, String status) {

                    }
                });
    }

    public void updateGroupSubject(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        String name = param.getString("name");

        EMClient.getInstance().groupManager().asyncChangeGroupName(groupId, name, new EMCallBack() {
            @Override
            public void onSuccess() {
                EMWrapper.onSuccess(result, channelName, null);
            }

            @Override
            public void onError(int code, String error) {
                EMWrapper.onError(result, code, error);
            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });

    }

    public void updateDescription(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        String desc = param.getString("desc");

        EMClient.getInstance().groupManager().asyncChangeGroupDescription(groupId, desc, new EMCallBack() {
            @Override
            public void onSuccess() {
                EMWrapper.onSuccess(result, channelName, null);
            }

            @Override
            public void onError(int code, String error) {
                EMWrapper.onError(result, code, error);
            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    public void leaveGroup(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        EMClient.getInstance().groupManager().asyncLeaveGroup(groupId,
                new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        EMWrapper.onSuccess(result, channelName, true);
                    }

                    @Override
                    public void onError(int code, String error) {
                        EMWrapper.onError(result, code, error);
                    }

                    @Override
                    public void onProgress(int progress, String status) {

                    }
                });
    }

    public void destroyGroup(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        EMClient.getInstance().groupManager().asyncDestroyGroup(groupId,
                new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        EMWrapper.onSuccess(result, channelName, true);
                    }

                    @Override
                    public void onError(int code, String error) {
                        EMWrapper.onError(result, code, error);
                    }

                    @Override
                    public void onProgress(int progress, String status) {

                    }
                });
    }

    public void blockGroup(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");

        EMClient.getInstance().groupManager().asyncBlockGroupMessage(groupId, new EMCallBack() {
            @Override
            public void onSuccess() {
                EMWrapper.onSuccess(result, channelName, null);
            }

            @Override
            public void onError(int code, String error) {
                EMWrapper.onError(result, code, error);
            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    public void unblockGroup(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");

        EMClient.getInstance().groupManager().asyncUnblockGroupMessage(groupId, new EMCallBack() {
            @Override
            public void onSuccess() {
                EMWrapper.onSuccess(result, channelName, null);
            }

            @Override
            public void onError(int code, String error) {
                EMWrapper.onError(result, code, error);
            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    public void updateGroupOwner(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        String newOwner = param.getString("owner");

        EMClient.getInstance().groupManager().asyncChangeOwner(groupId, newOwner, new EMValueCallBack<EMGroup>() {
            @Override
            public void onSuccess(EMGroup value) {
                EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(value));
            }

            @Override
            public void onError(int error, String errorMsg) {
                EMWrapper.onError(result, error, errorMsg);
            }
        });
    }

    public void addAdmin(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        String admin = param.getString("admin");

        EMClient.getInstance().groupManager().asyncAddGroupAdmin(groupId, admin, new EMValueCallBack<EMGroup>() {
            @Override
            public void onSuccess(EMGroup value) {
                EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(value));
            }

            @Override
            public void onError(int error, String errorMsg) {
                EMWrapper.onError(result, error, errorMsg);
            }
        });
    }

    public void removeAdmin(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        String admin = param.getString("admin");

        EMClient.getInstance().groupManager().asyncRemoveGroupAdmin(groupId, admin, new EMValueCallBack<EMGroup>() {
            @Override
            public void onSuccess(EMGroup value) {
                EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(value));
            }

            @Override
            public void onError(int error, String errorMsg) {
                EMWrapper.onError(result, error, errorMsg);
            }
        });
    }

    public void muteMembers(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        int duration = param.getInt("duration");
        JSONArray array = param.getJSONArray("members");
        List<String> members = new ArrayList<>();
        for (int i = 0; i < array.length(); i++) {
            members.add(array.getString(i));
        }

        EMClient.getInstance().groupManager().aysncMuteGroupMembers(groupId, members, duration, new EMValueCallBack<EMGroup>() {
            @Override
            public void onSuccess(EMGroup value) {
                EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(value));
            }

            @Override
            public void onError(int error, String errorMsg) {
                EMWrapper.onError(result, error, errorMsg);
            }
        });
    }

    public void unMuteMembers(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        JSONArray array = param.getJSONArray("members");
        List<String> members = new ArrayList<>();
        for (int i = 0; i < array.length(); i++) {
            members.add(array.getString(i));
        }

        EMClient.getInstance().groupManager().asyncUnMuteGroupMembers(groupId, members, new EMValueCallBack<EMGroup>() {
            @Override
            public void onSuccess(EMGroup value) {
                EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(value));
            }

            @Override
            public void onError(int error, String errorMsg) {
                EMWrapper.onError(result, error, errorMsg);
            }
        });
    }

    public void muteAllMembers(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");

        EMClient.getInstance().groupManager().muteAllMembers(groupId, new EMValueCallBack<EMGroup>() {
            @Override
            public void onSuccess(EMGroup value) {
                EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(value));
            }

            @Override
            public void onError(int error, String errorMsg) {
                EMWrapper.onError(result, error, errorMsg);
            }
        });
    }

    public void unMuteAllMembers(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");

        EMClient.getInstance().groupManager().unmuteAllMembers(groupId, new EMValueCallBack<EMGroup>() {
            @Override
            public void onSuccess(EMGroup value) {
                EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(value));
            }

            @Override
            public void onError(int error, String errorMsg) {
                EMWrapper.onError(result, error, errorMsg);
            }
        });
    }

    public void addWhiteList(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        JSONArray array = param.getJSONArray("members");
        List<String> members = new ArrayList<>();
        for (int i = 0; i < array.length(); i++) {
            members.add(array.getString(i));
        }

        EMClient.getInstance().groupManager().addToGroupWhiteList(groupId, members,
                new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        EMWrapper.onSuccess(result, channelName, true);
                    }

                    @Override
                    public void onError(int code, String error) {
                        EMWrapper.onError(result, code, error);
                    }

                    @Override
                    public void onProgress(int progress, String status) {

                    }
                });
    }

    public void removeWhiteList(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        JSONArray array = param.getJSONArray("members");
        List<String> members = new ArrayList<>();
        for (int i = 0; i < array.length(); i++) {
            members.add(array.getString(i));
        }

        EMClient.getInstance().groupManager().removeFromGroupWhiteList(groupId, members,
                new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        EMWrapper.onSuccess(result, channelName, true);
                    }

                    @Override
                    public void onError(int code, String error) {
                        EMWrapper.onError(result, code, error);
                    }

                    @Override
                    public void onProgress(int progress, String status) {

                    }
                });
    }

    public void uploadGroupSharedFile(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        String filePath = param.getString("filePath");

        EMClient.getInstance().groupManager().asyncUploadGroupSharedFile(groupId, filePath,
                new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        EMWrapper.onSuccess(result, channelName, true);
                    }

                    @Override
                    public void onError(int code, String error) {
                        EMWrapper.onError(result, code, error);
                    }

                    @Override
                    public void onProgress(int progress, String status) {

                    }
                });
    }

    public void downloadGroupSharedFile(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        String fileId = param.getString("fileId");
        String savePath = param.getString("savePath");

        EMClient.getInstance().groupManager().asyncDownloadGroupSharedFile(groupId, fileId, savePath,
                new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        EMWrapper.onSuccess(result, channelName, true);
                    }

                    @Override
                    public void onError(int code, String error) {
                        EMWrapper.onError(result, code, error);
                    }

                    @Override
                    public void onProgress(int progress, String status) {

                    }
                });
    }

    public void removeGroupSharedFile(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        String fileId = param.getString("fileId");
        EMClient.getInstance().groupManager().asyncDeleteGroupSharedFile(groupId, fileId,
                new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        EMWrapper.onSuccess(result, channelName, true);
                    }

                    @Override
                    public void onError(int code, String error) {
                        EMWrapper.onError(result, code, error);
                    }

                    @Override
                    public void onProgress(int progress, String status) {

                    }
                });
    }

    public void updateGroupAnnouncement(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        String announcement = param.getString("announcement");

        EMClient.getInstance().groupManager().asyncUpdateGroupAnnouncement(groupId, announcement, new EMCallBack() {
            @Override
            public void onSuccess() {
                ExtSdkThreadUtil.asyncExecute(()->{
                    EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                    EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(group));
                });
            }

            @Override
            public void onError(int code, String error) {
                EMWrapper.onError(result, code, error);
            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    public void updateGroupExt(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        String ext = param.getString("ext");
        try {
            EMGroup group = EMClient.getInstance().groupManager().updateGroupExtension(groupId, ext);
            onSuccess(result, channelName, EMGroupHelper.toJson(group));
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void joinPublicGroup(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");

        EMClient.getInstance().groupManager().asyncJoinGroup(groupId, new EMCallBack() {
            @Override
            public void onSuccess() {
                ExtSdkThreadUtil.asyncExecute(()->{
                    EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                    EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(group));
                });
            }

            @Override
            public void onError(int code, String error) {
                EMWrapper.onError(result, code, error);
            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    public void requestToJoinPublicGroup(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");

        EMClient.getInstance().groupManager().asyncJoinGroup(groupId, new EMCallBack() {
            @Override
            public void onSuccess() {
                ExtSdkThreadUtil.asyncExecute(()->{
                    EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                    EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(group));
                });
            }

            @Override
            public void onError(int code, String error) {
                EMWrapper.onError(result, code, error);
            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    public void acceptJoinApplication(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        String username = param.getString("username");

        EMClient.getInstance().groupManager().asyncAcceptApplication(username, groupId, new EMCallBack() {
            @Override
            public void onSuccess() {
                ExtSdkThreadUtil.asyncExecute(()->{
                    EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                    EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(group));
                });
            }

            @Override
            public void onError(int code, String error) {
                EMWrapper.onError(result, code, error);
            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    public void declineJoinApplication(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        String username = param.getString("username");
        String reason = param.getString("reason");

        EMClient.getInstance().groupManager().asyncDeclineApplication(username, groupId, reason, new EMCallBack() {
            @Override
            public void onSuccess() {
                ExtSdkThreadUtil.asyncExecute(()->{
                    EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                    EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(group));
                });
            }

            @Override
            public void onError(int code, String error) {
                EMWrapper.onError(result, code, error);
            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    public void acceptInvitationFromGroup(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        String inviter = param.getString("inviter");

        EMClient.getInstance().groupManager().asyncAcceptInvitation(groupId, inviter, new EMValueCallBack<EMGroup>() {
            @Override
            public void onSuccess(EMGroup value) {
                EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(value));
            }

            @Override
            public void onError(int error, String errorMsg) {
                EMWrapper.onError(result, error, errorMsg);
            }
        });
    }

    public void declineInvitationFromGroup(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        String username = param.getString("username");
        String reason = param.getString("reason");
        
        EMClient.getInstance().groupManager().asyncDeclineInvitation(groupId, username, reason, new EMCallBack() {
            @Override
            public void onSuccess() {
                ExtSdkThreadUtil.asyncExecute(()->{
                    EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                    EMWrapper.onSuccess(result, channelName, EMGroupHelper.toJson(group));
                });
            }

            @Override
            public void onError(int code, String error) {
                EMWrapper.onError(result, code, error);
            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    public void ignoreGroupPush(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String groupId = param.getString("groupId");
        boolean ignore = param.getBoolean("ignore");
        List<String> list = new ArrayList<>();
        list.add(groupId);
        try {
            EMClient.getInstance().pushManager().updatePushServiceForGroup(list, !ignore);
            EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
            onSuccess(result, channelName, EMGroupHelper.toJson(group));
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    private void registerEaseListener() {
        EMClient.getInstance().groupManager().addGroupChangeListener(new EMGroupChangeListener() {

            @Override
            public void onWhiteListAdded(String groupId, List<String> whitelist) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onWhiteListAdded");
                data.put("groupId", groupId);
                data.put("whitelist", whitelist);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onWhiteListRemoved(String groupId, List<String> whitelist) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onWhiteListRemoved");
                data.put("groupId", groupId);
                data.put("whitelist", whitelist);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onAllMemberMuteStateChanged(String groupId, boolean isMuted) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onAllMemberMuteStateChanged");
                data.put("groupId", groupId);
                data.put("isMuted", isMuted);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onInvitationReceived(String groupId, String groupName, String inviter, String reason) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onInvitationReceived");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                data.put("inviter", inviter);
                data.put("reason", reason);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onRequestToJoinReceived(String groupId, String groupName, String applicant, String reason) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onRequestToJoinReceived");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                data.put("applicant", applicant);
                data.put("reason", reason);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onRequestToJoinAccepted(String groupId, String groupName, String accepter) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onRequestToJoinAccepted");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                data.put("accepter", accepter);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onRequestToJoinDeclined(String groupId, String groupName, String decliner, String reason) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onRequestToJoinDeclined");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                data.put("decliner", decliner);
                data.put("reason", reason);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onInvitationAccepted(String groupId, String invitee, String reason) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onInvitationAccepted");
                data.put("groupId", groupId);
                data.put("invitee", invitee);
                data.put("reason", reason);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onInvitationDeclined(String groupId, String invitee, String reason) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onInvitationDeclined");
                data.put("groupId", groupId);
                data.put("invitee", invitee);
                data.put("reason", reason);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onUserRemoved(String groupId, String groupName) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onUserRemoved");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onGroupDestroyed(String groupId, String groupName) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onGroupDestroyed");
                data.put("groupId", groupId);
                data.put("groupName", groupName);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onAutoAcceptInvitationFromGroup(String groupId, String inviter, String inviteMessage) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onAutoAcceptInvitationFromGroup");
                data.put("groupId", groupId);
                data.put("inviter", inviter);
                data.put("inviteMessage", inviteMessage);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onMuteListAdded(String groupId, List<String> mutes, long muteExpire) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onMuteListAdded");
                data.put("groupId", groupId);
                data.put("mutes", mutes);
                data.put("muteExpire", muteExpire);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onMuteListRemoved(String groupId, List<String> mutes) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onMuteListRemoved");
                data.put("groupId", groupId);
                data.put("mutes", mutes);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onAdminAdded(String groupId, String administrator) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onAdminAdded");
                data.put("groupId", groupId);
                data.put("administrator", administrator);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onAdminRemoved(String groupId, String administrator) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onAdminRemoved");
                data.put("groupId", groupId);
                data.put("administrator", administrator);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onOwnerChanged(String groupId, String newOwner, String oldOwner) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onOwnerChanged");
                data.put("groupId", groupId);
                data.put("newOwner", newOwner);
                data.put("oldOwner", oldOwner);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onMemberJoined(String groupId, String member) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onMemberJoined");
                data.put("groupId", groupId);
                data.put("member", member);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onMemberExited(String groupId, String member) {
                EMLog.e("_emGroupManagerWrapper", "onMemberExited");
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onMemberExited");
                data.put("groupId", groupId);
                data.put("member", member);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onAnnouncementChanged(String groupId, String announcement) {
                EMLog.e("_emGroupManagerWrapper", "onAnnouncementChanged");
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onAnnouncementChanged");
                data.put("groupId", groupId);
                data.put("announcement", announcement);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onSharedFileAdded(String groupId, EMMucSharedFile sharedFile) {
                EMLog.e("_emGroupManagerWrapper", "onSharedFileAdded");
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onSharedFileAdded");
                data.put("groupId", groupId);
                data.put("sharedFile", EMMucSharedFileHelper.toJson(sharedFile));
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }

            @Override
            public void onSharedFileDeleted(String groupId, String fileId) {
                EMLog.e("_emGroupManagerWrapper", "onSharedFileDeleted");
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onSharedFileDeleted");
                data.put("groupId", groupId);
                data.put("fileId", fileId);
                EMWrapper.onReceive(ExtSdkMethodType.onGroupChanged, data);
            }
        });
    }
}
