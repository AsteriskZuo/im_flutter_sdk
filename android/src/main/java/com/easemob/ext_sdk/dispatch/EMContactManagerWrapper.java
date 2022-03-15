package com.easemob.ext_sdk.dispatch;

import com.easemob.ext_sdk.common.ExtSdkCallback;
import com.easemob.ext_sdk.common.ExtSdkMethodType;
import com.hyphenate.EMContactListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.exceptions.HyphenateException;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class EMContactManagerWrapper extends EMWrapper {

    public static class SingleHolder {
        static EMContactManagerWrapper instance = new EMContactManagerWrapper();
    }

    public static EMContactManagerWrapper getInstance() {
        return EMContactManagerWrapper.SingleHolder.instance;
    }

    EMContactManagerWrapper() {
        registerEaseListener();
    }

    public void addContact(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String username = param.getString("username");
        String reason = param.getString("reason");

        try {
            EMClient.getInstance().contactManager().addContact(username, reason);
            onSuccess(result, channelName, username);
        } catch (HyphenateException e) {
            onError(result, e, null);

        }
    }

    public void deleteContact(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String username = param.getString("username");
        boolean keepConversation = param.getBoolean("keepConversation");
        try {
            EMClient.getInstance().contactManager().deleteContact(username, keepConversation);
            onSuccess(result, channelName, username);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void getAllContactsFromServer(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        try {
            List contacts = EMClient.getInstance().contactManager().getAllContactsFromServer();
            onSuccess(result, channelName, contacts);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void getAllContactsFromDB(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        try {
            List contacts = EMClient.getInstance().contactManager().getContactsFromLocal();
            onSuccess(result, channelName, contacts);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void addUserToBlockList(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        String username = params.getString("username");
        try {
            EMClient.getInstance().contactManager().addUserToBlackList(username, false);
            onSuccess(result, channelName, username);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void removeUserFromBlockList(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        String username = params.getString("username");
        try {
            EMClient.getInstance().contactManager().removeUserFromBlackList(username);
            onSuccess(result, channelName, username);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void getBlockListFromServer(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        try {
            List contacts = EMClient.getInstance().contactManager().getBlackListFromServer();
            onSuccess(result, channelName, contacts);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void getBlockListFromDB(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        List contacts = EMClient.getInstance().contactManager().getBlackListUsernames();
        onSuccess(result, channelName, contacts);
    }

    public void acceptInvitation(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        String username = params.getString("username");
        try {
            EMClient.getInstance().contactManager().acceptInvitation(username);
            onSuccess(result, channelName, username);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void declineInvitation(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        String username = params.getString("username");
        try {
            EMClient.getInstance().contactManager().declineInvitation(username);
            onSuccess(result, channelName, username);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void getSelfIdsOnOtherPlatform(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        try {
            List platforms = EMClient.getInstance().contactManager().getSelfIdsOnOtherPlatform();
            onSuccess(result, channelName, platforms);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    private void registerEaseListener() {
        EMClient.getInstance().contactManager().setContactListener(new EMContactListener() {
            @Override
            public void onContactAdded(String userName) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onContactAdded");
                data.put("username", userName);
                onReceive(ExtSdkMethodType.onContactChanged, data);

            }

            @Override
            public void onContactDeleted(String userName) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onContactDeleted");
                data.put("username", userName);
                onReceive(ExtSdkMethodType.onContactChanged, data);
            }

            @Override
            public void onContactInvited(String userName, String reason) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onContactInvited");
                data.put("username", userName);
                data.put("reason", reason);
                onReceive(ExtSdkMethodType.onContactChanged, data);
            }

            @Override
            public void onFriendRequestAccepted(String userName) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onFriendRequestAccepted");
                data.put("username", userName);
                onReceive(ExtSdkMethodType.onContactChanged, data);
            }

            @Override
            public void onFriendRequestDeclined(String userName) {
                Map<String, Object> data = new HashMap<>();
                data.put("type", "onFriendRequestDeclined");
                data.put("username", userName);
                onReceive(ExtSdkMethodType.onContactChanged, data);
            }
        });
    }
}
