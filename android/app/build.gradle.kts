plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val signingValues = listOf(
    providers.environmentVariable("ANDROID_KEYSTORE_PATH").orNull,
    providers.environmentVariable("ANDROID_KEYSTORE_PASSWORD").orNull,
    providers.environmentVariable("ANDROID_KEY_ALIAS").orNull,
    providers.environmentVariable("ANDROID_KEY_PASSWORD").orNull,
)
val hasAnyReleaseSigningValue = signingValues.any { !it.isNullOrBlank() }
val hasCompleteReleaseSigning = signingValues.all { !it.isNullOrBlank() }

require(!hasAnyReleaseSigningValue || hasCompleteReleaseSigning) {
    "Release signing is partially configured. Set all four ANDROID_KEYSTORE_* / ANDROID_KEY_* environment variables."
}

android {
    namespace = "com.example.staynest"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.staynest"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasCompleteReleaseSigning) {
                storeFile = file(signingValues[0]!!)
                storePassword = signingValues[1]
                keyAlias = signingValues[2]
                keyPassword = signingValues[3]
            }
        }
    }

    buildTypes {
        release {
            // A debug-signed APK is produced only when no private release key is
            // configured. Add the documented GitHub Actions secrets for distribution.
            signingConfig = if (hasCompleteReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
