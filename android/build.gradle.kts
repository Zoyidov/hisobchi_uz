allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Ba'zi pluginlar (masalan file_picker 8.x) compileSdk = 34 ni qattiq yozib
// qo'ygan, flutter_plugin_android_lifecycle esa 36+ talab qiladi. Barcha
// Android library pluginlarni kamida 36 bilan kompilyatsiya qilamiz.
// Bu faqat compileSdk — targetSdk/minSdk va ilova xatti-harakatiga ta'sir qilmaydi.
subprojects {
    afterEvaluate {
        val android = extensions.findByName("android")
        if (plugins.hasPlugin("com.android.library") &&
            android is com.android.build.gradle.BaseExtension
        ) {
            val current = android.compileSdkVersion
                ?.removePrefix("android-")?.toIntOrNull() ?: 0
            if (current < 36) {
                android.compileSdkVersion(36)
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
