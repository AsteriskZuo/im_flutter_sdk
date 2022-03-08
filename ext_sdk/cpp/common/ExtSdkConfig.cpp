//
// Created by asterisk on 2022/3/3.
//

#include "ExtSdkConfig.h"

EXT_SDK_NAMESPACE_BEGIN


const std::string ExtSdkConfig::current_ext_sdk_version = "1.0.0";

#if defined(JAVA_LANGUAGE)
const ExtSdkLanguageTypeValue ExtSdkConfig::current_language_type = ExtSdkLanguageTypeValue::LANGUAGE_JAVA;
#elif defined(CPP_LANGUAGE)
#elif defined(OBJC_LANGUAGE)
#else
#error "Please specify the language macro definition."
#endif

EXT_SDK_NAMESPACE_END