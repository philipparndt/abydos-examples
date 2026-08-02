// The application half of a two-container pod.
//
// It reads what the chart gave it — a database URL from a Secret, a cache from
// a Service — and serves the API the web half calls. Neither half knows how it
// was deployed; that is the point of replacing one container at a time.
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	_ "net/http/pprof"
	"os"
)

func main() {
	database := env("DATABASE_URL", "postgres://localhost:5432/app?sslmode=disable")
	cache := env("VALKEY_ADDR", "localhost:6379")
	stage := env("STAGE", "local")
	log.Printf("app starting: stage=%s database=%s cache=%s", stage, redact(database), cache)

	mux := http.NewServeMux()
	mux.HandleFunc("/api/summary", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]any{
			"stage": stage, "database": redact(database), "cache": cache,
			"orders": orders(),
		})
	})
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) { w.Write([]byte("ok")) })

	go func() { log.Println(http.ListenAndServe(":6060", nil)) }()
	log.Println("app listening on :8080")
	log.Fatal(http.ListenAndServe(":8080", mux))
}

// Stands in for a query. A breakpoint here is hit by the web half's page load.
func orders() []map[string]any {
	return []map[string]any{
		{"id": 1, "customer": "ada", "total": 42.0},
		{"id": 2, "customer": "grace", "total": 17.5},
	}
}

func env(name, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return fallback
}

// A database URL is a password: it goes in the log without one.
func redact(url string) string {
	at := -1
	for i, c := range url {
		if c == '@' {
			at = i
			break
		}
	}
	if at < 0 {
		return url
	}
	return fmt.Sprintf("postgres://***%s", url[at:])
}
