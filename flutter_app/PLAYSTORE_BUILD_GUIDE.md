# Google Play Store Release & Build Guide

This guide details how to generate your **Google Play Store App Bundle (`.aab`)** and **Release APK (`.apk`)** for the Gas Delivery application.

---

## ⚠️ Important Google Play Store Policy (2024–2026)

- **New App Requirement**: Google Play Console mandates that all new applications must be submitted as an **Android App Bundle (`.aab`)** rather than a standalone `.apk`.
- **Target SDK**: Google Play requires target SDK 34 (Android 14). This has already been configured in [`flutter_app/android/app/build.gradle`](file:///c:/Users/kemolosiwa/Desktop/gas-main/flutter_app/android/app/build.gradle).
- **Package Name**: `com.gasexpress.delivery`.

---

## Option 1: Automated 1-Click Cloud Build (Recommended)

Because building an Android APK/AAB locally requires the **Flutter SDK**, **Java JDK 17**, and the **Android SDK Build-Tools** (totaling ~5GB+), an automated GitHub Actions CI/CD workflow is included at [`.github/workflows/build_apk.yml`](file:///c:/Users/kemolosiwa/Desktop/gas-main/.github/workflows/build_apk.yml).

1. Push this project to your GitHub repository:
   ```powershell
   git add .
   git commit -m "Configure Play Store build pipeline"
   git push origin main
   ```
2. Open your GitHub repository in your browser and click on the **Actions** tab.
3. You will see the **Build Release APK and Play Store Bundle (AAB)** workflow running.
4. Once completed (~3–4 minutes), click on the build summary to download:
   - **`GasExpress-PlayStore-AAB`** (the `.aab` file ready to drag-and-drop into Google Play Console).
   - **`GasExpress-Release-APK`** (the `.apk` file for direct testing on Android phones).

---

## Option 2: Local Build on Your Machine

If you have Flutter and the Android SDK installed on your computer:

### Step 1: Generate Release Keystore
In your terminal, generate a release signing key:
```powershell
keytool -genkey -v -keystore c:\Users\kemolosiwa\Desktop\gas-main\flutter_app\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Step 2: Configure `key.properties`
Create a file named `key.properties` in `flutter_app/android/`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

### Step 3: Run the Build Commands
Navigate to the Flutter project:
```powershell
cd c:\Users\kemolosiwa\Desktop\gas-main\flutter_app

# Download dependencies
flutter pub get

# 1. Generate Google Play Store Bundle (.aab)
flutter build appbundle --release
# Output: flutter_app/build/app/outputs/bundle/release/app-release.aab

# 2. Generate Release APK (.apk)
flutter build apk --release
# Output: flutter_app/build/app/outputs/flutter-apk/app-release.apk
```

---

## Step 4: Uploading to Google Play Console

1. Log into your [Google Play Console](https://play.google.com/console).
2. Click **Create app** and set:
   - App name: **GasExpress Botswana**
   - Default language: English
   - App or game: **App**
   - Free or paid: **Free**
3. Navigate to **Release > Production** (or **Internal Testing** to test first).
4. Click **Create new release**.
5. Drag and drop `app-release.aab` (or download it from the GitHub Actions artifacts).
6. Fill in your Release Notes and click **Save and Review release**.
