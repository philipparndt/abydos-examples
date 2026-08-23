package com.example.hotswap;

/**
 * The class to edit while the program is running.
 *
 * <p>Nothing here is called from anywhere but {@link Ticker}, and nothing holds
 * state, so a change to a body is exactly as safe to make at second fifty as it
 * was before the program started.
 */
public final class Greeting {
	private Greeting() {
	}

	/**
	 * One line of output.
	 *
	 * <p><b>Edit this body.</b> Change the wording, save, and watch the running
	 * program: the count carries on from where it was, and the wording is the
	 * new one. That is a hot code replace — a method body swapped into a JVM
	 * that never stopped.
	 */
	static String line(int count) {
		return "tick " + count + " — hello from the original code6";
	}

	/**
	 * A second body, for trying the same thing twice in one session.
	 *
	 * <p>Unused on purpose: call it from {@link #line} to see a swap that
	 * changes which method runs rather than what one method says.
	 */
	static String shout(int count) {
		return ("tick " + count + " — HELLO").toUpperCase();
	}
}
