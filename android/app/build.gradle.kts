plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase
}

android {
    namespace = "com.example.e_cycle"
    compileSdk = 35 // Replace with your Flutter compileSdkVersion
    ndkVersion = "27.0.12077973" // Use flutter.ndkVersion if available

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.e_cycle"
        minSdk = 23
        targetSdk = 34 // Replace with flutter.targetSdkVersion if needed
        versionCode = 1 // Set manually if `flutter.versionCode` isn't working
        versionName = "1.0" // Set manually if `flutter.versionName` isn't working
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Update if you have a release key
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.9.0"))
    implementation("com.google.firebase:firebase-analytics")
}
