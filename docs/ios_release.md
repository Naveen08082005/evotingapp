# iOS Release Guide — College E-Voting System

This guide outlines the steps required to configure, sign, and build a production-ready iOS version of the College E-Voting System for distribution on Apple TestFlight or the App Store.

---

## Prerequisites
- An active **Apple Developer Account** (Enrollment at [developer.apple.com](https://developer.apple.com/)).
- A Mac computer running macOS with the latest version of Xcode installed.
- CocoaPods dependency manager installed (`sudo gem install cocoapods` or `brew install cocoapods`).

---

## 1. Xcode Workspace Setup

1. Open a terminal and run the following commands to install iOS dependencies and generate the Xcode workspace:
   ```bash
   flutter clean
   flutter pub get
   cd ios
   pod install
   cd ..
   ```

2. Open the iOS project in Xcode by double-clicking `ios/Runner.xcworkspace` or running:
   ```bash
   open ios/Runner.xcworkspace
   ```

---

## 2. Signing and Provisioning Profiles

Before you can run the app on a physical device or submit it to Apple, you must configure a development/distribution certificate and provisioning profile.

### Step 1: Add Apple Developer Account to Xcode
1. In Xcode, navigate to **Xcode** -> **Settings...** (or **Preferences...** on older versions).
2. Go to the **Accounts** tab.
3. Click the **+** button, select **Apple ID**, and sign in with your Apple Developer credentials.

### Step 2: Configure Signing Settings
1. In the left Navigator pane of Xcode, select the root **Runner** project node.
2. Select the **Runner** target in the targets list.
3. Select the **Signing & Capabilities** tab at the top.
4. Check the box for **Automatically manage signing**.
5. Select your development **Team** from the dropdown menu.
6. Verify that Xcode successfully generates the signing certificate and provisioning profile:
   - **Signing Certificate**: Apple Development (or Apple Distribution for App Store builds)
   - **Provisioning Profile**: Automatically managed profile.
7. Under the **General** tab:
   - Verify that your **Bundle Identifier** is unique (e.g., `com.college.evoting`).
   - Set **Minimum Deployments** target (recommend iOS 13.0 or higher).

---

## 3. Configure Info.plist permissions

Since the application requires profile picture uploads for both students and candidates, the app must request camera and photo library access.

Verify or add the following keys to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app requires access to the camera to allow students and candidates to take a profile photo during registration and setup.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app requires access to the photo library to upload profile picture images for students and candidates.</string>
```

---

## 4. Build and Distribute using Xcode / TestFlight

To deploy the app to Apple for distribution:

### Step 1: Create an Archive
1. In the Xcode menu bar, select **Product** -> **Destination** and choose **Any iOS Device (arm64)**.
2. Select **Product** -> **Archive** from the menu. Xcode will build the project and compile the binary.
3. Once the archive is created, the **Organizer** window will open automatically.

### Step 2: Upload to App Store Connect
1. In the **Organizer** window, select the archive you just built.
2. Click the **Distribute App** button on the right-hand panel.
3. Select **App Store Connect** (for App Store or TestFlight beta releases) and click **Next**.
4. Select **Upload** (sends the build to App Store Connect) and click **Next**.
5. Accept the default options for strip swift symbols, rebuild from bitcode, etc., and select **Next**.
6. Select your App Store Connect distribution certificate and profile. Click **Next** to finalize the upload.

### Step 3: Configure TestFlight Beta Distribution
1. Log in to [App Store Connect](https://appstoreconnect.apple.com/).
2. Navigate to **My Apps** and select your E-Voting app (create a new app record first if this is the first release, matching your Bundle ID).
3. Click the **TestFlight** tab.
4. Once processing is complete (can take 10-15 minutes), select the uploaded build.
5. Create an **Internal Testing Group** to instantly distribute the app to up to 100 internal team members or college administrators.
6. Create an **External Testing Group** (requires brief Beta App Review by Apple) to share a public link with up to 10,000 students for student-wide voting test runs.
