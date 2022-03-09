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
    # :git => 'https://github.com/AsteriskZuo/im_flutter_sdk.git'
    :path => '.' 
  }


  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'

  s.dependency 'Flutter'
  s.dependency 'HyphenateChat','3.8.3.1'
  # s.dependency 'im_flutter_sdk_cpp', :podspec => 'https://raw.github.com/gist/1346394/1d26570f68ca27377a27430c65841a0880395d72/JSONKit.podspec'

  s.ios.deployment_target = '10.0'

  # s.subspec 'cpp' do |s_cpp|
  #   # s_cpp.source = {
  #   #   :git => 'https://github.com/AsteriskZuo/im_flutter_sdk.git',
  #   # }
  #   s_cpp.source_files = 'ext_sdk/cpp/common/**/*.cpp'
  #   s_cpp.public_header_files = 'ext_sdk/cpp/common/**/*.h'
  #   s_cpp.dependency 'Flutter'
  #   s_cpp.ios.deployment_target = '10.0'
  # end

end

