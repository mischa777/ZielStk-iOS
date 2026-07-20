# iOS Dependency Migration

## Current state

- `SwiftyStoreKit` removed from runtime code and `Podfile`
- minimum deployment target raised to `iOS 15`
- purchases migrated to `StoreKit 2`
- `GoogleSignIn` runtime code migrated to the modern closure-based API
- `AppsFlyerFramework` prepared for v7 initialization/session startup
- CocoaPods dependency constraints moved to current 2025-2026 release lines:
  - `Firebase*` `~> 12.15`
  - `GoogleSignIn` `~> 9.2`
  - `FBSDK*` `~> 18.1`
  - `AppsFlyerFramework` `~> 7.0`
  - `SDWebImage` `~> 5.21`

## Required resolver step

This repository currently has a stale `Podfile.lock` from the older pod graph.
Regenerate it on macOS with CocoaPods after opening this project:

```sh
pod repo update
pod update
```

Then open `ZielStk.xcworkspace`, clean the build folder, and build the `ZielStk`
scheme. Do not manually edit `Podfile.lock`; let CocoaPods resolve transitive
Firebase, Google, Facebook, AppsFlyer, and SDWebImage dependencies.

## Recommended next package moves

1. Move `GoogleSignIn` from CocoaPods to Swift Package Manager after the pod update builds cleanly
   - URL: `https://github.com/google/GoogleSignIn-iOS`
2. Move Firebase modules from CocoaPods to Swift Package Manager
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - products to add:
     - `FirebaseAnalytics`
     - `FirebaseAuth`
     - `FirebaseCrashlytics`
     - `FirebaseFirestore`
     - `FirebaseMessaging`
     - `FirebaseRemoteConfig`
     - `FirebaseStorage`
3. Keep these on CocoaPods for the next pass unless Xcode package validation is available
   - `FBSDKCoreKit`
   - `FBSDKLoginKit`
   - `FBSDKMarketingKit`
   - `AppsFlyerFramework`
   - `SDWebImage`

## Safe Xcode order

1. Run the CocoaPods resolver step above and build the app.
2. Open `ZielStk.xcworkspace` in Xcode.
3. Add the Google and Firebase packages in `File > Add Packages...`.
4. Link the package products to target `ZielStk`.
5. Remove `GoogleSignIn` and Firebase pods from `Podfile`.
6. Run `pod install`.
7. Clean build folder and build the app.
8. After the app builds cleanly, remove old Firebase and Google linker leftovers if Xcode still shows duplicate linking.

## Why staged migration is safer here

- Firebase and Google are tightly wired into the existing CocoaPods-generated workspace.
- The package graph and linker cleanup should be validated directly in Xcode after each step.
- Doing Google/Firebase first gives the biggest reduction in CocoaPods surface with the lowest functional risk.
