import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

// AdMob App ID: android/admob.properties > env ADMOB_APP_ID > Google test ID
val admobProperties = Properties()
val admobPropertiesFile = rootProject.file("admob.properties")
if (admobPropertiesFile.exists()) {
    admobPropertiesFile.inputStream().use { admobProperties.load(it) }
}
val admobAppId: String =
    System.getenv("ADMOB_APP_ID")
        ?: admobProperties.getProperty("ADMOB_APP_ID")
        ?: "ca-app-pub-3940256099942544~3347511713"

android {
    namespace = "com.dragonsblock.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                // Paths in key.properties are relative to android/ (rootProject)
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile") ?: "")
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.dragonsblock.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobAppId"] = admobAppId
    }

    buildTypes {
        release {
            val releaseSigning = signingConfigs.findByName("release")
            check(releaseSigning != null) {
                "Release signing missing. Copy android/key.properties.example → android/key.properties " +
                    "and point storeFile at your upload-keystore.jks (see PLAY_RELEASE.md)."
            }
            check(releaseSigning.storeFile?.exists() == true) {
                "Release keystore file not found: ${releaseSigning.storeFile}. " +
                    "Run tool/create_upload_keystore.ps1 or fix storeFile in android/key.properties."
            }
            signingConfig = releaseSigning
        }
    }
}

flutter {
    source = "../.."
}
