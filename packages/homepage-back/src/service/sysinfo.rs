use serde::{Deserialize, Serialize};
use ts_rs::TS;

#[derive(Deserialize)]
pub struct SysInfoOpts {}

#[derive(Serialize, TS)]
pub struct SysInfo {
    cpu: CpuInfo,
    memory: MemoryInfo,
}

#[derive(Serialize, TS)]
struct CpuInfo {}

#[derive(Serialize, TS)]
struct MemoryInfo {}

impl SysInfo {
    pub async fn fetch(_opts: &SysInfoOpts) -> Result<Self, String> {
        todo!()
    }
}
