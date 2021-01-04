# Uncomment the next line to define a global platform for your project
# platform :ios, '14.2'

target 'Spike' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pod deployment target
  post_install do |pi|
      pi.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.2'
        end
      end
  end
  
  # Pods for Spike
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'FirebaseUI'
  pod 'FirebaseUI/Storage'
  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
  pod 'Firebase/Functions'
  pod 'Geofirestore', :git => 'https://github.com/basementaspirations/GeoFirestore-iOS', :branch => 'firebase-upgrade'
  pod 'GoogleSignIn'
  pod 'FBSDKCoreKit'
  pod 'FBSDKShareKit'
  pod 'FBSDKLoginKit'
  pod 'PickerButton'
end
