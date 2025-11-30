use std::{collections::HashMap, convert::Infallible, time::Duration};

use serde::{Deserialize, Serialize};
use sysinfo::{CpuRefreshKind, DiskRefreshKind, Disks, MemoryRefreshKind, RefreshKind, System};
use ts_rs::TS;

#[derive(Deserialize)]
pub struct SysInfoOpts {}

#[derive(Serialize, TS)]
pub struct SysInfo {
    cpu: CpuInfo,
    mem: MemoryInfo,
    disk: HashMap<String, DiskInfo>,
}

#[derive(Serialize, TS)]
struct CpuInfo {
    /// CPU model name
    #[ts(as = "String")]
    model: String,
    /// Average CPU usage between all cores
    average_usage: f32,
    /// Usage of the core with the highest load
    max_usage: f32,
}

#[derive(Serialize, TS)]
struct MemoryInfo {
    /// Available RAM in bytes
    #[ts(as = "f64")]
    used: u64,
    /// Total RAM in bytes
    #[ts(as = "f64")]
    total: u64,
}

#[derive(Serialize, TS)]
struct DiskInfo {
    /// Total disk space in bytes
    #[ts(as = "f64")]
    capacity: u64,
    /// Available disk space in bytes
    #[ts(as = "f64")]
    free: u64,
    /// Current write speed in bytes per second
    #[ts(as = "f64")]
    write_speed: u64,
    /// Current read speed in bytes per second
    #[ts(as = "f64")]
    read_speed: u64,
}

fn average_speed(bytes: u64, duration: Duration) -> u64 {
    let res = bytes as f64 / duration.as_secs_f64();
    res as u64
}

impl SysInfo {
    pub async fn fetch(_opts: &SysInfoOpts) -> Result<Self, Infallible> {
        let cpu_refresh = CpuRefreshKind::nothing().with_cpu_usage().with_frequency();

        let mut system = System::new_with_specifics(
            RefreshKind::nothing()
                .with_cpu(cpu_refresh)
                .with_memory(MemoryRefreshKind::nothing().with_ram()),
        );
        let mut disks = Disks::new_with_refreshed_list_specifics(
            DiskRefreshKind::nothing()
                .with_kind()
                .with_io_usage()
                .with_storage(),
        );

        // CPU and disk stats need two data points to be accurate
        let stopwatch = tokio::time::Instant::now();
        tokio::time::sleep(sysinfo::MINIMUM_CPU_UPDATE_INTERVAL).await;

        disks.refresh(true);
        system.refresh_cpu_specifics(cpu_refresh);
        let elapsed = stopwatch.elapsed();

        let disk_stats = disks
            .iter()
            .map(|disk| {
                let info = DiskInfo {
                    capacity: disk.total_space(),
                    free: disk.available_space(),
                    write_speed: average_speed(disk.usage().written_bytes, elapsed),
                    read_speed: average_speed(disk.usage().read_bytes, elapsed),
                };
                (disk.name().to_string_lossy().into_owned(), info)
            })
            .collect();

        let max_core = system
            .cpus()
            .iter()
            .map(|cpu| cpu.cpu_usage())
            .reduce(f32::max)
            .unwrap();

        Ok(Self {
            cpu: CpuInfo {
                model: system.cpus()[0].brand().to_owned(),
                average_usage: system.global_cpu_usage(),
                max_usage: max_core,
            },
            mem: MemoryInfo {
                used: system.used_memory(),
                total: system.total_memory(),
            },
            disk: disk_stats,
        })
    }
}
