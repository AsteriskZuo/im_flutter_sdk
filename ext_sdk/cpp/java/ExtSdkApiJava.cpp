//
// Created by asterisk on 2022/3/3.
//

#include "ExtSdkApiJava.h"
#include "ExtSdkObjectJava.h"
#include "ExtSdkListenerJava.h"
#include "ExtSdkApi.h"
#include "ExtSdkJniHelper.h"
#include <jni.h>

EXT_SDK_NAMESPACE_BEGIN

void ExtSdkApiJava::init(const std::shared_ptr<ExtSdkObject> config) {

}

void ExtSdkApiJava::addListener(const std::shared_ptr<ExtSdkObject> listener) {

}

void ExtSdkApiJava::delListener(const std::shared_ptr<ExtSdkObject> listener) {

}

void
ExtSdkApiJava::callSdkApi(const std::string &methodType, const std::shared_ptr<ExtSdkObject> params,
                          const std::shared_ptr<ExtSdkObject> callback) {
    JNIEnv *env = 0;
    env = ExtSdkJniHelper::getInstance()->attachCurrentThread();
    if (!env)
        return;
    std::shared_ptr<ExtSdkObjectJava> java_params = std::dynamic_pointer_cast<ExtSdkObjectJava>(
            params);
    std::shared_ptr<ExtSdkObjectJava> java_callback = std::dynamic_pointer_cast<ExtSdkObjectJava>(
            callback);
    jstring java_method_type = env->NewStringUTF(methodType.c_str());

    jclass jcls = env->FindClass("com/easemob/ext_sdk/common/ExtSdkDispatch");
    jmethodID jmid_getInstance = env->GetStaticMethodID(jcls, "getInstance",
                                                        "()Lcom/easemob/ext_sdk/common/ExtSdkDispatch;");
    jmethodID jmid_callSdkApi = env->GetMethodID(jcls, "callSdkApi",
                                                 "(Ljava/lang/String;Ljava/lang/Object;Lcom/easemob/ext_sdk/common/ExtSdkCallback;)V");
    jobject jobj = env->CallStaticObjectMethod(jcls, jmid_getInstance);
    env->CallVoidMethod(jobj, jmid_callSdkApi, java_method_type, java_params->obj,
                        java_callback->obj);
    env->DeleteLocalRef(jcls);
}

void ExtSdkApiJava::unInit() {

}

EXT_SDK_NAMESPACE_END

extern "C"
JNIEXPORT void JNICALL
Java_com_easemob_ext_1sdk_jni_ExtSdkApiJni_nativeInit(JNIEnv *env, jclass clazz,
                                                      jobject configures) {
    EXT_SDK_NAMESPACE_USING
    std::shared_ptr<ExtSdkObject> java_config = std::make_shared<ExtSdkObjectJava>(configures);
    ExtSdkApi::getInstance()->init(java_config);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_easemob_ext_1sdk_jni_ExtSdkApiJni_nativeAddListener(JNIEnv *env, jclass clazz,
                                                             jobject listener) {
    EXT_SDK_NAMESPACE_USING
    std::shared_ptr<ExtSdkObject> java_listener = std::make_shared<ExtSdkObjectJava>(listener);
    ExtSdkApi::getInstance()->addListener(java_listener);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_easemob_ext_1sdk_jni_ExtSdkApiJni_nativeDelListener(JNIEnv *env, jclass clazz,
                                                             jobject listener) {
    EXT_SDK_NAMESPACE_USING
    std::shared_ptr<ExtSdkObject> java_listener = std::make_shared<ExtSdkObjectJava>(listener);
    ExtSdkApi::getInstance()->delListener(java_listener);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_easemob_ext_1sdk_jni_ExtSdkApiJni_nativeCallSdkApi(JNIEnv *env, jclass clazz,
                                                            jstring method_type, jobject params,
                                                            jobject callback) {
    EXT_SDK_NAMESPACE_USING
    std::shared_ptr<ExtSdkObject> java_params = std::make_shared<ExtSdkObjectJava>(params);
    std::shared_ptr<ExtSdkObject> java_callback = std::make_shared<ExtSdkObjectJava>(callback);
    const char *java_method_type = env->GetStringUTFChars(method_type, 0);
    ExtSdkApi::getInstance()->callSdkApi(java_method_type, java_params, java_callback);
}
extern "C"
JNIEXPORT void JNICALL
Java_com_easemob_ext_1sdk_jni_ExtSdkApiJni_nativeUnInit(JNIEnv *env, jclass clazz) {
    EXT_SDK_NAMESPACE_USING
    ExtSdkApi::getInstance()->unInit();
}