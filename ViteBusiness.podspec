#
# Be sure to run `pod lib lint ViteBusiness.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ViteBusiness'
  s.version          = '0.0.1'
  s.summary          = 'Vite Business'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "Vite Business"

  s.homepage         = 'https://github.com/vitelabs/vite-business-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'haoshenyang' => 'shenyang@vite.org' }
  s.source           = { :git => 'https://github.com/vitelabs/vite-business-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  
  #s.resources = 'ViteBusiness/Assets/ViteBusiness.bundle'


  s.static_framework = true
  s.default_subspec = 'Default'
  s.subspec 'Default' do |c|
    c.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }
    c.source_files = 'ViteBusiness/Classes/**/*'
    c.resource_bundles = {
      'ViteBusiness' => ['ViteBusiness/Assets/*']
    }
  end

  s.subspec 'Official' do |c|
    c.dependency "ViteBusiness/Default"
    c.pod_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => 'OFFICIAL=1',
      'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'OFFICIAL'
    }
  end

  s.subspec 'Test' do |c|
    c.dependency "ViteBusiness/Default"
    c.pod_target_xcconfig = { 
      'GCC_PREPROCESSOR_DEFINITIONS' => 'TEST=1',
      'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'TEST'
    }
  end

  s.subspec 'Enterprise' do |c|
    c.dependency "ViteBusiness/Default"
    c.pod_target_xcconfig = { 
      'GCC_PREPROCESSOR_DEFINITIONS' => 'ENTERPRISE=1',
      'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'ENTERPRISE'
    }
  end

  s.dependency 'R.swift'
  s.dependency 'RxSwift'
  s.dependency 'SnapKit'
  s.dependency 'RxCocoa'
  s.dependency 'XCGLogger'
  s.dependency 'CryptoSwift'
  s.dependency 'ObjectMapper'
  s.dependency 'Then'
  s.dependency 'NSObject+Rx'
  s.dependency 'MBProgressHUD'
  s.dependency 'RxOptional'
  s.dependency 'PromiseKit'
  s.dependency 'Vite_HDWalletKit'
  s.dependency 'Eureka'
  s.dependency 'KeychainSwift'
  s.dependency 'Alamofire'
  s.dependency 'Moya'
  s.dependency 'SwiftyJSON'
  s.dependency 'JSONRPCKit'
  s.dependency 'APIKit'


  s.dependency 'SnapKit', '~> 4.0.0'
  s.dependency 'BigInt', '~> 3.0'
  s.dependency 'R.swift', '5.0.0.alpha.3'
  s.dependency 'JSONRPCKit', '~> 3.0.0'
  s.dependency 'PromiseKit', '~> 6.0'
  s.dependency 'APIKit'
  s.dependency 'ObjectMapper'
  s.dependency 'MBProgressHUD'
  s.dependency 'KeychainSwift'
  s.dependency 'Moya'
  s.dependency 'MJRefresh'
  s.dependency 'KMNavigationBarTransition'
  s.dependency 'XCGLogger', '~> 6.1.0'
  s.dependency 'pop', '~> 1.0'
  s.dependency 'DACircularProgress', '2.3.1'
  s.dependency 'Kingfisher', '~> 4.0'
  s.dependency 'NYXImagesKit', '2.3'

  #request
  s.dependency 'SwiftyJSON'

  #statistics
  s.dependency 'BaiduMobStat'

  #UI Control
  s.dependency 'ActionSheetPicker-3.0'
  s.dependency 'MBProgressHUD'
  s.dependency 'Toast-Swift', '~> 4.0.1'
  s.dependency 'RazzleDazzle'
  s.dependency 'CHIPageControl'

  #table static form
  s.dependency 'Eureka', '~> 4.3.0'

  #RX
  s.dependency 'RxSwift', '~> 4.0'
  s.dependency 'RxCocoa'
  s.dependency 'RxDataSources', '~> 3.0'
  s.dependency 'NSObject+Rx'
  s.dependency 'RxOptional'
  s.dependency 'RxGesture'
  s.dependency 'Then'
  s.dependency 'Action'
  s.dependency 'ReusableKit', '~> 2.1.0'
  s.dependency 'ReactorKit'


  #code review
  s.dependency 'SwiftLint'

  #crash
  s.dependency 'Fabric'
  s.dependency 'Crashlytics'
  s.dependency 'Firebase/Core'

  s.dependency 'MLeaksFinder'

  s.dependency 'ViteUtils'
  s.dependency 'ViteWallet'

  # s.resource_bundles = {
  #   'ViteBusiness' => ['ViteBusiness/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
