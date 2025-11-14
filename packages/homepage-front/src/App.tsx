import type { CombinedResponse } from "./bindings/CombinedResponse"
import { useState } from "react"
import useInterval from "./useInterval"
import Metrics from "./Metrics"

const API_ROOT = "http://localhost:4321"
const UPDATE_INTERVAL = 1000
const SAMPLES = 15

function App() {
  const [metrics, setMetrics] = useState<CombinedResponse[]>([])

  useInterval(() => {
    fetch(API_ROOT)
      .then(res => res.json() as CombinedResponse)
      .then(data => {
        const newMetrics = [...metrics, data]
        if (newMetrics.length > SAMPLES) newMetrics.shift()

        setMetrics(newMetrics)
      })
      .catch(e => {
        const newMetrics = [...metrics, {}]
        if (newMetrics.length > SAMPLES) newMetrics.shift()
        setMetrics(newMetrics)
      })
  }, UPDATE_INTERVAL, true)

  // TODO: Endpoint to check what's available
  const baseline = metrics.length > 0 ? metrics[0] : {}

  return (
    <>
      {baseline.sysinfo && <Metrics samples={metrics.map(m => m.sysinfo)} />}
    </>
  )
}

export default App
