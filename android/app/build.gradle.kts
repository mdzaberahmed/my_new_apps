plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val flutterVersionCode = project.findProperty("flutter.versionCode") as String? ?: "1"
val flutterVersionName = project.findProperty("flutter.versionName") as String? ?: "1.0.0"

android {
    namespace = "com.mdzaberahmed.ffboostpanel"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.mdzaberahmed.ffboostpanel"
        minSdk = 21
        targetSdk = 34
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}
