# hot-swap

A program that keeps count out loud, so that a change reaching a running JVM can
be told from a restart.

That is the whole design. Every other way of watching a hot code replace — a log
line, an HTTP response, a breakpoint being hit — tells you the new code ran and
tells you nothing about whether the old process is still the one running it. **A
counter that does not go back to one does.**

## The one that works

1. Debug **here**. It prints a line a second.
2. Let it reach fifty or so.
3. Open `Greeting.java` and change the wording in `line`.
4. Save.

The next line is the new wording, at fifty-one. The JVM never stopped: the same
process, the same count, a different method body. That is the feature.

If the count goes back to one, nothing was swapped and something restarted.

## The one that does not

Now add a method to `Greeting` — any method, it need not be called — and save.

The JVM refuses it, and this is the ordinary case rather than the exceptional
one. **HotSpot replaces method bodies and nothing else**: adding or removing a
method, changing a signature, adding a field and changing what a class extends
are all refused. Most of what editing feels like is refused.

What you should see is *which class* and *what about the change*, in the JVM's
own words, with restarting the session one press away. Nothing restarts on its
own — a debug session holds a stack and a breakpoint that were expensive to
reach.

## The one that moves the floor

Put a breakpoint in `line`, debug, and wait for it. While stopped there, change
the body and save.

The adapter drops to the affected frame and enters it again, so the line you are
stopped on moves under you. That is the Eclipse debugger's behaviour and this
app does not turn it off; it says that it happened, which unexplained is the most
confusing thing hot code replace does.

## In the cluster

Debug **in the cluster** and do the same three things. Redefinition is the JVM's
own, so where it is running has nothing to do with whether it works — the request
travels the same port-forward as every other debugger request.

The difference is what a refusal costs. Restarting a JVM in a pod is restarting
somebody's service, so the offer says what it is about to restart before it does
it.

## What it needs

A JDK, and Maven or nothing at all. For the editor's Java support:

```sh
brew install jdtls
```

Hot code replace needs the same `java-debug` bundle the debugger already needs —
it is not a separate piece. See the note in abydos's README.

## Why `Greeting.line` is called every second

A swap takes effect **when the method is next entered**. A body that runs once
at startup would need a restart to show its change, which is the thing being
avoided — so the loop enters it again a second later and the change has
somewhere to land.
