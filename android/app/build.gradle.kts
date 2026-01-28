plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android")
    // Flutter Gradle Plugin (must be last)
    id("dev.flutter.flutter-gradle-plugin")
}

// ---- FIX: Read Flutter version values correctly (Kotlin DSL) ----
val flutterVersionCode: Int =
    project.findProperty("flutter.versionCode")?.toString()?.toInt() ?: 1

val flutterVersionName: String =
    project.findProperty("flutter.versionName")?.toString() ?: "1.0"

android {
    namespace = "com.example.covoicam_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // ---- FIX: modern Kotlin compiler options ----
    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        applicationId = "com.example.covoicam_mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        // ---- FIXED ----
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            // For now, debug signing (Codemagic can still build)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
