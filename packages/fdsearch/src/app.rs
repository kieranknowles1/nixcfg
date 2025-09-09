use eframe::egui::{self, ScrollArea, Ui};
use egui_extras::{Column, TableBuilder};

use crate::{
    args::Args,
    search::{QueryResult, search},
};

pub struct App {
    args: Args,
    query: String,
    // We want to cache results of the search query, even if it failed.
    cached_results: Option<QueryResult>,
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
    pub fn new(args: Args) -> Self {
        Self {
            args,
            query: String::new(),
            cached_results: None,
        }
    }

    fn lazy_search(&mut self) -> &QueryResult {
        match self.cached_results {
            Some(ref results) => &results,
            None => {
                let results = search(&self.args.base_path, &self.query);
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

            let text_height = egui::TextStyle::Body.resolve(ui.style()).size;

            maybe_error(ui, self.lazy_search(), |ui, results| {
                TableBuilder::new(ui)
                    .striped(true)
                    .resizable(false)
                    .cell_layout(egui::Layout::left_to_right(egui::Align::Min))
                    // .column(Column::remainder().clip(true))
                    .column(Column::remainder())
                    .column(Column::auto().at_least(64.0))
                    .header(text_height, |mut header| {
                        header.col(|ui| {
                            ui.strong("Path");
                        });
                        header.col(|ui| {
                            ui.strong("Size");
                        });
                    })
                    .body(|mut body| {
                        body.rows(text_height, results.num_entries(), |mut row| {
                            let line = results.entry(row.index()).unwrap_or("INVALID UTF8");
                            row.col(|ui| {
                                ui.label(line);
                            });
                            row.col(|ui| {
                                ui.label(format!("{}", line.len()));
                            });
                        })
                    });
            });
        });
    }
}
