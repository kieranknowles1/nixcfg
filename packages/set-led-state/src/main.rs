use clap::{Parser, ValueEnum};
use std::{fs, io};

#[derive(Parser)]
struct Opts {
    /// The LED to control. This will be set for all devices that provide the specified LED.
    led: String,
    /// The state to set the LED to.
    state: State,
}

#[derive(Clone, ValueEnum)]
enum State {
    On,
    Off,
}

fn list_leds(name: &str) -> io::Result<impl Iterator<Item = fs::DirEntry>> {
    let all_leds = fs::read_dir("/sys/class/leds")?;
    // LED names are in the form of `device::name`, so we want to search for directories that
    // end with `::name`.
    let ending = format!("::{name}");

    // The `move` keyword causes the closure to take ownership of the `ending` variable, which
    // is required because the closure outlives the `list_leds` function.
    let filtered = all_leds
        .filter_map(Result::ok)
        .filter(move |e| e.file_name().to_str().is_some_and(|f| f.ends_with(&ending)));

    Ok(filtered)
}

fn set_led_state(led: &fs::DirEntry, state: &State) -> io::Result<()> {
    let brightness_path = led.path().join("brightness");

    let value = match state {
        State::On => "1",
        State::Off => "0",
    };

    fs::write(brightness_path, value)?;

    Ok(())
}

fn main() -> io::Result<()> {
    let opts = Opts::parse();

    // Disallow slashes to protect against directory traversal attacks.
    if opts.led.contains('/') {
        return Err(io::Error::new(
            io::ErrorKind::InvalidInput,
            "LED name must not contain a slash",
        ));
    }

    let leds = list_leds(&opts.led)?;

    for led in leds {
        set_led_state(&led, &opts.state)?;
    }

    Ok(())
}
