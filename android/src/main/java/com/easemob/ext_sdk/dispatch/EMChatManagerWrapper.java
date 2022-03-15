package com.easemob.ext_sdk.dispatch;

import com.easemob.ext_sdk.common.ExtSdkCallback;
import com.easemob.ext_sdk.common.ExtSdkMethodType;
import com.hyphenate.EMCallBack;
import com.hyphenate.EMConversationListener;
import com.hyphenate.EMMessageListener;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMGroupReadAck;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.exceptions.HyphenateException;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class EMChatManagerWrapper extends EMWrapper {

    public static class SingleHolder {
        static EMChatManagerWrapper instance = new EMChatManagerWrapper();
    }

    public static EMChatManagerWrapper getInstance() {
        return EMChatManagerWrapper.SingleHolder.instance;
    }

    EMChatManagerWrapper() {
        registerEaseListener();
    }

    public void sendMessage(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        final EMMessage msg = EMMessageHelper.fromJson(param);
        msg.setMessageStatusCallback(new EMCallBack() {
            @Override
            public void onSuccess() {
                Map<String, Object> map = new HashMap<>();
                map.put("message", EMMessageHelper.toJson(msg));
                map.put("localTime", msg.localTime());
                EMWrapper.onSuccess(result, ExtSdkMethodType.onMessageSuccess, map);
            }

            @Override
            public void onProgress(int progress, String status) {

                Map<String, Object> map = new HashMap<>();
                map.put("progress", progress);
                map.put("localTime", msg.localTime());
                EMWrapper.onSuccess(result, ExtSdkMethodType.onMessageProgressUpdate, map);
            }

            @Override
            public void onError(int code, String desc) {
                Map<String, Object> data = new HashMap<>();
                data.put("code", code);
                data.put("description", desc);

                Map<String, Object> map = new HashMap<>();
                map.put("message", EMMessageHelper.toJson(msg));
                map.put("localTime", msg.localTime());
                map.put("error", data);
                EMWrapper.onSuccess(result, ExtSdkMethodType.onMessageError, map);
            }
        });

        EMClient.getInstance().chatManager().sendMessage(msg);
        onSuccess(result, channelName, EMMessageHelper.toJson(msg));
    }

    public void resendMessage(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        EMMessage tempMsg = EMMessageHelper.fromJson(param);
        EMMessage msg = EMClient.getInstance().chatManager().getMessage(tempMsg.getMsgId());
        if (msg == null) {
            msg = tempMsg;
        }
        msg.setStatus(EMMessage.Status.CREATE);
        EMMessage finalMsg = msg;
        finalMsg.setMessageStatusCallback(new EMCallBack() {
            @Override
            public void onSuccess() {

                Map<String, Object> map = new HashMap<>();
                map.put("message", EMMessageHelper.toJson(finalMsg));
                map.put("localTime", finalMsg.localTime());
                EMWrapper.onSuccess(result, ExtSdkMethodType.onMessageSuccess, map);
            }

            @Override
            public void onProgress(int progress, String status) {

                Map<String, Object> map = new HashMap<>();
                map.put("progress", progress);
                map.put("localTime", finalMsg.localTime());
                EMWrapper.onSuccess(result, ExtSdkMethodType.onMessageProgressUpdate, map);
            }

            @Override
            public void onError(int code, String desc) {
                Map<String, Object> data = new HashMap<>();
                data.put("code", code);
                data.put("description", desc);

                Map<String, Object> map = new HashMap<>();
                map.put("message", EMMessageHelper.toJson(finalMsg));
                map.put("localTime", finalMsg.localTime());
                map.put("error", data);
                EMWrapper.onSuccess(result, ExtSdkMethodType.onMessageError, map);
            }
        });
        EMClient.getInstance().chatManager().sendMessage(msg);

        onSuccess(result, channelName, EMMessageHelper.toJson(finalMsg));
    }

    public void ackMessageRead(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String msgId = param.getString("msg_id");
        String to = param.getString("to");

        try {
            EMClient.getInstance().chatManager().ackMessageRead(to, msgId);
            onSuccess(result, channelName, true);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void ackGroupMessageRead(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String msgId = param.getString("msg_id");
        String to = param.getString("group_id");
        String content = null;
        if (param.has("content")) {
            content = param.getString("content");
        }
        String finalContent = content;

        try {
            EMClient.getInstance().chatManager().ackGroupMessageRead(to, msgId, finalContent);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void ackConversationRead(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String conversationId = param.getString("con_id");

        try {
            EMClient.getInstance().chatManager().ackConversationRead(conversationId);
            onSuccess(result, channelName, true);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void recallMessage(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String msgId = param.getString("msg_id");

        try {
            EMMessage msg = EMClient.getInstance().chatManager().getMessage(msgId);
            if (msg != null) {
                EMClient.getInstance().chatManager().recallMessage(msg);
            }
            onSuccess(result, channelName, true);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void getMessage(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String msgId = param.getString("msg_id");

        EMMessage msg = EMClient.getInstance().chatManager().getMessage(msgId);
        onSuccess(result, channelName, EMMessageHelper.toJson(msg));
    }

    public void getConversation(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String conId = param.getString("con_id");
        EMConversation.EMConversationType type = EMConversationHelper.typeFromInt(param.getInt("type"));

        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(conId, type, true);
        onSuccess(result, channelName, EMConversationHelper.toJson(conversation));
    }

    public void markAllChatMsgAsRead(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        EMClient.getInstance().chatManager().markAllConversationsAsRead();

        onSuccess(result, channelName, true);
    }

    public void getUnreadMessageCount(JSONObject param, String channelName, ExtSdkCallback result)
            throws JSONException {
        int count = EMClient.getInstance().chatManager().getUnreadMessageCount();

        onSuccess(result, channelName, count);
    }

    public void updateChatMessage(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        EMMessage msg = EMMessageHelper.fromJson(param.getJSONObject("message"));

        EMClient.getInstance().chatManager().updateMessage(msg);
        onSuccess(result, channelName, EMMessageHelper.toJson(msg));
    }

    public void importMessages(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        JSONArray ary = param.getJSONArray("messages");
        List<EMMessage> messages = new ArrayList<>();
        for (int i = 0; i < ary.length(); i++) {
            JSONObject obj = ary.getJSONObject(i);
            messages.add(EMMessageHelper.fromJson(obj));
        }

        EMClient.getInstance().chatManager().importMessages(messages);
        onSuccess(result, channelName, true);
    }

    public void downloadAttachment(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        EMMessage tempMsg = EMMessageHelper.fromJson(param.getJSONObject("message"));
        final EMMessage msg = EMClient.getInstance().chatManager().getMessage(tempMsg.getMsgId());
        msg.setMessageStatusCallback(new EMCallBack() {
            @Override
            public void onSuccess() {

                Map<String, Object> map = new HashMap<>();
                map.put("message", EMMessageHelper.toJson(msg));
                map.put("localTime", msg.localTime());
                EMWrapper.onSuccess(result, ExtSdkMethodType.onMessageSuccess, map);
            }

            @Override
            public void onProgress(int progress, String status) {

                Map<String, Object> map = new HashMap<>();
                map.put("progress", progress);
                map.put("localTime", msg.localTime());
                EMWrapper.onSuccess(result, ExtSdkMethodType.onMessageProgressUpdate, map);
            }

            @Override
            public void onError(int code, String desc) {
                Map<String, Object> data = new HashMap<>();
                data.put("code", code);
                data.put("description", desc);

                Map<String, Object> map = new HashMap<>();
                map.put("message", EMMessageHelper.toJson(msg));
                map.put("localTime", msg.localTime());
                map.put("error", data);
                EMWrapper.onSuccess(result, ExtSdkMethodType.onMessageError, map);
            }
        });

        EMClient.getInstance().chatManager().downloadAttachment(msg);
        onSuccess(result, channelName, EMMessageHelper.toJson(msg));
    }

    public void downloadThumbnail(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        EMMessage tempMsg = EMMessageHelper.fromJson(param.getJSONObject("message"));
        final EMMessage msg = EMClient.getInstance().chatManager().getMessage(tempMsg.getMsgId());
        msg.setMessageStatusCallback(new EMCallBack() {
            @Override
            public void onSuccess() {

                Map<String, Object> map = new HashMap<>();
                map.put("message", EMMessageHelper.toJson(msg));
                map.put("localTime", msg.localTime());
                EMWrapper.onSuccess(result, ExtSdkMethodType.onMessageSuccess, map);
            }

            @Override
            public void onProgress(int progress, String status) {

                Map<String, Object> map = new HashMap<>();
                map.put("progress", progress);
                map.put("localTime", msg.localTime());
                EMWrapper.onSuccess(result, ExtSdkMethodType.onMessageProgressUpdate, map);
            }

            @Override
            public void onError(int code, String desc) {
                Map<String, Object> data = new HashMap<>();
                data.put("code", code);
                data.put("description", desc);

                Map<String, Object> map = new HashMap<>();
                map.put("message", EMMessageHelper.toJson(msg));
                map.put("localTime", msg.localTime());
                map.put("error", data);
                EMWrapper.onSuccess(result, ExtSdkMethodType.onMessageError, map);
            }
        });

        EMClient.getInstance().chatManager().downloadThumbnail(msg);
        onSuccess(result, channelName, EMMessageHelper.toJson(msg));
    }

    public void loadAllConversations(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {

        List<EMConversation> list =
                new ArrayList<>(EMClient.getInstance().chatManager().getAllConversations().values());
        Collections.sort(list, new Comparator<EMConversation>() {
            @Override
            public int compare(EMConversation o1, EMConversation o2) {
                if (o1.getLastMessage() == null) {
                    return 1;
                }

                if (o2.getLastMessage() == null) {
                    return -1;
                }
                return o2.getLastMessage().getMsgTime() - o1.getLastMessage().getMsgTime() > 0 ? 1 : -1;
            }
        });
        List<Map> conversations = new ArrayList<>();
        for (EMConversation conversation : list) {
            conversations.add(EMConversationHelper.toJson(conversation));
        }
        onSuccess(result, channelName, conversations);
    }

    public void getConversationsFromServer(JSONObject param, String channelName, ExtSdkCallback result)
            throws JSONException {

        try {
            List<EMConversation> list =
                    new ArrayList<>(EMClient.getInstance().chatManager().fetchConversationsFromServer().values());
            Collections.sort(
                    list, (o1, o2) -> (o2.getLastMessage().getMsgTime() - o1.getLastMessage().getMsgTime() > 0 ? 1 : -1));
            List<Map> conversations = new ArrayList<>();
            for (EMConversation conversation : list) {
                conversations.add(EMConversationHelper.toJson(conversation));
            }
            onSuccess(result, channelName, conversations);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void deleteConversation(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String conId = param.getString("con_id");
        boolean isDelete = param.getBoolean("deleteMessages");

        boolean ret = EMClient.getInstance().chatManager().deleteConversation(conId, isDelete);
        onSuccess(result, channelName, ret);
    }

    public void fetchHistoryMessages(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String conId = param.getString("con_id");
        EMConversation.EMConversationType type = EMConversationHelper.typeFromInt(param.getInt("type"));
        int pageSize = param.getInt("pageSize");
        String startMsgId = param.getString("startMsgId");

        try {
            EMCursorResult<EMMessage> cursorResult =
                    EMClient.getInstance().chatManager().fetchHistoryMessages(conId, type, pageSize, startMsgId);
            onSuccess(result, channelName, EMCursorResultHelper.toJson(cursorResult));
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void searchChatMsgFromDB(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String keywords = param.getString("keywords");
        long timeStamp = param.getLong("timeStamp");
        int count = param.getInt("maxCount");
        String from = param.getString("from");
        EMConversation.EMSearchDirection direction = searchDirectionFromString(param.getString("direction"));

        List<EMMessage> msgList =
                EMClient.getInstance().chatManager().searchMsgFromDB(keywords, timeStamp, count, from, direction);
        List<Map> messages = new ArrayList<>();
        for (EMMessage msg : msgList) {
            messages.add(EMMessageHelper.toJson(msg));
        }
        onSuccess(result, channelName, messages);
    }

    public void asyncFetchGroupAcks(JSONObject param, String channelName, ExtSdkCallback result)
            throws JSONException {
        String msgId = param.getString("msg_id");
        String ackId = param.getString("ack_id");
        int pageSize = param.getInt("pageSize");
        EMClient.getInstance().chatManager().asyncFetchGroupReadAcks(
                msgId, pageSize, ackId, new EMValueCallBack<EMCursorResult<EMGroupReadAck>>() {
                    @Override
                    public void onSuccess(EMCursorResult<EMGroupReadAck> value) {
                        EMWrapper.onSuccess(result, channelName, EMCursorResultHelper.toJson(value));
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        EMWrapper.onError(result, error, errorMsg);
                    }
                });
    }

    private void registerEaseListener() {
        EMClient.getInstance().chatManager().addMessageListener(new EMMessageListener() {
            @Override
            public void onMessageReceived(List<EMMessage> messages) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMMessage message : messages) {
                    msgList.add(EMMessageHelper.toJson(message));
                }
                EMWrapper.onReceive(ExtSdkMethodType.onMessagesReceived, msgList);
            }

            @Override
            public void onCmdMessageReceived(List<EMMessage> messages) {

                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMMessage message : messages) {
                    msgList.add(EMMessageHelper.toJson(message));
                }
                EMWrapper.onReceive(ExtSdkMethodType.onCmdMessagesReceived, msgList);
            }

            @Override
            public void onMessageRead(List<EMMessage> messages) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMMessage message : messages) {
                    msgList.add(EMMessageHelper.toJson(message));
                    EMWrapper.onReceive(ExtSdkMethodType.onMessageReadAck, EMMessageHelper.toJson(message));
                }

                EMWrapper.onReceive(ExtSdkMethodType.onMessagesRead, msgList);
            }

            @Override
            public void onMessageDelivered(List<EMMessage> messages) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMMessage message : messages) {
                    msgList.add(EMMessageHelper.toJson(message));
                    EMWrapper.onReceive(ExtSdkMethodType.onMessageDeliveryAck, EMMessageHelper.toJson(message));
                }
                EMWrapper.onReceive(ExtSdkMethodType.onMessagesDelivered, msgList);
            }

            @Override
            public void onMessageRecalled(List<EMMessage> messages) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMMessage message : messages) {
                    msgList.add(EMMessageHelper.toJson(message));
                }
                EMWrapper.onReceive(ExtSdkMethodType.onMessagesRecalled, msgList);
            }

            @Override
            public void onMessageChanged(EMMessage message, Object change) {
                Map<String, Object> data = new HashMap<>();
                data.put("message", EMMessageHelper.toJson(message));
                EMWrapper.onReceive(ExtSdkMethodType.onMessageStatusChanged, data);
            }

            @Override
            public void onGroupMessageRead(List<EMGroupReadAck> var1) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMGroupReadAck ack : var1) {
                    msgList.add(EMGroupAckHelper.toJson(ack));
                }
                EMWrapper.onReceive(ExtSdkMethodType.onGroupMessageRead, msgList);
            }

            @Override
            public void onReadAckForGroupMessageUpdated() {
            }
        });
        // setup conversation listener
        EMClient.getInstance().chatManager().addConversationListener(new EMConversationListener() {
            @Override
            public void onCoversationUpdate() {
                Map<String, Object> data = new HashMap<>();
                EMWrapper.onReceive(ExtSdkMethodType.onConversationUpdate, data);
            }

            @Override
            public void onConversationRead(String from, String to) {
                Map<String, Object> data = new HashMap<>();
                data.put("from", from);
                data.put("to", to);
                EMWrapper.onReceive(ExtSdkMethodType.onConversationHasRead, data);
            }
        });
    }

    private EMConversation.EMSearchDirection searchDirectionFromString(String direction) {
        return direction == "up" ? EMConversation.EMSearchDirection.UP : EMConversation.EMSearchDirection.DOWN;
    }
}
