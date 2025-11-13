use std::{collections::HashMap, time::Duration};

use serde::Serialize;
use sysinfo::{CpuRefreshKind, Disks, MemoryRefreshKind, RefreshKind, System};

/// Fetches system information.
/// Note that values are for a rough estimate only, they are made with too
/// little data for an accurate benchmark, especially disk usage.
/// If a proper benchmark is needed, consider using something that was meant for
/// it
#[derive(Serialize, ts_rs::TS)]
pub struct SysInfo {
    pub mem: MemInfo,
    pub cpu: CpuInfo,
    pub disk: HashMap<String, DiskInfo>,
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

#[derive(Serialize, ts_rs::TS)]
pub struct DiskInfo {
    /// Total disk capacity in bytes.
    pub capacity: u64,
    /// Disk space available in bytes.
    pub free: u64,
    /// Current write speed in bytes per second.
    pub write_speed: u64,
    /// Current read speed in bytes per second.
    pub read_speed: u64,
}

fn average_speed(sample: u64, duration: Duration) -> u64 {
    let res = sample as f64 / duration.as_secs_f64();
    res as u64
}

impl SysInfo {
    pub async fn fetch() -> Self {
        let cpu_refresh = CpuRefreshKind::nothing().with_cpu_usage();
        let mut sys = System::new_with_specifics(
            RefreshKind::nothing()
                .with_cpu(cpu_refresh)
                .with_memory(MemoryRefreshKind::nothing().with_ram()),
        );

        // CPU and disk statistics need two data points, so wait a moment and refresh
        let mut disks = Disks::new_with_refreshed_list();
        let stopwatch = tokio::time::Instant::now();

        tokio::time::sleep(sysinfo::MINIMUM_CPU_UPDATE_INTERVAL).await;
        disks.refresh(true);
        let refresh_cmp_duration = stopwatch.elapsed();

        sys.refresh_cpu_specifics(cpu_refresh);

        let mut disk_stats = HashMap::new();
        for disk in disks.iter() {
            let info = DiskInfo {
                capacity: disk.total_space(),
                free: disk.available_space(),
                read_speed: average_speed(disk.usage().read_bytes, refresh_cmp_duration),
                write_speed: average_speed(disk.usage().written_bytes, refresh_cmp_duration),
            };
            // NOTE: This groups disks by partition name (/dev/sdXY)
            // This may cause a harmless collision + overwrite with identical data
            // if a disk is mounted at multiple points, as is the case with /nix/store
            disk_stats.insert(disk.name().to_string_lossy().into_owned(), info);
        }

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
            disk: disk_stats,
        }
    }
}
