// A small Odin program with the things worth stepping through in it: a struct,
// a slice, a procedure that takes one, and a loop that changes a value on
// every pass.
//
// Odin's own style is used throughout — `::` for constants and procedures,
// snake_case for names, `context.temp_allocator` for the throwaway strings —
// because the point of this example is to look at a real one.
package main

import "core:fmt"
import "core:slice"
import "core:strings"

Reading :: struct {
	sensor:  string,
	celsius: f64,
}

// A slice of the temperatures a house might report.
readings :: proc(allocator := context.allocator) -> []Reading {
	names := []string{"kitchen", "bedroom", "garage", "cellar", "loft"}
	out := make([]Reading, len(names), allocator)
	for name, i in names {
		out[i] = Reading{sensor = name, celsius = 21.5 - f64(i) * 3.25}
	}
	return out
}

// The one to put a breakpoint in: it walks the slice and keeps the extreme.
coldest :: proc(values: []Reading) -> (Reading, bool) {
	if len(values) == 0 {
		return Reading{}, false
	}
	found := values[0]
	for reading in values[1:] {
		if reading.celsius < found.celsius {
			found = reading
		}
	}
	return found, true
}

average :: proc(values: []Reading) -> f64 {
	if len(values) == 0 {
		return 0
	}
	total: f64
	for reading in values {
		total += reading.celsius
	}
	return total / f64(len(values))
}

// Sorted by temperature, warmest first — `slice.sort_by` takes the comparison
// as a procedure value, which is worth seeing once.
warmest_first :: proc(values: []Reading) {
	slice.sort_by(values, proc(a, b: Reading) -> bool {
		return a.celsius > b.celsius
	})
}

main :: proc() {
	values := readings()
	defer delete(values)

	warmest_first(values)
	for reading in values {
		// `%-8s` pads the name so the column lines up. A width on a float pads
		// with zeros here, which is not what a temperature wants.
		fmt.printfln("%-8s %.1f C", reading.sensor, reading.celsius)
	}

	fmt.printfln("average  %.1f C", average(values))

	if cold, ok := coldest(values); ok {
		names := make([dynamic]string, context.temp_allocator)
		for reading in values {
			append(&names, reading.sensor)
		}
		fmt.printfln("coldest  %s of %s", cold.sensor,
			strings.join(names[:], ", ", context.temp_allocator))
	}
	free_all(context.temp_allocator)
}
