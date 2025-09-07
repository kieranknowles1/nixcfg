use std::f32;

use eframe::egui::{self, ScrollArea, Ui};

use crate::search::{QueryResult, search};

pub struct App {
    query: String,
    // We want to cache results of the search query, even if it failed.
    cached_results: Option<QueryResult>,
}

impl Default for App {
    fn default() -> Self {
        Self {
            query: String::new(),
            cached_results: None,
        }
    }
}

fn maybe_error<T, E: std::error::Error>(
    ui: &mut Ui,
    result: &Result<T, E>,
    display_ok: impl FnOnce(&mut Ui, &T),
) {
    match result {
        Ok(value) => display_ok(ui, value),
        Err(err) => {
            ui.label(format!("Error: {}", err));
        }
    }
}

impl App {
    fn lazy_search(&mut self) -> &QueryResult {
        match self.cached_results {
            Some(ref results) => &results,
            None => {
                let results = search(&self.query);
                self.cached_results = Some(results);
                // SAFETY: We just set the value above.
                unsafe { self.cached_results.as_ref().unwrap_unchecked() }
            }
        }
    }
}

impl eframe::App for App {
    fn update(&mut self, ctx: &egui::Context, frame: &mut eframe::Frame) {
        egui::CentralPanel::default().show(ctx, |ui| {
            let edit = ui.text_edit_singleline(&mut self.query);
            edit.request_focus();
            if edit.changed() {
                self.cached_results = None;
            }

            maybe_error(ui, self.lazy_search(), |ui, results| {
                ScrollArea::vertical().auto_shrink(false).show_rows(
                    ui,
                    ui.text_style_height(&egui::TextStyle::Body),
                    results.num_entries(),
                    |ui, range| {
                        for index in range {
                            // (hopefully) rare, so no proper handling.
                            let line = results.entry(index).unwrap_or("INVALID UTF8");
                            ui.label(line);
                        }
                    },
                );
            });
        });
    }
}
