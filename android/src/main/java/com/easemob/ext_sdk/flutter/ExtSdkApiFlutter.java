package com.easemob.ext_sdk.flutter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.easemob.ext_sdk.common.ExtSdkApi;
import com.easemob.ext_sdk.common.ExtSdkCallback;
import com.easemob.ext_sdk.common.ExtSdkListener;
import com.easemob.ext_sdk.jni.ExtSdkApiJni;

public class ExtSdkApiFlutter implements ExtSdkApi {

    private static class SingleHolder {
        static ExtSdkApiFlutter instance = new ExtSdkApiFlutter();
    }

    public static ExtSdkApiFlutter getInstance() {
        return ExtSdkApiFlutter.SingleHolder.instance;
    }

    @Override
    public void init(@NonNull Object config) {
        ExtSdkApiJni.nativeInit(config);
    }

    @Override
    public void unInit(@Nullable Object params) {
        ExtSdkApiJni.nativeUnInit();
    }

    @Override
    public void addListener(@NonNull ExtSdkListener listener) {
        ExtSdkApiJni.nativeAddListener(listener);
    }

    @Override
    public void delListener(@NonNull ExtSdkListener listener) {
        ExtSdkApiJni.nativeDelListener(listener);
    }

    @Override
    public void callSdkApi(@NonNull String methodType, @Nullable Object params, @Nullable ExtSdkCallback callback) {
        ExtSdkApiJni.nativeCallSdkApi(methodType, params, callback);
    }
}
