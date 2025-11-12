import { useEffect } from "react"

/**
 * @param callback Function to call whenever the timeout expires
 * @param timeout Frequency at which to call `callback`
 * @param eager Run `callback` immediately
 * @returns
 */
export default function useInterval(callback: () => void, timeout: number, eager: boolean = false) {
  return useEffect(() => {
    if (eager) callback()
    const interval = setInterval(callback, timeout)
    return () => {
        clearInterval(interval)
    }
  }, [])
}
