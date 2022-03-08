//
// Created by asterisk on 2022/3/3.
//

#ifndef ANDROID_EXTSDKCONFIG_H
#define ANDROID_EXTSDKCONFIG_H

#include "ExtSdkDefine.h"
#include "ExtSdkLanguageType.h"
#include <string>

EXT_SDK_NAMESPACE_BEGIN

class ExtSdkConfig {
    static const ExtSdkLanguageTypeValue current_language_type;
    static const std::string current_ext_sdk_version;
};

EXT_SDK_NAMESPACE_END

#endif //ANDROID_EXTSDKCONFIG_H
