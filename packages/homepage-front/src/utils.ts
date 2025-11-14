export const BYTE = 1
export const KILOBYTE = BYTE * 1024
export const MEGABYTE = KILOBYTE * 1024
export const GIGABYTE = MEGABYTE * 1024

export function latest<T>(arr: Array<T>) {
  return arr[arr.length - 1]
}

export function formatFilesize(bytes: number) {
  const SIZE_UNITS = [" Bytes", "KB", "MB", "GB", "TB"]

  let i = 0
  while (i < SIZE_UNITS.length && bytes > 1024) {
    bytes /= 1024
    i += 1
  }

  return `${bytes.toFixed(i > 0 ? 2 : 0)}${SIZE_UNITS[i]}`
}
