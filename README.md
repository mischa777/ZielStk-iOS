# ZielStk iOS

Private source copy prepared for macOS and Xcode.

## Open on a Mac

1. Install Xcode and CocoaPods.
2. Clone this repository:

   ```bash
   git clone https://github.com/mischa777/ZielStk-iOS.git
   cd ZielStk-iOS
   ```

3. Resolve the current dependencies and create the workspace:

   ```bash
   pod repo update
   pod update
   ```

4. Open `ZielStk.xcworkspace` in Xcode:

   ```bash
   open ZielStk.xcworkspace
   ```

5. Select your Apple Developer team in Signing & Capabilities, then build the `ZielStk` scheme.

The app targets iOS 15.0 or newer. The old `Pods`, workspace, and `Podfile.lock` were deliberately not copied because their versions no longer matched the current `Podfile`; CocoaPods regenerates them on the Mac.

## Security

Apple private keys such as `AuthKey_*.p8` are intentionally excluded. Keep them outside Git and add them locally only where required.
