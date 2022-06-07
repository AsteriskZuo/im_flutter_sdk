#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'im_flutter_sdk'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { 
    # :git => 'https://github.com/AsteriskZuo/im_flutter_sdk.git', :branch => "ext_sdk", :commit => "911483aed3300a25b53013350e36f1134eea5f4f"
    :path => '.' 
  }


  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  
  s.source_files = ['Classes/**/*', 'cpp/**/*.{h,cpp,mm}', 'objc/**/*']
  s.public_header_files = ['Classes/**/*.h']
  s.private_header_files = ['cpp/**/*.h']
  s.exclude_files = ['cpp/java/**/*', 'cpp/android/**/*', 'objc/rn/**/*']

  s.dependency 'Flutter'
  s.dependency 'HyphenateChat','3.9.3.1'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    "CLANG_CXX_LANGUAGE_STANDARD" => "c++11",
    'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
    # "ENABLE_BITCODE": "NO",
    'OTHER_LDFLAGS' => [ 
      '-Wunused-function', 
      '-Wunreachable-code', 
      '-Wunused-variable'
    ],
    'HEADER_SEARCH_PATHS' => [
      "$(PODS_TARGET_SRCROOT)/cpp/common",
      "$(PODS_TARGET_SRCROOT)/cpp/core",
      "$(PODS_TARGET_SRCROOT)/cpp/objc",
      "$(PODS_TARGET_SRCROOT)/objc/common",
      "$(PODS_TARGET_SRCROOT)/objc/dispatch",
      "$(PODS_TARGET_SRCROOT)/objc/flutter"
    ]
  }
  s.xcconfig = {
    "OTHER_LDFLAGS": "-ObjC",
    'GCC_PREPROCESSOR_DEFINITIONS' => [
      "OBJC_LANGUAGE",
      "FLUTTER_ARCHITECTURE",
      "IOS_PLATFORM"
    ]
  }

  s.ios.deployment_target = '10.0'

end

