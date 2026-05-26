plugins {
    id("com.android.application")
    id("kotlin-android") 
    
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // 🎯 [수정 완료] Firebase 신분증 이름(qr_attendance_manager)과 똑같이 맞췄습니다.
    // 이 줄이 "com.example.checky"로 되어 있어서 앱이 튕겼던 겁니다!
    namespace = "com.example.qr_attendance_manager" 
    
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // 🎯 Firebase 설정 파일과 일치해야 합니다.
        applicationId = "com.example.qr_attendance_manager"
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}