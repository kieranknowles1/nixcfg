export const BYTE = 1
export const KILOBYTE = BYTE * 1024
export const MEGABYTE = KILOBYTE * 1024
export const GIGABYTE = MEGABYTE * 1024

export function latest<T>(arr: Array<T>) {
  return arr[arr.length - 1]
}
