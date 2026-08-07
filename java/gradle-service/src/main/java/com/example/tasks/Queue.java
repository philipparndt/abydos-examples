// A worker rather than a server: it does something, prints what it did, and
// exits — which is the other shape a service comes in, and the one where a
// suspended JVM in a pod matters most. Debug it in the cluster and the first
// thing that happens is your breakpoint, not the process finishing before you
// arrived.
package com.example.tasks;

import java.util.ArrayList;
import java.util.List;

public class Queue {
	public static void main(String[] args) throws InterruptedException {
		String stage = System.getenv().getOrDefault("STAGE", "local");
		int rounds = args.length > 0 ? Integer.parseInt(args[0]) : 5;

		System.out.println("gradle-service, stage " + stage + ", " + rounds + " rounds");
		for (int round = 1; round <= rounds; round++) {
			List<String> done = work(round);
			System.out.println("round " + round + ": " + String.join(", ", done));
			Thread.sleep(1000);
		}
		System.out.println("finished");
	}

	/// Something to put a breakpoint in.
	static List<String> work(int round) {
		List<String> done = new ArrayList<>();
		for (int item = 1; item <= 3; item++) {
			done.add("task " + (round * 10 + item));
		}
		return done;
	}
}
