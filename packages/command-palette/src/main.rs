use clap::Parser;

mod data;
mod dialog;

#[derive(Parser)]
struct Opts {
    /// A JSON file containing the options to display.
    #[clap(long)]
    file: String,
    /// The path to the Zenity executable.
    #[clap(long)]
    zenity: String,
}

struct CommandOutput {
    stdout: String,
    stderr: String,
    code: Option<i32>
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

fn run_command(command: &data::Command) -> std::io::Result<CommandOutput> {
    let output = std::process::Command::new(&command.action[0])
        .args(&command.action[1..])
        .output()?;

    Ok(CommandOutput {
        // We assume the output is valid UTF-8 and unwrap here.
        stdout: String::from_utf8(output.stdout).unwrap(),
        stderr: String::from_utf8(output.stderr).unwrap(),
        code: output.status.code(),
    })
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let opts = Opts::parse();
    let commands = data::from_file(&opts.file)?;

    let choice = dialog::show_choices(&opts.zenity, &commands)?;

    let output = run_command(&choice)?;

    if output.code != Some(0) {
        // An error occurred, show a dialog box even if we don't have any output.
        let message = format!("Error running command {}", output.combine().unwrap_or_default());
        dialog::show_message(&opts.zenity, &message, dialog::MessageKind::Error)?;
    } else if let Some(combined) = output.combine() {
        // The command ran successfully. Show the output if we have any.
        dialog::show_message(&opts.zenity, &combined, dialog::MessageKind::Info)?;
    }
    // Don't show anything if there was no output and the command ran successfully.

    Ok(())
}
