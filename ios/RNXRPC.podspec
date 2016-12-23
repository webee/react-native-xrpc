Pod::Spec.new do |s|
  s.name                = "RNXRPC"
  s.version             = '0.5.0'
  s.summary             = 'react-native-xprc client for ios'
  s.description         = <<-DESC
                            RNXRPC(rpc, pub/sub between js and natives both way and some helpers for react-native.) client for ios.
                         DESC
  s.homepage            = "https://github.com/webee/react-native-xrpc-ios"
  s.license             = 'MIT'
  s.author              = "webee.yw <webee.yw@gmail.com>"
  s.source              = { :git => "https://github.com/webee/react-native-xrpc-ios", :tag => s.version }
  s.default_subspec     = 'XRPC'
  s.requires_arc        = true
  s.platform            = :ios, "8.0"

  s.subspec 'XRPC' do |ss|
    ss.dependency 'React/Core'
    ss.dependency 'ReactiveObjC', '~> 2.1'
    ss.dependency 'PromiseKit', '~> 4.0'
    ss.source_files        = "ReactNativeXRPC/**/*.{h,m,swift}"
    ss.pod_target_xcconfig = { "CLANG_CXX_LANGUAGE_STANDARD" => "c++14" }
  end

  s.subspec 'Helper' do |ss|
    ss.dependency 'RNXRPC/XRPC'
    ss.source_files        = "RNHelper/**/*.{h,m,swift}"
    ss.pod_target_xcconfig = { "CLANG_CXX_LANGUAGE_STANDARD" => "c++14" }
  end
end
