import type { CombinedResponse } from "./bindings/CombinedResponse"
import { useEffect, useState } from "react"
import useInterval from "./useInterval"
import Metrics from "./Metrics"
import { type EnabledMetrics } from "./bindings/EnabledMetrics"

const API_ROOT = "http://localhost:4321"
const UPDATE_INTERVAL = 1000
const SAMPLES = 15

function App() {
  const [enabled, setEnabled] = useState<EnabledMetrics>()
  const [metrics, setMetrics] = useState<CombinedResponse[]>([])

  function upsertMetric(data: CombinedResponse) {
    const newMetrics = [...metrics, data]
    if (newMetrics.length > SAMPLES) newMetrics.shift()

    setMetrics(newMetrics)
  }

  useEffect(() => {
    fetch(`${API_ROOT}/info`)
      .then(res => res.json() as Promise<EnabledMetrics>)
      .then(setEnabled)
  })

  useInterval(() => {
    fetch(`${API_ROOT}/metrics`)
      .then(res => res.json() as Promise<CombinedResponse>)
      .then(upsertMetric)
      // If the server fails to respond, add a period of no data
      .catch(_ => { upsertMetric({}) })
  }, UPDATE_INTERVAL, true)

  return (
    <>
      {enabled?.sysinfo && <Metrics samples={metrics.map(m => m.sysinfo)} />}
    </>
  )
}

export default App
