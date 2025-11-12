import type { CombinedResponse } from "./bindings/CombinedResponse"
import { useEffect, useState } from "react"
import useInterval from "./useInterval"

const API_ROOT = "http://localhost:4321"
const UPDATE_INTERVAL = 1000
const SAMPLES = 15

function App() {
  const [metrics, setMetrics] = useState<CombinedResponse | undefined>(undefined)

  useInterval(() => {
    fetch(API_ROOT)
      .then(res => res.json())
      .then(setMetrics)
  }, UPDATE_INTERVAL, true)

  return (
    <>
      {metrics?.sysinfo?.cpu.max}
    </>
  )
}

export default App
