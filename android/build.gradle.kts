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
    project.evaluationDependsOn(":app")
}

subprojects {
    if (project.name != "app") {
        val forceCompileSdk = {
            val android = project.extensions.findByName("android")
            if (android != null) {
                for (method in android.javaClass.methods) {
                    if (method.name == "compileSdkVersion" || method.name == "setCompileSdk" || method.name == "setCompileSdkVersion") {
                        val params = method.parameterTypes
                        if (params.size == 1 && (params[0] == java.lang.Integer.TYPE || params[0] == java.lang.Integer::class.java)) {
                            try {
                                method.invoke(android, 36)
                                break
                            } catch (_: Exception) {}
                        }
                    }
                }
            }
        }
        if (state.executed) {
            forceCompileSdk()
        } else {
            afterEvaluate { forceCompileSdk() }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
