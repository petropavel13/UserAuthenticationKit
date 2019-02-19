source 'https://github.com/CocoaPods/Specs'
source 'https://github.com/TouchInstinct/Podspecs.git'

abstract_target 'UserAuthenticationKit' do

  use_frameworks!
  inhibit_all_warnings!

  # common pods
  pod 'SwiftLint'
  pod "CryptoSwift"
  pod "KeychainAccess"

  target 'UserAuthenticationKit-iOS' do
    platform :ios, '8.0'

    pod "CollectionKit"

  end

  target 'UserAuthenticationKit-watchOS' do
    platform :watchos, '2.0'

    # pods for watchOS

  end

  target 'UserAuthenticationKit-tvOS' do
    platform :tvos, '9.0'

    # pods for tvOS

  end

  # target 'Example' do
  #   platform :ios, '8.0'

  #   pod "UserAuthenticationKit", :path => "UserAuthenticationKit.podspec"

  # end

end

ENV['COCOAPODS_DISABLE_STATS'] = "true"
