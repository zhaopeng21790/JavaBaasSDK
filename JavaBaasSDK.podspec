
Pod::Spec.new do |s|

  s.name         = "JavaBaasSDK"
  s.version      = "0.0.2"
  s.summary      = "一款基于baas服务的SDK 提供基本查询 ACL 云方法 用户系统 第三方登录等"
  s.description  = "一款基于baas服务的SDK 提供基本查询 ACL 云方法 用户系统 第三方登录等等..."

  s.homepage     = "https://github.com/zhaopeng21790"
  s.license      = "MIT"
  s.author       = { "赵朋" => "185403812@qq.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/zhaopeng21790/JavaBaasSDK.git",:tag => '0.0.2' }
  s.source_files  = "SDK", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.frameworks = "UIKit", "Foundation"
  s.dependency "HappyDNS"

end