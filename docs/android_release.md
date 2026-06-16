# Android Release Guide — College E-Voting System

This guide outlines the steps required to configure, sign, and build a production-ready Android version (APK and AAB) of the College E-Voting System for distribution on the Google Play Store or private college distribution channels.

---

## 1. Generate a Keystore File

Flutter apps must be digitally signed before they can be installed on Android devices. You need to generate a private signing key (keystore).

Run the following command in your terminal. Replace `your_password` and key details as necessary.

### Windows (PowerShell or Command Prompt)
```powershell
keytool -genkey -v -keystore d:/projects/evoting_app/android/app/upload-keystore.jks `
  -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 `
  -alias upload
```

### macOS / Linux
```bash
keytool -genkey -v -keystore ./android/app/upload-keystore.jks \
  -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

> [!WARNING]
> Keep the keystore file private. If you lose this file, you will be unable to update your application on the Google Play Store. Ensure the keystore file (`*.jks`) is added to your `.gitignore` so it is not committed to source control.

---

## 2. Configure `key.properties`

Create a file named `key.properties` in the `android/` directory of the project (`android/key.properties`). This file holds your signing configuration.

Add the following lines to `android/key.properties`:

```properties
storePassword=your_keystore_store_password_here
keyPassword=your_keystore_key_password_here
keyAlias=upload
storeFile=upload-keystore.jks
```

*(Note: Since the `storeFile` is configured as a relative path, Android Gradle will look for `upload-keystore.jks` in the `android/app/` directory).*

---

## 3. Configure `build.gradle`

Configure Gradle to use the `key.properties` signing key when compiling the application in release mode.

Modify `android/app/build.gradle`. Locate the `android` block and replace or update the signing config code:

```groovy
def keystorePropertiesFile = rootProject.file('key.properties')
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new java.io.FileInputStream(keystorePropertiesFile))
}

android {
    ...
    defaultConfig {
        // Ensure your applicationId is unique (e.g., edu.college.evoting)
        applicationId "com.college.evoting"
        minSdkVersion 21 // Required for Flutter/Supabase integration
        targetSdkVersion 34 // Keep aligned with Play Store requirements
        versionCode 1
        versionName "1.0.0"
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            // Signing with release key
            signingConfig signingConfigs.release
            
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

## 4. Run Release Build Commands

Open a terminal in the project root directory and run the following compilation pipeline:

1. Clean previous build files:
   ```bash
   flutter clean
   ```

2. Resolve all dependencies:
   ```bash
   flutter pub get
   ```

3. Build the Release APK (for direct sideloading/manual distributions):
   ```bash
   flutter build apk --release
   ```
   *Output path: `build/app/outputs/flutter-apk/app-release.apk`*

4. Build the Release App Bundle (AAB - required for Google Play Store):
   ```bash
   flutter build appbundle --release
   ```
   *Output path: `build/app/outputs/bundle/release/app-release.aab`*

---

## 5. Google Play Store Upload

To deploy the app to students via Google Play:

1. Go to the [Google Play Console](https://play.google.com/console/) and sign in.
2. Click **Create app** and configure details (App name, language, Free app).
3. Under **Production**, click **Create new release**.
4. Upload the generated App Bundle (`app-release.aab`) located in `build/app/outputs/bundle/release/`.
5. Define the Release Name (e.g., `1.0.0 (1)`) and release notes.
6. Submit the release for review. Once approved, the app will be live for students to download.
7. Or, use **Internal Testing** or **Closed Beta** to distribute to a selected group of student testers first.
