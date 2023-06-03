plugins {
    id("com.android.application")
}

android {
    namespace = "com.programminghoch10.revancedandroidcli"
    compileSdk = 33

    defaultConfig {
        applicationId = "com.programminghoch10.revancedandroidcli"
        minSdk = 23
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            signingConfig = signingConfigs["debug"]
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
}

dependencies {
    implementation(project(":revancedcli"))
}