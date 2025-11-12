use serde::Serialize;
use sysinfo::{CpuRefreshKind, MemoryRefreshKind, RefreshKind, System};

#[derive(Serialize, ts_rs::TS)]
pub struct SysInfo {
    pub mem: MemInfo,
    /// CPU usage, as the sum of all cores.
    /// Therefore may be up to 100% * number of cores.
    pub cpu_usage: f32,
}

#[derive(Serialize, ts_rs::TS)]
pub struct MemInfo {
    /// Total RAM available in bytes.
    pub total: u64,
    /// Total RAM used in bytes.
    pub used: u64,
}

impl SysInfo {
    pub fn fetch() -> Self {
        let sys = System::new_with_specifics(
            RefreshKind::nothing()
                .with_cpu(CpuRefreshKind::nothing().with_cpu_usage())
                .with_memory(MemoryRefreshKind::nothing().with_ram()),
        );

        Self {
            mem: MemInfo {
                total: sys.total_memory(),
                used: sys.used_memory(),
            },
            cpu_usage: sys.global_cpu_usage(),
        }
    }
}
