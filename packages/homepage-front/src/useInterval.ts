import { useEffect, useRef } from "react"

// https://overreacted.io/making-setinterval-declarative-with-react-hooks/
/**
 * @param callback Function to call whenever the timeout expires
 * @param timeout Frequency at which to call `callback`
 * @param eager Run `callback` immediately
 * @returns
 */
export default function useInterval(callback: () => void, timeout: number, eager: boolean = false) {
  // Make the callback persistent between calls
  const savedCallback = useRef(callback)
  useEffect(() => {
    savedCallback.current = callback
  }, [callback])

  useEffect(() => {
    function tick() {
      savedCallback.current()
    }
    const id = setInterval(tick, timeout)
    if (eager) tick()
    return () => clearInterval(id)
  }, [timeout])
}
