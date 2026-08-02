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
}

type State struct {
	On     bool
	Brewed int
}

type Machine struct {
	mutex  sync.Mutex
	on     bool
	brewed int
	subs   map[chan State]struct{}
}

func NewMachine() *Machine {
	return &Machine{subs: map[chan State]struct{}{}}
}

func (m *Machine) Status() State {
	m.mutex.Lock()
	defer m.mutex.Unlock()
	return State{m.on, m.brewed}
}

func (m *Machine) Toggle() State {
	m.mutex.Lock()
	defer m.mutex.Unlock()
	m.on = !m.on
	if m.on {
		m.brewed++
	}
	state := State{m.on, m.brewed}
	for sub := range m.subs {
		select {
		case sub <- state:
		default: // a watcher that is not keeping up gets the next one
		}
	}
	return state
}

// Watch hands out every state change until the returned cancel is called.
func (m *Machine) Watch() (<-chan State, func()) {
	m.mutex.Lock()
	defer m.mutex.Unlock()
	sub := make(chan State, 1)
	m.subs[sub] = struct{}{}
	return sub, func() {
		m.mutex.Lock()
		defer m.mutex.Unlock()
		delete(m.subs, sub)
		close(sub)
	}
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("no configuration file given: smart-home-microservice config/dev.json")
	}
	config, err := load(os.Args[1])
	if err != nil {
		log.Fatalf("cannot read %s: %v", os.Args[1], err)
	}
	log.Printf("%s starting: broker %s, machine %s %s",
		config.Name, config.Broker, config.Machine.Model, config.Machine.Serial)

	machine := NewMachine()
	pages, _ := fs.Sub(web, "web")

	mux := http.NewServeMux()
	mux.Handle("/", http.FileServer(http.FS(pages)))
	mux.HandleFunc("/api/status", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Write(append(report(config, machine.Status()), '\n'))
	})
	// The page listens here instead of asking again every couple of seconds:
	// a toggle reaches every open browser as it happens.
	mux.HandleFunc("/api/events", func(w http.ResponseWriter, r *http.Request) {
		flusher, ok := w.(http.Flusher)
		if !ok {
			http.Error(w, "streaming not supported", http.StatusInternalServerError)
			return
		}
		w.Header().Set("Content-Type", "text/event-stream")
		w.Header().Set("Cache-Control", "no-cache")
		w.Header().Set("X-Accel-Buffering", "no") // no buffering in front of us

		updates, cancel := machine.Watch()
		defer cancel()

		send := func(state State) bool {
			if _, err := fmt.Fprintf(w, "data: %s\n\n", report(config, state)); err != nil {
				return false
			}
			flusher.Flush()
			return true
		}
		if !send(machine.Status()) { // the counters as they stand right now
			return
		}
		for {
			select {
			case state := <-updates:
				if !send(state) {
					return
				}
			case <-r.Context().Done():
				return
			}
		}
	})
	mux.HandleFunc("/api/toggle", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, `{"on": %t}`, machine.Toggle().On)
	})

	go watch(machine)
	go func() { log.Println(http.ListenAndServe(":6060", nil)) }()

	log.Println("listening on :8080")
	log.Fatal(http.ListenAndServe(":8080", mux))
}

func load(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	config := &Config{}
	if err := json.Unmarshal(data, config); err != nil {
		return nil, err
	}
	return config, nil
}

// report is what both the status endpoint and the event stream say.
func report(config *Config, state State) []byte {
	data, _ := json.Marshal(map[string]any{
		"name": config.Name, "model": config.Machine.Model,
		"on": state.On, "brewed": state.Brewed,
	})
	return data
}

// Where a breakpoint belongs: the loop that would talk to the machine. It
// wakes on a change rather than on a tick, so the counters in the log are the
// ones that just happened and nothing repeats itself every few seconds.
func watch(machine *Machine) {
	updates, cancel := machine.Watch()
	defer cancel()
	for state := range updates {
		log.Printf("machine: on=%t brewed=%d", state.On, state.Brewed)
	}
}
