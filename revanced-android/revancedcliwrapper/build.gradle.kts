plugins {
    id("com.android.application")
}

android {
    namespace = "com.programminghoch10.revancedandroidcli"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.programminghoch10.revancedandroidcli"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            signingConfig = signingConfigs["debug"]
        }
    }
}

dependencies {
    implementation(project(":revancedcli"))
}