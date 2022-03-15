package com.easemob.ext_sdk.dispatch;

import android.text.TextUtils;

import com.easemob.ext_sdk.common.ExtSdkCallback;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMMessage;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class EMConversationWrapper extends EMWrapper {

    public static class SingleHolder {
        static EMConversationWrapper instance = new EMConversationWrapper();
    }

    public static EMConversationWrapper getInstance() {
        return EMConversationWrapper.SingleHolder.instance;
    }

    EMConversationWrapper() {
        
    }


    public void getUnreadMsgCount(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        onSuccess(result, channelName,  conversation.getUnreadMsgCount());
    }

    public void markAllMessagesAsRead(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        conversation.markAllMessagesAsRead();
        onSuccess(result, channelName, true);
    }

    public void markMessageAsRead(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        String msg_id = params.getString("msg_id");
        conversation.markMessageAsRead(msg_id);
        onSuccess(result, channelName, true);
    }

    public void syncConversationName(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        String conName = params.getString("con_name");
        String extField = conversation.getExtField();
        JSONObject jsonObject = new JSONObject();
        if(!extField.isEmpty()){
            jsonObject = new JSONObject(extField);
        }
        jsonObject.put("con_name", conName);
        String jsonStr = jsonObject.toString();
        conversation.setExtField(jsonStr);
        onSuccess(result, channelName, true);
    }

    public void syncConversationExt(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        JSONObject ext = params.getJSONObject("ext");
        String jsonStr = "";
        if (ext.length() != 0) {
            jsonStr = ext.toString();
        }
        conversation.setExtField(jsonStr);
        onSuccess(result, channelName, true);
    }

    public void removeMessage(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        String msg_id = params.getString("msg_id");
        conversation.removeMessage(msg_id);
        onSuccess(result, channelName, true);
    }

    public void getLatestMessage(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        EMMessage msg = conversation.getLastMessage();
        onSuccess(result, channelName, EMMessageHelper.toJson(msg));
    }

    public void getLatestMessageFromOthers(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        EMMessage msg = conversation.getLatestMessageFromOthers();
        onSuccess(result, channelName, EMMessageHelper.toJson(msg));
    }

    public void clearAllMessages(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        conversation.clearAllMessages();
        onSuccess(result, channelName, true);
    }

    public void insertMessage(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        JSONObject msg = params.getJSONObject("msg");
        EMMessage message = EMMessageHelper.fromJson(msg);
        conversation.insertMessage(message);
        onSuccess(result, channelName, true);
    }

    public void appendMessage(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        JSONObject msg = params.getJSONObject("msg");
        EMMessage message = EMMessageHelper.fromJson(msg);
        conversation.appendMessage(message);
        onSuccess(result, channelName, true);
    }

    public void updateConversationMessage(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        JSONObject msg = params.getJSONObject("msg");
        EMMessage message = EMMessageHelper.fromJson(msg);
        conversation.updateMessage(message);
        onSuccess(result, channelName, true);
    }

    public void loadMsgWithId(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        String msgId = params.getString("msg_id");
        EMMessage msg = EMClient.getInstance().chatManager().getMessage(msgId);
        onSuccess(result, channelName, EMMessageHelper.toJson(msg));
    }

    public void loadMsgWithStartId(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        String startId = params.getString("startId");
        int pageSize = params.getInt("count");
        EMConversation.EMSearchDirection direction = searchDirectionFromString(params.getString("direction"));
        List<EMMessage> msgList = conversation.loadMoreMsgFromDB(startId, pageSize, direction);
        List<Map> messages = new ArrayList<>();
        for(EMMessage msg: msgList) {
            messages.add(EMMessageHelper.toJson(msg));
        }
        onSuccess(result, channelName, messages);
    }

    public void loadMsgWithKeywords(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        String keywords = params.getString("keywords");
        String sender = null;
        if (params.has("sender")) {
            sender = params.getString("sender");
        }
        final String name = sender;
        int count = params.getInt("count");
        long timestamp = params.getLong("timestamp");
        EMConversation.EMSearchDirection direction = searchDirectionFromString(params.getString("direction"));
        List<EMMessage> msgList = conversation.searchMsgFromDB(keywords, timestamp, count, name, direction);
        List<Map> messages = new ArrayList<>();
        for(EMMessage msg: msgList) {
            messages.add(EMMessageHelper.toJson(msg));
        }
        onSuccess(result, channelName, messages);
    }

    public void loadMsgWithMsgType(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        long timestamp = params.getLong("timestamp");
        String sender = params.getString("sender");
        int count = params.getInt("count");
        EMConversation.EMSearchDirection direction = searchDirectionFromString(params.getString("direction"));
        String typeStr = params.getString("type");
        EMMessage.Type type = EMMessage.Type.TXT;
        switch (typeStr) {
            case "txt" : type = EMMessage.Type.TXT; break;
            case "loc" : type = EMMessage.Type.LOCATION; break;
            case "cmd" : type = EMMessage.Type.CMD; break;
            case "custom" : type = EMMessage.Type.CUSTOM; break;
            case "file" : type = EMMessage.Type.FILE; break;
            case "img" : type = EMMessage.Type.IMAGE; break;
            case "video" : type = EMMessage.Type.VIDEO; break;
            case "voice" : type = EMMessage.Type.VOICE; break;
        }

        EMMessage.Type finalType = type;
        List<EMMessage> msgList = conversation.searchMsgFromDB(finalType, timestamp, count, sender, direction);
        List<Map> messages = new ArrayList<>();
        for(EMMessage msg: msgList) {
            messages.add(EMMessageHelper.toJson(msg));
        }
        onSuccess(result, channelName, messages);
    }

    public void loadMsgWithTime(JSONObject params, String channelName, ExtSdkCallback result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        long startTime = params.getLong("startTime");
        long endTime = params.getLong("endTime");
        int count = params.getInt("count");
        List<EMMessage> msgList = conversation.searchMsgFromDB(startTime, endTime, count);
        List<Map> messages = new ArrayList<>();
        for(EMMessage msg: msgList) {
            messages.add(EMMessageHelper.toJson(msg));
        }
        onSuccess(result, channelName, messages);
    }


    private EMConversation conversationWithParam(JSONObject params ) throws JSONException {
        String con_id = params.getString("con_id");
        EMConversation.EMConversationType type = EMConversationHelper.typeFromInt(params.getInt("type"));
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(con_id, type, true);
        return conversation;
    }

    private EMConversation.EMSearchDirection searchDirectionFromString(String direction) {
        return TextUtils.equals(direction, "up") ? EMConversation.EMSearchDirection.UP : EMConversation.EMSearchDirection.DOWN;
    }
}

