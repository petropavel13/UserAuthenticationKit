Pod::Spec.new do |s|
  s.name            = "UserAuthenticationKit"
  s.version         = "0.1"
  s.summary         = "User authentication framework for iOS"
  s.homepage        = "https://github.com/TouchInstinct/UserAuthenticationKit"
  s.license         = "Apache License, Version 2.0"
  s.author          = "Touch Instinct"
  s.source          = { :git => "https://github.com/TouchInstinct/UserAuthenticationKit.git", :tag => s.version }
  s.platform        = :ios, '9.0'

  s.subspec 'Core' do |ss|
    ss.ios.deployment_target = '9.0'
    ss.tvos.deployment_target = '9.0'
    ss.watchos.deployment_target = '2.0'

    ss.ios.source_files = "Sources/**/*.swift"
    ss.watchos.source_files = [
      "Sources/Classes/PassCode/{Storage,Validation}/*.swift",
      "Sources/Enums/{PassCodeFlowError,PassCodeState}.swift",
      "Sources/Extensions/PassCode/String+PassCodeValidation.swift",
      "Sources/Protocols/PassCode/{Storage,Validation}/*.swift"
    ]
    ss.tvos.source_files = [
      "Sources/Classes/PassCode/{Storage,Validation}/*.swift",
      "Sources/Enums/{PassCodeFlowError,PassCodeState}.swift",
      "Sources/Extensions/PassCode/String+PassCodeValidation.swift",
      "Sources/Protocols/PassCode/{Storage,Validation}/*.swift"
    ]

    ss.dependency "CryptoSwift"
    ss.dependency "KeychainAccess"
    ss.ios.dependency "CollectionKit"
  end

  s.default_subspec = 'Core'
  s.swift_version = '4.2'

end
