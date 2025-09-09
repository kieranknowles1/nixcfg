use std::path::PathBuf;

use clap::Parser;

#[derive(Parser)]
pub struct Args {
    #[clap(env = "HOME")]
    pub base_path: PathBuf,
}
