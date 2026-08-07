# gradle-service

A worker built by Gradle, in the Kotlin DSL: it does a little work in a loop,
prints what it did, and exits.

The shape matters. A server can be attached to at leisure; a worker is over
before you get there. So the pod's JVM is started suspended and waits for the
debugger, and the first thing that happens after the attach is the breakpoint.

- **here** runs `com.example.tasks.Queue` through `gradle run`, three rounds.
  Debugging it skips Gradle: the classpath comes from the language server and
  the JVM is started here.
- **in the cluster** runs `assemble`, pushes the jar into a development pod and
  runs it there for twenty rounds — long enough to attach, watch a few, and
  stop it.

Put a breakpoint in `work` and debug either one.

## What it needs

A JDK. Gradle itself is not needed: run `gradle wrapper` once if you want the
wrapper committed, and after that the build uses it. The editor prefers
`./gradlew` over any Gradle on the path, because a build pins its Gradle
version for the same reason it pins its dependencies.

`build.gradle.kts` and `settings.gradle.kts` are Kotlin, and read as Kotlin —
⇧⌘O over the build file lists `describe` beside the plugins it applies.
