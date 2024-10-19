mod activate;
mod config;

use clap::Parser;

type Result<T> = activate::Result<T>;

#[derive(Parser)]
enum Opt {
    Activate(activate::Opt)
}

fn main() -> Result<()> {
    match Opt::parse() {
        Opt::Activate(args) => activate::run(args)
    }
}
