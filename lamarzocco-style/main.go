// A service that will not start without being told where its configuration is.
//
// This is the shape of most of the bridges in a smart home: a config file with
// the broker and the device in it, a handful of HTTP endpoints, and a page to
// look at while working on it. It is here because a service like this is the
// awkward one to develop in a cluster — the pod has never seen the file.
package main

import (
	"embed"
	"encoding/json"
	"fmt"
	"io/fs"
	"log"
	"net/http"
	_ "net/http/pprof"
	"os"
	"sync"
	"time"
)

//go:embed web
var web embed.FS

type Config struct {
	Name    string `json:"name"`
	Broker  string `json:"broker"`
	Machine struct {
		Serial string `json:"serial"`
		Model  string `json:"model"`
	} `json:"machine"`
	PollSeconds int `json:"pollSeconds"`
}

type Machine struct {
	mutex  sync.Mutex
	on     bool
	brewed int
}

func (m *Machine) Status() (bool, int) {
	m.mutex.Lock()
	defer m.mutex.Unlock()
	return m.on, m.brewed
}

func (m *Machine) Toggle() bool {
	m.mutex.Lock()
	defer m.mutex.Unlock()
	m.on = !m.on
	if m.on {
		m.brewed++
	}
	return m.on
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("no configuration file given: lamarzocco-style config/dev.json")
	}
	config, err := load(os.Args[1])
	if err != nil {
		log.Fatalf("cannot read %s: %v", os.Args[1], err)
	}
	log.Printf("%s starting: broker %s, machine %s %s",
		config.Name, config.Broker, config.Machine.Model, config.Machine.Serial)

	machine := &Machine{}
	pages, _ := fs.Sub(web, "web")

	mux := http.NewServeMux()
	mux.Handle("/", http.FileServer(http.FS(pages)))
	mux.HandleFunc("/api/status", func(w http.ResponseWriter, r *http.Request) {
		on, brewed := machine.Status()
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]any{
			"name": config.Name, "model": config.Machine.Model,
			"on": on, "brewed": brewed,
		})
	})
	mux.HandleFunc("/api/toggle", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, `{"on": %t}`, machine.Toggle())
	})

	go poll(config, machine)
	go func() { log.Println(http.ListenAndServe(":6060", nil)) }()

	log.Println("listening on :8080")
	log.Fatal(http.ListenAndServe(":8080", mux))
}

func load(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	config := &Config{PollSeconds: 30}
	if err := json.Unmarshal(data, config); err != nil {
		return nil, err
	}
	return config, nil
}

// Where a breakpoint belongs: the loop that would talk to the machine.
func poll(config *Config, machine *Machine) {
	every := time.Duration(config.PollSeconds) * time.Second
	for range time.Tick(every) {
		on, brewed := machine.Status()
		log.Printf("poll: on=%t brewed=%d", on, brewed)
	}
}
