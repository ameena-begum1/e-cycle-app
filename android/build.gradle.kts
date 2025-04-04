// allprojects {
//     repositories {
//         google()
//         mavenCentral()
//     }
// }

// rootProject.buildDir = "../build"
// subprojects {
//     project.buildDir = "${rootProject.buildDir}/${project.name}"
// }
// subprojects {
//     project.evaluationDependsOn(":app")
// }

// tasks.register("clean", Delete) {
//     delete rootProject.buildDir
// }

////this is i added manually because my dependencies were missing
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Add the Android Gradle plugin
        classpath "com.android.tools.build:gradle:8.0.2" // to run on mobile i added, if not comment out 

        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.20"  // to run on mobile i added, if not comment out 

        // Add the Google Services classpath
        classpath "com.google.gms:google-services:4.4.2" // Add this line
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = "../build"
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}