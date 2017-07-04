Pod::Spec.new do |s|
  s.name = "CBBDataBus"
  s.version = "2.1.4"
  s.summary = "DataBus for iOS"
  s.homepage = "https://github.com/cross-border-bridge/data-bus-ios"
  s.author = 'DWANGO Co., Ltd.'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.platform = :ios, "8.0"
  s.source = { :git => "https://github.com/cross-border-bridge/data-bus-ios.git", :tag => "#{s.version}" }
  s.source_files = "CBBDataBus/**/*.{h,m}"
  s.resources = "typescript/build/*.js"
  s.frameworks = "WebKit"
  s.preserve_path = "CBBDataBus.modulemap"
  s.module_map = "CBBDataBus.modulemap"
end
