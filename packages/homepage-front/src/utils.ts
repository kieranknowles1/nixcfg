export function formatSize(bytes: number): string {
  const units = ['B', 'KB', 'MB', 'GB', 'TB']

  // Which is the smallest unit that is less than one of the next unit
  // I.e.:
  // 900 KB = KB
  // 1000 KB = 1 MB

  var unitIndex = Math.floor(Math.log(bytes) / Math.log(1024))
  unitIndex = Math.min(unitIndex, units.length - 1)

  const unit = units[unitIndex]
  const value = bytes / Math.pow(1024, unitIndex)

  return `${value.toFixed(2)} ${unit}`
}
