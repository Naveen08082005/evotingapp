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

subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            android?.let {
                val currentSdk = it.compileSdkVersion
                if (currentSdk != null) {
                    if (currentSdk.startsWith("android-")) {
                        val versionNum = currentSdk.substringAfter("android-").toIntOrNull()
                        if (versionNum != null && versionNum < 34) {
                            it.compileSdkVersion("android-34")
                        }
                    } else {
                        val versionNum = currentSdk.toIntOrNull()
                        if (versionNum != null && versionNum < 34) {
                            it.compileSdkVersion(34)
                        }
                    }
                }
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


