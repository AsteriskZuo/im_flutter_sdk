//
// Created by asterisk on 2022/3/3.
//

#include "ExtSdkApi.h"
#include "ExtSdkMethodType.h"
#include "ExtSdkJniHelper.h"

#if defined(JAVA_LANGUAGE)
#include "ExtSdkApiJava.h"
#elif defined(CPP_LANGUAGE)
#elif defined(OBJC_LANGUAGE)
#else
#error "Please specify the language macro definition."
#endif

EXT_SDK_NAMESPACE_BEGIN

ExtSdkApi* ExtSdkApi::getInstance() {
#if defined(JAVA_LANGUAGE)
    static ExtSdkApiJava instance;
    return &instance;
#elif defined(CPP_LANGUAGE)
    // TODO: no implement
#elif defined(OBJC_LANGUAGE)
    // TODO: no implement
#else
#error "Please specify the language macro definition."
#endif
}

EXT_SDK_NAMESPACE_END