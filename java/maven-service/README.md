# maven-service

A Java service built by Maven, with no dependencies at all: the JDK's own HTTP
server, a health check, and one method worth stopping in.

- **here** starts `com.example.api.Server` on this machine. Running it goes
  through Maven — `mvn compile exec:java` — and debugging it does not: the
  debugger builds its own classpath from the language server and starts a JVM
  of its own, which is why a breakpoint is hit in under a second.
- **in the cluster** packages the jar, pushes it into a development pod and
  runs it there with the pod's JVM. Debugging it opens JDWP in that JVM,
  suspends it at the first instruction and attaches through a port-forward, so
  the same breakpoint is hit in the cluster.

Try, in order: run it here and open http://localhost:8080/api/things. Put a
breakpoint in `things` and debug — the `Thing` records are in the variables
pane. Then run it in the cluster, and debug it there.

## What it needs

A JDK, and Maven or nothing at all — `mvn` is used when it is on the path, and
a project with `mvnw` uses that instead. For the editor's own Java support:

```sh
brew install jdtls
```

Completion, problems, go-to-declaration and find-usages come from that. The
debugger needs one more piece, which is not a program but a bundle jdtls loads:
see the note in ideai's README about `java-debug`.

## The jar

`mvn package` leaves `target/maven-service-1.0.0.jar` with a `Main-Class` in
its manifest, which is what the pod's `java -jar` runs. That is the whole
contract between this project and the development pod: a jar that starts
itself.
