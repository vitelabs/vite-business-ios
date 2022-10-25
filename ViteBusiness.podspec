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
  s.description      = "Vite Business"
  s.homepage         = 'https://github.com/vitelabs/vite-business-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'haoshenyang' => 'shenyang@vite.org' }
  s.source           = { :git => 'https://github.com/vitelabs/vite-business-ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'
  s.static_framework = true
  s.vendored_frameworks = 'ViteBusiness/Frameworks/**/*.{framework}'
  s.source_files = 'ViteBusiness/Classes/**/*.{h,m,swift,c}'
  s.resource_bundles = {
      'ViteBusiness' => ['ViteBusiness/Assets/*','ViteBusiness/Classes/**/*.{storyboard,xib}']
  }

  s.dependency 'R.swift'
  s.dependency 'SnapKit'
  s.dependency 'RxCocoa'
  s.dependency 'XCGLogger'
  s.dependency 'CryptoSwift'
  s.dependency 'ObjectMapper'
  s.dependency 'Then'
  s.dependency 'NSObject+Rx'
  s.dependency 'MBProgressHUD'
  s.dependency 'RxOptional'
  s.dependency 'Vite_HDWalletKit'
  s.dependency 'KeychainSwift'
  s.dependency 'Alamofire'
  s.dependency 'Moya'
  s.dependency 'SwiftyJSON'
  s.dependency 'JSONRPCKit'
  s.dependency 'APIKit'
  s.dependency 'Starscream'


  s.dependency 'SnapKit', '~> 4.0.0'
  s.dependency 'BigInt'
  s.dependency 'R.swift', '5.0.0.alpha.3'
  s.dependency 'JSONRPCKit', '~> 3.0.0'
  s.dependency 'PromiseKit', '~> 6.0'
  s.dependency 'PromiseKit/Alamofire'
  s.dependency 'APIKit'
  s.dependency 'ObjectMapper', '3.5.1'
  s.dependency 'MBProgressHUD'
  s.dependency 'KeychainSwift'
  s.dependency 'Moya'
  s.dependency 'MJRefresh'
  s.dependency 'KMNavigationBarTransition', '1.1.8'
  s.dependency 'XCGLogger', '~> 7.0'
  s.dependency 'pop', '~> 1.0'
  s.dependency 'DACircularProgress', '2.3.1'
  s.dependency 'Kingfisher', '~> 4.0'
  s.dependency 'NYXImagesKit', '2.3'
  s.dependency 'FSPagerView'
  s.dependency 'URLNavigator'
  s.dependency 'web3swift'
  s.dependency 'Charts', '4.1.0'
  #request
  s.dependency 'SwiftyJSON'


  #UI Control
  s.dependency 'ActionSheetPicker-3.0'
  s.dependency 'MBProgressHUD'
  s.dependency 'Toast-Swift', '~> 4.0.1'
  s.dependency 'RazzleDazzle'
  s.dependency 'CHIPageControl'
  s.dependency 'ActiveLabel', '1.1.0'
  s.dependency 'PPBadgeViewSwift', '3.1.0'

  #table static form
  s.dependency 'Eureka', '~> 5.3.0'

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
  s.dependency 'Firebase/Crashlytics'
  s.dependency 'Firebase/Analytics'
  s.dependency 'Firebase/Core'

  s.dependency 'ViteWallet'
  s.dependency 'BinanceChain'

end
