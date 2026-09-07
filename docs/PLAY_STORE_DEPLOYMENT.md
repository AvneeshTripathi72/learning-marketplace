# Google Play Store Deployment Guide

Complete step-by-step instructions for preparing, signing, building, and deploying the **Publication & Education Platform** Flutter application to the Google Play Store.

---

## 📋 Prerequisites

- **Google Play Console Account**: Verified Developer Account.
- **Java Development Kit (JDK)**: JDK 17 installed and added to environment variables.
- **Flutter SDK**: Updated Flutter stable channel (`>=3.20.0`).
- **Android Studio**: Installed with Android SDK Build-Tools and Command-line Tools.

---

## 🔑 Step 1: Create an Android Release Keystore

Generate a secure release keystore file for signing your Android app bundle:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

> **Important**: Store `upload-keystore.jks` in a secure location (e.g. `android/app/upload-keystore.jks`). Never check the keystore file or password secrets into public version control.

---

## ⚙️ Step 2: Configure Key Properties (`key.properties`)

Create a `key.properties` file in the `android/` directory containing your keystore configuration:

```properties
storePassword=<YOUR_STORE_PASSWORD>
keyPassword=<YOUR_KEY_PASSWORD>
keyAlias=upload
storeFile=../app/upload-keystore.jks
```

---

## 📝 Step 3: Configure Android App Signing (`android/app/build.gradle`)

Ensure `android/app/build.gradle` is configured to load `key.properties` for the release build:

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace "com.education.platform"
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.education.platform"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile file(keystoreProperties['storeFile'])
                storePassword keystoreProperties['storePassword']
            }
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

## 📦 Step 4: Build the Android App Bundle (AAB)

Run the release build command to compile an optimized Android App Bundle:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

The generated `.aab` package will be saved to:
`build/app/outputs/bundle/release/app-release.aab`

---

## 🚀 Step 5: Upload to Google Play Console

1. Log into your [Google Play Console](https://play.google.com/console).
2. Click **Create App** and fill in app details (App Name, Default Language, Free/Paid, Privacy Policy).
3. Navigate to **Testing** $\rightarrow$ **Internal Testing** or **Production**.
4. Create a new release and upload the compiled `app-release.aab` bundle.
5. Fill out the Store Listing assets:
   - **App Icon**: 512 x 512 px PNG
   - **Feature Graphic**: 1024 x 500 px PNG
   - **Phone Screenshots**: At least 2 screenshots (16:9 or 9:16 aspect ratio)
   - **7-inch & 10-inch Tablet Screenshots**
6. Complete the Content Rating questionnaire and Target Audience details.
7. Submit the release for Google Play review!
