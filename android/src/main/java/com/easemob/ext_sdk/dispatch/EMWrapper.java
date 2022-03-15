package com.easemob.ext_sdk.dispatch;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.easemob.ext_sdk.common.ExtSdkCallback;
import com.easemob.ext_sdk.common.ExtSdkThreadUtil;
import com.hyphenate.exceptions.HyphenateException;

import org.json.JSONException;

import java.util.HashMap;
import java.util.Map;

public class EMWrapper {
//    protected void post(Runnable runnable) {
//        ExtSdkThreadUtil.mainThreadExecute(runnable);
//    }
//    protected void asyncRunnable(Runnable runnable) {
//        ExtSdkThreadUtil.asyncExecute(runnable);
//    }
    protected static void onSuccess(@NonNull ExtSdkCallback callback, @NonNull String methodType, @Nullable Object object) {
        Map<String, Object> data = new HashMap<>();
        if (object != null) {
            data.put(methodType, object);
        }
        callback.success(data);
    }

    public static void onError(@NonNull ExtSdkCallback callback, @NonNull Object e, @Nullable Object ext) {
        Map<String, Object> data = new HashMap<>();
        if (e instanceof HyphenateException) {
            data.put("error", HyphenateExceptionHelper.toJson((HyphenateException)e));
        } else if (e instanceof Integer) {
            data.put("error", EMErrorHelper.toJson((int)e, ext.toString()));
        } else if (e instanceof JSONException) {
            data.put("error", JSONExceptionHelper.toJson((JSONException)e));
        } else {
            data.put("error", "no implement");
        }
        callback.success(data);
    }

    protected static void onReceive(@NonNull String methodType, @Nullable Object data) {
        ExtSdkDispatch.getInstance().onReceive(methodType, data);
    }
}
