package com.example.hotswap;

/**
 * A program that keeps count out loud, so that a change reaching it can be
 * told from a restart.
 *
 * <p>That is the whole design of this example. Every other way of watching a
 * hot code replace — a log line, an HTTP response, a breakpoint — tells you
 * that the new code ran, and tells you nothing about whether the old process
 * is still the one running it. A counter that does not go back to one does.
 *
 * <p>So: run it, let it reach fifty, edit {@link Greeting#line(int)}, save. If
 * the next line is the new wording at fifty-one, the JVM took the change. If it
 * is the new wording at one, something restarted and the feature did not work.
 */
public final class Ticker {
	public static void main(String[] args) throws InterruptedException {
		System.out.println("ticking — edit Greeting.line and save");
		int count = 0;
		while (true) {
			count++;
			// Called every second rather than once, because a swap takes effect
			// when the method is next entered. A body that is entered once at
			// startup would need a restart to show its change, which is the
			// thing being avoided.
			System.out.println(Greeting.line(count));
			Thread.sleep(1000);
		}
	}
}
