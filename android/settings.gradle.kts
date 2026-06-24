pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.2.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}

include(":app")

// Inject namespace for plugins that don't specify one (required by AGP 8.x)
subprojects {
    afterEvaluate {
        val android = extensions.findByName("android")
        if (android != null && android is com.android.build.gradle.BaseExtension) {
            if (android.namespace == null) {
                android.namespace = "com.cattrace.${project.name.replace("-", "_")}"
            }
        }
    }
}
