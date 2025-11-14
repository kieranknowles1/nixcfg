export const BYTE = 1
export const KILOBYTE = BYTE * 1024
export const MEGABYTE = KILOBYTE * 1024
export const GIGABYTE = MEGABYTE * 1024

export function any<T>(arr: Array<T | undefined>) {
  const filtered = arr.filter(e => e != undefined)
  return filtered.length > 0 ? arr[0] : undefined
}

export function latest<T>(arr: Array<T | undefined>) {
  return arr.length > 0 ? arr[arr.length - 1] : undefined
}
