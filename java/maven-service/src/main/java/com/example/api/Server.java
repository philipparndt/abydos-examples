// A backend with nothing in it but the shape of one, in Java.
//
// The JDK's own HTTP server, so the example builds with no dependency to
// download and the interesting part stays the loop: edit, run, breakpoint,
// run it in a cluster and hit the same breakpoint there.
package com.example.api;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

public class Server {
	private static final Instant STARTED = Instant.now();

	public static void main(String[] args) throws IOException {
		String stage = System.getenv().getOrDefault("STAGE", "local");
		int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));

		HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
		server.createContext("/", exchange -> respond(exchange, 200,
				"maven-service, stage " + stage + ", up for " + uptime() + "\n"));
		server.createContext("/healthz", exchange -> respond(exchange, 200, "ok"));
		server.createContext("/api/things", exchange -> {
			exchange.getResponseHeaders().add("Content-Type", "application/json");
			respond(exchange, 200, json(things()));
		});

		// No executor: one thread is enough for something that exists to be
		// stepped through.
		server.setExecutor(null);
		System.out.println("maven-service listening on :" + port + ", stage " + stage);
		server.start();
	}

	/// Something to put a breakpoint in.
	static List<Thing> things() {
		List<Thing> found = new ArrayList<>();
		for (int id = 1; id <= 3; id++) {
			found.add(new Thing(id, "thing " + id));
		}
		return found;
	}

	record Thing(int id, String name) {
	}

	private static String uptime() {
		return Duration.between(STARTED, Instant.now()).withNanos(0).toString();
	}

	private static String json(List<Thing> things) {
		StringBuilder out = new StringBuilder("[");
		for (int index = 0; index < things.size(); index++) {
			Thing thing = things.get(index);
			if (index > 0) {
				out.append(",");
			}
			out.append("{\"id\":").append(thing.id())
					.append(",\"name\":\"").append(thing.name()).append("\"}");
		}
		return out.append("]").toString();
	}

	private static void respond(HttpExchange exchange, int status, String body) throws IOException {
		byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
		exchange.sendResponseHeaders(status, bytes.length);
		try (OutputStream stream = exchange.getResponseBody()) {
			stream.write(bytes);
		}
	}
}
