use eframe::egui::{self, ScrollArea};

use crate::search::search;

pub struct App {
    query: String,
}

impl Default for App {
    fn default() -> Self {
        Self {
            query: String::new(),
        }
    }
}

impl eframe::App for App {
    fn update(&mut self, ctx: &egui::Context, frame: &mut eframe::Frame) {
        egui::CentralPanel::default().show(ctx, |ui| {
            ui.text_edit_singleline(&mut self.query).request_focus();

            let results = search(&self.query);
            match results {
                Ok(results) => {
                    ScrollArea::vertical().show_rows(
                        ui,
                        ui.text_style_height(&egui::TextStyle::Body),
                        results.num_entries(),
                        |ui, range| {
                            for index in range {
                                let line = results.entry(index).unwrap_or("INVALID UTF8");
                                ui.label(line);
                            }
                        },
                    );
                }
                Err(err) => {
                    ui.label(format!("Error: {}", err));
                }
            }

            // ui.lis
        });
    }
}
