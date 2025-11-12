use serde::Serialize;
use sysinfo::{CpuRefreshKind, MemoryRefreshKind, RefreshKind, System};

#[derive(Serialize, ts_rs::TS)]
pub struct SysInfo {
    pub mem: MemInfo,
    pub cpu: CpuInfo,
}

#[derive(Serialize, ts_rs::TS)]
pub struct MemInfo {
    /// Total RAM available in bytes.
    pub total: u64,
    /// Total RAM used in bytes.
    pub used: u64,
}

#[derive(Serialize, ts_rs::TS)]
pub struct CpuInfo {
    /// CPU usage, averaged between all cores.
    pub average: f32,
    /// Usage of the core with highest load
    pub max: f32,
}

impl SysInfo {
    pub async fn fetch() -> Self {
        let cpu_refresh = CpuRefreshKind::nothing().with_cpu_usage();
        let mut sys = System::new_with_specifics(
            RefreshKind::nothing()
                .with_cpu(cpu_refresh)
                .with_memory(MemoryRefreshKind::nothing().with_ram()),
        );
        // CPU statistics need two data points, so wait a moment and refresh
        tokio::time::sleep(sysinfo::MINIMUM_CPU_UPDATE_INTERVAL).await;
        sys.refresh_cpu_specifics(cpu_refresh);

        let max_core = sys
            .cpus()
            .iter()
            .map(|cpu| cpu.cpu_usage())
            .reduce(f32::max) // Can't use max due to NaN behavior
            .unwrap(); // Assume we have data for at least one core

        Self {
            mem: MemInfo {
                total: sys.total_memory(),
                used: sys.used_memory(),
            },
            cpu: CpuInfo {
                average: sys.global_cpu_usage(),
                max: max_core,
            },
        }
    }
}
