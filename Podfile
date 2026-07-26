platform :ios, '15.0'

target 'ZielStk' do
  use_frameworks!

  pod 'FBSDKCoreKit', '~> 18.1'
  pod 'FBSDKLoginKit', '~> 18.1'
  pod 'GoogleSignIn', '~> 9.2'
  pod 'AppsFlyerFramework', '~> 7.0'

  pod 'FirebaseAnalytics', '~> 12.15'
  pod 'FirebaseAuth', '~> 12.15'
  pod 'FirebaseStorage', '~> 12.15'
  pod 'FirebaseFirestore', '~> 12.15'
  pod 'FirebaseCrashlytics', '~> 12.15'
  pod 'FirebaseMessaging', '~> 12.15'
  pod 'FirebaseRemoteConfig', '~> 12.15'

  pod 'SDWebImage', '~> 5.21'
end

target 'ZielStkShare' do
  use_frameworks!
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end
