plugins {
    id("com.android.application")
}

android {
    namespace = "com.programminghoch10.revancedandroidcli"
    compileSdk = 36

    defaultConfig {
        minSdk = 23
        targetSdk = 36
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
