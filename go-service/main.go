// A backend with nothing in it but the shape of one.
//
// It serves two things a service needs to be developed in a cluster: something
// to talk to, and something to profile. Everything else — the config file, the
// front end, the database — is another example.
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	_ "net/http/pprof"
	"os"
	"time"
)

func main() {
	stage := os.Getenv("STAGE")
	if stage == "" {
		stage = "local"
	}
	started := time.Now()

	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "go-service, stage %s, up for %s\n", stage, time.Since(started).Round(time.Second))
	})
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("ok"))
	})
	mux.HandleFunc("/api/things", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(things())
	})

	// pprof on its own port, where the profiler looks for it.
	go func() { log.Println(http.ListenAndServe(":6060", nil)) }()

	log.Println("go-service listening on :8080, pprof on :6060")
	log.Fatal(http.ListenAndServe(":8080", mux))
}

// Something to put a breakpoint in.
func things() []map[string]any {
	out := make([]map[string]any, 0, 3)
	for i := 1; i <= 3; i++ {
		out = append(out, map[string]any{"id": i, "name": fmt.Sprintf("thing %d", i)})
	}
	return out
}
