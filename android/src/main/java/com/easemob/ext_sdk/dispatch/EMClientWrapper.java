package com.easemob.ext_sdk.dispatch;


import androidx.annotation.NonNull;

import com.easemob.ext_sdk.common.ExtSdkContext;
import com.easemob.ext_sdk.common.ExtSdkCallback;
import com.easemob.ext_sdk.common.ExtSdkMethodType;

import com.easemob.ext_sdk.common.ExtSdkThreadUtil;
import com.hyphenate.EMCallBack;
import com.hyphenate.EMConnectionListener;
import com.hyphenate.EMMultiDeviceListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMDeviceInfo;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.exceptions.HyphenateException;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class EMClientWrapper extends EMWrapper {

    public static class SingleHolder {
        static EMClientWrapper instance = new EMClientWrapper();
    }

    public static EMClientWrapper getInstance() {
        return EMClientWrapper.SingleHolder.instance;
    }

    public void createAccount(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String username = param.getString("username");
        String password = param.getString("password");
        try {
            EMClient.getInstance().createAccount(username, password);
            onSuccess(result, channelName, username);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void login(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        boolean isPwd = param.getBoolean("isPassword");
        String username = param.getString("username");
        String pwdOrToken = param.getString("pwdOrToken");

        if (isPwd) {
            EMClient.getInstance().login(username, pwdOrToken, new EMCallBack() {
                @Override
                public void onSuccess() {
                    Map<String, String> param = new HashMap<>();
                    param.put("username", EMClient.getInstance().getCurrentUser());
                    param.put("token", EMClient.getInstance().getAccessToken());
                    EMClientWrapper.this.onSuccess(result, channelName, param);
                }

                @Override
                public void onError(int code, String error) {
                    EMClientWrapper.this.onError(result, code, error);
                }

                @Override
                public void onProgress(int progress, String status) {
                    // todo: 原来就没有写
                }
            });
        } else {
            EMClient.getInstance().loginWithToken(username, pwdOrToken, new EMCallBack() {
                @Override
                public void onSuccess() {
                    Map<String, String> param = new HashMap<>();
                    param.put("username", EMClient.getInstance().getCurrentUser());
                    param.put("token", EMClient.getInstance().getAccessToken());
                    EMClientWrapper.this.onSuccess(result, channelName, param);
                }

                @Override
                public void onError(int code, String error) {
                    EMClientWrapper.this.onError(result, code, error);
                }

                @Override
                public void onProgress(int progress, String status) {
                    // todo: 原来就没有写
                }
            });
        }
    }


    public void logout(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        boolean unbindToken = param.getBoolean("unbindToken");
        EMClient.getInstance().logout(unbindToken, new EMCallBack() {
            @Override
            public void onSuccess() {
                EMClientWrapper.this.onSuccess(result, channelName, true);
            }

            @Override
            public void onError(int code, String error) {
                EMClientWrapper.this.onError(result, code, error);
            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    public void changeAppKey(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String appKey = param.getString("appKey");
        try {
            EMClient.getInstance().changeAppkey(appKey);
            onSuccess(result, channelName, true);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void getCurrentUser(JSONObject param, String channelName, ExtSdkCallback result) {
        onSuccess(result, channelName, EMClient.getInstance().getCurrentUser());
    }

    public void updateCurrentUserNick(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String nickName = param.getString("nickname");
        try {
            boolean status = EMClient.getInstance().pushManager().updatePushNickname(nickName);
            onSuccess(result, channelName, status);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }


    public void uploadLog(JSONObject param, String channelName, ExtSdkCallback result) {
        EMClient.getInstance().uploadLog(new EMCallBack() {
            @Override
            public void onSuccess() {

            }

            @Override
            public void onError(int code, String error) {

            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
    }

    public void compressLogs(JSONObject param, String channelName, ExtSdkCallback result) {
        try {
            String path = EMClient.getInstance().compressLogs();
            onSuccess(result, channelName, path);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void kickDevice(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {

        String username = param.getString("username");
        String password = param.getString("password");
        String resource = param.getString("resource");

        try {
            EMClient.getInstance().kickDevice(username, password, resource);
            onSuccess(result, channelName, true);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void kickAllDevices(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String username = param.getString("username");
        String password = param.getString("password");

        try {
            EMClient.getInstance().kickAllDevices(username, password);
            onSuccess(result, channelName, true);
        } catch (HyphenateException e) {
            onError(result, e, null);
        }
    }

    public void isLoggedInBefore(JSONObject param, String channelName, ExtSdkCallback result) {
        onSuccess(result, channelName, EMClient.getInstance().isLoggedInBefore());
    }

    public void onMultiDeviceEvent(JSONObject param, String channelName, ExtSdkCallback result) {

    }

    public void getLoggedInDevicesFromServer(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        String username = param.getString("username");
        String password = param.getString("password");
        new Thread(() -> {
            try {
                List<EMDeviceInfo> devices = EMClient.getInstance().getLoggedInDevicesFromServer(username, password);
                List<Map> jsonList = new ArrayList<>();
                for (EMDeviceInfo info : devices) {
                    jsonList.add(EMDeviceInfoHelper.toJson(info));
                }
                onSuccess(result, channelName, jsonList);
            } catch (HyphenateException e) {
                onError(result, e, null);
            }
        });
    }

    public void init(JSONObject param, String channelName, ExtSdkCallback result) throws JSONException {
        EMOptions options = EMOptionsHelper.fromJson(param, ExtSdkContext.context);
        boolean debugModel = param.getBoolean("debugModel");

        EMOptions finalOptions = options;
        boolean finalDebugModel = debugModel;

        ExtSdkThreadUtil.mainThreadExecute(() -> {

            EMClient.getInstance().init(ExtSdkContext.context, finalOptions);
            EMClient.getInstance().setDebugMode(finalDebugModel);

            addEMListener();

            Map<String, Object> data = new HashMap<>();
            data.put("isLoginBefore", EMClient.getInstance().isLoggedInBefore());
            data.put("currentUsername", EMClient.getInstance().getCurrentUser());
            onSuccess(result, channelName, data);

        });
    }

    public void addEMListener() {
        EMClient.getInstance().addMultiDeviceListener(new EMMultiDeviceListener() {
            @Override
            public void onContactEvent(int event, String target, String ext) {
                Map<String, Object> data = new HashMap<>();
                data.put("event", Integer.valueOf(event));
                data.put("target", target);
                data.put("ext", ext);
                onReceive(ExtSdkMethodType.onMultiDeviceEvent, data);
            }

            @Override
            public void onGroupEvent(int event, String target, List<String> userNames) {
                Map<String, Object> data = new HashMap<>();
                data.put("event", Integer.valueOf(event));
                data.put("target", target);
                data.put("userNames", userNames);
                onReceive(ExtSdkMethodType.onMultiDeviceEvent, data);
            }
        });

        //setup connection listener
        EMClient.getInstance().addConnectionListener(new EMConnectionListener() {
            @Override
            public void onConnected() {
                Map<String, Object> data = new HashMap<>();
                data.put("connected", Boolean.TRUE);
                onReceive(ExtSdkMethodType.onConnected, data);
            }

            @Override
            public void onDisconnected(int errorCode) {
                Map<String, Object> data = new HashMap<>();
                data.put("errorCode", errorCode);
                onReceive(ExtSdkMethodType.onDisconnected, data);
            }
        });
    }
}