import type { CombinedResponse } from "./bindings/CombinedResponse"
import { useState } from "react"
import useInterval from "./useInterval"
import Graph from "./Graph"

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
  }, UPDATE_INTERVAL, true)

  return (
    <>
      <Graph
        range={{min: 0, max: 100}}
        samples={metrics.map(m => m.sysinfo?.cpu.average)}
      />
    </>
  )
}

export default App
