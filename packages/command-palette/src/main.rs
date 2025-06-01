use std::process::Command;

use clap::Parser;
use data::Config;

mod data;
mod dialog;

#[derive(Parser)]
struct Opts {
    /// A JSON file containing the options to display.
    #[clap(long)]
    file: String,
}

struct CommandOutput {
    stdout: String,
    stderr: String,
    code: Option<i32>,
}

impl CommandOutput {
    fn combine(self) -> Option<String> {
        let has_stdout = !self.stdout.is_empty();
        let has_stderr = !self.stderr.is_empty();

        if has_stdout && has_stderr {
            Some(format!("{}\n{}", self.stdout, self.stderr))
        } else if has_stdout {
            Some(self.stdout)
        } else if has_stderr {
            Some(self.stderr)
        } else {
            None
        }
    }
}

fn run_command(config: &Config, command: &data::Command) -> std::io::Result<CommandOutput> {
    let mut argv = if command.use_terminal {
        config.terminal_args.iter().chain(&command.action)
    } else {
        command.action.iter().chain(&[])
    };

    // argv should never be empty.
    let output = Command::new(argv.next().unwrap()).args(argv).output()?;

    Ok(CommandOutput {
        // We assume the output is valid UTF-8 and unwrap here.
        stdout: String::from_utf8(output.stdout).unwrap(),
        stderr: String::from_utf8(output.stderr).unwrap(),
        code: output.status.code(),
    })
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let opts = Opts::parse();
    let config = data::from_file(&opts.file)?;

    let choice = dialog::pick_command(&config.commands)?;

    let output = run_command(&config, &choice)?;

    if output.code != Some(0) {
        // An error occurred, show a dialog box even if we don't have any output.
        let message = format!(
            "Error running command {}",
            output.combine().unwrap_or_default()
        );
        dialog::show_message(&message, dialog::MessageKind::Error)?;
    } else if let Some(combined) = output.combine() {
        // The command ran successfully. Show the output if we have any.
        dialog::show_message(&combined, dialog::MessageKind::Info)?;
    }
    // Don't show anything if there was no output and the command ran successfully.

    Ok(())
}
