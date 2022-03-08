package com.easemob.ext_sdk.common;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class ExtSdkDispatch implements ExtSdkApi{

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

    }

    @Override
    public void delListener(@NonNull ExtSdkListener listener) {

    }

    @Override
    public void callSdkApi(@NonNull String methodType, @Nullable Object params, @Nullable ExtSdkCallback callback) {

    }
}
