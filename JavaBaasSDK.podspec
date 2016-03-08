
Pod::Spec.new do |s|

  s.name         = "JavaBaasSDK"
  s.version      = "0.0.8"
  s.summary      = "一款基于baas服务的SDK 提供基本查询 ACL 云方法 用户系统 第三方登录等"
  s.description  = "一款基于baas服务的SDK 提供基本查询 ACL 云方法 用户系统 第三方登录等等..."
  s.homepage     = "https://github.com/zhaopeng21790"
  s.license      = "MIT"
  s.author       = { "赵朋" => "185403812@qq.com" }
  s.platform     = :ios, "6.0"
  #s.public_header_files = "JavaBaasSDK/JavaBaas.h"
  s.source       = { :git => "https://github.com/zhaopeng21790/JavaBaasSDK.git",:tag => s.version}
  s.source_files  = "JavaBaasSDK","JavaBaasSDK/**/*.{h,m}"
  #s.exclude_files = "Classes/Exclude"
  s.frameworks = "UIKit", "Foundation"
  s.dependency "Qiniu"
  s.dependency "HappyDNS"
  s.dependency "AFNetworking"

end
