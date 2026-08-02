//! Small enough to read, with something worth stepping through: a struct, a
//! loop, and a value that changes on every pass.

#[derive(Debug)]
struct Reading {
    sensor: String,
    celsius: f64,
}

fn readings() -> Vec<Reading> {
    (1..=5)
        .map(|i| Reading {
            sensor: format!("sensor-{i}"),
            celsius: 18.0 + (i as f64) * 1.5,
        })
        .collect()
}

fn warmest(readings: &[Reading]) -> Option<&Reading> {
    readings
        .iter()
        .max_by(|a, b| a.celsius.partial_cmp(&b.celsius).unwrap())
}

fn main() {
    let readings = readings();
    for reading in &readings {
        println!("{} is at {:.1}°C", reading.sensor, reading.celsius);
    }
    match warmest(&readings) {
        Some(reading) => println!("warmest: {}", reading.sensor),
        None => println!("nothing to read"),
    }
}
