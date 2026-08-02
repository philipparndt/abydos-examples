// The web half of a two-container pod: it renders what the application half
// serves, and talks to it over localhost because they share a pod.
package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
)

func main() {
	api := os.Getenv("API_URL")
	if api == "" {
		api = "http://localhost:8080"
	}
	log.Println("web starting, api =", api)

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		summary := "the application is not answering"
		if response, err := http.Get(api + "/api/summary"); err == nil {
			defer response.Body.Close()
			if body, err := io.ReadAll(response.Body); err == nil {
				summary = string(body)
			}
		}
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		fmt.Fprintf(w, page, summary)
	})

	log.Println("web listening on :3000")
	log.Fatal(http.ListenAndServe(":3000", nil))
}

const page = `<!doctype html><meta charset="utf-8"><title>multi-tier</title>
<style>body{font:15px/1.5 system-ui;margin:3rem auto;max-width:40rem;color:#e6e6e6;background:#1b1d23}
pre{background:#262a33;padding:1rem;border-radius:.5rem;overflow:auto}</style>
<h1>multi-tier</h1><p>What the application half says:</p><pre>%s</pre>`
