use std::fs;

use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::cli;

#[derive(Serialize, ts_rs::TS)]
pub struct TriliumData {
    #[ts(as = "f64")]
    pub note_count: u64,
    #[ts(as = "f64")]
    pub db_size: u64,
}

#[derive(Error, Debug)]
pub enum Error {
    #[error(transparent)]
    Reqwest(#[from] reqwest::Error),
    #[error(transparent)]
    Io(#[from] std::io::Error),
    #[error(transparent)]
    Json(#[from] serde_json::Error),
}

#[derive(Deserialize)]
struct ApiResponse {
    database: ApiDatabase,
    statistics: ApiStats,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct ApiDatabase {
    total_notes: u64,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct ApiStats {
    database_size_bytes: u64,
}

impl TriliumData {
    pub async fn fetch() -> Result<Self, Error> {
        let endpoint = format!(
            "{}/etapi/metrics?format=json",
            cli().trilium.url.as_ref().unwrap()
        );
        let api_key = fs::read_to_string(cli().trilium.api_file.as_ref().unwrap())?;
        let api_key = api_key.trim();

        let client = reqwest::Client::new();
        let res = client.get(endpoint).bearer_auth(api_key).send().await?;

        let body = res.text().await?;
        let body: ApiResponse = serde_json::from_str(&body)?;
        Ok(Self {
            note_count: body.database.total_notes,
            db_size: body.statistics.database_size_bytes,
        })
    }
}
