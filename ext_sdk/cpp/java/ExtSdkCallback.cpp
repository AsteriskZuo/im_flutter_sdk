//
// Created by asterisk on 2022/3/4.
//

#include "ExtSdkCallback.h"
#include "ExtSdkMethodType.h"
#include <jni.h>
#include <string>
#include <functional>

extern "C"
JNIEXPORT void JNICALL
Java_com_example_extension_1sdk_1demo_test4_jni_ExtSdkCallbackJniR_nativeSuccess(JNIEnv *env,
                                                                                 jobject thiz,
                                                                                 jlong obj,
                                                                                 jstring method_type,
                                                                                 jobject data) {
    // TODO: implement nativeSuccess()


}
extern "C"
JNIEXPORT void JNICALL
Java_com_example_extension_1sdk_1demo_test4_jni_ExtSdkCallbackJniR_nativeFail(JNIEnv *env,
                                                                              jobject thiz,
                                                                              jlong obj,
                                                                              jstring method_type,
                                                                              jint code,
                                                                              jobject ext) {
    // TODO: implement nativeFail()
    // todo: 和success一样，这个知识demo
}