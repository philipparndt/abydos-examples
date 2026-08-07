// A Gradle build in the Kotlin DSL, which is what new builds are written in.
//
// The application plugin is the whole trick: it gives the build a `run` task,
// and it makes `assemble` produce a jar that starts itself — which is what a
// development pod runs.
plugins {
	application
}

group = "com.example"
version = "1.0.0"

repositories {
	mavenCentral()
}

java {
	toolchain {
		languageVersion = JavaLanguageVersion.of(21)
	}
}

application {
	mainClass.set("com.example.tasks.Queue")
}

// A jar that `java -jar` can run. The application plugin's own `run` does not
// need this; the pod does, because all it is ever given is the jar.
tasks.jar {
	manifest {
		attributes["Main-Class"] = "com.example.tasks.Queue"
	}
}

// One task of the build's own, so ⇧⌘O over this file has something in it that
// Gradle did not put there.
tasks.register("describe") {
	description = "Say what this build produces"
	doLast {
		println("$group:${project.name}:$version — main class ${application.mainClass.get()}")
	}
}
