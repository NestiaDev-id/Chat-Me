// In android/app/build.gradle.kts
android {
    namespace = "com.example.chat_me"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Make sure this is present and correct, or update if newer is required by llama_cpp.

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.chat_me"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Add this for llama_cpp
        externalNativeBuild {
            cmake {
                cppFlags += "-std=c++17"
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Add this for llama_cpp
    externalNativeBuild {
        cmake {
            path = file("${projectDir}/../../.dart_tool/flutter_build/bd4040951111627eb188e44dd49557a7/outputs/cmake_build_release/armeabi-v7a/android-arm/libllama_cpp.so") // This path might need adjustment
            // You might need to adjust this path based on your Flutter version and where llama_cpp places its CMakeLists.txt
            // Usually, the plugin will handle this automatically during build.
        }
    }
}

flutter {
    source = "../.."
}