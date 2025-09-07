use eframe::egui;

mod app;
mod search;

fn main() -> eframe::Result<()> {
    let options = eframe::NativeOptions {
        // TODO: Position on centre of main display. Currently hardcoded
        // to show on right monitor.
        viewport: egui::ViewportBuilder::default().with_position([2000.0, 400.0]),
        ..Default::default()
    };
    eframe::run_native(
        "fdsearch",
        options,
        Box::new(|cc| Ok(Box::new(app::App::default()))),
    )
}
