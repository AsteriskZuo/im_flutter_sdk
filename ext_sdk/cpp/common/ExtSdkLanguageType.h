//
// Created by asterisk on 2022/3/3.
//

#ifndef ANDROID_EXTSDKLANGUAGETYPE_H
#define ANDROID_EXTSDKLANGUAGETYPE_H

#include "ExtSdkDefine.h"
#include <cstdint>

EXT_SDK_NAMESPACE_BEGIN

enum class ExtSdkLanguageTypeValue : std::uint8_t {
    LANGUAGE_CPP, // with C language
    LANGUAGE_JAVA, // with kotlin language
    LANGUAGE_OBJECTIVE_C, // with C language, swift language
};

class ExtSdkLanguageType {

};

EXT_SDK_NAMESPACE_END

#endif //ANDROID_EXTSDKLANGUAGETYPE_H
