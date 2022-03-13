package com.easemob.im_flutter_sdk;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.easemob.ext_sdk.common.ExtSdkContext;
import com.easemob.ext_sdk.flutter.ExtSdkChannelManager;
import com.easemob.ext_sdk.flutter.ExtSdkApiFlutter;
import com.easemob.ext_sdk.flutter.ExtSdkTest;
import com.hyphenate.EMCallBack;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.util.EMLog;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.HashMap;
import java.util.Map;


/**
 * ImFlutterSdkPlugin
 */
public class ImFlutterSdkPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {

    static final Handler handler = new Handler(Looper.getMainLooper());

    public ImFlutterSdkPlugin() {
    }

    static {
        System.loadLibrary("im_flutter_sdk");
    }

    static MethodChannel _channel;


    @Override
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        if (ExtSdkTest.TEST_TYPE == 1) {
            final MethodChannel channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "em_client");
            channel.setMethodCallHandler(new EMClientWrapper(flutterPluginBinding, "em_client"));
        } else if (ExtSdkTest.TEST_TYPE == 2) {
            ExtSdkChannelManager.getInstance().add(flutterPluginBinding.getBinaryMessenger(), ExtSdkChannelManager.ExtSdkChannelName.SEND_CHANNEL);
            ExtSdkChannelManager.getInstance().get(ExtSdkChannelManager.ExtSdkChannelName.SEND_CHANNEL).setMethodCallHandler(ExtSdkApiFlutter.getInstance());
            ExtSdkChannelManager.getInstance().add(flutterPluginBinding.getBinaryMessenger(), ExtSdkChannelManager.ExtSdkChannelName.RECV_CHANNEL);
            ExtSdkContext.context = flutterPluginBinding.getApplicationContext();
            ExtSdkApiFlutter.getInstance().init(new Object());
//            _channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "dart_to_native", JSONMethodCodec.INSTANCE);
//            _channel.setMethodCallHandler(this);
        }
    }

    @Override
    public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        if (ExtSdkTest.TEST_TYPE == 1) {

        } else if (ExtSdkTest.TEST_TYPE == 2) {
            ExtSdkApiFlutter.getInstance().unInit(null);
        }
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        Log.i(TAG, call.method + ": " + call.arguments.toString());
        result.notImplemented();
    }

    private static final String TAG = "ImFlutterSdkPlugin";
}


class EMWrapperCallBack implements EMCallBack {

    EMWrapperCallBack(Result result, String channelName, Object object) {
        this.result = result;
        this.channelName = channelName;
        this.object = object;
    }

    Result result;
    String channelName;
    Object object;

    void post(Runnable runnable) {
        ImFlutterSdkPlugin.handler.post(runnable);
    }

    @Override
    public void onSuccess() {
        post(() -> {
            Map<String, Object> data = new HashMap<>();
            if (object != null) {
                data.put(channelName, object);
            }
            result.success(data);
        });
    }

    @Override
    public void onError(int code, String desc) {
        post(() -> {
            Map<String, Object> data = new HashMap<>();
            data.put("error", EMErrorHelper.toJson(code, desc));
            EMLog.e("callback", desc);
            result.success(data);
        });
    }

    @Override
    public void onProgress(int progress, String status) {
        // no need
    }
}


class EMValueWrapperCallBack<T> implements EMValueCallBack<T> {

    EMValueWrapperCallBack(MethodChannel.Result result, String channelName) {
        this.result = result;
        this.channelName = channelName;
    }

    private MethodChannel.Result result;
    private String channelName;

    public void post(Runnable runnable) {
        ImFlutterSdkPlugin.handler.post(runnable);
    }

    @Override
    public void onSuccess(T object) {
        updateObject(object);
    }

    @Override
    public void onError(int code, String desc) {
        post(() -> {
            Map<String, Object> data = new HashMap<>();
            data.put("error", EMErrorHelper.toJson(code, desc));
            EMLog.e("callback", "onError");
            result.success(data);
        });
    }

    public void updateObject(Object object) {
        post(() -> {
            Map<String, Object> data = new HashMap<>();
            if (object != null) {
                data.put(channelName, object);
            }
            result.success(data);
        });
    }
}